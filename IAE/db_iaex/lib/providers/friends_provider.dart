import 'package:flutter/material.dart';
import '../models/sport_friend.dart';
import '../core/services/api_client.dart';

/// Friends state management
class FriendsProvider extends ChangeNotifier {
  final ApiClient _api;
  List<SportFriend> _friends = [];
  List<SportFriend> _friendRequests = [];
  List<SportFriend> _searchResults = [];
  bool _isLoading = false;

  FriendsProvider({required ApiClient api}) : _api = api;

  List<SportFriend> get friends => _friends;
  List<SportFriend> get friendRequests => _friendRequests;
  List<SportFriend> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/friends');
      if (res.isSuccess && res.data is List) {
        _friends = (res.data as List).map((e) => SportFriend.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFriendRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.get('/friends/requests');
      if (res.isSuccess && res.data is List) {
        _friendRequests = (res.data as List).map((e) => SportFriend.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchFriends({String? sport, String? location, String? skill, String? query}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (sport != null && sport != 'all') params['sport'] = sport;
      if (location != null) params['location'] = location;
      if (skill != null) params['skill'] = skill;
      if (query != null && query.isNotEmpty) params['query'] = query;
      final res = await _api.get('/friends/search', queryParams: params.isNotEmpty ? params : null);
      if (res.isSuccess && res.data is List) {
        _searchResults = (res.data as List).map((e) => SportFriend.fromJson(e)).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendFriendRequest(int userId) async {
    try {
      final res = await _api.post('/friends/$userId/add');
      if (res.isSuccess) {
        await searchFriends(); // Refresh list
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> acceptFriendRequest(int friendId) async {
    try {
      final res = await _api.post('/friends/$friendId/accept');
      if (res.isSuccess) {
        await loadFriends();
        await loadFriendRequests();
        await searchFriends(); // Refresh search results too
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> removeFriend(int friendId) async {
    try {
      final res = await _api.delete('/friends/$friendId/remove');
      if (res.isSuccess) {
        await loadFriends();
        await loadFriendRequests();
        await searchFriends();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
