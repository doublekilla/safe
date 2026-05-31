import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/activities_provider.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

/// Full event detail screen
class EventDetailScreen extends StatefulWidget {
  final int activityId;
  const EventDetailScreen({super.key, required this.activityId});
  @override State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivitiesProvider>().loadActivityDetail(widget.activityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ActivitiesProvider>();
    final act = prov.selectedActivity;
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    final isHost = act != null && act.hostUserId == currentUserId;

    if (prov.isLoading && act == null) return const Scaffold(backgroundColor: AppColors.background, body: Center(child: CircularProgressIndicator()));
    if (act == null) return const Scaffold(backgroundColor: AppColors.background);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Event Detail'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF101820).withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))]),
              child: const Icon(Icons.sports_tennis_rounded, size: 32, color: AppColors.buttonPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.chipBackground, borderRadius: BorderRadius.circular(9999)), child: Text(act.sportType.isNotEmpty ? '${act.sportType[0].toUpperCase()}${act.sportType.substring(1)}' : '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.chipText))),
                const SizedBox(width: 8),
                if (act.skillLevel != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(9999)), child: Text(act.skillLevel!, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))),
                const Spacer(),
                StatusBadge(status: act.status),
              ]),
              const SizedBox(height: 8),
              Text(act.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ])),
          ]),
          const SizedBox(height: 24),

          // Host
          if (act.hostName != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                UserAvatar(name: act.hostName!, imageUrl: act.hostProfileImage, size: 40),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Hosted by', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(act.hostName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ])),
                if (!isHost) const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.textSecondary),
              ]),
            ),
            const SizedBox(height: 24),
          ],

          // Details Grid
          Row(children: [
            Expanded(child: _detailCard(Icons.calendar_today_rounded, 'Date', Formatters.formatDate(act.date, includeYear: true))),
            const SizedBox(width: 12),
            Expanded(child: _detailCard(Icons.access_time_rounded, 'Time', Formatters.formatTime(act.time))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _detailCard(Icons.payments_outlined, 'Cost', Formatters.formatPrice(act.cost))),
            const SizedBox(width: 12),
            Expanded(child: _detailCard(Icons.people_outline_rounded, 'Slots', '${act.currentParticipants} / ${act.quota}')),
          ]),
          const SizedBox(height: 12),
          _detailCard(Icons.location_on_outlined, 'Location', act.location ?? '-', width: double.infinity),
          const SizedBox(height: 24),

          // Notes
          if (act.notes != null) ...[
            const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(act.notes!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
          ],

          // Participants preview
          Builder(
            builder: (context) {
              final confirmedParts = act.participants.where((p) => p.status == 'confirmed').toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'Participants (${act.currentParticipants})', actionLabel: 'See All', onAction: () => context.push('/activity/${act.id}/rsvp')),
                  const SizedBox(height: 12),
                  if (confirmedParts.isEmpty)
                    const Text('No participants yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                  else
                    SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (confirmedParts.length > 5 ? 5 : confirmedParts.length) + (confirmedParts.length > 5 ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (confirmedParts.length > 5 && index == 5) {
                            return Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.softGray,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: Center(
                                child: Text('+${confirmedParts.length - 5}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              ),
                            );
                          }
                          final part = confirmedParts[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: UserAvatar(name: part.name, imageUrl: part.profileImage, size: 48),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              );
            }
          ),

          // Action Buttons
          if (isHost) ...[
            PrimaryButton(label: 'Edit Activity', onPressed: () {
              context.push('/activity/${act.id}/edit');
            }),
            const SizedBox(height: 12),
            SecondaryButton(label: 'Delete Activity', onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete Activity'),
                  content: const Text('Are you sure you want to delete this activity?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                final success = await prov.deleteActivity(act.id);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity deleted')));
                  context.pop();
                }
              }
            }),
          ] else if (act.confirmedParticipants.contains(currentUserId)) ...[
            Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20), SizedBox(width: 8), Text("You're going!", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.success))])),
            const SizedBox(height: 12),
            SecondaryButton(label: 'Cancel RSVP', onPressed: () async {
              final success = await prov.leaveActivity(act.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RSVP Cancelled')));
              }
            }),
          ] else if (act.waitingList.contains(currentUserId)) ...[
            Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.hourglass_empty_rounded, color: AppColors.warning, size: 20), SizedBox(width: 8), Text("On Waiting List", style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.warning))])),
            const SizedBox(height: 12),
            SecondaryButton(label: 'Leave Waiting List', onPressed: () async {
              final success = await prov.leaveActivity(act.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Left Waiting List')));
              }
            }),
          ] else if (act.remainingSlots > 0 && act.canJoin) ...[
            PrimaryButton(label: 'Join Activity', onPressed: () async {
              final success = await prov.joinActivity(act.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully joined!')));
              }
            }),
          ] else if (act.remainingSlots <= 0) ...[
            PrimaryButton(label: 'Join Waiting List', onPressed: () async {
              final success = await prov.joinWaitingList(act.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined waiting list!')));
              }
            }),
          ],
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _detailCard(IconData icon, String label, String value, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}
