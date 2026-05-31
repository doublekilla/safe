import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/formatters.dart';
import '../../models/activity.dart';
import '../../providers/activities_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cards.dart';

/// Activity listing and search screen
class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});
  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  String _selectedPayment = 'All'; // All, Free, Paid
  String _selectedSkill = 'All'; // All, Beginner, Intermediate, Advanced
  String _selectedSport = 'All'; // All, Badminton, Basketball, Futsal, Padel, Volleyball
  String? _selectedDate;
  final List<DateTime> _dates = [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    for (int i = 0; i < 10; i++) {
      _dates.add(today.add(Duration(days: i)));
    }
    _selectedDate = Formatters.formatDate(_dates.first.toIso8601String());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivitiesProvider>().loadActivities();
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 20),
                      const Text('Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['All', 'Free', 'Paid'].map((opt) {
                          final sel = _selectedPayment == opt;
                          return ChoiceChip(
                            label: Text(opt),
                            selected: sel,
                            onSelected: (val) {
                              if (val) setModalState(() => _selectedPayment = opt);
                            },
                            selectedColor: AppColors.buttonPrimary,
                            labelStyle: TextStyle(color: sel ? Colors.white : AppColors.textPrimary),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Skill Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['All', 'Beginner', 'Intermediate', 'Advanced'].map((opt) {
                          final sel = _selectedSkill == opt;
                          return ChoiceChip(
                            label: Text(opt),
                            selected: sel,
                            onSelected: (val) {
                              if (val) setModalState(() => _selectedSkill = opt);
                            },
                            selectedColor: AppColors.buttonPrimary,
                            labelStyle: TextStyle(color: sel ? Colors.white : AppColors.textPrimary),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Sport Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['All', 'Badminton', 'Basketball', 'Futsal', 'Padel', 'Volleyball'].map((opt) {
                          final sel = _selectedSport == opt;
                          return ChoiceChip(
                            label: Text(opt),
                            selected: sel,
                            onSelected: (val) {
                              if (val) setModalState(() => _selectedSport = opt);
                            },
                            selectedColor: AppColors.buttonPrimary,
                            labelStyle: TextStyle(color: sel ? Colors.white : AppColors.textPrimary),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {}); // trigger rebuild with new filters

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _passesFilters(Activity a, {bool isExplore = false}) {
    // Filter out past activities
    if (a.date != null && a.time != null) {
      try {
        final d = DateTime.parse(a.date!).toLocal();
        final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
        final dt = DateTime.parse('$dateStr ${a.time}:00');
        if (dt.isBefore(DateTime.now())) return false;
      } catch (_) {}
    }

    // Explore should not show joined activities
    if (isExplore) {
      final currentUserId = context.read<AuthProvider>().currentUser?.id;
      if (currentUserId != null) {
        if (a.hostUserId == currentUserId || a.confirmedParticipants.contains(currentUserId) || a.waitingList.contains(currentUserId)) {
          return false;
        }
      }
    }

    // Payment
    if (_selectedPayment == 'Free' && a.cost > 0) return false;
    if (_selectedPayment == 'Paid' && a.cost <= 0) return false;
    // Skill Level
    if (_selectedSkill != 'All') {
      if (a.skillLevel == null || a.skillLevel!.toLowerCase() != _selectedSkill.toLowerCase()) return false;
    }
    // Sport
    if (_selectedSport != 'All') {
      if (a.sportType.toLowerCase() != _selectedSport.toLowerCase()) return false;
    }
    // Date
    if (_selectedDate != null) {
      if (Formatters.formatDate(a.date) != _selectedDate) return false;
    }
    return true;
  }

  Widget _buildGroupedList(List<Activity> activities, {bool isExplore = false}) {
    if (activities.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_rounded,
        title: 'No activities found',
      );
    }

    // Group by Date
    Map<String, List<Activity>> grouped = {};
    for (var act in activities) {
      if (!_passesFilters(act, isExplore: isExplore)) continue;
      String dateStr = Formatters.formatDate(act.date);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(act);
    }

    if (grouped.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_rounded,
        title: 'No activities match the filters',
      );
    }

    // Sort dates
    final sortedKeys = grouped.keys.toList();
    // Assuming dates are already coming sorted from API, but we'll preserve insertion order or sort if needed
    
    for (var key in grouped.keys) {
      grouped[key]!.sort((a, b) => (a.time ?? '').compareTo(b.time ?? ''));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        String dateStr = sortedKeys[index];
        List<Activity> acts = grouped[dateStr]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedDate == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  dateStr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ...acts.map((act) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.formatTime(act.time),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  ActivityCard(
                    title: act.title,
                    sportType: act.sportType,
                    location: act.location,
                    quota: act.quota,
                    currentParticipants: act.currentParticipants,
                    cost: act.cost,
                    skillLevel: act.skillLevel,
                    activityType: act.activityType,
                    status: act.status,
                    onTap: () => context.push('/activity/${act.id}'),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Activities'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded),
              onPressed: _showFilterModal,
            ),
            IconButton(
              icon: const Icon(Icons.mail_outline_rounded),
              onPressed: () => context.push('/activities/invitations'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Explore'),
              Tab(text: 'My Activities'),
            ],
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.buttonPrimary,
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _dates.length,
                itemBuilder: (context, index) {
                  final d = _dates[index];
                  final str = Formatters.formatDate(d.toIso8601String());
                  final isSel = _selectedDate == str;
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                  return _buildDateChip(d.day.toString(), months[d.month - 1], isSel, () {
                    setState(() => _selectedDate = str);
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildExploreTab(),
                  _buildMyActivitiesTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/activity/create'),
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return Consumer<ActivitiesProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: () => context.read<ActivitiesProvider>().loadActivities(),
          child: _buildGroupedList(prov.activities, isExplore: true),
        );
      },
    );
  }

  Widget _buildMyActivitiesTab() {
    final currentUserId = context.read<AuthProvider>().currentUser?.id;
    return Consumer<ActivitiesProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final myList = prov.activities.where((a) {
          if (currentUserId == null) return false;
          final isHost = a.hostUserId == currentUserId;
          final isParticipant = a.confirmedParticipants.contains(currentUserId);
          final isWaiting = a.waitingList.contains(currentUserId);
          return isHost || isParticipant || isWaiting;
        }).toList();

        return RefreshIndicator(
          onRefresh: () => context.read<ActivitiesProvider>().loadActivities(),
          child: _buildGroupedList(myList),
        );
      },
    );
  }

  Widget _buildDateChip(String top, String bottom, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonPrimary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.buttonPrimary : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(top, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
            Text(bottom, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
