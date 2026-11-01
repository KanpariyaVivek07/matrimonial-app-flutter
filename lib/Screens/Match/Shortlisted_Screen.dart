import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widget/Match_Card_Screen.dart';

class ShortlistedScreen extends StatefulWidget {
  const ShortlistedScreen({super.key});

  @override
  State<ShortlistedScreen> createState() => _ShortlistedScreenState();
}

class _ShortlistedScreenState extends State<ShortlistedScreen> {
  List<Map<String, dynamic>> _shortlist = [];
  bool _isLoading = true;
  String _viewMode = 'grid'; // 'grid' or 'list'

  @override
  void initState() {
    super.initState();
    _loadShortlist();
  }

  Future<void> _loadShortlist() async {
    setState(() => _isLoading = true);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final loadedShortlist = [
      {
        "name": "Kavya Desai",
        "age": "24",
        "city": "Jamnagar",
        "education": "BA",
        "photo": "assets/image/f4.jpeg",
        "shortlistedDate": DateTime.now().subtract(const Duration(days: 3)),
        "compatibility": "92%",
      },
      {
        "name": "Nikhil Joshi",
        "age": "29",
        "city": "Anand",
        "education": "IT Professional",
        "photo": "assets/image/m4.jpeg",
        "shortlistedDate": DateTime.now().subtract(const Duration(days: 1)),
        "compatibility": "85%",
      },
      {
        "name": "Meera Patel",
        "age": "26",
        "city": "Gandhinagar",
        "education": "Architect",
        "photo": "assets/image/f5.jpeg",
        "shortlistedDate": DateTime.now().subtract(const Duration(hours: 5)),
        "compatibility": "78%",
      },
      {
        "name": "Rohan Mehta",
        "age": "27",
        "city": "Surat",
        "education": "Business Owner",
        "photo": "assets/image/m5.jpeg",
        "shortlistedDate": DateTime.now().subtract(const Duration(days: 2)),
        "compatibility": "90%",
      },
    ];

    setState(() {
      _shortlist = loadedShortlist;
      _isLoading = false;
    });
  }

  Future<void> _removeFromShortlist(int index) async {
    final removedProfile = _shortlist[index];
    final prefs = await SharedPreferences.getInstance();
    final removedProfiles = prefs.getStringList('removed_from_shortlist') ?? [];

    setState(() {
      _shortlist.removeAt(index);
    });

    await prefs.setStringList(
      'removed_from_shortlist',
      [...removedProfiles, removedProfile['name']],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Removed ${removedProfile['name']} from shortlist"),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            final updatedRemoved = prefs.getStringList('removed_from_shortlist') ?? [];
            updatedRemoved.remove(removedProfile['name']);
            await prefs.setStringList('removed_from_shortlist', updatedRemoved);

            setState(() {
              _shortlist.insert(index, removedProfile);
            });
          },
        ),
      ),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == 'grid' ? 'list' : 'grid';
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildGridCard(Map<String, dynamic> profile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/profileDetail',
          arguments: profile,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    profile['photo']!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      profile['compatibility']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${profile['age']} yrs • ${profile['city']}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile['education']!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Shortlisted on ${_formatDate(profile['shortlistedDate'])}",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shortlisted Profiles", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_viewMode == 'grid' ? Icons.list : Icons.grid_view),
            onPressed: _toggleViewMode,
            tooltip: 'Change view',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadShortlist,
            tooltip: 'Refresh shortlist',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      )
          : _shortlist.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              "No shortlisted profiles yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "When you shortlist profiles you're interested in, they'll appear here",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadShortlist,
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
          : _viewMode == 'grid'
          ? GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: _shortlist.length,
        itemBuilder: (context, index) => Dismissible(
          key: Key(_shortlist[index]['name']!),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          onDismissed: (_) => _removeFromShortlist(index),
          child: _buildGridCard(_shortlist[index]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _shortlist.length,
        itemBuilder: (context, index) {
          final data = _shortlist[index];
          return Dismissible(
            key: Key(data['name']!),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white, size: 30),
            ),
            onDismissed: (_) => _removeFromShortlist(index),
            child: MatchCard(
              name: data['name']!,
              age: data['age']!,
              city: data['city']!,
              education: data['education']!,
              photo: data['photo']!,
              status: data['compatibility']!,
              subtitle: "Shortlisted on ${_formatDate(data['shortlistedDate'])}",
              onTap: () => Navigator.pushNamed(
                context,
                '/profileDetail',
                arguments: data,
              ),
              onIgnore: () => _removeFromShortlist(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action to search for more profiles
          Navigator.pushNamed(context, '/search');
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.search),
        tooltip: 'Search for profiles',
      ),
    );
  }
}