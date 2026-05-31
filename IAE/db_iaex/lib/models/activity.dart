/// Activity / Event model with RSVP participant lists
class Activity {
  final int id;
  final String title;
  final String sportType;
  final String? activityType;
  final String? location;
  final String? date;
  final String? time;
  final int quota;
  final int currentParticipants;
  final double cost;
  final String? skillLevel;
  final int? hostUserId;
  final String? hostName;
  final String? hostProfileImage;
  final int? communityId;
  final String? communityName;
  final String? notes;
  final String status; // available, full, completed, canceled
  final List<int> confirmedParticipants;
  final List<int> waitingList;
  final List<ActivityParticipant> participants;
  final bool canJoin;

  const Activity({
    required this.id,
    required this.title,
    required this.sportType,
    this.activityType,
    this.location,
    this.date,
    this.time,
    this.quota = 10,
    this.currentParticipants = 0,
    this.cost = 0,
    this.skillLevel,
    this.hostUserId,
    this.hostName,
    this.hostProfileImage,
    this.communityId,
    this.communityName,
    this.notes,
    this.status = 'available',
    this.confirmedParticipants = const [],
    this.waitingList = const [],
    this.participants = const [],
    this.canJoin = true,
  });

  int get remainingSlots => quota - currentParticipants;

  factory Activity.fromJson(Map<String, dynamic> json) {
    double parsedCost = 0;
    if (json['cost'] != null) {
      if (json['cost'] is num) {
        parsedCost = (json['cost'] as num).toDouble();
      } else if (json['cost'] is String) {
        parsedCost = double.tryParse(json['cost']) ?? 0;
      }
    }

    List<ActivityParticipant> parts = [];
    List<int> confirmed = [];
    List<int> waiting = [];
    
    if (json['participants'] != null && json['participants'] is List) {
      for (var p in json['participants']) {
        final part = ActivityParticipant.fromJson(p);
        parts.add(part);
        if (part.status == 'confirmed') {
          confirmed.add(part.userId);
        } else if (part.status == 'pending' || part.status == 'waiting') {
          waiting.add(part.userId);
        }
      }
    }

    return Activity(
      id: _toInt(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      sportType: json['sport_type']?.toString() ?? '',
      activityType: json['activity_type']?.toString(),
      location: json['location']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      quota: _toInt(json['quota']) ?? 10,
      currentParticipants: _toInt(json['current_participants']) ?? 0,
      cost: parsedCost,
      skillLevel: json['skill_level']?.toString(),
      hostUserId: _toInt(json['host_user_id']),
      hostName: (json['host'] != null && json['host'] is Map) ? json['host']['name']?.toString() : json['host_name']?.toString(),
      hostProfileImage: (json['host'] != null && json['host'] is Map) 
          ? ((json['host']['sl_profile'] != null && json['host']['sl_profile'] is Map && json['host']['sl_profile']['profile_image'] != null)
              ? json['host']['sl_profile']['profile_image']?.toString()
              : json['host']['avatar']?.toString())
          : null,
      communityId: _toInt(json['community_id']),
      communityName: (json['community'] != null && json['community'] is Map) ? json['community']['name']?.toString() : json['community_name']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'available',
      confirmedParticipants: confirmed,
      waitingList: waiting,
      participants: parts,
      canJoin: json['can_join'] as bool? ?? true,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'sport_type': sportType,
        'activity_type': activityType, 'location': location,
        'date': date, 'time': time, 'quota': quota,
        'current_participants': currentParticipants, 'cost': cost,
        'skill_level': skillLevel, 'host_user_id': hostUserId,
        'community_id': communityId, 'notes': notes, 'status': status,
      };
}

class ActivityParticipant {
  final int id;
  final int userId;
  final String status;
  final String name;
  final String? profileImage;

  ActivityParticipant({
    required this.id,
    required this.userId,
    required this.status,
    required this.name,
    this.profileImage,
  });

  factory ActivityParticipant.fromJson(Map<String, dynamic> json) {
    String? pImage;
    if (json['user'] != null && json['user'] is Map) {
      final u = json['user'];
      pImage = (u['sl_profile'] != null && u['sl_profile'] is Map && u['sl_profile']['profile_image'] != null)
          ? u['sl_profile']['profile_image']?.toString()
          : u['avatar']?.toString();
    }
    
    return ActivityParticipant(
      id: Activity._toInt(json['id']) ?? 0,
      userId: Activity._toInt(json['user_id']) ?? 0,
      status: json['status']?.toString() ?? 'confirmed',
      name: (json['user'] != null && json['user'] is Map) ? json['user']['name']?.toString() ?? 'Unknown User' : 'Unknown User',
      profileImage: pImage,
    );
  }
}
