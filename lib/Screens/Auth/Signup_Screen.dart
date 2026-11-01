import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../utils/validators.dart';
import '../../routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isDarkMode = false;
  bool _agreeToTerms = false;

  late AnimationController _controller;
  late Animation<double> _fadeInAnim;
  late Animation<Offset> _slideAnim;
  late Animation<Color?> _gradientAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check system theme
    _isDarkMode = SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500)
    );

    _fadeInAnim = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut)
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _gradientAnim = ColorTween(
      begin: Colors.indigo.shade800,
      end: Colors.purple.shade600,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
    ));

    _controller.forward();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      _isDarkMode = SchedulerBinding.instance.window.platformBrightness == Brightness.dark;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passCtrl.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _signup() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() => _isLoading = true);

      // Hide keyboard
      FocusScope.of(context).unfocus();

      print("Name: ${_nameCtrl.text}");
      print("Email: ${_emailCtrl.text}");
      print("Password: ${_passCtrl.text}");

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Account created successfully!"),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
          ),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
        });
      });
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please agree to the Terms & Conditions"),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms & Conditions"),
        content: SingleChildScrollView(
          child: Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
                "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris...\n\n"
                "1. Your data will be kept secure and private\n"
                "2. We will never share your information with third parties\n"
                "3. You can delete your account at any time\n\n"
                "By creating an account, you agree to these terms.",
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.indigo.shade900, Colors.purple.shade900, Colors.black]
                : [Colors.indigo.shade800, Colors.purple.shade600, Colors.pink.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.1, 0.5, 0.9],
            transform: GradientRotation(_controller.value * 0.5),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeInAnim,
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  shadowColor: Colors.indigo.withOpacity(0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                        colors: [Colors.grey.shade900, Colors.grey.shade800],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                          : LinearGradient(
                        colors: [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Avatar
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        _gradientAnim.value ?? Colors.indigo.shade700,
                                        Colors.purple.shade500,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.indigo.withOpacity(0.4),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ClipOval(
                                      child: Image.asset(
                                          "assets/image/signup.png",
                                          fit: BoxFit.cover
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Create Your Account",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.indigo.shade800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Join us and start your journey",
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Name Field
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(
                                labelText: "Full Name",
                                labelStyle: TextStyle(color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                prefixIcon: Icon(Icons.person, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.indigo.shade700 : Colors.indigo.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700, width: 2),
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                              ),
                              validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            TextFormField(
                              controller: _emailCtrl,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                prefixIcon: Icon(Icons.email, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.indigo.shade700 : Colors.indigo.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700, width: 2),
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                              ),
                              validator: Validators.validateEmail,
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscurePass,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                prefixIcon: Icon(Icons.lock, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.indigo.shade700 : Colors.indigo.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700, width: 2),
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                                    color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
                                  ),
                                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                ),
                              ),
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: 20),

                            // Confirm Password Field
                            TextFormField(
                              controller: _confirmPassCtrl,
                              obscureText: _obscureConfirmPass,
                              decoration: InputDecoration(
                                labelText: "Confirm Password",
                                labelStyle: TextStyle(color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.indigo.shade700 : Colors.indigo.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700, width: 2),
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPass ? Icons.visibility_off : Icons.visibility,
                                    color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
                                  ),
                                  onPressed: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                                ),
                              ),
                              validator: _validateConfirmPassword,
                            ),
                            const SizedBox(height: 20),

                            // Terms and Conditions
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
                                ),
                                Expanded(
                                  child: Wrap(
                                    children: [
                                      Text(
                                        "I agree to the ",
                                        style: TextStyle(
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _showTermsDialog,
                                        child: Text(
                                          "Terms & Conditions",
                                          style: TextStyle(
                                            color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Signup Button
                            _isLoading
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                            )
                                : SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.indigo.shade700 : Colors.indigo.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: Colors.indigo.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  "Create Account",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Already have an account
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}