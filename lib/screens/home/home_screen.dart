import 'package:flutter/material.dart';
import '../workout/workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Muscle Rich')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Welcome back, Aadit 👋', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('You’re 2 workouts away from your weekly goal.'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Workout'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress screen coming soon.')),
                );
              },
              icon: const Icon(Icons.show_chart),
              label: const Text('View Progress'),
            ),
            const SizedBox(height: 24),
            const Text('Today’s stats', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _StatCard(label: 'Minutes', value: '24', icon: Icons.timer)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Calories', value: '180', icon: Icons.local_fire_department)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0x225E60CE),
              child: Icon(icon, color: const Color(0xFF5E60CE)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const Text(''),
                Text(label, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}