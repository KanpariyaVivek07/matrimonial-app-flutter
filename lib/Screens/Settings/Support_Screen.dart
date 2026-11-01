import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final String supportEmail = "vivekkanpariya0407@gmail.com";
  final String supportPhone = "+91 949 966 1142";
  // final String faqUrl = "https://example.com/faq";
  bool isDarkMode = false;

  void _showCopiedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not launch $url"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPlatformSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
              title: Text(
                "WhatsApp",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onTap: () => _launchUrl("https://wa.me/15551234567"),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
              title: Text(
                "Facebook",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onTap: () => _launchUrl("https://facebook.com/example"),
            ),
            ListTile(
              leading: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: FaIcon(
                  FontAwesomeIcons.instagram,
                  color: isDarkMode ? Colors.white : Colors.white,
                ),
              ),
              title: Text(
                "Instagram",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onTap: () => _launchUrl("https://instagram.com/example"),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.linkedin, color: Colors.blueAccent),
              title: Text(
                "LinkedIn",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onTap: () => _launchUrl("https://linkedin.com/company/example"),
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
        title: const Text(
          "Support",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Need help?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reach us via email or phone below:",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.deepPurple),
                      title: Text(supportEmail),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: supportEmail));
                          _showCopiedSnackbar("Email copied to clipboard");
                        },
                      ),
                      onTap: () => _launchUrl("mailto:$supportEmail"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: Text(supportPhone),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: supportPhone));
                          _showCopiedSnackbar("Phone number copied to clipboard");
                        },
                      ),
                      onTap: () => _launchUrl("tel:$supportPhone"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // child: Padding(
              //   padding: const EdgeInsets.all(16),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       const Text(
              //         "Frequently Asked Questions",
              //         style: TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       const SizedBox(height: 10),
              //       const Text(
              //         "Find answers to common questions in our FAQ section.",
              //         style: TextStyle(fontSize: 14),
              //       ),
              //       const SizedBox(height: 16),
              //       ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.deepPurple,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(8),
              //           ),
              //         ),
              //         onPressed: () => _launchUrl(faqUrl),
              //         child: const Text(
              //           "View FAQ",
              //           style: TextStyle(color: Colors.white),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Connect with us:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.deepPurple),
              title: const Text("Choose Platform"),
              // trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showPlatformSheet,
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _launchUrl("mailto:$supportEmail"),
                icon: const Icon(Icons.mail, color: Colors.white),
                label: const Text(
                  "Contact Support",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "We typically reply within 24 hours",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}