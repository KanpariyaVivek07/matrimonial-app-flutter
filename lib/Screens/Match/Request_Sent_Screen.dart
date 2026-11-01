import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/Match_Card_Screen.dart';

class RequestSentScreen extends StatefulWidget {
  const RequestSentScreen({super.key});

  @override
  State<RequestSentScreen> createState() => _RequestSentScreenState();
}

class _RequestSentScreenState extends State<RequestSentScreen> {
  List<Map<String, dynamic>> _sentRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  String _searchQuery = "";
  bool _isLoading = true;
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    _loadSentRequests();
  }

  Future<void> _loadSentRequests() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final loadedRequests = [
      {
        "name": "Pooja Mehta",
        "age": "25",
        "city": "Rajkot",
        "education": "MBA",
        "photo": "assets/image/f4.jpeg",
        "status": "Pending",
        "sentDate": DateTime.now().subtract(const Duration(days: 1)),
        "lastActive": "2 hours ago",
      },
      {
        "name": "Ankit Joshi",
        "age": "28",
        "city": "Surat",
        "education": "Engineer",
        "photo": "assets/image/m4.jpeg",
        "status": "Pending",
        "sentDate": DateTime.now().subtract(const Duration(hours: 3)),
        "lastActive": "5 minutes ago",
      },
      {
        "name": "Rahul Sharma",
        "age": "26",
        "city": "Ahmedabad",
        "education": "Doctor",
        "photo": "assets/image/m3.jpeg",
        "status": "Viewed",
        "sentDate": DateTime.now().subtract(const Duration(days: 2)),
        "lastActive": "Yesterday",
      },
    ];

    setState(() {
      _sentRequests = loadedRequests;
      _filteredRequests = loadedRequests;
      _isLoading = false;
      _sortRequests();
    });
  }

  void _filterRequests(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredRequests = _sentRequests
          .where((item) => item['name']!.toLowerCase().contains(_searchQuery))
          .toList();
      _sortRequests();
    });
  }

  void _sortRequests() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _filteredRequests.sort((a, b) => a['name']!.compareTo(b['name']!));
          break;
        case 'age':
          _filteredRequests.sort((a, b) => int.parse(a['age']!).compareTo(int.parse(b['age']!)));
          break;
        case 'date':
        default:
          _filteredRequests.sort((a, b) => b['sentDate'].compareTo(a['sentDate']));
          break;
      }
    });
  }

  void _setSortMethod(String method) {
    setState(() {
      _sortBy = method;
      _sortRequests();
    });
  }

  void _cancelRequest(int index) async {
    final requestToCancel = _filteredRequests[index];
    final prefs = await SharedPreferences.getInstance();
    final cancelledRequests = prefs.getStringList('cancelled_requests') ?? [];

    setState(() {
      _filteredRequests.removeAt(index);
      _sentRequests.removeWhere((req) => req['name'] == requestToCancel['name']);
    });

    await prefs.setStringList(
      'cancelled_requests',
      [...cancelledRequests, requestToCancel['name']],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Request to ${requestToCancel['name']} cancelled"),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            final updatedCancelled = prefs.getStringList('cancelled_requests') ?? [];
            updatedCancelled.remove(requestToCancel['name']);
            await prefs.setStringList('cancelled_requests', updatedCancelled);

            setState(() {
              _sentRequests.add(requestToCancel);
              _filteredRequests = List.from(_sentRequests);
              if (_searchQuery.isNotEmpty) {
                _filterRequests(_searchQuery);
              }
              _sortRequests();
            });
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requests Sent", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: _setSortMethod,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'date',
                child: Text('Sort by Date'),
              ),
              const PopupMenuItem<String>(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<String>(
                value: 'age',
                child: Text('Sort by Age'),
              ),
            ],
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade50,
            child: TextField(
              onChanged: _filterRequests,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  "Sort by: ",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Date', style: TextStyle(color: _sortBy == 'date' ? Colors.white : Colors.deepPurple)),
                  selected: _sortBy == 'date',
                  selectedColor: Colors.deepPurple,
                  onSelected: (selected) => _setSortMethod('date'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Name', style: TextStyle(color: _sortBy == 'name' ? Colors.white : Colors.deepPurple)),
                  selected: _sortBy == 'name',
                  selectedColor: Colors.deepPurple,
                  onSelected: (selected) => _setSortMethod('name'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Age', style: TextStyle(color: _sortBy == 'age' ? Colors.white : Colors.deepPurple)),
                  selected: _sortBy == 'age',
                  selectedColor: Colors.deepPurple,
                  onSelected: (selected) => _setSortMethod('age'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
                : _filteredRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? "No sent requests yet"
                        : "No matches found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_searchQuery.isNotEmpty)
                    Text(
                      "Try a different search term",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredRequests.length,
              itemBuilder: (context, index) {
                final data = _filteredRequests[index];
                return Dismissible(
                  key: Key(data['name']!),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.cancel, color: Colors.white, size: 30),
                  ),
                  onDismissed: (_) => _cancelRequest(index),
                  child: MatchCard(
                    name: data['name']!,
                    age: data['age']!,
                    city: data['city']!,
                    education: data['education']!,
                    photo: data['photo']!,
                    status: data['status']!,
                    subtitle: "Sent on ${_formatDate(data['sentDate'])} • Last active: ${data['lastActive']}",
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/profileDetail',
                      arguments: data,
                    ),
                    onIgnore: () => _cancelRequest(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadSentRequests,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh requests',
      ),
    );
  }
}