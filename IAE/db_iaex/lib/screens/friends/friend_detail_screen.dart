import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/cards.dart';
import '../../widgets/buttons.dart';
import '../../models/sport_friend.dart';

/// Full friend profile screen
class FriendDetailScreen extends StatefulWidget {
  final int friendId;
  const FriendDetailScreen({super.key, required this.friendId});

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final friend = context.select<FriendsProvider, SportFriend?>((p) {
      final inFriends = p.friends.where((f) => f.id == widget.friendId);
      if (inFriends.isNotEmpty) return inFriends.first;
      
      final inSearch = p.searchResults.where((f) => f.id == widget.friendId);
      if (inSearch.isNotEmpty) return inSearch.first;
      
      return null;
    });

    if (friend == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(children: [
              UserAvatar(name: friend.name, imageUrl: friend.profileImage, size: 100),
              const SizedBox(height: 16),
              Text(friend.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              if (friend.location != null) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(friend.location!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _statBox('Matches', '${friend.activityCount}'),
              ]),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (friend.friendStatus == 'accepted') ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                      tooltip: 'Message',
                      onPressed: () => context.push('/chat/${friend.id}?name=${Uri.encodeComponent(friend.name)}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.event_available_rounded, color: AppColors.textPrimary),
                      tooltip: 'Invite to Activity',
                      onPressed: () {
                        context.push('/activity/select-existing/${friend.id}');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_remove_rounded, color: AppColors.errorRed),
                      tooltip: 'Unfriend',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.cardSurface,
                            title: const Text('Unfriend', style: TextStyle(color: AppColors.textPrimary)),
                            content: const Text('Are you sure you want to remove this friend?', style: TextStyle(color: AppColors.textSecondary)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.read<FriendsProvider>().removeFriend(friend.id);
                                  context.pop();
                                },
                                child: const Text('Unfriend', style: TextStyle(color: AppColors.errorRed)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: PrimaryButton(
                      label: 'Message',
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: () => context.push('/chat/${friend.id}?name=${Uri.encodeComponent(friend.name)}'),
                    ),
                  ),
                  if (friend.friendStatus == 'none') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Add Friend',
                        icon: Icons.person_add_rounded,
                        onPressed: () => context.read<FriendsProvider>().sendFriendRequest(friend.id),
                      ),
                    ),
                  ],
                ],
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          // Info Sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    _infoRow(Icons.sports_tennis_rounded, 'Sports', friend.sports.isNotEmpty ? friend.sports.join(', ') : '-'),
                    const SizedBox(height: 12),
                    _infoRow(Icons.star_border_rounded, 'Skill Level', friend.skillLevel ?? '-'),
                    const SizedBox(height: 12),
                    _infoRow(Icons.event_available_rounded, 'Availability', friend.availability.isNotEmpty ? friend.availability.join(', ') : '-'),
                    const SizedBox(height: 12),
                    _infoRow(Icons.person_outline_rounded, 'Gender', friend.gender ?? '-'),
                    const SizedBox(height: 12),
                    _infoRow(Icons.location_on_outlined, 'Location', (friend.location != null && friend.location!.isNotEmpty) ? friend.location! : '-'),
                  ],
                ),
              ),
              if (friend.mutualClubs.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Mutual Clubs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                ...friend.mutualClubs.map((club) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => context.push('/community/${club['id']}'),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            club['image'] != null && club['image'].toString().isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      club['image'].toString(),
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.shield_outlined, color: AppColors.textPrimary),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.shield_outlined, color: AppColors.textPrimary),
                                  ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(club['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  Text('${club['member_count'] ?? 0} Members', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
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
}
