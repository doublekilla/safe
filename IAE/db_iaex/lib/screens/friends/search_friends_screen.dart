import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/sport_categories.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/cards.dart';
import '../../widgets/search_and_chips.dart';

/// Search and list friends
class SearchFriendsScreen extends StatefulWidget {
  const SearchFriendsScreen({super.key});
  @override
  State<SearchFriendsScreen> createState() => _SearchFriendsScreenState();
}

class _SearchFriendsScreenState extends State<SearchFriendsScreen> {
  final _searchCtl = TextEditingController();
  String _selectedSport = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().searchFriends();
    });
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FriendsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find Friends'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.textPrimary),
            onPressed: () => context.push('/friends/requests'),
          ),
          IconButton(
            icon: const Icon(Icons.people_alt_rounded, color: AppColors.textPrimary),
            onPressed: () => context.push('/friends/my'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: AppSearchBar(
                    controller: _searchCtl,
                    hint: 'Search by name...',
                    onChanged: (v) => context.read<FriendsProvider>().searchFriends(
                      query: v,
                      sport: _selectedSport,
                    ),
                    suffixIcon: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: _selectedSport == 'all' ? AppColors.textMuted : AppColors.buttonPrimary,
                      ),
                      onSelected: (value) {
                        setState(() => _selectedSport = value);
                        context.read<FriendsProvider>().searchFriends(
                          query: _searchCtl.text,
                          sport: _selectedSport,
                        );
                      },
                      itemBuilder: (BuildContext context) {
                        return SportCategory.values.map((category) {
                          return PopupMenuItem<String>(
                            value: category.value,
                            child: Row(
                              children: [
                                Icon(category.icon, size: 18, color: AppColors.textSecondary),
                                const SizedBox(width: 12),
                                Text(category.label),
                                if (_selectedSport == category.value) ...[
                                  const Spacer(),
                                  const Icon(Icons.check, size: 18, color: AppColors.buttonPrimary),
                                ],
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (prov.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (prov.searchResults.where((u) => u.friendStatus != 'accepted').isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                icon: Icons.person_search_rounded,
                title: 'No users found',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final nonFriends = prov.searchResults.where((u) => u.friendStatus != 'accepted').toList();
                    final friend = nonFriends[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FriendCard(
                        name: friend.name,
                        profileImage: friend.profileImage,
                        location: friend.location,
                        distance: friend.distance,
                        sports: friend.sports,
                        skillLevel: friend.skillLevel,
                        friendStatus: friend.friendStatus,
                        onTap: () => context.push('/friend/${friend.id}'),
                        onAdd: () => context
                            .read<FriendsProvider>()
                            .sendFriendRequest(friend.id),
                        onMessage: () {
                           // Mock chat functionality for now
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Chat with ${friend.name} coming soon!')),
                           );
                        },
                      ),
                    );
                  },
                  childCount: prov.searchResults.where((u) => u.friendStatus != 'accepted').length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
