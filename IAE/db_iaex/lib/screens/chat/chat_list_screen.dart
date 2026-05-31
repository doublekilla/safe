import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../providers/friends_provider.dart';
import '../../providers/communities_provider.dart';
import '../../widgets/cards.dart';

/// Chat conversations list screen
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Club'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  @override void dispose() { _searchController.dispose(); super.dispose(); }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timeStr;
    }
  }

  void _showNewMessageSheet() async {
    context.read<FriendsProvider>().loadFriends();
    context.read<CommunitiesProvider>().loadCommunities();
    
    final route = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollCtrl) => _NewMessageSheet(scrollCtrl: scrollCtrl),
      ),
    );

    if (route != null && mounted) {
      await context.push(route);
      if (mounted) {
        context.read<ChatProvider>().loadConversations();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ChatProvider>();
    
    // Apply filters and search
    var filteredConv = prov.conversations.where((c) {
      if (_selectedFilter == 'Club' && !c.isGroup) return false;
      if (_searchQuery.isNotEmpty && !c.name.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'), 
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewMessageSheet,
        backgroundColor: AppColors.buttonPrimary,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search friends or club...', hintStyle: TextStyle(color: AppColors.textMuted)),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                        )
                    ]),
                  ),
                ),
              ],
            ),
          ),
          
          // Filter Chips
          Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Club'),
                ],
              ),
            ),
          ),
          
          // List
          Expanded(
            child: prov.isLoading && prov.conversations.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredConv.isEmpty
                    ? EmptyState(icon: Icons.chat_bubble_outline_rounded, title: 'No messages found', subtitle: _searchQuery.isEmpty ? 'Start a conversation with a friend or club' : 'Try adjusting your search')
                    : ListView.separated(
                        itemCount: filteredConv.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, indent: 80, endIndent: 20, color: AppColors.border),
                        itemBuilder: (context, index) {
                          final conv = filteredConv[index];
                          return GestureDetector(
                            onLongPress: () {
                              if (!conv.isGroup) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Chat'),
                                    content: Text('Are you sure you want to delete the chat with ${conv.name}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(ctx);
                                          await context.read<ChatProvider>().deletePrivateChat(conv.id);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: UserAvatar(name: conv.name, imageUrl: conv.image, size: 52),
                              title: Row(children: [
                                Expanded(child: Text(conv.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                if (conv.lastMessageTime != null) Text(_formatTime(conv.lastMessageTime), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ]),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(conv.lastMessage ?? '', style: TextStyle(fontSize: 13, color: conv.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: conv.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                              trailing: conv.unreadCount > 0
                                  ? Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.buttonPrimary, shape: BoxShape.circle), child: Text('${conv.unreadCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)))
                                  : null,
                              onTap: () async {
                                if (conv.isGroup) {
                                  await context.push('/group-chat/${conv.id}?name=${Uri.encodeComponent(conv.name)}');
                                } else {
                                  await context.push('/chat/${conv.id}?name=${Uri.encodeComponent(conv.name)}');
                                }
                                if (context.mounted) {
                                  context.read<ChatProvider>().loadConversations();
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonPrimary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.buttonPrimary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

class _NewMessageSheet extends StatefulWidget {
  final ScrollController scrollCtrl;
  const _NewMessageSheet({required this.scrollCtrl});
  @override State<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fProv = context.watch<FriendsProvider>();
    final cProv = context.watch<CommunitiesProvider>();

    final myFriends = fProv.friends.where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    final myJoinedCommunities = cProv.communities.where((c) => c.isJoined == true && c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Container(
      decoration: const BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Align(alignment: Alignment.centerLeft, child: Text('New Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search friends or club...', hintStyle: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
              ]),
            ),
          ),
          Expanded(
            child: ListView(
              controller: widget.scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                if (myFriends.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Friends', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                  ...myFriends.map((f) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: UserAvatar(name: f.name, imageUrl: f.profileImage, size: 40),
                    title: Text(f.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context, '/chat/${f.id}?name=${Uri.encodeComponent(f.name)}');
                    },
                  )),
                ],
                if (myJoinedCommunities.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.only(top: 16, bottom: 8), child: Text('Clubs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
                  ...myJoinedCommunities.map((c) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: UserAvatar(name: c.name, imageUrl: c.image, size: 40),
                    title: Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(context, '/group-chat/${c.id}?name=${Uri.encodeComponent(c.name)}');
                    },
                  )),
                ],
                if (myFriends.isEmpty && myJoinedCommunities.isEmpty)
                  const Padding(padding: EdgeInsets.only(top: 32), child: Center(child: Text('No results found', style: TextStyle(color: AppColors.textMuted)))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
