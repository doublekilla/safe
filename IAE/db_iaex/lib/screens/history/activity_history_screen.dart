import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/formatters.dart';
import '../../providers/activities_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cards.dart';

/// Activity history screen
class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});
  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivitiesProvider>().loadActivities();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.buttonPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ActivitiesProvider>();
    final currentUserId = context.read<AuthProvider>().currentUser?.id;

    var pastActivities = prov.activities.where((act) {
      if (currentUserId == null) return false;
      final isParticipant = act.confirmedParticipants.contains(currentUserId) || act.hostUserId == currentUserId;
      if (!isParticipant) return false;

      if (act.date == null || act.time == null) return false;
      try {
        final d = DateTime.parse(act.date!).toLocal();
        final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final dt = DateTime.parse('$dateStr ${act.time}:00');
        return dt.isBefore(DateTime.now());
      } catch (_) {
        return false;
      }
    }).toList();

    if (_selectedDate != null) {
      pastActivities = pastActivities.where((act) {
        if (act.date == null) return false;
        try {
          final d = DateTime.parse(act.date!).toLocal();
          return d.year == _selectedDate!.year && d.month == _selectedDate!.month && d.day == _selectedDate!.day;
        } catch (_) {
          return false;
        }
      }).toList();
    }

    pastActivities.sort((a, b) {
      if (a.date == null || a.time == null || b.date == null || b.time == null) return 0;
      try {
        final dA = DateTime.parse(a.date!).toLocal();
        final dateStrA = '${dA.year}-${dA.month.toString().padLeft(2, '0')}-${dA.day.toString().padLeft(2, '0')}';
        final dtA = DateTime.parse('$dateStrA ${a.time}:00');

        final dB = DateTime.parse(b.date!).toLocal();
        final dateStrB = '${dB.year}-${dB.month.toString().padLeft(2, '0')}-${dB.day.toString().padLeft(2, '0')}';
        final dtB = DateTime.parse('$dateStrB ${b.time}:00');
        
        return dtB.compareTo(dtA);
      } catch (_) {
        return 0;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.errorRed),
              onPressed: () => setState(() => _selectedDate = null),
              tooltip: 'Clear Filter',
            ),
          IconButton(
            icon: Icon(Icons.calendar_month_rounded, color: _selectedDate != null ? AppColors.buttonPrimary : AppColors.textPrimary),
            onPressed: () => _selectDate(context),
            tooltip: 'Filter by Date',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: prov.isLoading && pastActivities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : pastActivities.isEmpty
          ? EmptyState(
              icon: Icons.history_rounded,
              title: _selectedDate != null ? 'No activities on this date' : 'No past activities',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: pastActivities.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final act = pastActivities[index];
                
                return ActivityCard(
                  title: act.title,
                  sportType: act.sportType,
                  location: act.location,
                  date: Formatters.formatDate(act.date),
                  time: Formatters.formatTime(act.time),
                  quota: act.quota,
                  currentParticipants: act.currentParticipants,
                  cost: act.cost,
                  skillLevel: act.skillLevel,
                  status: 'Completed',
                  onTap: () => context.push('/activity/${act.id}'),
                );
              },
            ),
    );
  }
}
