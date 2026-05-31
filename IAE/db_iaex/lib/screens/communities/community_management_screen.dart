import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/communities_provider.dart';
import '../../widgets/buttons.dart';

/// Community / Club management screen (admin view)
class CommunityManagementScreen extends StatefulWidget {
  final int communityId;
  const CommunityManagementScreen({super.key, required this.communityId});

  @override
  State<CommunityManagementScreen> createState() => _CommunityManagementScreenState();
}

class _CommunityManagementScreenState extends State<CommunityManagementScreen> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final prov = context.read<CommunitiesProvider>();
    final pending = await prov.getPendingRequests(widget.communityId);
    if (mounted) {
      setState(() => _pendingCount = pending.length);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Club'),
        content: const Text('Are you sure you want to permanently delete this club? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<CommunitiesProvider>().deleteCommunity(widget.communityId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Club deleted')));
                context.go('/communities');
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Club'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Stats
          Row(children: [
            Expanded(child: _statCard('Members', '${com.memberCount}', Icons.people_outline_rounded)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Activities', '0', Icons.event_note_rounded)),
          ]),
          const SizedBox(height: 32),

          // Actions
          const Text('Club Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _actionTile(Icons.edit_rounded, 'Edit Profile', 'Update name, description, cover, and rules', () => context.push('/community/${widget.communityId}/edit')),
          
          const SizedBox(height: 32),
          const Text('Members & Roles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _actionTile(Icons.people_alt_rounded, 'Member List', 'View and remove members', () => context.push('/community/${widget.communityId}/members')),
          _actionTile(Icons.person_add_alt_1_rounded, 'Pending Requests', 'Approve or deny join requests', () async {
            await context.push('/community/${widget.communityId}/pending');
            _loadPending(); // reload count when returning
          }, badge: _pendingCount),
          _actionTile(Icons.admin_panel_settings_rounded, 'Assign Admins', 'Manage club administrators', () => context.push('/community/${widget.communityId}/admins')),
          
          const SizedBox(height: 40),
          SecondaryButton(label: 'Delete Club', icon: Icons.delete_outline_rounded, onPressed: () => _confirmDelete(context)),
        ]),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 24, color: AppColors.buttonPrimary),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {int badge = 0}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.textPrimary, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: badge > 0
          ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.errorRed, borderRadius: BorderRadius.circular(9999)), child: Text('$badge', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)))
          : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
