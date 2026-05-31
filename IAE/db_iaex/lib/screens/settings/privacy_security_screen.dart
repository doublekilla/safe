import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Privacy & Security settings screen
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});
  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _profileVisible = true;
  bool _showActivity = true;
  bool _showLocation = false;
  bool _allowInvitations = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSection('Profile Visibility', [
            _buildSwitchTile(
              Icons.person_outline_rounded,
              'Public Profile',
              'Others can view your profile information',
              _profileVisible,
              (v) => setState(() => _profileVisible = v),
            ),
            _buildSwitchTile(
              Icons.sports_rounded,
              'Show Activity Status',
              'Display your upcoming activities to others',
              _showActivity,
              (v) => setState(() => _showActivity = v),
            ),
            _buildSwitchTile(
              Icons.location_on_outlined,
              'Show Location',
              'Share your city on your profile',
              _showLocation,
              (v) => setState(() => _showLocation = v),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Interactions', [
            _buildSwitchTile(
              Icons.mail_outline_rounded,
              'Allow Invitations',
              'Receive activity invitations from others',
              _allowInvitations,
              (v) => setState(() => _allowInvitations = v),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection('Account', [
            _buildActionTile(
              Icons.block_rounded,
              'Blocked Users',
              'Manage your blocked list',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No blocked users')),
                );
              },
            ),
            _buildActionTile(
              Icons.delete_outline_rounded,
              'Delete Account',
              'Permanently delete your account and data',
              () => _showDeleteDialog(),
              isDestructive: true,
            ),
          ]),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone. All your data, activities, and club memberships will be removed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion request submitted'), backgroundColor: Colors.orange),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: AppColors.buttonPrimary),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.textPrimary, size: 22),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
