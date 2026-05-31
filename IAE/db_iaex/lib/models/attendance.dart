/// Attendance record for activity participants
class AttendanceRecord {
  final int activityId;
  final int userId;
  final String userName;
  final String? userImage;
  String status; // present, absent, late, canceled

  AttendanceRecord({
    required this.activityId,
    required this.userId,
    required this.userName,
    this.userImage,
    this.status = 'present',
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      activityId: json['activity_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String? ?? '',
      userImage: json['user_image'] as String?,
      status: json['status'] as String? ?? 'present',
    );
  }

  Map<String, dynamic> toJson() => {
        'activity_id': activityId,
        'user_id': userId,
        'status': status,
      };
}
