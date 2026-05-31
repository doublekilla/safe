import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/cards.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({super.key});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().loadFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<FriendsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Friends'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.friends.isEmpty
              ? const Center(
                  child: Text('You have no friends listed yet.', style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: prov.friends.length,
                  itemBuilder: (context, index) {
                    final friend = prov.friends[index];
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
                        onMessage: () => context.push('/chat/${friend.id}?name=${Uri.encodeComponent(friend.name)}'),
                      ),
                    );
                  },
                ),
    );
  }
}