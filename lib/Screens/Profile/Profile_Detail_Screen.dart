import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  bool _isLoading = false;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No profile data received.",
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    final data = args;
    final photo = data['photo'] ?? 'assets/default_user.png';

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Profile'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () async {
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(milliseconds: 500));
              setState(() {
                _isFavorite = !_isFavorite;
                _isLoading = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorite
                      ? "Added to favorites"
                      : "Removed from favorites"),
                  backgroundColor: _isFavorite ? Colors.green : Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'profile-${data['id']}',
              child: CircleAvatar(
                radius: 60,
                backgroundImage: photo is String
                    ? AssetImage(photo)
                    : photo as ImageProvider,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              data['name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "${data['age'] ?? '-'} yrs | ${data['city'] ?? '-'}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.school, "Education", data['education'] ?? '-'),
                  const Divider(height: 20),
                  _buildDetailRow(Icons.work, "Occupation", data['occupation'] ?? '-'),
                  const Divider(height: 20),
                  _buildDetailRow(Icons.favorite, "Hobbies", data['hobbies'] ?? '-'),
                  const Divider(height: 20),
                  _buildDetailRow(Icons.info, "About", data['bio'] ?? '-'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.message, color: Colors.white),
                label: const Text("Send Message", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Message sent!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.deepPurple),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}