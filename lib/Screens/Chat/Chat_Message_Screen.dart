import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:convert';
import 'dart:math';

class ChatMessageScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatMessageScreen({super.key, required this.user});

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  List<Map<String, dynamic>> _messages = [];
  String _chatKey = 'chat_messages_default';
  bool _isUserTyping = false;
  bool _isPeerTyping = false;
  Map<String, dynamic> _user = {};
  String _selectedMessageId = '';
  String? _replyingTo;
  bool _showEmojiPicker = false;
  bool _isDarkMode = false;

  // Sample responses to simulate a real conversation
  final List<String> _sampleResponses = [
    "Hi there! How are you doing?",
    "That's interesting! Tell me more.",
    "I understand what you mean.",
    "I've been thinking about that too.",
    "What are your plans for the weekend?",
    "That sounds like a great idea!",
    "I'd love to hear more about that.",
    "Thanks for sharing that with me.",
    "I appreciate your perspective.",
    "Let's catch up soon in person!",
    "I've been meaning to ask you about that.",
    "That's amazing! Congratulations!",
    "How was your day?",
    "I'm here if you need to talk.",
    "What do you think about this weather?",
    "Have you seen any good movies lately?",
    "I miss hanging out with you!",
    "We should plan something together soon.",
    "I'm glad we're talking about this.",
    "That's really helpful, thank you!"
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkTheme();
    _user = widget.user;
    final userName = _user['name'] ?? 'default';
    _chatKey = 'chat_messages_${userName.replaceAll(" ", "_")}';
    _loadMessages();
  }

  void _checkTheme() {
    final brightness = MediaQuery.of(context).platformBrightness;
    setState(() {
      _isDarkMode = brightness == Brightness.dark;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _messageController.text.isEmpty) {
      setState(() => _isUserTyping = false);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final messageId = now.microsecondsSinceEpoch.toString();
    final formattedTime = DateFormat('hh:mm a').format(now);

    setState(() {
      _messages.add({
        "id": messageId,
        "text": text,
        "isMe": true,
        "time": formattedTime,
        "status": "sent",
        "reaction": null,
        "replyingTo": _replyingTo,
      });
      _isUserTyping = false;
      _replyingTo = null;
      _showEmojiPicker = false;
    });

    _messageController.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
    _saveMessages();

    // Simulate peer typing and replying with a random response
    setState(() => _isPeerTyping = true);

    // Random delay between 1-3 seconds for more realistic typing
    final randomDelay = Duration(seconds: 1 + Random().nextInt(3));

    Future.delayed(randomDelay, () {
      setState(() {
        _isPeerTyping = false;
        final replyId = DateTime.now().microsecondsSinceEpoch.toString();

        // Select a random response from the sample responses
        final randomResponse = _sampleResponses[Random().nextInt(_sampleResponses.length)];

        _messages.add({
          'id': replyId,
          'text': randomResponse,
          'isMe': false,
          'time': DateFormat('hh:mm a').format(DateTime.now()),
          'status': "read",
          'reaction': null,
          'replyingTo': null,
        });
      });
      _scrollToBottom();
      _saveMessages();
    });
  }

  void _deleteMessage(String messageId) {
    setState(() {
      _messages.removeWhere((msg) => msg['id'] == messageId);
      _selectedMessageId = '';
    });
    _saveMessages();
  }

  void _deleteAllMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatKey);
    setState(() {
      _messages.clear();
    });
  }

  void _addReaction(String messageId, String emoji) {
    setState(() {
      for (var msg in _messages) {
        if (msg['id'] == messageId) {
          msg['reaction'] = msg['reaction'] == emoji ? null : emoji;
          break;
        }
      }
      _selectedMessageId = '';
    });
    _saveMessages();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_messages);
    prefs.setString(_chatKey, encoded);
  }

  void _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMessages = prefs.getString(_chatKey);

    if (storedMessages != null) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(jsonDecode(storedMessages));
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _showMessageOptions(String messageId) {
    final message = _messages.firstWhere((msg) => msg['id'] == messageId);

    setState(() {
      _selectedMessageId = messageId;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.reply, color: _isDarkMode ? Colors.white : Colors.black),
              title: Text('Reply', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _replyingTo = messageId;
                  _focusNode.requestFocus();
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: _isDarkMode ? Colors.white : Colors.black),
              title: Text('Delete', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(messageId);
              },
            ),
            Divider(color: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                children: ['❤️', '😂', '😮', '👍', '😢'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _addReaction(messageId, emoji);
                    },
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReplyPreview() {
    if (_replyingTo == null) return const SizedBox.shrink();

    final repliedMessage = _messages.firstWhere((msg) => msg['id'] == _replyingTo);
    final isMeReplying = repliedMessage['isMe'];

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            color: isMeReplying
                ? (_isDarkMode ? Colors.purple.shade300 : Colors.purple.shade700)
                : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMeReplying ? 'You' : _user['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  repliedMessage['text'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: _isDarkMode ? Colors.white : Colors.black),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
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

    final String userName = _user['name'] ?? 'Unknown User';
    final String userPhoto = _user['photo'] ?? 'assets/default_user.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.purple.shade900 : Colors.purple.shade800,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'avatar-${_user['name']}',
              child: CircleAvatar(
                backgroundImage: AssetImage(userPhoto),
                radius: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(fontSize: 18, color: Colors.white)),
                Text(
                  _isPeerTyping ? 'typing...' : 'online',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              // Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {
              // Implement voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.person, color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('View Profile', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/profileDetail',
                            arguments: _user,
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.photo_library, color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('Media & Files', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          Navigator.pop(context);
                          // Implement media view
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.notifications, color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('Mute Notifications', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          Navigator.pop(context);
                          // Implement mute notifications
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete Chat', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteChatConfirmation();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _selectedMessageId = '';
            _showEmojiPicker = false;
          });
        },
        child: Container(
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
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
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
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Start a conversation with ${_user['name']}',
                        style: TextStyle(
                          color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isMe = message['isMe'] as bool;
                    final isSelected = message['id'] == _selectedMessageId;

                    return Column(
                      children: [
                        if (message['replyingTo'] != null)
                          Padding(
                            padding: EdgeInsets.only(
                              left: isMe ? 60 : 12,
                              right: isMe ? 12 : 60,
                              top: 8,
                            ),
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Replying to: ${_messages.firstWhere((m) => m['id'] == message['replyingTo'])['text']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        GestureDetector(
                          onLongPress: () => _showMessageOptions(message['id']),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? (_isDarkMode ? Colors.blue.shade800 : Colors.blue.shade100)
                                        : isMe
                                        ? (_isDarkMode ? Colors.purple.shade700 : Colors.purple.shade100)
                                        : (_isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                                      bottomRight: Radius.circular(isMe ? 4 : 16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        message['text'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            message['time'] ?? '',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              message['status'] == 'read'
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              size: 12,
                                              color: message['status'] == 'read'
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (message['reaction'] != null)
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: _isDarkMode ? Colors.grey.shade700 : Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              message['reaction'],
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (_replyingTo != null) _buildReplyPreview(),
              if (_showEmojiPicker)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      setState(() {
                        _messageController.text += emoji.emoji;
                      });
                    },
                    // config: Config(
                    //   bgColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
                    //   indicatorColor: _isDarkMode ? Colors.purple.shade700 : Colors.purple.shade800,
                    //   iconColor: _isDarkMode ? Colors.grey.shade400 : Colors.grey,
                    //   iconColorSelected: _isDarkMode ? Colors.purple.shade300 : Colors.purple.shade700,
                    //   skinToneDialogBgColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                    //   skinToneIndicatorColor: _isDarkMode ? Colors.grey.shade400 : Colors.grey,
                    //   enableSkinTones: true,
                    //   recentTabBehavior: RecentTabBehavior.RECENT,
                    //   recentsLimit: 28,
                    //   replaceEmojiOnLimitExceed: false,
                    //   noRecents: Text(
                    //     'No Recents',
                    //     style: TextStyle(
                    //       fontSize: 20,
                    //       color: _isDarkMode ? Colors.grey.shade400 : Colors.black26,
                    //     ),
                    //   ),
                    //   loadingIndicator: const SizedBox.shrink(),
                    //   categoryIcons: const CategoryIcons(),
                    //   buttonMode: ButtonMode.MATERIAL,
                    // ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined),
                      color: _showEmojiPicker
                          ? (_isDarkMode ? Colors.purple.shade300 : Colors.purple.shade800)
                          : (_isDarkMode ? Colors.grey.shade400 : Colors.grey),
                      onPressed: () {
                        setState(() {
                          _showEmojiPicker = !_showEmojiPicker;
                          if (_showEmojiPicker) {
                            FocusScope.of(context).unfocus();
                          } else {
                            FocusScope.of(context).requestFocus(_focusNode);
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file),
                      color: _isDarkMode ? Colors.grey.shade400 : Colors.grey,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.image, color: _isDarkMode ? Colors.white : Colors.black),
                                  title: Text('Gallery', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Implement image picker
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.camera_alt, color: _isDarkMode ? Colors.white : Colors.black),
                                  title: Text('Camera', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Implement camera functionality
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.attach_file, color: _isDarkMode ? Colors.white : Colors.black),
                                  title: Text('Document', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Implement document picker
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.location_on, color: _isDarkMode ? Colors.white : Colors.black),
                                  title: Text('Location', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Implement location sharing
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        onChanged: (val) {
                          setState(() {
                            _isUserTyping = val.trim().isNotEmpty;
                          });
                        },
                        style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: _isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isUserTyping ? Icons.send : Icons.mic,
                        color: _isUserTyping
                            ? (_isDarkMode ? Colors.purple.shade300 : Colors.purple.shade800)
                            : (_isDarkMode ? Colors.grey.shade400 : Colors.grey),
                      ),
                      onPressed: _isUserTyping ? _sendMessage : () {
                        // Implement voice recording
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteChatConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Chat',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
          ),
          content: Text(
            'Are you sure you want to delete this chat? All messages will be permanently removed.',
            style: TextStyle(color: _isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
          backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: _isDarkMode ? Colors.purple.shade300 : Colors.purple.shade700),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteAllMessages();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chat deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}