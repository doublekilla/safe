import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../core/services/api_client.dart';

/// Activities state management
class ActivitiesProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Activity> _activities = [];
  Activity? _selectedActivity;
  bool _isLoading = false;

  ActivitiesProvider({required ApiClient api}) : _api = api;

  List<Activity> get activities => _activities;
  Activity? get selectedActivity => _selectedActivity;
  bool get isLoading => _isLoading;

  Future<void> loadActivities({String? filter}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (filter != null && filter != 'all') params['filter'] = filter;
      final res = await _api.get('/activities', queryParams: params.isNotEmpty ? params : null);
      if (res.isSuccess) {
        if (res.data is List) {
          _activities = (res.data as List).map((e) => Activity.fromJson(e)).toList();
        } else if (res.data is Map && res.data['data'] is List) {
          _activities = (res.data['data'] as List).map((e) => Activity.fromJson(e)).toList();
        }
      }
    } catch (e, stack) {
      debugPrint('Load activities error: $e\n$stack');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadActivityDetail(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/activities/$id');
      if (res.isSuccess) {
        if (res.data is Map && res.data['data'] is Map) {
          _selectedActivity = Activity.fromJson(res.data['data'] as Map<String, dynamic>);
        } else {
          _selectedActivity = Activity.fromJson(res.data as Map<String, dynamic>);
        }
        
        final index = _activities.indexWhere((a) => a.id == id);
        if (index != -1 && _selectedActivity != null) {
          _activities[index] = _selectedActivity!;
        }
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createActivity(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/activities', body: data);
      if (res.isSuccess) { await loadActivities(); _isLoading = false; notifyListeners(); return true; }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateActivity(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.put('/activities/$id', body: data);
      if (res.isSuccess) {
        await loadActivityDetail(id);
        await loadActivities();
        return true;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> joinActivity(int activityId) async {
    try {
      final res = await _api.post('/activities/$activityId/join', body: {});
      if (res.isSuccess) { await loadActivityDetail(activityId); return true; }
    } catch (_) {}
    return false;
  }

  Future<bool> joinWaitingList(int activityId) async {
    try {
      final res = await _api.post('/activities/$activityId/join', body: {});
      if (res.isSuccess) { await loadActivityDetail(activityId); return true; }
    } catch (_) {}
    return false;
  }

  Future<bool> cancelRsvp(int activityId) async {
    try {
      final res = await _api.post('/activities/$activityId/cancel-rsvp');
      if (res.isSuccess) { await loadActivityDetail(activityId); return true; }
    } catch (_) {}
    return false;
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/activities/history');
      if (res.isSuccess && res.data is List) {
        _activities = (res.data as List).map((e) => Activity.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> leaveActivity(int activityId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.delete('/activities/$activityId/leave');
      if (response.isSuccess) {
        await loadActivityDetail(activityId);
        await loadActivities();
        return true;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteActivity(int activityId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _api.delete('/activities/$activityId');
      if (response.isSuccess) {
        await loadActivities();
        return true;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
