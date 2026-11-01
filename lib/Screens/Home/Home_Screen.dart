import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import '../Chat/Chat_List.dart';
import '../success/success_stories_screen.dart';
import '../match/request_received_screen.dart';
import '../match/shortlisted_screen.dart';
import '../premium/subscription_screen.dart';
import '../profile/my_profile_screen.dart';
import '../settings/setting_screen.dart';
import '../settings/support_screen.dart';
import '../settings/block_user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _unreadChats = 0;
  int _shortlistedCount = 0;
  int _requestsCount = 0;
  bool _isLoading = true;
  String _userName = "User";
  String? _userPhoto;
  bool _isPremium = false;

  final List<Widget> _screens = [
    const ChatListScreen(),
    const ShortlistedScreen(),
    const RequestReceivedScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCounts();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "User";
      _userPhoto = prefs.getString('user_photo');
      _isPremium = prefs.getBool('is_premium') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _loadCounts() async {
    final prefs = await SharedPreferences.getInstance();

    // Load unread chats
    final chats = prefs.getStringList('accepted_chats') ?? [];
    _unreadChats = chats.fold(0, (sum, chat) {
      final parts = chat.split('|');
      return sum + (parts.length > 4 ? int.parse(parts[4]) : 0);
    });

    // Load shortlisted count
    final shortlist = prefs.getStringList('shortlisted_profiles') ?? [];
    _shortlistedCount = shortlist.length;

    // Load pending requests
    final requests = prefs.getStringList('pending_requests') ?? [];
    _requestsCount = requests.length;

    setState(() {});
  }

  Future<void> _navigateTo(BuildContext context, Widget screen) async {
    Navigator.of(context).pop();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );

    // Refresh counts when returning from screens that might change them
    if (result == true) {
      await _loadCounts();
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.purpleAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_logged_in');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildDrawerHeader() {
    return _isLoading
        ? Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.pink.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 150,
      ),
    )
        : Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade800, Colors.pink.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade300, Colors.pink.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _userPhoto != null
                      ? NetworkImage(_userPhoto!)
                      : null,
                  child: _userPhoto == null
                      ? const Icon(Icons.person, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, $_userName!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _isPremium
                            ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                "Premium",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Free Member",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (!_isPremium)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.rocket_launch, color: Colors.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Upgrade to unlock all features",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateTo(context, const SubscriptionScreen()),
                    child: Text(
                      "UPGRADE",
                      style: TextStyle(
                        color: Colors.amber.shade300,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildDrawerItems() {
    return [
      _buildDrawerItem(
        icon: Icons.person,
        title: "My Profile",
        color: Colors.purpleAccent,
        onTap: () => _navigateTo(context, const MyProfileScreen()),
      ),
      _buildDrawerItem(
        icon: Icons.settings,
        title: "Settings",
        color: Colors.blueAccent,
        onTap: () => _navigateTo(context, const SettingsScreen()),
      ),
      _buildDrawerItem(
        icon: Icons.star,
        title: "Subscription",
        color: Colors.amber,
        onTap: () => _navigateTo(context, const SubscriptionScreen()),
      ),
      _buildDrawerItem(
        icon: Icons.favorite,
        title: "Success Stories",
        color: Colors.pinkAccent,
        onTap: () => _navigateTo(context, const SuccessStoriesScreen()),
      ),
      _buildDrawerItem(
        icon: Icons.help,
        title: "Support",
        color: Colors.lightBlue,
        onTap: () => _navigateTo(context, const SupportScreen()),
      ),
      _buildDrawerItem(
        icon: Icons.block,
        title: "Blocked Users",
        color: Colors.redAccent,
        onTap: () => _navigateTo(context, const BlockedUsersScreen()),
      ),
      const Divider(color: Colors.grey),
      _buildDrawerItem(
        icon: Icons.logout,
        title: "Logout",
        color: Colors.red,
        onTap: _handleLogout,
      ),
    ];
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: "Find",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            TextSpan(
              text: "With",
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            TextSpan(
              text: "Vivek",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade800, Colors.pink.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
          onPressed: () {
            // Show notifications
          },
        ),
        Builder(
          builder: (context) => badges.Badge(
            showBadge: _requestsCount > 0,
            badgeContent: Text(
              '$_requestsCount',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(5),
            ),
            position: badges.BadgePosition.topEnd(top: -5, end: -5),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade800, Colors.pink.shade600],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: _unreadChats > 0,
              badgeContent: Text(
                '$_unreadChats',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(5),
              ),
              position: badges.BadgePosition.topEnd(top: -8, end: -12),
              child: const Icon(Icons.chat_bubble_outline, size: 26),
            ),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: _shortlistedCount > 0,
              badgeContent: Text(
                '$_shortlistedCount',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(5),
              ),
              // position: badges.BadgePosition.topEnd(top: -8, end: -12),
              child: const Icon(Icons.person_add_rounded, size: 26),
            ),
            label: 'Shortlist',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: _requestsCount > 0,
              badgeContent: Text(
                '$_requestsCount',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(5),
              ),
              position: badges.BadgePosition.topEnd(top: -8, end: -12),
              child: const Icon(Icons.mark_email_unread_outlined, size: 26),
            ),
            label: 'Requests',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.pushNamed(context, '/search');
        _loadCounts(); // Refresh counts after returning from search
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      endDrawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildDrawerHeader(),
            ..._buildDrawerItems(),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.grey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}