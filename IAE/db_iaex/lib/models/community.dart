import '../core/constants/app_constants.dart';

/// Community model
class Community {
  final int id;
  final String name;
  final String sportCategory;
  final String? location;
  final String? description;
  final String? rules;
  final String? image;
  final String privacy; // public, private
  final int adminUserId;
  final String? adminName;
  final int memberCount;
  final String? activityFrequency;
  final bool isJoined;

  final List<CommunityMember> members;

  const Community({
    required this.id,
    required this.name,
    required this.sportCategory,
    this.location,
    this.description,
    this.rules,
    this.image,
    this.privacy = 'public',
    required this.adminUserId,
    this.adminName,
    this.memberCount = 0,
    this.activityFrequency,
    this.isJoined = false,
    this.members = const [],
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String? ?? '',
      sportCategory: json['sport_category'] as String? ?? '',
      location: json['location'] as String?,
      description: json['description'] as String?,
      rules: json['rules'] as String?,
      image: (json['image'] as String?)?.startsWith('/storage') == true 
          ? '${AppConstants.apiBaseUrl.replaceAll('/api', '')}${json['image']}' 
          : json['image'] as String?,
      privacy: json['privacy'] as String? ?? 'public',
      adminUserId: json['admin_user_id'] is int ? json['admin_user_id'] as int : int.tryParse(json['admin_user_id']?.toString() ?? '') ?? 0,
      adminName: json['admin_name'] as String?,
      memberCount: json['member_count'] is int ? json['member_count'] as int : (json['members_count'] is int ? json['members_count'] as int : int.tryParse(json['member_count']?.toString() ?? json['members_count']?.toString() ?? '') ?? 0),
      activityFrequency: json['activity_frequency'] as String?,
      isJoined: json['is_joined'] as bool? ?? false,
      members: (json['members'] as List?)?.map((e) => CommunityMember.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'sport_category': sportCategory,
        'location': location, 'description': description, 'rules': rules,
        'image': image, 'privacy': privacy, 'admin_user_id': adminUserId,
        'admin_name': adminName, 'member_count': memberCount,
        'activity_frequency': activityFrequency, 'is_joined': isJoined,
        'members': members.map((e) => e.toJson()).toList(),
      };
}

class CommunityMember {
  final int id;
  final String name;
  final String? avatar;
  final String? role;

  const CommunityMember({
    required this.id,
    required this.name,
    this.avatar,
    this.role,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> userMap = json;
    String? role = json['pivot']?['role'] as String?;
    int userId = json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0;

    if (json['user'] != null && json['user'] is Map) {
      userMap = json['user'];
      role = json['role'] as String? ?? role;
      userId = userMap['id'] is int ? userMap['id'] as int : int.tryParse(userMap['id']?.toString() ?? '') ?? 0;
    }

    String? pImage = userMap['avatar']?.toString();
    if (userMap['sl_profile'] != null && userMap['sl_profile'] is Map && userMap['sl_profile']['profile_image'] != null) {
      pImage = userMap['sl_profile']['profile_image']?.toString();
    }
    
    return CommunityMember(
      id: userId,
      name: userMap['name'] as String? ?? 'Unknown',
      avatar: pImage,
      role: role,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatar': avatar,
        'pivot': {'role': role},
      };
}
