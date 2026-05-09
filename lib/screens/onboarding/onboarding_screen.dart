import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// naye user ka data collect karta hai 3 pages mein
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  String _gender = 'Male';
  String _goal = 'Bulk';
  String _level = 'Beginner';
  bool _saving = false;

  static const _accent = Color(0xFF22D3A6);

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // page 0 validation naam aur age check karo
  bool _validatePage1() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return false;
    }
    final age = int.tryParse(_ageController.text);
    if (age == null || age < 13 || age > 100) {
      _showError('Please enter a valid age (13–100)');
      return false;
    }
    return true;
  }

  // page 1 validation weight aur height check karo
  bool _validatePage2() {
    final weight = int.tryParse(_weightController.text);
    if (weight == null || weight < 20 || weight > 300) {
      _showError('Please enter a valid weight (20–300 kg)');
      return false;
    }
    final height = int.tryParse(_heightController.text);
    if (height == null || height < 50 || height > 250) {
      _showError('Please enter a valid height (50–250 cm)');
      return false;
    }
    return true;
  }

  // validate karke next page pe jao, last page pe finish karo
  void _next() {
    if (_page == 0 && !_validatePage1()) return;
    if (_page == 1 && !_validatePage2()) return;

    if (_page < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  // saara data Firestore mein save karo aur home pe bhejo
  Future<void> _finish() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'displayName': _nameController.text.trim(),
      'weightKg': int.tryParse(_weightController.text) ?? 0,
      'heightCm': int.tryParse(_heightController.text) ?? 0,
      'age': int.tryParse(_ageController.text) ?? 0,
      'gender': _gender,
      'goal': _goal,
      'level': _level,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Firebase Auth mein bhi naam update karo
    await user.updateDisplayName(_nameController.text.trim());

    if (mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // progress bar dikhata hai user kahan hai
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: List.generate(
                  3,
                  (i) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _page
                            ? _accent
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // manually control karo
                onPageChanged: (i) => setState(() => _page = i),
                children: [_page1(), _page2(), _page3()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: _saving
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _next,
                        child: Text(
                          _page == 2 ? "Let's Go 🚀" : 'Continue',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // page 1 naam, age, gender
  Widget _page1() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            "Let's set up\nyour profile",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us a bit about yourself',
            style: TextStyle(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 40),
          _field(_nameController, 'Your Name', Icons.person_rounded,
              hint: 'e.g. Aadit'),
          const SizedBox(height: 16),
          _field(_ageController, 'Age', Icons.cake_rounded,
              isNumber: true, hint: '13–100'),
          const SizedBox(height: 24),
          const Text(
            'GENDER',
            style: TextStyle(
              fontSize: 11,
              color: _accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Male', 'Female', 'Other'].map((g) {
              final sel = _gender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? _accent : const Color(0xFF141C2F),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: sel ? _accent : Colors.white24),
                    ),
                    child: Center(
                      child: Text(
                        g,
                        style: TextStyle(
                          color: sel ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // page 2 weight aur height
  Widget _page2() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Your body\nmeasurements',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Used to personalise your training plan',
            style: TextStyle(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 40),
          _field(_weightController, 'Weight (kg)',
              Icons.monitor_weight_rounded,
              isNumber: true, hint: '20–300 kg'),
          const SizedBox(height: 16),
          _field(_heightController, 'Height (cm)', Icons.height_rounded,
              isNumber: true, hint: '50–250 cm'),
        ],
      ),
    );
  }

  // page 3  goal aur experience level select karo
  Widget _page3() {
    final goals = [
      {
        'label': 'Cut',
        'desc': 'Lose fat, maintain muscle',
        'icon': Icons.local_fire_department_rounded,
        'color': const Color(0xFFFF6B6B)
      },
      {
        'label': 'Bulk',
        'desc': 'Build muscle and size',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFFFFB347)
      },
      {
        'label': 'Strength',
        'desc': 'Increase raw strength',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFFB45CFF)
      },
      {
        'label': 'Maintain',
        'desc': 'Stay fit and healthy',
        'icon': Icons.flag_rounded,
        'color': _accent
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Your training\ngoal',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll build your weekly plan around this",
            style: TextStyle(color: Colors.white38, fontSize: 15),
          ),
          const SizedBox(height: 32),
          const Text(
            'GOAL',
            style: TextStyle(
              fontSize: 11,
              color: _accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ...goals.map((g) {
            final label = g['label'] as String;
            final color = g['color'] as Color;
            final sel = _goal == label;
            return GestureDetector(
              onTap: () => setState(() => _goal = label),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      sel ? color.withOpacity(0.15) : const Color(0xFF141C2F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? color : Colors.white.withOpacity(0.06),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(g['icon'] as IconData, color: color, size: 24),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: sel ? color : Colors.white,
                          ),
                        ),
                        Text(
                          g['desc'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (sel)
                      Icon(Icons.check_circle_rounded, color: color, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            'EXPERIENCE LEVEL',
            style: TextStyle(
              fontSize: 11,
              color: _accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Beginner', 'Intermediate', 'Advanced'].map((l) {
              final sel = _level == l;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _level = l),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: sel ? _accent : const Color(0xFF141C2F),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: sel ? _accent : Colors.white24),
                    ),
                    child: Center(
                      child: Text(
                        l,
                        style: TextStyle(
                          color: sel ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // reusable text field
  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
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