/// Feed post model with likes, comments, tags
class FeedPost {
  final int id;
  final int userId;
  final String userName;
  final String? userImage;
  final int? communityId;
  final String? communityName;
  final String text;
  final String? image;
  final String? tag; // match_result, training_recap, announcement, general
  final int likes;
  final int comments;
  final bool isLiked;
  final String? createdAt;

  const FeedPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    this.communityId,
    this.communityName,
    required this.text,
    this.image,
    this.tag,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.createdAt,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user']?['name'] as String? ?? json['user_name'] as String? ?? 'User',
      userImage: json['user']?['sl_profile']?['profile_image'] as String? ?? json['user']?['avatar'] as String? ?? json['user_image'] as String?,
      communityId: json['community_id'] as int?,
      communityName: json['community']?['name'] as String? ?? json['community_name'] as String?,
      text: json['text'] as String? ?? '',
      image: json['image'] as String?,
      tag: json['tag'] as String?,
      likes: _parseLikes(json),
      comments: json['comments'] as int? ?? json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );
  }

  static int _parseLikes(Map<String, dynamic> json) {
    if (json['likes_count'] != null) return json['likes_count'] as int;
    final likes = json['likes'];
    if (likes is int) return likes;
    if (likes is List) return likes.length;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'user_id': userId, 'community_id': communityId,
        'text': text, 'image': image, 'tag': tag,
      };

  FeedPost copyWith({int? likes, bool? isLiked}) {
    return FeedPost(
      id: id, userId: userId, userName: userName, userImage: userImage,
      communityId: communityId, communityName: communityName, text: text,
      image: image, tag: tag, likes: likes ?? this.likes,
      comments: comments, isLiked: isLiked ?? this.isLiked, createdAt: createdAt,
    );
  }
}
