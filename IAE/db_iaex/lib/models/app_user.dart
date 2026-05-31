/// User model — shared auth (db_iae.users) + SpaceLink profile (sl_user_profiles)
class AppUser {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final String? location;
  final List<String> favoriteSports;
  final String? skillLevel;
  final List<String> availability;
  final List<String> joiningPurpose;
  final String? bio;
  final int? age;
  final String? gender;
  final String role;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    this.location,
    this.favoriteSports = const [],
    this.skillLevel,
    this.availability = const [],
    this.joiningPurpose = const [],
    this.bio,
    this.age,
    this.gender,
    this.role = 'customer',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final sl = json['sl_profile'] as Map<String, dynamic>? ?? {};
    return AppUser(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      profileImage: json['profile_image'] as String? ?? sl['profile_image'] as String?,
      location: json['location'] as String? ?? sl['location'] as String?,
      favoriteSports: _toStringList(json['favorite_sports'] ?? sl['favorite_sports']),
      skillLevel: json['skill_level'] as String? ?? sl['skill_level'] as String?,
      availability: _toStringList(json['availability'] ?? sl['availability']),
      joiningPurpose: _toStringList(json['joining_purpose'] ?? sl['joining_purpose']),
      bio: json['bio'] as String? ?? sl['bio'] as String?,
      age: json['age'] as int? ?? sl['age'] as int?,
      gender: json['gender'] as String? ?? sl['gender'] as String?,
      role: json['role'] as String? ?? 'customer',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'profile_image': profileImage,
        'location': location,
        'favorite_sports': favoriteSports,
        'skill_level': skillLevel,
        'availability': availability,
        'joining_purpose': joiningPurpose,
        'bio': bio,
        'age': age,
        'gender': gender,
        'role': role,
      };

  AppUser copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
    String? location,
    List<String>? favoriteSports,
    String? skillLevel,
    List<String>? availability,
    List<String>? joiningPurpose,
    String? bio,
    int? age,
    String? gender,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      favoriteSports: favoriteSports ?? this.favoriteSports,
      skillLevel: skillLevel ?? this.skillLevel,
      availability: availability ?? this.availability,
      joiningPurpose: joiningPurpose ?? this.joiningPurpose,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      role: role,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}
