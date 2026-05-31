import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/communities_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cards.dart';

class CommunityMembersScreen extends StatelessWidget {
  final int communityId;
  const CommunityMembersScreen({super.key, required this.communityId});

  void _confirmRemove(BuildContext context, int userId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove $name from the club?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prov = context.read<CommunitiesProvider>();
              final success = await prov.removeMember(communityId, userId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member removed')));
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to remove member')));
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CommunitiesProvider>();
    final com = prov.selectedCommunity;
    if (com == null) return const Scaffold(backgroundColor: AppColors.background);

    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final members = com.members.where((m) => m.role != 'pending').toList();
    final isAdmin = com.members.any((m) => m.id == currentUserId && m.role == 'admin');

    return Scaffold(
      backgroundColor: AppColors.cardSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        title: const Text('Member List'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: members.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final m = members[index];
          final isOwner = m.id == com.adminUserId;
          final isSelf = m.id == currentUserId;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: UserAvatar(name: m.name, imageUrl: m.avatar, size: 48),
            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            subtitle: Text(m.role == 'admin' ? 'Admin' : 'Member', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            trailing: isOwner || isSelf
                ? (isOwner ? const Text('Owner', style: TextStyle(color: AppColors.textMuted, fontSize: 12)) : null)
                : (isAdmin ? IconButton(
                    icon: const Icon(Icons.person_remove_rounded, color: Colors.red, size: 20),
                    onPressed: () => _confirmRemove(context, m.id, m.name),
                  ) : null),
          );
        },
      ),
    );
  }
}
