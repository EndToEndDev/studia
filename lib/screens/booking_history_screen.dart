import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/session.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late Future<List<Session>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = DatabaseHelper.instance.getSessionsForStudent(1);
  }

  String _formatDateTime(String iso) {
    try {
      final dateTime = DateTime.parse(iso);
      return '${dateTime.toLocal()}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: FutureBuilder<List<Session>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Unable to load booking history:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(
              child: Text('No bookings found yet.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tutor ID: ${session.tutorId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Subject ID: ${session.subjectId}'),
                      const SizedBox(height: 4),
                      Text('Status: ${session.status}'),
                      const SizedBox(height: 4),
                      Text('Start: ${_formatDateTime(session.startDateTime)}'),
                      const SizedBox(height: 4),
                      Text('End: ${_formatDateTime(session.endDateTime)}'),
                      const SizedBox(height: 4),
                      Text('Payment: ${session.meetingProvider ?? 'Unknown'}'),
                      if (session.meetingId != null) ...[
                        const SizedBox(height: 4),
                        Text('Payment ID: ${session.meetingId}'),
                      ],
                      if (session.notes != null) ...[
                        const SizedBox(height: 4),
                        Text('Notes: ${session.notes}'),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
