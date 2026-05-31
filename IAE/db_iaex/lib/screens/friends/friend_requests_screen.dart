import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/cards.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().loadFriendRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FriendsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Friend Requests'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.friendRequests.isEmpty
              ? const Center(
                  child: Text('No Friend Requests Yet', style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: prov.friendRequests.length,
                  itemBuilder: (context, index) {
                    final req = prov.friendRequests[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FriendCard(
                        name: req.name,
                        profileImage: req.profileImage,
                        location: req.location,
                        distance: req.distance,
                        sports: req.sports,
                        skillLevel: req.skillLevel,
                        friendStatus: req.friendStatus,
                        onTap: () => context.push('/friend/${req.id}'),
                        onAccept: () => prov.acceptFriendRequest(req.id),
                        onReject: () => prov.removeFriend(req.id),
                      ),
                    );
                  },
                ),
    );
  }
}