import 'package:flutter/material.dart';
import '../Auth/Login_Screen.dart';
import '../profile/my_profile_screen.dart';
import '../settings/block_user_screen.dart';
import '../success/success_stories_screen.dart';
import '../premium/subscription_screen.dart';
import '../settings/support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool locationEnabled = false;

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _logoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog(context);
              await Future.delayed(const Duration(seconds: 2));
              Navigator.pop(context);
              _showLogoutSnackbar(context);
              await Future.delayed(const Duration(seconds: 2));
              _navigateToLogin(context);
            },
            label: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showLogoutSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "You've been logged out successfully!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor:
      isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
      appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
      listTileTheme: ListTileThemeData(
        iconColor: isDarkMode ? Colors.amber : Colors.deepPurple,
        textColor: isDarkMode ? Colors.white : Colors.black,
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // White back button
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              tooltip: "Toggle Theme",
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "Preferences",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            _buildToggleCard(
              icon: Icons.notifications,
              title: "Notifications",
              value: notificationsEnabled,
              onChanged: (value) => setState(() {
                notificationsEnabled = value;
              }),
            ),
            _buildToggleCard(
              icon: Icons.location_on,
              title: "Location Services",
              value: locationEnabled,
              onChanged: (value) => setState(() {
                locationEnabled = value;
              }),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            _buildCard(
              icon: Icons.person,
              title: "My Profile",
              onTap: () => _navigateTo(context, const MyProfileScreen()),
            ),
            _buildCard(
              icon: Icons.block,
              title: "Blocked Users",
              onTap: () => _navigateTo(context, const BlockedUsersScreen()),
            ),
            _buildCard(
              icon: Icons.favorite,
              title: "Success Stories",
              onTap: () => _navigateTo(context, const SuccessStoriesScreen()),
            ),
            _buildCard(
              icon: Icons.star,
              title: "Subscription",
              onTap: () => _navigateTo(context, const SubscriptionScreen()),
            ),
            _buildCard(
              icon: Icons.support_agent,
              title: "Support",
              onTap: () => _navigateTo(context, const SupportScreen()),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            _buildCard(
              icon: Icons.logout,
              title: "Logout",
              color: Colors.red,
              onTap: () => _logoutConfirm(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color?.withOpacity(0.2) ?? Colors.deepPurple.withOpacity(0.2),
          child: Icon(
            icon,
            color: color ?? Colors.deepPurple,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: color,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleCard({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.2),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.deepPurple,
        ),
      ),
    );
  }
}