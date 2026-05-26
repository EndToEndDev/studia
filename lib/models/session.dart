class Session {
  final int? id;
  final int studentId;
  final int tutorId;
  final int subjectId;
  final String startDateTime;
  final String endDateTime;
  final String status;
  final String? notes;
  final String? createdAt;
  final String? meetingProvider;
  final String? meetingLink;
  final String? meetingId;
  Session({
    this.id,
    required this.studentId,
    required this.tutorId,
    required this.subjectId,
    required this.startDateTime,
    required this.endDateTime,
    required this.status,
    this.notes,
    this.createdAt,
    this.meetingProvider,
    this.meetingLink,
    this.meetingId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'tutor_id': tutorId,
      'subject_id': subjectId,
      'start_datetime': startDateTime,
      'end_datetime': endDateTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
      'meeting_provider': meetingProvider,
      'meeting_link': meetingLink,
      'meeting_id': meetingId,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      studentId: map['student_id'],
      tutorId: map['tutor_id'],
      subjectId: map['subject_id'],
      startDateTime: map['start_datetime'],
      endDateTime: map['end_datetime'],
      status: map['status'],
      notes: map['notes'],
      createdAt: map['created_at'],
      meetingProvider: map['meeting_provider'],
      meetingLink: map['meeting_link'],
      meetingId: map['meeting_id'],
    );
  }
}