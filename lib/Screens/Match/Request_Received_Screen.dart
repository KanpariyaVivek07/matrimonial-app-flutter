import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RequestReceivedScreen extends StatefulWidget {
  const RequestReceivedScreen({super.key});

  @override
  State<RequestReceivedScreen> createState() => _RequestReceivedScreenState();
}

class _RequestReceivedScreenState extends State<RequestReceivedScreen> {
  List<Map<String, dynamic>> _requests = [];
  late SharedPreferences _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    _prefs = await SharedPreferences.getInstance();
    final storedData = _prefs.getStringList('ignored_requests') ?? [];

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final allRequests = [
      {
        "name": "Sneha Rana",
        "age": "26",
        "city": "Bhavnagar",
        "education": "Pharmacist",
        "photo": "assets/image/f2.jpeg",
        "about": "I love traveling and trying new foods. Looking for someone who shares similar interests.",
        "hobbies": "Photography, Cooking, Reading",
        "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
        "compatibility": "87%",
      },
      {
        "name": "Manav Parmar",
        "age": "27",
        "city": "Vadodara",
        "education": "CA",
        "photo": "assets/image/m2.jpeg",
        "about": "Finance professional with a passion for music and outdoor activities.",
        "hobbies": "Guitar, Hiking, Chess",
        "timestamp": DateTime.now().subtract(const Duration(days: 1)),
        "compatibility": "92%",
      },
      {
        "name": "Priya Shah",
        "age": "25",
        "city": "Ahmedabad",
        "education": "Software Engineer",
        "photo": "assets/image/f3.jpeg",
        "about": "Tech enthusiast who loves coding and exploring new technologies.",
        "hobbies": "Coding, Dancing, Traveling",
        "timestamp": DateTime.now().subtract(const Duration(hours: 5)),
        "compatibility": "78%",
      },
    ];

    setState(() {
      _requests = allRequests
          .where((req) => !storedData.contains(req['name']))
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _handleAccept(int index) async {
    final acceptedUser = _requests[index];
    final messenger = ScaffoldMessenger.of(context);

    // Show snackbar
    messenger.showSnackBar(
      SnackBar(
        content: Text("You accepted ${acceptedUser['name']}'s request"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );

    // Load existing chats
    final existingChats = _prefs.getStringList('accepted_chats') ?? [];

    // Create new chat string (format: name|photo|lastMessage|timestamp|unreadCount)
    final chatEntry =
        "${acceptedUser['name']}|${acceptedUser['photo']}|Hey! We matched.|${DateFormat('hh:mm a').format(DateTime.now())}|1";

    if (!existingChats.any((entry) => entry.contains(acceptedUser['name']!))) {
      await _prefs.setStringList('accepted_chats', [...existingChats, chatEntry]);
    }

    // Remove user from requests list
    setState(() {
      _requests.removeAt(index);
    });
  }

  void _handleIgnore(int index) {
    final ignoredName = _requests[index]['name'];
    final ignoredRequest = _requests[index];

    // Remove from list
    setState(() {
      _requests.removeAt(index);
    });

    // Save to SharedPreferences
    final currentIgnored = _prefs.getStringList('ignored_requests') ?? [];
    _prefs.setStringList('ignored_requests', [...currentIgnored, ignoredName!]);

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You ignored $ignoredName's request"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            final updatedIgnored = _prefs.getStringList('ignored_requests') ?? [];
            updatedIgnored.remove(ignoredName);
            _prefs.setStringList('ignored_requests', updatedIgnored);

            setState(() {
              _requests.insert(index, ignoredRequest);
            });
          },
        ),
      ),
    );
  }

  String _formatTimeDifference(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildCompatibilityIndicator(String percentage) {
    final value = int.parse(percentage.replaceAll('%', '')) / 100;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 4,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  value > 0.8 ? Colors.green : value > 0.6 ? Colors.orange : Colors.red,
                ),
              ),
            ),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: value > 0.8 ? Colors.green : value > 0.6 ? Colors.orange : Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Match",
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRequests,
            tooltip: 'Refresh requests',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      )
          : _requests.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No requests yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "When someone sends you a request, it will appear here",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          final data = _requests[index];
          return Dismissible(
            key: Key(data['name']!),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _handleIgnore(index),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white, size: 30),
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimeDifference(data['timestamp']),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        _buildCompatibilityIndicator(data['compatibility']!),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Hero(
                        tag: 'profile-${data['name']}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.deepPurple.shade300,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              data['photo']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        data['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        "${data['age']} yrs, ${data['education']} • ${data['city']}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/profileDetail',
                        arguments: data,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        data['about']!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (data['hobbies'] as String)
                          .split(', ')
                          .map((hobby) => Chip(
                        label: Text(
                          hobby,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.deepPurple.shade50,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 20),
                            label: const Text("Accept"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _handleAccept(index),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close, size: 20),
                            label: const Text("Ignore"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade600,
                              side: BorderSide(color: Colors.red.shade600),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _handleIgnore(index),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}