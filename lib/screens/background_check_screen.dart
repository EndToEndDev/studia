import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/tutor_profile.dart';

class BackgroundCheckScreen extends StatefulWidget {
  const BackgroundCheckScreen({super.key});

  @override
  State<BackgroundCheckScreen> createState() => _BackgroundCheckScreenState();
}

class _BackgroundCheckScreenState extends State<BackgroundCheckScreen> {
  late Future<List<TutorProfile>> _tutorProfiles;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadTutorProfiles();
  }

  void _loadTutorProfiles() {
    _tutorProfiles = DatabaseHelper.instance.getAllTutorProfiles();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Check Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filter by Status:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                        value: 'Completed',
                        child: Text('Completed'),
                      ),
                      DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'Failed', child: Text('Failed')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TutorProfile>>(
              future: _tutorProfiles,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tutor profiles found'));
                }

                final profiles = snapshot.data!;
                final filteredProfiles = _selectedStatus == 'All'
                    ? profiles
                    : profiles
                        .where((p) =>
                            p.backgroundCheckStatus == _selectedStatus ||
                            (p.backgroundCheckStatus == null &&
                                _selectedStatus == 'Pending'))
                        .toList();

                return ListView.builder(
                  itemCount: filteredProfiles.length,
                  itemBuilder: (context, index) {
                    final profile = filteredProfiles[index];
                    return TutorBackgroundCheckCard(
                      profile: profile,
                      onStatusUpdated: _loadTutorProfiles,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TutorBackgroundCheckCard extends StatelessWidget {
  final TutorProfile profile;
  final VoidCallback onStatusUpdated;

  const TutorBackgroundCheckCard({
    super.key,
    required this.profile,
    required this.onStatusUpdated,
  });

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Failed':
        return Colors.red;
      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BackgroundCheckDetailScreen(
                profile: profile,
                onStatusUpdated: onStatusUpdated,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tutor ID: ${profile.userId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hourly Rate: \$${profile.hourlyRate.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Years of Experience: ${profile.yearsExperience}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(profile.backgroundCheckStatus),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profile.backgroundCheckStatus ?? 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (profile.backgroundCheckDate != null)
                Text(
                  'Check Date: ${profile.backgroundCheckDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              if (profile.verificationDocument != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Document: ${profile.verificationDocument}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Update'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BackgroundCheckDetailScreen(
                            profile: profile,
                            onStatusUpdated: onStatusUpdated,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackgroundCheckDetailScreen extends StatefulWidget {
  final TutorProfile profile;
  final VoidCallback onStatusUpdated;

  const BackgroundCheckDetailScreen({
    super.key,
    required this.profile,
    required this.onStatusUpdated,
  });

  @override
  State<BackgroundCheckDetailScreen> createState() =>
      _BackgroundCheckDetailScreenState();
}

class _BackgroundCheckDetailScreenState
    extends State<BackgroundCheckDetailScreen> {
  late String _selectedStatus;
  late TextEditingController _documentController;
  late TextEditingController _bioController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.profile.backgroundCheckStatus ?? 'Pending';
    _documentController =
        TextEditingController(text: widget.profile.verificationDocument);
    _bioController = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _documentController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedProfile = TutorProfile(
        userId: widget.profile.userId,
        bio: _bioController.text,
        hourlyRate: widget.profile.hourlyRate,
        yearsExperience: widget.profile.yearsExperience,
        verified: widget.profile.verified,
        avgRating: widget.profile.avgRating,
        totalReviews: widget.profile.totalReviews,
        backgroundCheckStatus: _selectedStatus,
        backgroundCheckDate: DateTime.now().toIso8601String(),
        verificationDocument:
            _documentController.text.isEmpty ? null : _documentController.text,
      );

      await DatabaseHelper.instance.updateTutorProfile(updatedProfile);

      if (mounted) {
        widget.onStatusUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Check Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tutor Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Tutor ID: ${widget.profile.userId}'),
                    Text(
                      'Hourly Rate: \$${widget.profile.hourlyRate.toStringAsFixed(2)}',
                    ),
                    Text(
                      'Years of Experience: ${widget.profile.yearsExperience}',
                    ),
                    Text('Verified: ${widget.profile.verified ? 'Yes' : 'No'}'),
                    Text('Average Rating: ${widget.profile.avgRating}'),
                    Text('Total Reviews: ${widget.profile.totalReviews}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Background Check Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                DropdownMenuItem(value: 'Failed', child: Text('Failed')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _documentController,
              decoration: const InputDecoration(
                labelText: 'Verification Document Path',
                hintText: 'e.g., /uploads/tutor_101_verification.pdf',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
