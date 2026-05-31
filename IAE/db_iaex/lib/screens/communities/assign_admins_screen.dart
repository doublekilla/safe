import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/communities_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cards.dart';

class AssignAdminsScreen extends StatelessWidget {
  final int communityId;
  const AssignAdminsScreen({super.key, required this.communityId});

  Future<void> _toggleAdmin(BuildContext context, int id, bool isAdmin) async {
    final success = await context.read<CommunitiesProvider>().assignAdmin(communityId, id, isAdmin);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAdmin ? 'Admin assigned' : 'Admin role revoked')));
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update role')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CommunitiesProvider>();
    final com = prov.selectedCommunity;
    if (com == null) return const Scaffold(backgroundColor: AppColors.background);

    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final members = com.members.where((m) => m.role != 'pending').toList();

    return Scaffold(
      backgroundColor: AppColors.cardSurface,
      appBar: AppBar(
        backgroundColor: AppColors.cardSurface,
        title: const Text('Assign Admins'),
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
          final isAdmin = m.role == 'admin';

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: UserAvatar(name: m.name, imageUrl: m.avatar, size: 48),
            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            subtitle: Text(isAdmin ? 'Admin' : 'Member', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            trailing: isOwner || isSelf
                ? (isOwner ? const Text('Owner', style: TextStyle(color: AppColors.textMuted, fontSize: 12)) : null)
                : Switch.adaptive(
                    value: isAdmin,
                    activeTrackColor: AppColors.buttonPrimary,
                    onChanged: (val) => _toggleAdmin(context, m.id, val),
                  ),
          );
        },
      ),
    );
  }
}
