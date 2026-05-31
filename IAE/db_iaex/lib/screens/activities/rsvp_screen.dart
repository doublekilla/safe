import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/activities_provider.dart';
import '../../models/activity.dart';
import '../../widgets/cards.dart';

/// RSVP Management Screen
class RsvpScreen extends StatelessWidget {
  final int activityId;
  const RsvpScreen({super.key, required this.activityId});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ActivitiesProvider>();
    final act = prov.selectedActivity;
    
    if (act == null || act.id != activityId) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('RSVP List')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final going = act.participants.where((p) => p.status == 'confirmed').toList();
    final waitlist = act.participants.where((p) => p.status == 'pending' || p.status == 'waiting').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('RSVP List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: AppColors.textPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.textPrimary,
              tabs: [
                Tab(text: 'Going (${going.length})'),
                Tab(text: 'Waitlist (${waitlist.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(going),
                  _buildList(waitlist),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<ActivityParticipant> participants) {
    if (participants.isEmpty) {
      return const Center(
        child: Text('No participants in this list.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: participants.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = participants[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              UserAvatar(name: p.name, imageUrl: p.profileImage, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // IconButton(
              //   icon: const Icon(
              //     Icons.more_vert_rounded,
              //     color: AppColors.textSecondary,
              //   ),
              //   onPressed: () {},
              // ),
            ],
          ),
        );
      },
    );
  }
}
