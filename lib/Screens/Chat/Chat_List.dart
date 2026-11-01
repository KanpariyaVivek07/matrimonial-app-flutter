import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Chat_Message_Screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _chats = [];
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkTheme();
  }

  void _checkTheme() {
    final brightness = MediaQuery.of(context).platformBrightness;
    setState(() {
      _isDarkMode = brightness == Brightness.dark;
    });
  }

  Future<void> _loadChats() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('accepted_chats') ?? [];

    final chats = stored.map((entry) {
      final parts = entry.split('|');
      return {
        "name": parts[0],
        "photo": parts[1],
        "lastMessage": parts[2],
        "timestamp": parts[3],
        "unread": int.tryParse(parts[4]) ?? 0,
        "online": true,
      };
    }).toList();

    setState(() {
      _chats = chats;
    });
  }

  void _deleteChat(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedChats = List<String>.from(prefs.getStringList('accepted_chats') ?? []);
    updatedChats.removeAt(index);
    await prefs.setStringList('accepted_chats', updatedChats);

    setState(() {
      _chats.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Chat removed'),
        backgroundColor: _isDarkMode ? Colors.purple.shade700 : Colors.purple.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            await _loadChats();
          },
        ),
      ),
    );
  }

  void _startNewChat() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Start New Chat",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.purple.shade800,
                ),
              ),
              const SizedBox(height: 20),
              _buildContactOption(
                icon: Icons.person_add,
                title: "Add Contact",
                subtitle: "Connect with new people",
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to add contact screen
                },
              ),
              _buildContactOption(
                icon: Icons.group_add,
                title: "Create Group",
                subtitle: "Start a group conversation",
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to create group screen
                },
              ),
              _buildContactOption(
                icon: Icons.qr_code_scanner,
                title: "Scan QR Code",
                subtitle: "Scan to connect instantly",
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to QR scanner
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isDarkMode
                ? [Colors.purple.shade700, Colors.indigo.shade700]
                : [Colors.purple.shade600, Colors.pink.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: _isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      onTap: onTap,
    );
  }

  void _navigateToChatScreen(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatMessageScreen(user: chat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure theme is up to date in case it changed since didChangeDependencies
    final currentBrightness = MediaQuery.of(context).platformBrightness;
    if (_isDarkMode != (currentBrightness == Brightness.dark)) {
      _isDarkMode = currentBrightness == Brightness.dark;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _isDarkMode ? Colors.purple.shade900 : Colors.purple.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(_chats),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.add_comment),
          //   onPressed: _startNewChat,
          // ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _isDarkMode
              ? LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : const LinearGradient(
            colors: [Colors.white, Color(0xFFF5F0FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _chats.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isDarkMode
                        ? [Colors.purple.shade700, Colors.indigo.shade700]
                        : [Colors.purple.shade600, Colors.pink.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "No chats yet",
                style: TextStyle(
                  fontSize: 20,
                  color: _isDarkMode ? Colors.white : Colors.purple.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Start a conversation to begin chatting",
                style: TextStyle(
                  color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _startNewChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDarkMode ? Colors.purple.shade700 : Colors.purple.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Start Chatting"),
              ),
            ],
          ),
        )
            : ListView.separated(
          itemCount: _chats.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          itemBuilder: (context, index) {
            final chat = _chats[index];
            return Dismissible(
              key: Key(chat['name']),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white, size: 28),
              ),
              onDismissed: (_) => _deleteChat(index),
              child: InkWell(
                onTap: () => _navigateToChatScreen(chat),
                splashColor: Colors.purple.withOpacity(0.1),
                highlightColor: Colors.purple.withOpacity(0.05),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Hero(
                            tag: 'avatar-${chat['name']}',
                            child: CircleAvatar(
                              backgroundImage: AssetImage(chat['photo']),
                              radius: 28,
                            ),
                          ),
                          if (chat['online'])
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: _isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chat['lastMessage'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: chat['unread'] > 0
                                    ? (_isDarkMode ? Colors.white : Colors.black87)
                                    : (_isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            chat['timestamp'],
                            style: TextStyle(
                              fontSize: 12,
                              color: chat['unread'] > 0
                                  ? (_isDarkMode ? Colors.purple.shade300 : Colors.purple.shade800)
                                  : (_isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500),
                            ),
                          ),
                          if (chat['unread'] > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isDarkMode
                                      ? [Colors.purple.shade700, Colors.indigo.shade700]
                                      : [Colors.purple.shade600, Colors.pink.shade400],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                chat['unread'].toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: _isDarkMode ? Colors.purple.shade700 : Colors.purple.shade800,
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class ChatSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> chats;

  ChatSearchDelegate(this.chats);

  get userData => null;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = chats.where((chat) {
      return chat['name'].toLowerCase().contains(query.toLowerCase()) ||
          chat['lastMessage'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(results, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = chats.where((chat) {
      return chat['name'].toLowerCase().contains(query.toLowerCase()) ||
          chat['lastMessage'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildSearchResults(results, context);
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results, BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(chat['photo']),
            radius: 24,
          ),
          title: Text(chat['name']),
          subtitle: Text(
            chat['lastMessage'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            chat['timestamp'],
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatMessageScreen(user: userData),
              ),
            );
          },
        );
      },
    );
  }
}