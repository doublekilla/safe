import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Settings screen with working toggles and navigation
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSection('Preferences', [
            _buildSwitchTile(Icons.notifications_none_rounded, 'Notifications', _notifications, (v) {
              setState(() => _notifications = v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(v ? 'Notifications enabled' : 'Notifications disabled')),
              );
            }),
            _buildSwitchTile(Icons.dark_mode_outlined, 'Dark Mode', _darkMode, (v) {
              setState(() => _darkMode = v);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(v ? 'Dark mode enabled (coming soon)' : 'Dark mode disabled')),
              );
            }),
            _buildNavTile(Icons.language_rounded, 'Language', trailing: 'English', onTap: () => context.push('/settings/language')),
          ]),
          const SizedBox(height: 24),
          _buildSection('Account & Security', [
            _buildNavTile(Icons.lock_outline_rounded, 'Change Password', onTap: () => context.push('/settings/change-password')),
            _buildNavTile(Icons.security_rounded, 'Privacy & Security', onTap: () => context.push('/settings/privacy-security')),
          ]),
          const SizedBox(height: 24),
          _buildSection('About', [
            _buildNavTile(Icons.info_outline_rounded, 'Terms of Service', onTap: () => context.push('/settings/terms')),
            _buildNavTile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () => context.push('/settings/privacy-policy')),
            _buildNavTile(Icons.help_outline_rounded, 'Help Center', onTap: () => context.push('/settings/help')),
          ]),
          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App version
          const Center(
            child: Text('SpaceLink v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              await context.read<AuthProvider>().logout();
              if (mounted) context.go('/login');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
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

  Widget _buildSwitchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: AppColors.buttonPrimary),
    );
  }

  Widget _buildNavTile(IconData icon, String title, {String? trailing, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) ...[
            Text(trailing, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 4),
          ],
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}
