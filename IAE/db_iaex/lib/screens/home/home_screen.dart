import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';

import '../../providers/auth_provider.dart';
import '../../providers/activities_provider.dart';
import '../../providers/communities_provider.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/cards.dart';

/// Home screen dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivitiesProvider>().loadActivities();
      context.read<CommunitiesProvider>().loadCommunities();
      context.read<FriendsProvider>().loadFriends();
      context.read<FriendsProvider>().searchFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final acts = context.watch<ActivitiesProvider>();
    final comms = context.watch<CommunitiesProvider>();
    final friendsProv = context.watch<FriendsProvider>();

    DateTime parseActDate(String? date, String? time) {
      if (date == null || time == null) return DateTime.now();
      try {
        final d = DateTime.parse(date).toLocal();
        final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final cleanTime = time.contains(':') && time.length > 5 ? time.substring(0, 5) : time;
        return DateTime.parse('$dateStr $cleanTime:00');
      } catch (_) {
        return DateTime.now();
      }
    }

    final myUpcoming = acts.activities.where((a) {
      if (a.date == null || a.time == null) return false;
      final dt = parseActDate(a.date, a.time);
      if (dt.isBefore(DateTime.now())) return false;
      final isJoined = auth.currentUser?.id != null && (a.confirmedParticipants.contains(auth.currentUser!.id) || a.hostUserId == auth.currentUser!.id);
      return isJoined;
    }).toList();
    
    myUpcoming.sort((a, b) {
      return parseActDate(a.date, a.time).compareTo(parseActDate(b.date, b.time));
    });

    final nextMatch = myUpcoming.isNotEmpty ? myUpcoming.first : null;

    final upcomingAllActs = acts.activities.where((a) {
      if (a.date == null || a.time == null) return false;
      final dt = parseActDate(a.date, a.time);
      if (dt.isBefore(DateTime.now())) return false;
      final isJoined = auth.currentUser?.id != null && (a.confirmedParticipants.contains(auth.currentUser!.id) || a.hostUserId == auth.currentUser!.id);
      return !isJoined;
    }).toList();
    
    upcomingAllActs.sort((a, b) {
      return parseActDate(a.date, a.time).compareTo(parseActDate(b.date, b.time));
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(
              name: auth.currentUser?.fullName ?? '',
              imageUrl: auth.currentUser?.profileImage,
              size: 36,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Good morning,', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(auth.currentUser?.fullName ?? 'Player', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textPrimary), onPressed: () => context.push('/chat')),
          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary), onPressed: () => context.push('/notifications')),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final acts = context.read<ActivitiesProvider>();
          final comms = context.read<CommunitiesProvider>();
          final friends = context.read<FriendsProvider>();
          await Future.wait([
            acts.loadActivities(),
            comms.loadCommunities(),
            friends.loadFriends(),
            friends.searchFriends(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Upcoming Action
              if (nextMatch != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () => context.push('/activity/${nextMatch.id}'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.buttonPrimary, borderRadius: BorderRadius.circular(24)),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                            child: const Icon(Icons.calendar_month_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Next Match', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text(nextMatch.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(nextMatch.date, nextMatch.time),
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.event_available_rounded, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('No Upcoming Match', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Find activities around you', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 28),

              // Recommended Activities
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Recommended Activities',
                  actionLabel: 'See All',
                  onAction: () => context.push('/activities'),
                ),
              ),
              const SizedBox(height: 12),
              if (acts.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (upcomingAllActs.isEmpty)
                const Padding(padding: EdgeInsets.all(20), child: EmptyState(icon: Icons.event_busy_rounded, title: 'No upcoming activities found'))
              else
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: upcomingAllActs.length > 3 ? 3 : upcomingAllActs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final act = upcomingAllActs[index];
                      return SizedBox(
                        width: 280,
                        child: ActivityCard(
                          title: act.title,
                          sportType: act.sportType,
                          location: act.location,
                          date: act.date,
                          time: act.time,
                          quota: act.quota,
                          currentParticipants: act.currentParticipants,
                          cost: act.cost,
                          skillLevel: act.skillLevel,
                          status: act.status,
                          onTap: () => context.push('/activity/${act.id}'),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 28),

              // Sport Friends (Max 5)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Sport Friends',
                  actionLabel: 'See All',
                  onAction: () => context.go('/friends'),
                ),
              ),
              const SizedBox(height: 12),
              if (friendsProv.isLoading && friendsProv.searchResults.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (friendsProv.searchResults.isEmpty)
                const Padding(padding: EdgeInsets.all(20), child: EmptyState(icon: Icons.group_off_rounded, title: 'No recommendations found'))
              else
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: friendsProv.searchResults.where((u) => u.friendStatus == 'none').take(5).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final nonFriends = friendsProv.searchResults.where((u) => u.friendStatus == 'none').take(5).toList();
                      final user = nonFriends[index];
                      return SizedBox(
                        width: 120,
                        child: GestureDetector(
                          onTap: () => context.push('/friend/${user.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                UserAvatar(name: user.name, imageUrl: user.profileImage, size: 40),
                                const SizedBox(height: 8),
                                Text(user.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 28),

              // Explore Clubs (Max 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Explore Clubs',
                  actionLabel: 'See All',
                  onAction: () => context.push('/communities'),
                ),
              ),
              const SizedBox(height: 12),
              if (comms.communities.where((c) => !c.isJoined).isEmpty)
                const Padding(padding: EdgeInsets.all(20), child: EmptyState(icon: Icons.groups_rounded, title: 'No new clubs found'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: comms.communities.where((c) => !c.isJoined).take(3).length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final unjoinedClubs = comms.communities.where((c) => !c.isJoined).toList();
                    final com = unjoinedClubs[index];
                    return CommunityCard(
                      name: com.name,
                      image: com.image,
                      sportCategory: com.sportCategory,
                      memberCount: com.memberCount,
                      location: com.location,
                      isJoined: com.isJoined,
                      onTap: () => context.push('/community/${com.id}'),
                    );
                  },
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  String _formatDate(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return 'Unknown';
    try {
      final d = DateTime.parse(dateStr).toLocal();
      final localDateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final cleanTime = timeStr.contains(':') && timeStr.length > 5 ? timeStr.substring(0, 5) : timeStr;
      final dt = DateTime.parse('$localDateStr $cleanTime:00');
      
      final now = DateTime.now();
      final difference = DateTime(now.year, now.month, now.day).difference(DateTime(dt.year, dt.month, dt.day)).inDays;
      if (difference == 0) return 'Today, ${DateFormat('HH:mm').format(dt)}';
      if (difference == -1) return 'Tomorrow, ${DateFormat('HH:mm').format(dt)}';
      return DateFormat('d MMM, HH:mm').format(dt);
    } catch (_) {
      return '$dateStr $timeStr';
    }
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.event_rounded, color: AppColors.textPrimary)),
              title: const Text('Create Activity', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Organize a match or training session', style: TextStyle(fontSize: 12)),
              onTap: () { context.pop(); context.push('/activity/create'); },
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.softGray, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.group_add_rounded, color: AppColors.textPrimary)),
              title: const Text('Create Club', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Start a new sports club', style: TextStyle(fontSize: 12)),
              onTap: () { context.pop(); context.push('/community/create'); },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
