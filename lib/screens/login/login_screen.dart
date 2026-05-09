import 'package:flutter/material.dart';
import 'package:muscle_rich/services/auth_service.dart';
import 'package:muscle_rich/screens/onboarding/onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;

  static const _accent = Color(0xFF22D3A6);

  // controllers dispose karo warna memory leak hoga
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // error snackbar dikhao
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF141C2F)),
    );
  }

  // existing user login
  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showError('Login failed: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  // naya account  register hone ke baad onboarding pe bhejo
  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      await _auth.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      _showError('Registration failed: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  // Google se sign in
  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final result = await _auth.signInWithGoogle();
      if (result != null && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      _showError('Google sign in failed: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  // Apple se sign in
  Future<void> _appleSignIn() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithApple();
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } catch (e) {
      _showError('Apple sign in failed: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22D3A6), Color(0xFF0A9B76)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.35),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'MUSCLE RICH',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Train Smarter. Track Everything.',
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to continue your journey',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
              const SizedBox(height: 28),
              _inputField(_emailController, 'Email', Icons.email_rounded),
              const SizedBox(height: 14),
              // password field show/hide toggle hai
              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(
                    Icons.lock_rounded,
                    color: _accent,
                    size: 20,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _hidePassword = !_hidePassword),
                    child: Icon(
                      _hidePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: Colors.white38,
                      size: 20,
                    ),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF141C2F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _accent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // loading ho raha hai toh spinner, warna buttons crp
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: _accent),
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _register,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: const BorderSide(color: _accent, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.1)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or continue with',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white.withOpacity(0.1)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // social login buttons
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        label: 'Google',
                        icon: Icons.g_mobiledata_rounded,
                        iconColor: const Color(0xFFEA4335),
                        onTap: _googleSignIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialButton(
                        label: 'Apple',
                        icon: Icons.apple_rounded,
                        iconColor: Colors.white,
                        onTap: _appleSignIn,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // reusable input field widget
  Widget _inputField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      autocorrect: false,
      enableSuggestions: false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: _accent, size: 20),
        filled: true,
        fillColor: const Color(0xFF141C2F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
      ),
    );
  }
}

// Google aur Apple ke liye reusable social button widget
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF141C2F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}