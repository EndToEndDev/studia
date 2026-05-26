import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../models/tutor_profile.dart';
import '../models/subject.dart';
import '../models/availability.dart';
import '../models/session.dart';
import '../models/message.dart';
import '../models/review.dart';

class DatabaseHelper {
  static const _databaseName = "tutorlink.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(
      await getDatabasesPath(),
      _databaseName,
    );

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL,
        profile_photo TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE tutor_profiles(
        user_id INTEGER PRIMARY KEY,
        bio TEXT,
        hourly_rate REAL NOT NULL,
        years_experience INTEGER,
        verified INTEGER,
        avg_rating REAL,
        total_reviews INTEGER,
        background_check_status TEXT,
        background_check_date TEXT,
        verification_document TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE availability(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tutor_id INTEGER NOT NULL,
        weekday INTEGER NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        tutor_id INTEGER NOT NULL,
        subject_id INTEGER NOT NULL,
        start_datetime TEXT NOT NULL,
        end_datetime TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        meeting_provider TEXT,
        meeting_link TEXT,
        meeting_id TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_id INTEGER NOT NULL,
        receiver_id INTEGER NOT NULL,
        body TEXT NOT NULL,
        sent_at TEXT DEFAULT CURRENT_TIMESTAMP,
        read_flag INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        read_flag INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER UNIQUE,
        student_id INTEGER NOT NULL,
        tutor_id INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE api_credentials(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        service_name TEXT NOT NULL,
        api_key TEXT NOT NULL,
        encrypted INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  //////////////////////////////////////////////////////
  // USERS
  //////////////////////////////////////////////////////

  Future<int> createUser(User user) async {
    final db = await database;

    return db.insert(
      'users',
      user.toMap(),
    );
  }
  

  Future<User?> getUser(int id) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;

    return User.fromMap(result.first);
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;

    final result = await db.query('users');

    return result
        .map((e) => User.fromMap(e))
        .toList();
  }

  Future<int> updateUser(User user) async {
    final db = await database;

    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;

    return db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //////////////////////////////////////////////////////
  // SUBJECTS
  //////////////////////////////////////////////////////

  Future<int> createSubject(Subject subject) async {
    final db = await database;

    return db.insert(
      'subjects',
      subject.toMap(),
    );
  }

  Future<List<Subject>> getSubjects() async {
    final db = await database;

    final result = await db.query('subjects');

    return result
        .map((e) => Subject.fromMap(e))
        .toList();
  }

  //////////////////////////////////////////////////////
  // TUTOR PROFILE
  //////////////////////////////////////////////////////

  Future<int> createTutorProfile(
      TutorProfile profile) async {

    final db = await database;

    return db.insert(
      'tutor_profiles',
      profile.toMap(),
    );
  }

  //////////////////////////////////////////////////////
  // AVAILABILITY
  //////////////////////////////////////////////////////

  Future<int> createAvailability(
      Availability availability) async {

    final db = await database;

    return db.insert(
      'availability',
      availability.toMap(),
    );
  }

  Future<List<Availability>>
      getTutorAvailability(int tutorId) async {

    final db = await database;

    final result = await db.query(
      'availability',
      where: 'tutor_id = ?',
      whereArgs: [tutorId],
    );

    return result
        .map((e) => Availability.fromMap(e))
        .toList();
  }

  //////////////////////////////////////////////////////
  // SESSIONS
  //////////////////////////////////////////////////////

  Future<int> createSession(
      Session session) async {

    final db = await database;

    return db.insert(
      'sessions',
      session.toMap(),
    );
  }

  Future<List<Session>>
      getTutorSessions(int tutorId) async {

    final db = await database;

    final result = await db.query(
      'sessions',
      where: 'tutor_id = ?',
      whereArgs: [tutorId],
    );

    return result
        .map((e) => Session.fromMap(e))
        .toList();
  }

  //////////////////////////////////////////////////////
  // MESSAGES
  //////////////////////////////////////////////////////

  Future<int> createMessage(
      Message message) async {

    final db = await database;

    return db.insert(
      'messages',
      message.toMap(),
    );
  }

  Future<List<Message>>
      getConversation(
      int user1,
      int user2) async {

    final db = await database;

    final result = await db.rawQuery('''
      SELECT * FROM messages
      WHERE
      (sender_id = ? AND receiver_id = ?)
      OR
      (sender_id = ? AND receiver_id = ?)
      ORDER BY sent_at ASC
    ''', [
      user1,
      user2,
      user2,
      user1,
    ]);

    return result
        .map((e) => Message.fromMap(e))
        .toList();
  }

  //////////////////////////////////////////////////////
  // REVIEWS
  //////////////////////////////////////////////////////

  Future<int> createReview(
      Review review) async {

    final db = await database;

    return db.insert(
      'reviews',
      review.toMap(),
    );
  }

  Future<List<Review>>
      getTutorReviews(int tutorId) async {

    final db = await database;

    final result = await db.query(
      'reviews',
      where: 'tutor_id = ?',
      whereArgs: [tutorId],
    );

    return result
        .map((e) => Review.fromMap(e))
        .toList();
  }
}