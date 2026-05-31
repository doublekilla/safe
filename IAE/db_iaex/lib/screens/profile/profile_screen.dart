import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activities_provider.dart';
import '../../providers/communities_provider.dart';
import '../../widgets/cards.dart';

/// User profile screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivitiesProvider>().loadActivities();
      context.read<CommunitiesProvider>().loadCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) return const Scaffold(backgroundColor: AppColors.background);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => context.push('/settings')),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 32),
            decoration: const BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))),
            child: Column(children: [
              UserAvatar(name: user.fullName, imageUrl: user.profileImage, size: 100),
              const SizedBox(height: 16),
              Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(user.email, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              if (user.location != null) ...[
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(user.location!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ]),
              ],
              const SizedBox(height: 24),
              Consumer2<ActivitiesProvider, CommunitiesProvider>(
                builder: (context, acts, coms, _) {
                  final matchesCount = acts.activities.where((act) {
                    final isParticipant = act.confirmedParticipants.contains(user.id) || act.hostUserId == user.id;
                    if (!isParticipant) return false;
                    
                    if (act.date == null || act.time == null) return false;
                    try {
                      final d = DateTime.parse(act.date!).toLocal();
                      final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                      final dt = DateTime.parse('$dateStr ${act.time}:00');
                      return dt.isBefore(DateTime.now());
                    } catch (_) {
                      return false;
                    }
                  }).length;
                  final clubsCount = coms.communities.where((c) => c.isJoined).length;

                  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _statBox('Matches', matchesCount.toString()),
                    Container(width: 1, height: 30, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    _statBox('Clubs', clubsCount.toString()),
                  ]);
                },
              ),
            ]),
          ),
          const SizedBox(height: 16),
          
          // Player Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Player Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _infoRow(Icons.sports_tennis_rounded, 'Sports', user.favoriteSports.isNotEmpty ? user.favoriteSports.join(', ') : '-'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.star_border_rounded, 'Skill Level', user.skillLevel ?? '-'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.event_available_rounded, 'Availability', user.availability.isNotEmpty ? user.availability.join(', ') : '-'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.person_outline_rounded, 'Gender', user.gender ?? '-'),
                      const SizedBox(height: 12),
                      _infoRow(Icons.location_on_outlined, 'Location', (user.location != null && user.location!.isNotEmpty) ? user.location! : '-'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              _menuTile(Icons.history_rounded, 'Activity History', 'View past matches and events', () {
                context.push('/activity-history');
              }),
              _menuTile(Icons.account_circle_outlined, 'Edit Profile', 'Update personal information', () {
                context.push('/edit-profile');
              }),
              const SizedBox(height: 40),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: isDestructive ? AppColors.errorRed.withValues(alpha: 0.1) : AppColors.softGray, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: isDestructive ? AppColors.errorRed : AppColors.textPrimary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? AppColors.errorRed : AppColors.textPrimary)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
