import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../models/activity.dart';
import '../../core/services/api_client.dart';
import '../../widgets/cards.dart';

class SelectExistingActivityScreen extends StatefulWidget {
  final int friendId;
  const SelectExistingActivityScreen({super.key, required this.friendId});

  @override
  State<SelectExistingActivityScreen> createState() => _SelectExistingActivityScreenState();
}

class _SelectExistingActivityScreenState extends State<SelectExistingActivityScreen> {
  bool _isLoading = true;
  List<Activity> _myActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchMyActivities();
  }

  Future<void> _fetchMyActivities() async {
    setState(() => _isLoading = true);
    try {
      final response = await context.read<ApiClient>().get('/activities/my');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : (response.body['data'] ?? []);
        setState(() {
          final allActivities = data.map((json) => Activity.fromJson(json)).toList();
          _myActivities = allActivities.where((a) {
            final alreadyInvolved = a.participants.any((p) => p.userId == widget.friendId);
            return !alreadyInvolved;
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading activities: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _inviteToActivity(Activity activity) async {
    try {
      final response = await context.read<ApiClient>().post(
        '/activities/${activity.id}/invite',
        body: {'user_id': widget.friendId},
      );
      
      if (response.statusCode == 200 && response.body['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation sent successfully!')));
          context.pop(); // Go back to profile
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myActivities.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myActivities.length,
                  itemBuilder: (context, index) {
                    final activity = _myActivities[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _inviteToActivity(activity),
                        child: ActivityCard(
                          title: activity.title,
                          sportType: activity.sportType,
                          location: activity.location,
                          date: activity.date,
                          time: activity.time,
                          quota: activity.quota,
                          currentParticipants: activity.currentParticipants,
                          cost: activity.cost,
                          skillLevel: activity.skillLevel,
                          activityType: activity.activityType,
                          status: activity.status,
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_busy_rounded, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Upcoming Activities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You don\'t have any upcoming activities to invite your friend to.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
