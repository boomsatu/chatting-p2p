import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/providers/core_providers.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/dao/conversations_dao.dart';
import '../../../../core/database/dao/identity_dao.dart';
import '../../../../core/database/dao/groups_dao.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/chat_list_item.dart';
import 'package:p2pchat/src/rust/api/node_api.dart' as rust_node;

/// Chat list screen — shows all conversations, groups, contacts with bottom navigation and centered search
class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  int _currentIndex = 0;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    final conversationsDao = ConversationsDao(db);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  autofocus: true,
                  textAlign: TextAlign.center, // Centered search text
                  style: const TextStyle(fontSize: 15),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            : Text(
                'Swarm',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: drift.Value(FontWeight.w900).value,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
        centerTitle: false,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Close Search',
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                });
              },
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search',
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              tooltip: 'Scan QR to Add Contact',
              onPressed: () => context.push('/add-contact'),
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              tooltip: 'Settings',
              onPressed: () => context.push('/settings'),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, ref, conversationsDao, theme),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
            _isSearching = false;
            _searchQuery = '';
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Contacts',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub_rounded),
            label: 'Swarm',
          ),
        ],
      ),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 2)
          ? FloatingActionButton(
              onPressed: () => context.push('/add-contact'),
              tooltip: 'Add Contact',
              child: const Icon(Icons.qr_code_scanner_rounded),
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    ConversationsDao conversationsDao,
    ThemeData theme,
  ) {
    switch (_currentIndex) {
      case 0:
        return _buildChatsTab(context, ref, conversationsDao, theme);
      case 1:
        return _buildGroupsTab(context, ref, theme);
      case 2:
        return _buildContactsTab(context, ref, theme);
      case 3:
        return _buildSwarmTab(context, ref, theme);
      default:
        return _buildChatsTab(context, ref, conversationsDao, theme);
    }
  }

  Widget _buildChatsTab(
    BuildContext context,
    WidgetRef ref,
    ConversationsDao conversationsDao,
    ThemeData theme,
  ) {
    return StreamBuilder<List<Conversation>>(
      stream: conversationsDao.watchAllConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final conversations = snapshot.data ?? [];
        final filteredConversations = conversations.where((convo) {
          return convo.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (convo.lastMessage ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredConversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 80,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No conversations yet' : 'No matches found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Scan a QR code to add a contact\nand start chatting.'
                        : 'Try searching with a different contact name.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredConversations.length,
          itemBuilder: (context, index) {
            final convo = filteredConversations[index];
            return ChatListItem(
              conversation: convo,
              onTap: () => context.push('/chat/${convo.id}'),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupsTab(BuildContext context, WidgetRef ref, ThemeData theme) {
    final groupsAsync = ref.watch(groupsProvider);

    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading groups: $err')),
      data: (groups) {
        final filteredGroups = groups.where((group) {
          return group.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _searchQuery.isEmpty ? 'Create a P2P Swarm Group' : 'No swarm groups found',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _searchQuery.isEmpty
                        ? 'Instantly connect multiple local peers. Messages are broadcasted securely via decentralized GossipSub.'
                        : 'Try searching with a different group name.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create New Group'),
                    onPressed: () {
                      _showCreateGroupDialog(context, ref, theme);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredGroups.length,
          itemBuilder: (context, index) {
            final group = filteredGroups[index];
            final initials = group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G';

            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(
                group.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Swarm Topic: ${group.topic}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontFamily: 'monospace',
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Active P2P',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Swarm group "${group.name}" is active on topic: ${group.topic}'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContactsTab(BuildContext context, WidgetRef ref, ThemeData theme) {
    final contactsAsync = ref.watch(contactsProvider);

    return contactsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading contacts: $err')),
      data: (contacts) {
        final filteredContacts = contacts.where((contact) {
          return contact.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              contact.peerId.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredContacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 80,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No contacts yet' : 'No contacts match search',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Add Contact via QR'),
                  onPressed: () => context.push('/add-contact'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = filteredContacts[index];
            final isOnline = contact.status == 'online';
            final initials = contact.displayName.isNotEmpty
                ? contact.displayName[0].toUpperCase()
                : 'U';

            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                contact.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Peer ID: ${contact.peerId.substring(0, 12)}...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontFamily: 'monospace',
                ),
              ),
              trailing: Chip(
                label: Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isOnline ? Colors.green[800] : Colors.grey[700],
                  ),
                ),
                backgroundColor: isOnline
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onTap: () async {
                try {
                  final db = ref.read(databaseProvider);
                  final conversationsDao = ConversationsDao(db);
                  final identityDao = IdentityDao(db);
                  
                  final myIdentity = await identityDao.getIdentity();
                  if (myIdentity == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please generate your keys first.')),
                    );
                    return;
                  }
                  
                  final myPeerId = myIdentity.peerId;
                  final sortedPeers = [myPeerId, contact.peerId]..sort();
                  final dmTopic = 'dm:${sortedPeers[0]}:${sortedPeers[1]}';
                  
                  Conversation? convo = await conversationsDao.getConversationByTopic(dmTopic);
                  if (convo == null) {
                    final now = DateTime.now().millisecondsSinceEpoch;
                    final convoCompanion = ConversationsCompanion.insert(
                      type: 'dm',
                      topic: dmTopic,
                      targetId: contact.peerId,
                      displayName: contact.displayName,
                      createdAt: now,
                    );
                    final id = await conversationsDao.insertOrUpdateConversation(convoCompanion);
                    convo = await conversationsDao.getConversation(id);
                  }
                  
                  if (context.mounted && convo != null) {
                    context.push('/chat/${convo.id}');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error starting chat: $e')),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSwarmTab(BuildContext context, WidgetRef ref, ThemeData theme) {
    return FutureBuilder<Map<String, dynamic>>(
      future: () async {
        try {
          final running = await rust_node.isNodeRunning();
          if (!running) return {'status': 'Offline', 'peers': BigInt.from(0)};
          final count = await rust_node.getPeerCount();
          return {'status': 'Active', 'peers': count};
        } catch (_) {
          return {'status': 'Offline', 'peers': BigInt.from(0)};
        }
      }(),
      builder: (context, snapshot) {
        final status = snapshot.data?['status'] ?? 'Offline';
        final peerCount = snapshot.data?['peers'] ?? BigInt.from(0);
        final isActive = status == 'Active';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Glowing Swarm Core Centerpiece
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isActive
                          ? [theme.colorScheme.secondary.withOpacity(0.4), Colors.transparent]
                          : [Colors.grey.withOpacity(0.3), Colors.transparent],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isActive ? theme.colorScheme.secondary : Colors.grey).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.hub_rounded,
                        size: 40,
                        color: isActive ? theme.colorScheme.secondary : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isActive ? 'Swarm Network Active' : 'Swarm Node Offline',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Decentralized GossipSub Mesh Network',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 32),

              // Network Metric cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      theme,
                      'Peers Connected',
                      '$peerCount',
                      Icons.people_rounded,
                      isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      theme,
                      'Kad-DHT Status',
                      isActive ? 'Listening' : 'Inactive',
                      Icons.explore_rounded,
                      isActive ? theme.colorScheme.primary : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      theme,
                      'GossipSub Topics',
                      isActive ? '4 Active' : '0',
                      Icons.layers_rounded,
                      isActive ? Colors.purple : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      theme,
                      'Local Swarm Port',
                      isActive ? 'TCP 6001' : 'None',
                      Icons.settings_ethernet_rounded,
                      isActive ? Colors.amber : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: accentColor),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref, ThemeData theme) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.groups_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              const Text('New P2P Swarm', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a name to initialize a decentralized group session.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.edit_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                try {
                  final db = ref.read(databaseProvider);
                  final groupsDao = GroupsDao(db);
                  
                  final id = 'grp_${drift.Value(DateTime.now().millisecondsSinceEpoch).value}';
                  final topic = 'group:$id';
                  
                  await groupsDao.insertGroup(
                    GroupsCompanion.insert(
                      id: id,
                      name: name,
                      topic: topic,
                      groupKeyId: 'default_group_key',
                      adminPeerId: 'me',
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ),
                    [],
                  );
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('P2P Swarm Group "$name" successfully created!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Initialize'),
            ),
          ],
        );
      },
    );
  }
}
