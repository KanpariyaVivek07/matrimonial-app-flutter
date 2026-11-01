import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../utils/validators.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _isLoading = false;
  bool _isDarkMode = false;

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
      begin: Colors.purple.shade800,
      end: Colors.pink.shade600,
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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Hide keyboard
      FocusScope.of(context).unfocus();

      // Print user input to console
      print('📧 Email: ${_emailCtrl.text}');
      print('🔒 Password: ${_passCtrl.text}');

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isLoading = false);

        // Show login success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Login successful!"),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to home screen after short delay
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        });
      });
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email to receive a password reset link:"),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: Validators.validateEmail,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Password reset link sent to your email"),
                  backgroundColor: Colors.blue.shade600,
                ),
              );
            },
            child: const Text("Send Link"),
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
                ? [Colors.purple.shade900, Colors.indigo.shade900, Colors.black]
                : [Colors.purple.shade800, Colors.pink.shade600, Colors.orange.shade400],
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
                  shadowColor: Colors.purple.withOpacity(0.5),
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
                            // Animated logo
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        _gradientAnim.value ?? Colors.purple.shade700,
                                        Colors.pink.shade500,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.4),
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
                                        "assets/image/login.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Welcome Back!",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.purple.shade800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Login to continue your journey",
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email Field
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: isDark ? Colors.purple.shade300 : Colors.purple.shade700),
                                prefixIcon: Icon(Icons.email, color: isDark ? Colors.purple.shade300 : Colors.purple.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.purple.shade700 : Colors.purple.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.purple.shade300 : Colors.purple.shade700, width: 2),
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
                                labelStyle: TextStyle(color: isDark ? Colors.purple.shade300 : Colors.purple.shade700),
                                prefixIcon: Icon(Icons.lock, color: isDark ? Colors.purple.shade300 : Colors.purple.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.purple.shade700 : Colors.purple.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: isDark ? Colors.purple.shade300 : Colors.purple.shade700, width: 2),
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePass ? Icons.visibility_off : Icons.visibility,
                                    color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                                  ),
                                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                                ),
                              ),
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: 12),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Login Button
                            _isLoading
                                ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                            )
                                : SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.purple.shade700 : Colors.purple.shade700,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor: Colors.purple.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: Divider(
                            //         color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                            //         thickness: 1,
                            //       ),
                            //     ),
                            //     Padding(
                            //       padding: const EdgeInsets.symmetric(horizontal: 12),
                            //       child: Text(
                            //         "or continue with",
                            //         style: TextStyle(
                            //           color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            //         ),
                            //       ),
                            //     ),
                            //     Expanded(
                            //       child: Divider(
                            //         color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                            //         thickness: 1,
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 24),

                            // Social login buttons
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     // Google
                            //     InkWell(
                            //       onTap: () {
                            //         print("Google login tapped");
                            //       },
                            //       child: Container(
                            //         padding: const EdgeInsets.all(12),
                            //         decoration: BoxDecoration(
                            //           color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            //           shape: BoxShape.circle,
                            //           border: Border.all(
                            //             color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            //           ),
                            //         ),
                            //         child: Image.asset(
                            //           "assets/image/google.png",
                            //           width: 24,
                            //           height: 24,
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(width: 20),
                            //
                            //     // Facebook
                            //     InkWell(
                            //       onTap: () {
                            //         print("Facebook login tapped");
                            //       },
                            //       child: Container(
                            //         padding: const EdgeInsets.all(12),
                            //         decoration: BoxDecoration(
                            //           color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            //           shape: BoxShape.circle,
                            //           border: Border.all(
                            //             color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            //           ),
                            //         ),
                            //         child: Image.asset(
                            //           "assets/image/facebook.png",
                            //           width: 24,
                            //           height: 24,
                            //         ),
                            //       ),
                            //     ),
                            //     const SizedBox(width: 20),
                            //
                            //     // Apple
                            //     InkWell(
                            //       onTap: () {
                            //         print("Apple login tapped");
                            //       },
                            //       child: Container(
                            //         padding: const EdgeInsets.all(12),
                            //         decoration: BoxDecoration(
                            //           color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                            //           shape: BoxShape.circle,
                            //           border: Border.all(
                            //             color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            //           ),
                            //         ),
                            //         child: Image.asset(
                            //           "assets/image/apple.png",
                            //           width: 24,
                            //           height: 24,
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 24),

                            // Signup link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
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