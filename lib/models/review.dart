class Review {
  final int? id;
  final int sessionId;
  final int studentId;
  final int tutorId;
  final int rating;
  final String? comment;
  final String? createdAt;

  Review({
    this.id,
    required this.sessionId,
    required this.studentId,
    required this.tutorId,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'student_id': studentId,
      'tutor_id': tutorId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      sessionId: map['session_id'],
      studentId: map['student_id'],
      tutorId: map['tutor_id'],
      rating: map['rating'],
      comment: map['comment'],
      createdAt: map['created_at'],
    );
  }
}