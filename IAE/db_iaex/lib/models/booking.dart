/// Court booking model — linked to EithSpace venue
class Booking {
  final int id;
  final int venueId;
  final String venueName;
  final String? address;
  final String sportType;
  final int? userId;
  final int? activityId;
  final String? selectedDate;
  final String? selectedTime;
  final int duration; // hours
  final double pricePerHour;
  final double totalCost;
  final String status; // pending, confirmed, completed, canceled
  final double rating;
  final String? distance;
  final int? linkedActivityId;

  const Booking({
    this.id = 0,
    required this.venueId,
    required this.venueName,
    this.address,
    this.sportType = '',
    this.userId,
    this.activityId,
    this.selectedDate,
    this.selectedTime,
    this.duration = 1,
    this.pricePerHour = 0,
    this.totalCost = 0,
    this.status = 'pending',
    this.rating = 0,
    this.distance,
    this.linkedActivityId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int? ?? 0,
      venueId: json['venue_id'] as int? ?? 0,
      venueName: json['venue_name'] as String? ?? '',
      address: json['address'] as String?,
      sportType: json['sport_type'] as String? ?? '',
      userId: json['user_id'] as int?,
      activityId: json['activity_id'] as int?,
      selectedDate: json['selected_date'] as String?,
      selectedTime: json['selected_time'] as String?,
      duration: json['duration'] as int? ?? 1,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      distance: json['distance'] as String?,
      linkedActivityId: json['linked_activity_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'venue_id': venueId, 'venue_name': venueName,
        'address': address, 'sport_type': sportType, 'user_id': userId,
        'activity_id': activityId, 'selected_date': selectedDate,
        'selected_time': selectedTime, 'duration': duration,
        'price_per_hour': pricePerHour, 'total_cost': totalCost,
        'status': status, 'linked_activity_id': linkedActivityId,
      };
}
