class TutorProfile {
  final int userId;
  final String? bio;
  final double hourlyRate;
  final int yearsExperience;
  final bool verified;
  final double avgRating;
  final int totalReviews;
  final String? backgroundCheckStatus;
  final String? backgroundCheckDate;
  final String? verificationDocument;
  TutorProfile({
    required this.userId,
    this.bio,
    required this.hourlyRate,
    required this.yearsExperience,
    required this.verified,
    required this.avgRating,
    required this.totalReviews,
    this.backgroundCheckStatus,
    this.backgroundCheckDate,
    this.verificationDocument,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'bio': bio,
      'hourly_rate': hourlyRate,
      'years_experience': yearsExperience,
      'verified': verified ? 1 : 0,
      'avg_rating': avgRating,
      'total_reviews': totalReviews,
      'background_check_status': backgroundCheckStatus,
      'background_check_date': backgroundCheckDate,
      'verification_document': verificationDocument,
    };
  }

  factory TutorProfile.fromMap(Map<String, dynamic> map) {
    return TutorProfile(
      userId: map['user_id'],
      bio: map['bio'],
      hourlyRate: map['hourly_rate'].toDouble(),
      yearsExperience: map['years_experience'],
      verified: map['verified'] == 1,
      avgRating: map['avg_rating'].toDouble(),
      totalReviews: map['total_reviews'],
      backgroundCheckStatus: map['background_check_status'],
      backgroundCheckDate: map['background_check_date'],
      verificationDocument: map['verification_document'],
    );
  }
}