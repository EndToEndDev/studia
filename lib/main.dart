import 'package:flutter/material.dart';

import 'screens/paypal_checkout_screen.dart';
import 'screens/stripe_checkout_screen.dart';

void main() {
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double sessionAmount = 30.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Tutor Session'),
      ),
      body: Padding(
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
                      content: Text('Session booked successfully via PayPal!'),
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
                    ),
                  ),
                );

                if (result == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session booked successfully via Stripe!'),
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
      ),
    );
  }
}