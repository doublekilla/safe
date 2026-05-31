import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../core/services/api_client.dart';

/// Attendance state management
class AttendanceProvider extends ChangeNotifier {
  final ApiClient _api;
  List<AttendanceRecord> _records = [];
  bool _isLoading = false;

  AttendanceProvider({required ApiClient api}) : _api = api;

  List<AttendanceRecord> get records => _records;
  bool get isLoading => _isLoading;

  int get presentCount => _records.where((r) => r.status == 'present').length;
  int get absentCount => _records.where((r) => r.status == 'absent').length;
  int get lateCount => _records.where((r) => r.status == 'late').length;
  int get canceledCount => _records.where((r) => r.status == 'canceled').length;

  Future<void> loadAttendance(int activityId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/attendance/$activityId');
      if (res.isSuccess && res.data is List) {
        _records = (res.data as List).map((e) => AttendanceRecord.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void updateStatus(int userId, String status) {
    final index = _records.indexWhere((r) => r.userId == userId);
    if (index != -1) {
      _records[index].status = status;
      notifyListeners();
    }
  }

  Future<bool> saveAttendance(int activityId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final body = {
        'activity_id': activityId,
        'records': _records.map((r) => r.toJson()).toList(),
      };
      final res = await _api.post('/attendance', body: body);
      if (res.isSuccess) { _isLoading = false; notifyListeners(); return true; }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
