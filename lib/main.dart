import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'database/database_helper.dart';
import 'screens/background_check_screen.dart';
import 'screens/paypal_checkout_screen.dart';
import 'screens/stripe_checkout_screen.dart';

// Entrypoint hint for debugging tools that expect a `program` identifier.
const String program = 'lib/main.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
  
  await DatabaseHelper.instance.initializeSampleData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studia Tutor Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studia Tutor Platform'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(icon: Icon(Icons.book), text: 'Book Session'),
            Tab(icon: Icon(Icons.verified_user), text: 'Background Checks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BookingSessionTab(),
          BackgroundCheckScreen(),
        ],
      ),
    );
  }
}

class BookingSessionTab extends StatelessWidget {
  const BookingSessionTab({super.key});

  static const double sessionAmount = 30.00;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tutor session details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Tutor: Anna Kowalska'),
          const Text('Subject: Mathematics'),
          const Text('Duration: 60 minutes'),
          const Text('Price: USD 30.00'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('Pay with PayPal'),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const PayPalCheckoutScreen(
                    amount: sessionAmount,
                    currency: 'USD',
                    description: 'Math tutoring session (60 min)',
                    studentId: 1,
                    tutorId: 101,
                    subjectId: 1,
                  ),
                ),
              );

              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Session booked successfully via PayPal!'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.credit_card),
            label: const Text('Pay with Stripe'),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => const StripeCheckoutScreen(
                    amount: sessionAmount,
                    currency: 'usd',
                    description: 'Math tutoring session (60 min)',
                    studentId: 1,
                    tutorId: 101,
                    subjectId: 1,
                  ),
                ),
              );

              if (result == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Session booked successfully via Stripe!'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'This sample app uses the PayPal Orders API to create a checkout order, open an approval page, and capture payment after approval.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}