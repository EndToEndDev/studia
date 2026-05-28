import 'package:flutter/material.dart';

import 'lib/test_db.dart';
import 'lib/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TutorLink',
      home: TestDBPage(),
    );
  }
}