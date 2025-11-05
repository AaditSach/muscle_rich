import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _seconds = 0;
  int _reps = 0;
  Timer? _timer;

  void _start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  void _pause() => _timer?.cancel();

  void _reset() {
    _timer?.cancel();
    setState(() { _seconds = 0; _reps = 0; });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  String get _time {
    final mm = (_seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Session Timer', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(_time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Reps completed', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('$_reps', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              trailing: IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _reps++)),
            ),
          ),
          const Spacer(),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: _start, child: const Text('Start'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: _pause, child: const Text('Pause'))),
            const SizedBox(width: 8),
            Expanded(child: TextButton(onPressed: _reset, child: const Text('Reset'))),
          ]),
        ]),
      ),
    );
  }
}