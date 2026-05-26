class User {
  final int? id;
  final String email;
  final String passwordHash;
  final String firstName;
  final String lastName;
  final String? phone;
  final String role;
  final String? profilePhoto;
  final String? createdAt;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    this.profilePhoto,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'role': role,
      'profile_photo': profilePhoto,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      passwordHash: map['password_hash'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      phone: map['phone'],
      role: map['role'],
      profilePhoto: map['profile_photo'],
      createdAt: map['created_at'],
    );
  }
}