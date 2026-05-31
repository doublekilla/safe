/// Sport friend model — friend search results, friend list items
class SportFriend {
  final int id;
  final String name;
  final String? profileImage;
  final String? location;
  final String? distance;
  final List<String> sports;
  final String? skillLevel;
  final List<String> availability;
  final List<String> joiningPurpose;
  final int? age;
  final String? gender;
  final String friendStatus; // none, pending, accepted
  final int mutualCommunities;
  final List<dynamic> mutualClubs; // Array of maps containing id, name, member_count
  final int activityCount;

  const SportFriend({
    required this.id,
    required this.name,
    this.profileImage,
    this.location,
    this.distance,
    this.sports = const [],
    this.skillLevel,
    this.availability = const [],
    this.joiningPurpose = const [],
    this.age,
    this.gender,
    this.friendStatus = 'none',
    this.mutualCommunities = 0,
    this.mutualClubs = const [],
    this.activityCount = 0,
  });

  factory SportFriend.fromJson(Map<String, dynamic> json) {
    return SportFriend(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
      location: json['location'] as String?,
      distance: json['distance'] as String?,
      sports: (json['sports'] as List?)?.map((e) => e.toString()).toList() ?? [],
      skillLevel: json['skill_level'] as String?,
      availability: (json['availability'] as List?)?.map((e) => e.toString()).toList() ?? [],
      joiningPurpose: (json['joining_purpose'] as List?)?.map((e) => e.toString()).toList() ?? [],
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      friendStatus: json['friend_status'] as String? ?? 'none',
      mutualCommunities: json['mutual_communities'] as int? ?? 0,
      mutualClubs: json['mutual_clubs'] as List<dynamic>? ?? [],
      activityCount: json['activity_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'profile_image': profileImage,
        'location': location, 'distance': distance, 'sports': sports,
        'skill_level': skillLevel, 'availability': availability,
        'joining_purpose': joiningPurpose, 'age': age, 'gender': gender,
        'friend_status': friendStatus, 'mutual_communities': mutualCommunities,
        'mutual_clubs': mutualClubs,
        'activity_count': activityCount,
      };
}
