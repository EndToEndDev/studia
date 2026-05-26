class Availability {
  final int? id;
  final int tutorId;
  final int weekday;
  final String startTime;
  final String endTime;

  Availability({
    this.id,
    required this.tutorId,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  factory Availability.fromMap(Map<String, dynamic> map) {
    return Availability(
      id: map['id'],
      tutorId: map['tutor_id'],
      weekday: map['weekday'],
      startTime: map['start_time'],
      endTime: map['end_time'],
    );
  }
}