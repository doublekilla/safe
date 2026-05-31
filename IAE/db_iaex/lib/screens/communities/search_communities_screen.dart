import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/sport_categories.dart';
import '../../providers/communities_provider.dart';
import '../../widgets/cards.dart';
import '../../widgets/search_and_chips.dart';

/// Search and list communities (clubs)
class SearchCommunitiesScreen extends StatefulWidget {
  const SearchCommunitiesScreen({super.key});
  @override
  State<SearchCommunitiesScreen> createState() =>
      _SearchCommunitiesScreenState();
}

class _SearchCommunitiesScreenState extends State<SearchCommunitiesScreen> {
  final _searchCtl = TextEditingController();
  String _selectedSport = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunitiesProvider>().loadCommunities();
    });
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Clubs'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.push('/community/create'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Explore'),
              Tab(text: 'My Communities'),
            ],
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.buttonPrimary,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchBar(
                        controller: _searchCtl,
                        hint: 'Find sports clubs...',
                        onChanged: (v) {
                          context.read<CommunitiesProvider>().loadCommunities(
                              query: v, sport: _selectedSport);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterIcon(context),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildExploreTab(),
                  _buildMyCommunitiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterIcon(BuildContext context) {
    final allowedCategories = [
      SportCategory.all,
      SportCategory.badminton,
      SportCategory.basketball,
      SportCategory.futsal,
      SportCategory.padel,
      SportCategory.volleyball,
    ];

    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardSurface,
      elevation: 4,
      onSelected: (value) {
        setState(() => _selectedSport = value);
        context.read<CommunitiesProvider>().loadCommunities(
          query: _searchCtl.text,
          sport: _selectedSport,
        );
      },
      itemBuilder: (context) {
        return allowedCategories.map((s) {
          final isSelected = _selectedSport == s.value;
          return PopupMenuItem<String>(
            value: s.value,
            child: Row(
              children: [
                Icon(
                  s.icon,
                  size: 20,
                  color: isSelected ? AppColors.buttonPrimary : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  s.label,
                  style: TextStyle(
                    color: isSelected ? AppColors.buttonPrimary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Icon(
            Icons.tune_rounded,
            color: _selectedSport == 'all' ? AppColors.textMuted : AppColors.buttonPrimary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return Consumer<CommunitiesProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.communities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final exploreList = prov.communities.where((c) => c.isJoined == false).toList();

        if (exploreList.isEmpty) {
          return const EmptyState(
            icon: Icons.groups_rounded,
            title: 'No clubs found',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          itemCount: exploreList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final com = exploreList[index];
            return CommunityCard(
              name: com.name,
              image: com.image,
              sportCategory: com.sportCategory,
              memberCount: com.memberCount,
              location: com.location,
              isJoined: com.isJoined,
              onTap: () => context.push('/community/${com.id}'),
              onJoin: null, // Removed join button from preview card
            );
          },
        );
      },
    );
  }

  Widget _buildMyCommunitiesTab() {
    return Consumer<CommunitiesProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.communities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final myList = prov.communities.where((c) => c.isJoined == true).toList();

        if (myList.isEmpty) {
          return const EmptyState(
            icon: Icons.groups_rounded,
            title: 'You haven\'t joined any clubs',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          itemCount: myList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final com = myList[index];
            return CommunityCard(
              name: com.name,
              image: com.image,
              sportCategory: com.sportCategory,
              memberCount: com.memberCount,
              location: com.location,
              isJoined: com.isJoined,
              onTap: () => context.push('/community/${com.id}'),
              onJoin: null,
            );
          },
        );
      },
    );
  }
}
