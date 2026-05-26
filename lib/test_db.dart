import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'models/user.dart';
import 'models/subject.dart';

class TestDBPage extends StatefulWidget {
  const TestDBPage({super.key});

  @override
  State<TestDBPage> createState() => _TestDBPageState();
}

class _TestDBPageState extends State<TestDBPage> {

  String output = "Waiting...";

  @override
  void initState() {
    super.initState();
    runTests();
  }

  Future<void> runTests() async {

    final db = DatabaseHelper.instance;

    // Insert test student
    await db.createUser(
      User(
        email: "student@test.com",
        passwordHash: "123",
        firstName: "John",
        lastName: "Doe",
        role: "student",
      ),
    );

    // Insert test tutor
    await db.createUser(
      User(
        email: "tutor@test.com",
        passwordHash: "456",
        firstName: "Jane",
        lastName: "Smith",
        role: "tutor",
      ),
    );

    // Insert subject
    await db.createSubject(
      Subject(
        name: "Algebra",
      ),
    );

    final users = await db.getAllUsers();
    final subjects = await db.getSubjects();

    setState(() {
      output =
          "Users: ${users.length}\n"
          "Subjects: ${subjects.length}\n\n"
          "${users.map((u) => "${u.firstName} ${u.role}").join("\n")}";
    });

    print(output);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLite Test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(output),
      ),
    );
  }
}