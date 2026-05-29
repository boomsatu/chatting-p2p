import 'dart:convert';
import '../database/database.dart';
import '../database/dao/contacts_dao.dart';
import '../database/dao/conversations_dao.dart';
import '../database/dao/identity_dao.dart';
import '../../rust/api/node_api.dart' as rust_node;

class ContactRepository {
  final ContactsDao _contactsDao;
  final ConversationsDao _conversationsDao;
  final IdentityDao _identityDao;

  ContactRepository(AppDatabase db)
      : _contactsDao = ContactsDao(db),
        _conversationsDao = ConversationsDao(db),
        _identityDao = IdentityDao(db);

  /// Parsers and adds a contact from a scanned QR code card JSON string.
  /// Also automatically creates a DM Conversation, subscribes to its GossipSub topic,
  /// and initiates a background libp2p dial.
  Future<Conversation> addContactFromQr(String qrJson) async {
    final Map<String, dynamic> data = jsonDecode(qrJson);

    // 1. Validate fields
    final peerId = data['peerId'] as String?;
    final displayName = data['displayName'] as String?;
    final pubKey = data['pubKey'] as String?;
    final signPubKey = data['signPubKey'] as String?;
    final List<dynamic>? multiaddrsRaw = data['multiaddrs'] as List<dynamic>?;

    if (peerId == null ||
        displayName == null ||
        pubKey == null ||
        signPubKey == null ||
        multiaddrsRaw == null) {
      throw const FormatException('Invalid QR code data format.');
    }

    final multiaddrs = multiaddrsRaw.map((e) => e.toString()).toList();

    // 2. Insert or update contact in database
    final now = DateTime.now().millisecondsSinceEpoch;
    final contactCompanion = ContactsCompanion.insert(
      peerId: peerId,
      displayName: displayName,
      pubKey: pubKey,
      signPubKey: signPubKey,
      multiaddrs: jsonEncode(multiaddrs),
      createdAt: now,
      updatedAt: now,
    );
    await _contactsDao.insertOrUpdateContact(contactCompanion);

    // 3. Obtain our own PeerID to establish the GossipSub DM topic name
    final myIdentity = await _identityDao.getIdentity();
    if (myIdentity == null) {
      throw StateError('User identity not generated yet. Please complete onboarding.');
    }
    final myPeerId = myIdentity.peerId;

    // Construct sorted GossipSub topic: dm:peerA:peerB
    final sortedPeers = [myPeerId, peerId]..sort();
    final dmTopic = 'dm:${sortedPeers[0]}:${sortedPeers[1]}';

    // 4. Create or fetch conversation
    Conversation? convo = await _conversationsDao.getConversationByTopic(dmTopic);
    if (convo == null) {
      final convoCompanion = ConversationsCompanion.insert(
        type: 'dm',
        topic: dmTopic,
        targetId: peerId,
        displayName: displayName,
        createdAt: now,
      );
      final id = await _conversationsDao.insertOrUpdateConversation(convoCompanion);
      convo = await _conversationsDao.getConversation(id);
    }

    // 5. Trigger FFI Actions in the background (subscribe, dial)
    _triggerP2PBackgroundActions(dmTopic, multiaddrs);

    return convo!;
  }

  /// Triggers non-blocking background subscription and dialing for the added peer.
  void _triggerP2PBackgroundActions(String topic, List<String> multiaddrs) async {
    try {
      if (await rust_node.isNodeRunning()) {
        // Subscribe to DM topic
        await rust_node.subscribeToTopic(topic: topic);
        
        // Dial peer multiaddresses
        for (final addr in multiaddrs) {
          try {
            await rust_node.dialPeer(multiaddr: addr);
          } catch (e) {
            // Keep dialing remaining addresses if one fails
            continue;
          }
        }
      }
    } catch (_) {
      // Ignore background errors so database saves are never blocked
    }
  }
}
