import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/formatters.dart';
import '../../models/activity.dart';
import '../../core/services/api_client.dart';
class ActivityInvitationsScreen extends StatefulWidget {
  const ActivityInvitationsScreen({super.key});

  @override
  State<ActivityInvitationsScreen> createState() => _ActivityInvitationsScreenState();
}

class _ActivityInvitationsScreenState extends State<ActivityInvitationsScreen> {
  bool _isLoading = true;
  List<Activity> _invitations = [];

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    setState(() => _isLoading = true);
    try {
      final response = await context.read<ApiClient>().get('/activities/invitations');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : (response.body['data'] ?? []);
        setState(() {
          _invitations = data.map((json) => Activity.fromJson(json)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _respondToInvite(Activity activity, bool accept) async {
    try {
      final endpoint = accept
          ? '/activities/${activity.id}/accept-invite'
          : '/activities/${activity.id}/decline-invite';
      final response = await context.read<ApiClient>().post(endpoint, body: {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
      _fetchInvitations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Activity Invitations', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invitations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _fetchInvitations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _invitations.length,
                    itemBuilder: (context, index) {
                      final activity = _invitations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF101820).withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.chipActiveBackground,
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: Text(
                                            Formatters.capitalizeWords(activity.sportType),
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.chipActiveText),
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: const Text(
                                            'Invited',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      activity.title,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 6),
                                    if (activity.date != null)
                                      _infoRow(Icons.calendar_today_rounded, '${Formatters.formatDate(activity.date, includeYear: true)} ${activity.time != null ? "• ${Formatters.formatTime(activity.time)}" : ""}'.trim()),
                                    if (activity.location != null)
                                      _infoRow(Icons.location_on_outlined, activity.location!),
                                    if (activity.hostName != null)
                                      _infoRow(Icons.person_outline_rounded, 'Hosted by ${activity.hostName}'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _respondToInvite(activity, false),
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        label: const Text('Decline'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.textSecondary,
                                          side: const BorderSide(color: AppColors.border),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _respondToInvite(activity, true),
                                        icon: Icon(activity.remainingSlots <= 0 ? Icons.hourglass_empty_rounded : Icons.check_rounded, size: 18),
                                        label: Text(activity.remainingSlots <= 0 ? 'Join Waiting List' : 'Accept'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
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
            child: const Icon(Icons.mail_outline_rounded, size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Invitations',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You don\'t have any pending activity invitations.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}