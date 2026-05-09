import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  bool _loading = true;
  bool _editMode = false;

  Map<String, dynamic>? _userData;

  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  String _gender = 'Male';
  String _goal = 'Maintain';
  String _level = 'Beginner';

  @override
  void initState() {
    super.initState();
    _loadUser(); // screen khulte hi user data load karo
  }

  // Firestore se user ka data fetch karo aur controllers mein daal do
  Future<void> _loadUser() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (doc.exists) {
      _userData = doc.data();
      _nameController.text = _userData?['displayName'] ?? '';
      _weightController.text = _userData?['weightKg']?.toString() ?? '';
      _heightController.text = _userData?['heightCm']?.toString() ?? '';
      _ageController.text = _userData?['age']?.toString() ?? '';
      _gender = _userData?['gender'] ?? 'Male';
      _goal = _userData?['goal'] ?? 'Maintain';
      _level = _userData?['level'] ?? 'Beginner';
    }
    setState(() => _loading = false);
  }

  // edited data Firestore mein save karo
  Future<void> _save() async {
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'displayName': _nameController.text.trim(),
      'weightKg': int.tryParse(_weightController.text),
      'heightCm': int.tryParse(_heightController.text),
      'age': int.tryParse(_ageController.text),
      'gender': _gender,
      'goal': _goal,
      'level': _level,
    });
    // Firebase Auth mein bhi naam update karo
    await user!.updateDisplayName(_nameController.text.trim());
    setState(() => _editMode = false);
    _loadUser();
  }

  Color _goalColor(String g) {
    if (g == 'Cut') return const Color(0xFFFF6B6B); //red
    if (g == 'Bulk') return const Color(0xFFFFB347); //orange
    if (g == 'Strength') return const Color(0xFFB45CFF); //purple
    return const Color(0xFF22D3A6);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F1A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF22D3A6))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          if (!_editMode)
            TextButton.icon(
              onPressed: () => setState(() => _editMode = true),
              icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF22D3A6)),
              label: const Text('Edit', style: TextStyle(color: Color(0xFF22D3A6), fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      // edit mode hai toh form, warna profile card
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _editMode ? _editForm() : _profileCard(),
      ),
    );
  }

  Widget _profileCard() {
    final name = _userData?['displayName'] ?? '-';
    final initial = name != '-' ? name[0].toUpperCase() : user!.email![0].toUpperCase();
    final goal = _userData?['goal'] ?? '-';
    final level = _userData?['level'] ?? '-';
    final goalColor = _goalColor(goal);

    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF22D3A6), Color(0xFF0A9B76)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: const Color(0xFF22D3A6).withOpacity(0.35), blurRadius: 20, spreadRadius: 2)],
                ),
                child: Center(child: Text(initial, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black))),
              ),
              const SizedBox(height: 14),
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(color: goalColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: goalColor.withOpacity(0.4))),
                child: Text('Goal: $goal', style: TextStyle(color: goalColor, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Weight', value: '${_userData?['weightKg'] ?? '-'}', unit: 'kg', color: const Color(0xFF36D1DC))),
            const SizedBox(width: 12),
            Expanded(child: _StatBox(label: 'Height', value: '${_userData?['heightCm'] ?? '-'}', unit: 'cm', color: const Color(0xFFB45CFF))),
            const SizedBox(width: 12),
            Expanded(child: _StatBox(label: 'Age', value: '${_userData?['age'] ?? '-'}', unit: 'yrs', color: const Color(0xFFFFB347))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF141C2F), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.06))),
          child: Column(
            children: [
              _infoRow(Icons.person_rounded, 'Name', name),
              _divider(),
              _infoRow(Icons.wc_rounded, 'Gender', _userData?['gender'] ?? '-'),
              _divider(),
              _infoRow(Icons.flag_rounded, 'Goal', goal, valueColor: goalColor),
              _divider(),
              _infoRow(Icons.fitness_center_rounded, 'Level', level),
              _divider(),
              _infoRow(Icons.email_rounded, 'Email', user!.email ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _divider() => Divider(color: Colors.white.withOpacity(0.06), height: 20);

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white38),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? Colors.white)),
      ],
    );
  }

  // edit form  saari fields editable
  Widget _editForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _sectionLabel('PERSONAL INFO'),
          const SizedBox(height: 12),
          _field(_nameController, 'Display Name', Icons.person_rounded),
          const SizedBox(height: 12),
          _field(_weightController, 'Weight (kg)', Icons.monitor_weight_rounded, isNumber: true),
          const SizedBox(height: 12),
          _field(_heightController, 'Height (cm)', Icons.height_rounded, isNumber: true),
          const SizedBox(height: 12),
          _field(_ageController, 'Age', Icons.cake_rounded, isNumber: true),
          const SizedBox(height: 20),
          _sectionLabel('GENDER'),
          const SizedBox(height: 10),
          Row(
            children: ['Male', 'Female', 'Other'].map((g) {
              final sel = _gender == g;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? const Color(0xFF22D3A6) : const Color(0xFF141C2F),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: sel ? const Color(0xFF22D3A6) : Colors.white24),
                    ),
                    child: Text(g, style: TextStyle(color: sel ? Colors.black : Colors.white70, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _sectionLabel('TRAINING GOAL'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ['Cut', 'Bulk', 'Strength', 'Maintain'].map((g) {
              final sel = _goal == g;
              final c = _goalColor(g);
              return GestureDetector(
                onTap: () => setState(() => _goal = g),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? c.withOpacity(0.2) : const Color(0xFF141C2F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? c : Colors.white24),
                  ),
                  child: Text(g, style: TextStyle(color: sel ? c : Colors.white70, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _sectionLabel('EXPERIENCE LEVEL'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ['Beginner', 'Intermediate', 'Advanced'].map((l) {
              final sel = _level == l;
              const c = Color(0xFF22D3A6);
              return GestureDetector(
                onTap: () => setState(() => _level = l),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? c.withOpacity(0.2) : const Color(0xFF141C2F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? c : Colors.white24),
                  ),
                  child: Text(l, style: TextStyle(color: sel ? c : Colors.white70, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => setState(() => _editMode = false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF22D3A6), fontWeight: FontWeight.w700, letterSpacing: 1.4));
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF22D3A6), size: 20),
        filled: true,
        fillColor: const Color(0xFF141C2F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22D3A6), width: 1.5)),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(unit, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}