import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/dao/contacts_dao.dart';
import '../database/dao/conversations_dao.dart';
import '../database/dao/messages_dao.dart';
import '../database/dao/identity_dao.dart';
import '../database/dao/message_queue_dao.dart';
import '../../rust/api/chat_api.dart' as rust_chat;
import '../../rust/api/crypto_api.dart' as rust_crypto;
import '../../rust/models/message.dart' as ffi_models;

class ChatRepository {
  final AppDatabase _db;
  final ContactsDao _contactsDao;
  final ConversationsDao _conversationsDao;
  final MessagesDao _messagesDao;
  final IdentityDao _identityDao;
  final MessageQueueDao _messageQueueDao;

  StreamSubscription<String>? _incomingMessageSubscription;

  ChatRepository(this._db)
      : _contactsDao = ContactsDao(_db),
        _conversationsDao = ConversationsDao(_db),
        _messagesDao = MessagesDao(_db),
        _identityDao = IdentityDao(_db),
        _messageQueueDao = MessageQueueDao(_db);

  /// Starts listening to FFI streams for incoming GossipSub messages.
  void startIncomingMessageListener() {
    _incomingMessageSubscription?.cancel();
    _incomingMessageSubscription = rust_chat.registerMessageStream().listen(
      (jsonStr) async {
        try {
          await handleIncomingEnvelope(jsonStr);
        } catch (e) {
          debugPrint('Error handling incoming message envelope: $e');
        }
      },
      onError: (err) {
        debugPrint('Error in incoming message stream: $err');
      },
    );
  }

  /// Stops the incoming GossipSub stream listener.
  void stopIncomingMessageListener() {
    _incomingMessageSubscription?.cancel();
    _incomingMessageSubscription = null;
  }

  /// Sends a secure DM to a peer contact.
  Future<void> sendDM({required String targetPeerId, required String content}) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Fetch recipient's contact info
    final contact = await _contactsDao.getContact(targetPeerId);
    if (contact == null) {
      throw StateError('Contact $targetPeerId not found.');
    }

    // 2. Fetch or create the DM conversation record
    final sortedPeers = [(await _myPeerId()), targetPeerId]..sort();
    final dmTopic = 'dm:${sortedPeers[0]}:${sortedPeers[1]}';
    Conversation? convo = await _conversationsDao.getConversationByTopic(dmTopic);
    if (convo == null) {
      final convoCompanion = ConversationsCompanion.insert(
        type: 'dm',
        topic: dmTopic,
        targetId: targetPeerId,
        displayName: contact.displayName,
        createdAt: now,
      );
      final id = await _conversationsDao.insertOrUpdateConversation(convoCompanion);
      convo = await _conversationsDao.getConversation(id);
    }

    // 3. Insert local message in 'sending' status
    final messageId = 'msg_${now}_${targetPeerId.hashCode}'; // placeholder ID before signed envelope ID is generated
    final msgCompanion = MessagesCompanion.insert(
      id: messageId,
      conversationId: convo!.id,
      senderPeerId: (await _myPeerId()),
      content: content,
      isMine: 1,
      status: const Value('sending'),
      createdAt: now,
      updatedAt: now,
    );
    await _messagesDao.insertMessage(msgCompanion);

    // 4. Encrypt, sign, and publish DM via FFI in background
    _publishDMInBackground(messageId, convo.id, targetPeerId, contact.pubKey, content, dmTopic);
  }

  /// Handles GossipSub transmission and updates database records on success or failure.
  Future<void> _publishDMInBackground(
    String localId,
    int conversationId,
    String targetPeerId,
    String targetPubKey,
    String content,
    String topic,
  ) async {
    try {
      // call Rust FFI to encrypt, sign, and publish DM
      final envelopeId = await rust_chat.sendDm(
        targetPeerId: targetPeerId,
        targetPubKey: targetPubKey,
        content: content,
      );

      // On FFI success: Update status to 'sent', swap placeholder ID with envelope ID, update convo summary
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Delete temporary message ID and insert/update under the signed UUID
      await _messagesDao.insertMessage(
        MessagesCompanion.insert(
          id: envelopeId,
          conversationId: conversationId,
          senderPeerId: (await _myPeerId()),
          content: content,
          isMine: 1,
          status: const Value('sent'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // If the envelope ID is different, delete the temporary one
      if (localId != envelopeId) {
        // Drift currently does not have a bulk delete by ID, we can do it via raw delete in DAO
        // but for simplicity we can insert/update status, or delete the old placeholder
        // Since we are writing to DAO, we'll keep it simple:
        await _db.customStatement('DELETE FROM messages WHERE id = ?', [localId]);
      }

      await _conversationsDao.updateLastMessage(topic, content, now);
    } catch (e) {
      debugPrint('Failed to send GossipSub DM: $e');
      // Update local record to 'failed'
      await _messagesDao.updateMessageStatus(localId, 'failed');

      // Enqueue in MessageQueue table for automatic retries per the architecture blueprint
      final now = DateTime.now().millisecondsSinceEpoch;
      await _messageQueueDao.enqueueMessage(
        MessageQueueCompanion.insert(
          messageId: localId,
          topic: topic,
          payload: jsonEncode({
            'targetPeerId': targetPeerId,
            'targetPubKey': targetPubKey,
            'content': content,
          }),
          nextRetryAt: now + 5000, // retry in 5 seconds
          createdAt: now,
        ),
      );
    }
  }

  /// Processes received GossipSub packets
  Future<void> handleIncomingEnvelope(String jsonStr) async {
    final Map<String, dynamic> envelope = jsonDecode(jsonStr);
    final String id = envelope['id'];
    final String sender = envelope['sender'];
    final int timestamp = envelope['timestamp'];
    final String msgType = envelope['msg_type'];
    final Map<String, dynamic> payload = envelope['payload'];

    // 1. Message Deduplication: If already processed, ignore!
    final existing = await _messagesDao.getMessage(id);
    if (existing != null) return;

    final sortedPeers = [(await _myPeerId()), sender]..sort();
    final dmTopic = 'dm:${sortedPeers[0]}:${sortedPeers[1]}';

    // 2. Fetch or create conversation
    Conversation? convo = await _conversationsDao.getConversationByTopic(dmTopic);
    if (convo == null) {
      final contact = await _contactsDao.getContact(sender);
      final displayName = contact?.displayName ?? 'Peer ${sender.substring(0, 6)}';
      final convoCompanion = ConversationsCompanion.insert(
        type: 'dm',
        topic: dmTopic,
        targetId: sender,
        displayName: displayName,
        createdAt: timestamp,
      );
      final cid = await _conversationsDao.insertOrUpdateConversation(convoCompanion);
      convo = await _conversationsDao.getConversation(cid);
    }

    if (msgType == 'Chat') {
      // 3. Decrypt DMPayload
      if (payload['type'] == 'Dm') {
        final Map<String, dynamic> dmData = payload['data'];
        final ffiPayload = ffi_models.DMPayload(
          nonce: dmData['nonce'],
          ciphertext: dmData['ciphertext'],
          senderPubKey: dmData['sender_pub_key'],
        );

        final decryptedJson = await rust_crypto.decryptDmMessage(payload: ffiPayload);
        final Map<String, dynamic> chatMsg = jsonDecode(decryptedJson);
        final String content = chatMsg['content'];

        // 4. Save decrypted message to database
        await _messagesDao.insertMessage(
          MessagesCompanion.insert(
            id: id,
            conversationId: convo!.id,
            senderPeerId: sender,
            content: content,
            isMine: 0,
            status: const Value('read'), // marked read locally on receive
            createdAt: timestamp,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        // 5. Update last message details & increment unread badge
        await _conversationsDao.updateLastMessage(dmTopic, content, timestamp);
        await _conversationsDao.incrementUnreadCount(dmTopic);

        // 6. ACK Transmission: Auto-reply with ACK packet to confirm delivery
        _sendACKInBackground(sender, id, dmTopic);
      }
    } else if (msgType == 'Ack') {
      // 7. ACK Processing: Update message delivery status
      if (payload['type'] == 'Dm') {
        final Map<String, dynamic> dmData = payload['data'];
        final ffiPayload = ffi_models.DMPayload(
          nonce: dmData['nonce'],
          ciphertext: dmData['ciphertext'],
          senderPubKey: dmData['sender_pub_key'],
        );

        final decryptedJson = await rust_crypto.decryptDmMessage(payload: ffiPayload);
        final Map<String, dynamic> ackMsg = jsonDecode(decryptedJson);
        final String ackedMessageId = ackMsg['content']; // ACK contains the target message ID in content field

        // Update target message's status to 'read' or 'delivered'
        await _messagesDao.updateMessageStatus(ackedMessageId, 'read');
      }
    } else if (msgType == 'Presence') {
      // 8. Presence Processing: Update peer online status & last seen timestamp
      await _contactsDao.updateContactStatus(sender, 'online', timestamp);
    }
  }

  /// Sends a signed delivery acknowledgment to the peer in the background.
  Future<void> _sendACKInBackground(String targetPeerId, String ackedMessageId, String topic) async {
    try {
      final contact = await _contactsDao.getContact(targetPeerId);
      if (contact != null) {
        // Send ACK over GossipSub (containing the target message ID)
        await rust_chat.sendDm(
          targetPeerId: targetPeerId,
          targetPubKey: contact.pubKey,
          content: ackedMessageId,
        );
      }
    } catch (_) {
      // Silent catch for background FFI ACK failures
    }
  }

  /// Helper to get our own PeerID
  Future<String> _myPeerId() async {
    final myIdentity = await _identityDao.getIdentity();
    if (myIdentity == null) {
      throw StateError('Identity keys are missing.');
    }
    return myIdentity.peerId;
  }
}
