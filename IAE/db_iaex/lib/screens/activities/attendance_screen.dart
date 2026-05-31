import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';

/// Activity attendance screen
class AttendanceScreen extends StatefulWidget {
  final int activityId;
  const AttendanceScreen({super.key, required this.activityId});
  @override State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadAttendance(widget.activityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Attendance'), leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop())),
      body: Column(children: [
        // Summary
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(child: _summaryBox('Present', prov.presentCount, AppColors.success)),
            const SizedBox(width: 8),
            Expanded(child: _summaryBox('Absent', prov.absentCount, AppColors.errorRed)),
            const SizedBox(width: 8),
            Expanded(child: _summaryBox('Late', prov.lateCount, AppColors.warning)),
          ]),
        ),
        
        // List
        Expanded(
          child: prov.isLoading && prov.records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: prov.records.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final rec = prov.records[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(16)),
                      child: Column(children: [
                        Row(children: [
                          UserAvatar(name: rec.userName, imageUrl: rec.userImage, size: 40),
                          const SizedBox(width: 12),
                          Expanded(child: Text(rec.userName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                        ]),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _statusBtn(rec.userId, rec.status, 'present', 'Present', AppColors.success, prov)),
                          const SizedBox(width: 8),
                          Expanded(child: _statusBtn(rec.userId, rec.status, 'absent', 'Absent', AppColors.errorRed, prov)),
                          const SizedBox(width: 8),
                          Expanded(child: _statusBtn(rec.userId, rec.status, 'late', 'Late', AppColors.warning, prov)),
                        ]),
                      ]),
                    );
                  },
                ),
        ),
        
        // Save
        Padding(
          padding: const EdgeInsets.all(20),
          child: PrimaryButton(
            label: 'Save Attendance',
            isLoading: prov.isLoading,
            onPressed: () async {
              final success = await prov.saveAttendance(widget.activityId);
              if (success && context.mounted) context.pop();
            },
          ),
        ),
      ]),
    );
  }

  Widget _summaryBox(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  Widget _statusBtn(int userId, String currentStatus, String targetStatus, String label, Color color, AttendanceProvider prov) {
    final sel = currentStatus == targetStatus;
    return GestureDetector(
      onTap: () => prov.updateStatus(userId, targetStatus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: sel ? color : AppColors.softGray, borderRadius: BorderRadius.circular(8)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
