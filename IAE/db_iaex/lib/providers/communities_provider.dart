import 'package:flutter/material.dart';
import '../models/community.dart';
import '../core/services/api_client.dart';

/// Communities state management
class CommunitiesProvider extends ChangeNotifier {
  final ApiClient _api;
  List<Community> _communities = [];
  Community? _selectedCommunity;
  bool _isLoading = false;

  CommunitiesProvider({required ApiClient api}) : _api = api;

  List<Community> get communities => _communities;
  Community? get selectedCommunity => _selectedCommunity;
  bool get isLoading => _isLoading;

  Future<void> loadCommunities({String? sport, String? query}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (sport != null && sport != 'all') params['sport_category'] = sport;
      if (query != null && query.isNotEmpty) params['search'] = query;
      final res = await _api.get('/communities', queryParams: params.isNotEmpty ? params : null);
      if (res.isSuccess && res.data is List) {
        _communities = (res.data as List).map((e) => Community.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCommunityDetail(int id) async {
    _isLoading = true;
    _selectedCommunity = null;
    notifyListeners();
    try {
      final res = await _api.get('/communities/$id');
      if (res.isSuccess) {
        _selectedCommunity = Community.fromJson(res.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error loading community detail: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createCommunity(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/communities', body: data);
      if (res.isSuccess) { await loadCommunities(); return true; }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> joinCommunity(int communityId) async {
    try {
      final res = await _api.post('/communities/$communityId/join');
      if (res.isSuccess) {
        await loadCommunities();
        if (_selectedCommunity != null && _selectedCommunity!.id == communityId) {
          await loadCommunityDetail(communityId);
        }
        return true;
      }
    } catch (e) {
      debugPrint('Error joining community: $e');
    }
    return false;
  }

  Future<bool> leaveCommunity(int communityId) async {
    try {
      final res = await _api.post('/communities/$communityId/leave');
      if (res.isSuccess) {
        await loadCommunities();
        return true;
      }
    } catch (e) {
      debugPrint('Error leaving community: $e');
    }
    return false;
  }

  Future<bool> updateCommunity(int id, Map<String, String> data, {String? imagePath}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.postMultipart(
        '/communities/$id',
        fields: data,
        fileField: imagePath != null ? 'image' : null,
        filePath: imagePath,
      );
      if (res.isSuccess) {
        await loadCommunityDetail(id);
        await loadCommunities();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteCommunity(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.delete('/communities/$id');
      if (res.isSuccess) {
        _selectedCommunity = null;
        await loadCommunities();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<List<CommunityMember>> getPendingRequests(int id) async {
    try {
      final res = await _api.get('/communities/$id/requests');
      if (res.isSuccess && res.data is List) {
        return (res.data as List).map((e) => CommunityMember.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> approveRequest(int communityId, int userId) async {
    try {
      final res = await _api.post('/communities/$communityId/approve', body: {'user_id': userId});
      if (res.isSuccess) {
        await loadCommunityDetail(communityId);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> denyRequest(int communityId, int userId) async {
    try {
      final res = await _api.post('/communities/$communityId/deny', body: {'user_id': userId});
      return res.isSuccess;
    } catch (_) {}
    return false;
  }

  Future<bool> removeMember(int communityId, int userId) async {
    try {
      final res = await _api.post('/communities/$communityId/remove-member', body: {'user_id': userId});
      if (res.isSuccess) {
        await loadCommunityDetail(communityId);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> assignAdmin(int communityId, int userId, bool isAdmin) async {
    try {
      final res = await _api.post('/communities/$communityId/assign-admin', body: {
        'user_id': userId,
        'is_admin': isAdmin,
      });
      if (res.isSuccess) {
        await loadCommunityDetail(communityId);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
