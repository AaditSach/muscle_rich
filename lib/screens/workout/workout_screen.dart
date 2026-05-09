import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WorkoutScreen extends StatefulWidget {
  final String? bodyPart;
  final String? exerciseName;

  const WorkoutScreen({super.key, this.bodyPart, this.exerciseName});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _seconds = 0;
  Timer? _timer;
  bool _running = false;

  // har set ke liye weight aur reps controllers
  final List<TextEditingController> _weights = [];
  final List<TextEditingController> _reps = [];

  // body part ke hisaab se accent color
  Color get _accent {
    if (widget.bodyPart == 'Chest') return const Color(0xFF22D3A6);
    if (widget.bodyPart == 'Back') return const Color(0xFFB45CFF);
    if (widget.bodyPart == 'Legs') return const Color(0xFF36D1DC);
    if (widget.bodyPart == 'Arms') return const Color(0xFFFFB347);
    if (widget.bodyPart == 'Shoulders') return const Color(0xFFFF6B6B);
    if (widget.bodyPart == 'Core') return const Color(0xFF4ECDC4);
    return const Color(0xFF22D3A6);
  }

  // seconds ko MM:SS format mein convert karo
  String get _time {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // timer start  har second ek increment
  void _start() {
    if (_running) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _seconds++));
    setState(() => _running = true);
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  // reset  timer aur saare sets clear
  void _reset() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _running = false;
      _weights.clear();
      _reps.clear();
    });
  }

  // naya set row add karo
  void _addSet() {
    setState(() {
      _weights.add(TextEditingController());
      _reps.add(TextEditingController());
    });
  }

  // workout finish karo  confirm dialog, phir Firestore mein save karo
  Future<void> _finish() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF141C2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Finish Workout?'),
        content: Text(
          "You've logged ${_weights.length} set${_weights.length != 1 ? 's' : ''} in $_time.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Going', style: TextStyle(color: Colors.white54))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save & Finish')),
        ],
      ),
    );

    if (confirm != true) return;
    _timer?.cancel();

    // controllers se sets ka data collect karo
    final sets = List.generate(_weights.length, (i) => {
      'weight': int.tryParse(_weights[i].text) ?? 0,
      'reps': int.tryParse(_reps[i].text) ?? 0,
    });

    // Firestore mein workout document save karo
    await FirebaseFirestore.instance.collection('workouts').add({
      'userId': user.uid,
      'bodyPart': widget.bodyPart,
      'exerciseName': widget.exerciseName,
      'durationSeconds': _seconds,
      'sets': sets,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.exerciseName ?? 'Workout', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _timerCard(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _addSetButton(),
                const SizedBox(height: 12),
                ..._weights.asMap().entries.map((e) => _setRow(e.key)),
                if (_weights.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('Tap "Add Set" to log your first set', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 14)),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Finish Workout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    onPressed: _finish,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(_time, style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: _running ? _accent : Colors.white54, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(_running ? 'Timer running' : 'Timer paused', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimerBtn(label: 'Start', icon: Icons.play_arrow_rounded, color: _accent, onTap: _start, enabled: !_running),
              const SizedBox(width: 12),
              _TimerBtn(label: 'Pause', icon: Icons.pause_rounded, color: const Color(0xFFFFB347), onTap: _pause, enabled: _running),
              const SizedBox(width: 12),
              _TimerBtn(label: 'Reset', icon: Icons.refresh_rounded, color: Colors.white30, onTap: _reset, enabled: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addSetButton() {
    return GestureDetector(
      onTap: _addSet,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(color: _accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _accent.withOpacity(0.4))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: _accent, size: 20),
            const SizedBox(width: 8),
            Text('Add Set', style: TextStyle(color: _accent, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  // set number, weight aur reps input row
  Widget _setRow(int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF141C2F), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: _accent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('${i + 1}', style: TextStyle(color: _accent, fontWeight: FontWeight.bold, fontSize: 14))),
          ),
          const SizedBox(width: 12),
          Expanded(child: _SetField(controller: _weights[i], label: 'kg', hint: 'Weight', accent: _accent)),
          const SizedBox(width: 10),
          Expanded(child: _SetField(controller: _reps[i], label: 'reps', hint: 'Reps', accent: _accent)),
        ],
      ),
    );
  }
}

class _TimerBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const _TimerBtn({required this.label, required this.icon, required this.color, required this.onTap, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.4))),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color accent;

  const _SetField({required this.controller, required this.label, required this.hint, required this.accent});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        suffixText: label,
        suffixStyle: TextStyle(color: accent, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF0B0F1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: accent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}