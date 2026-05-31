import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../core/services/api_client.dart';

/// Feed state management
class FeedProvider extends ChangeNotifier {
  final ApiClient _api;
  List<FeedPost> _posts = [];
  bool _isLoading = false;

  FeedProvider({required ApiClient api}) : _api = api;

  List<FeedPost> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> loadFeed({int? communityId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final params = <String, String>{};
      if (communityId != null) params['community_id'] = communityId.toString();
      final res = await _api.get('/feed', queryParams: params.isNotEmpty ? params : null);
      if (res.isSuccess) {
        if (res.data is List) {
          _posts = (res.data as List).map((e) => FeedPost.fromJson(e)).toList();
        } else if (res.data is Map && res.data['data'] is List) {
          _posts = (res.data['data'] as List).map((e) => FeedPost.fromJson(e)).toList();
        }
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createPost({required String text, int? communityId, String? tag, String? imagePath}) async {
    try {
      if (imagePath != null) {
        final fields = <String, String>{'text': text};
        if (communityId != null) fields['community_id'] = communityId.toString();
        if (tag != null) fields['tag'] = tag;
        
        debugPrint('Creating post with image');
        final res = await _api.postMultipart('/feed', fields: fields, fileField: 'image', filePath: imagePath);
        debugPrint('Create post multipart response: ${res.statusCode} ${res.body}');
        if (res.isSuccess) {
          await loadFeed(communityId: communityId);
          return true;
        }
      } else {
        final body = <String, dynamic>{'text': text};
        if (communityId != null) body['community_id'] = communityId;
        if (tag != null) body['tag'] = tag;
        debugPrint('Creating post with body: $body');
        final res = await _api.post('/feed', body: body);
        debugPrint('Create post response: ${res.statusCode} ${res.body}');
        if (res.isSuccess) {
          await loadFeed(communityId: communityId);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Create post exception: $e');
    }
    return false;
  }

  void toggleLike(int postId) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    final post = _posts[index];
    _posts[index] = post.copyWith(
      isLiked: !post.isLiked,
      likes: post.isLiked ? post.likes - 1 : post.likes + 1,
    );
    notifyListeners();
    // Optimistic — fire API in background
    if (_posts[index].isLiked) {
      _api.post('/feed/$postId/like');
    } else {
      _api.post('/feed/$postId/unlike');
    }
  }
}
