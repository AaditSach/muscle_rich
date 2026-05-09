import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  // volume ki calculation se motivational message
  String _motivationLabel(double volume) {
    if (volume == 0) return 'Log your first workout to get started!';
    if (volume < 5000) return 'Great start — keep building! 💪';
    if (volume < 20000) return "You're making serious progress! 🔥";
    if (volume < 50000) return 'Beast mode activated! 🏆';
    return 'Legendary lifter status! 🥇';
  }

  // bade numbers mein comma lagega
  String _formatVolume(double volume) {
    if (volume < 1000) return volume.toStringAsFixed(0); //no ko convert karega pehle
    final parts = volume.toStringAsFixed(0).split('');
    final result = StringBuffer();
    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) result.write(',');//comma kahan jayega
      result.write(parts[i]);
    }
    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text('Progress', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      // real time stream  naya workout aate hi screen update hogi
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workouts')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF22D3A6)));
          }

          double totalVolume = 0;
          int totalWorkouts = 0;
          int totalMinutes = 0;
          final weekly = List.filled(7, 0);

          if (snapshot.hasData) {
            totalWorkouts = snapshot.data!.docs.length;

            // is week ki range calculate karo
            final now = DateTime.now();
            final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1)); //1 kam hoga , aur 7 din baad
            final weekEnd = weekStart.add(const Duration(days: 7));

            for (final doc in snapshot.data!.docs) {
              final d = doc.data() as Map<String, dynamic>;

              // volume = weight x reps - har set ke liye
              final sets = d['sets'];
              if (sets is List) {
                for (final set in sets) {
                  if (set is Map<String, dynamic>) {
                    totalVolume += ((set['weight'] ?? 0) as num) * ((set['reps'] ?? 0) as num);
                  }
                }
              }

              totalMinutes += ((d['durationSeconds'] ?? 0) as num).toInt() ~/ 60;

              // weekly chart ke liye  is week ke workouts count karo
              final ts = d['timestamp'];
              if (ts is Timestamp) {
                final date = ts.toDate();
                if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
                  weekly[date.weekday - 1] += 1;
                }
              }
            }
          }

          final maxWeekly = weekly.reduce((a, b) => a > b ? a : b);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 8),
              _volumeCard(totalVolume),
              const SizedBox(height: 16),
              _statsRow(totalWorkouts, totalMinutes, weekly),
              const SizedBox(height: 20),
              _weeklyChart(weekly, maxWeekly),
              const SizedBox(height: 20),
              if (totalWorkouts == 0) _emptyState(),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _volumeCard(double totalVolume) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D2E2A), Color(0xFF141C2F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF22D3A6).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF22D3A6).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF22D3A6), size: 20),
              ),
              const SizedBox(width: 10),
              const Text('LIFETIME VOLUME', style: TextStyle(color: Color(0xFF22D3A6), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 16),
          Text(_formatVolume(totalVolume), style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
          const Text('kilograms lifted', style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF22D3A6).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(_motivationLabel(totalVolume), style: const TextStyle(color: Color(0xFF22D3A6), fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(int workouts, int minutes, List<int> weekly) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Workouts', value: workouts.toString(), icon: Icons.fitness_center_rounded, color: const Color(0xFFB45CFF))),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'Minutes', value: minutes.toString(), icon: Icons.timer_rounded, color: const Color(0xFF36D1DC))),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'This Week', value: weekly.where((d) => d > 0).length.toString(), icon: Icons.calendar_today_rounded, color: const Color(0xFFFFB347))),
      ],
    );
  }

  // bar chart  har din ki activity dikhata hai
  Widget _weeklyChart(List<int> weekly, int maxWeekly) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIndex = DateTime.now().weekday - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF141C2F), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('This Week', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${weekly.where((d) => d > 0).length}/7 days', style: const TextStyle(color: Color(0xFF22D3A6), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (i) {
              final count = weekly[i];
              final isToday = todayIndex == i;
              final barHeight = count == 0 ? 8.0 : maxWeekly == 0 ? 8.0 : (count / maxWeekly) * 80.0;
              final active = count > 0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(active ? count.toString() : '', style: const TextStyle(fontSize: 11, color: Color(0xFF22D3A6), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    height: barHeight,
                    width: 28,
                    decoration: BoxDecoration(
                      gradient: active ? const LinearGradient(colors: [Color(0xFF22D3A6), Color(0xFF0A9B76)], begin: Alignment.topCenter, end: Alignment.bottomCenter) : null,
                      color: active ? null : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: isToday ? Border.all(color: const Color(0xFF22D3A6), width: 1.5) : null,
                      boxShadow: active ? [BoxShadow(color: const Color(0xFF22D3A6).withOpacity(0.3), blurRadius: 8, spreadRadius: 1)] : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(labels[i], style: TextStyle(fontSize: 12, color: isToday ? const Color(0xFF22D3A6) : Colors.white54, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: const Color(0xFF141C2F), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.06))),
      child: Column(
        children: [
          Icon(Icons.fitness_center_rounded, size: 48, color: Colors.white.withOpacity(0.15)),
          const SizedBox(height: 16),
          const Text('No workouts yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white54)),
          const SizedBox(height: 6),
          const Text('Complete your first session to see your progress here.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white30, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF141C2F), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}