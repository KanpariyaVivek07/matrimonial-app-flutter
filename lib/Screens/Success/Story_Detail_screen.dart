import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class StoryDetailScreen extends StatelessWidget {
  final Map<String, String> story;

  const StoryDetailScreen({super.key, required this.story});

  void _shareStory(BuildContext context) {
    Share.share(
      "${story['name']} from ${story['city']}:\n\n${story['desc']!}\n\nShared via Matrimony App ❤️",
    );
  }

  void _openZoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: PhotoView(
              imageProvider: AssetImage(story['photo']!),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(story['name']!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white), // This makes the back icon white
      ),
      body: Column(
        children: [
          // 📸 Tap-to-zoom
          GestureDetector(
            onTap: () => _openZoom(context),
            child: Hero(
              tag: story['photo']!,
              child: Image.asset(
                story['photo']!,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xfffceabb)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story['name']!,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.location_city, "City: ${story['city']!}"),
                    _buildInfoRow(Icons.calendar_today, "Wedding Date: June 12, 2023"),
                    _buildInfoRow(Icons.favorite, "Together for 2 years"),
                    const SizedBox(height: 20),
                    const Text(
                      "Their Story:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      story['desc']!,
                      style: const TextStyle(fontSize: 18, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Advice for Others:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Trust the process and be patient. True love comes when you least expect it!",
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _shareStory(context),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }
}