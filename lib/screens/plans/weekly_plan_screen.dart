import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

  // day name se weekday number  TODAY badge ke liye
  static const _dayIndex = {
    'Monday': 1, 'Tuesday': 2, 'Wednesday': 3, 'Thursday': 4,
    'Friday': 5, 'Saturday': 6, 'Sunday': 7,
  };

  // goal ke hisaab se color
  Color _goalColor(String goal) {
    if (goal == 'Cut') return const Color(0xFFFF6B6B);
    if (goal == 'Bulk') return const Color(0xFFFFB347);
    if (goal == 'Strength') return const Color(0xFFB45CFF);
    return const Color(0xFF22D3A6);
  }

  IconData _goalIcon(String goal) {
    if (goal == 'Cut') return Icons.local_fire_department_rounded;
    if (goal == 'Bulk') return Icons.trending_up_rounded;
    if (goal == 'Strength') return Icons.fitness_center_rounded;
    return Icons.flag_rounded;
  }

  // goal aur level ke combination se sahi plan select karo
  List<Map<String, dynamic>> _buildPlan(String goal, String level) {
    if (goal == 'Cut') return _cutPlan(level);
    if (goal == 'Bulk') return _bulkPlan(level);
    if (goal == 'Strength') return _strengthPlan(level);
    return _maintainPlan();
  }

  List<Map<String, dynamic>> _cutPlan(String level) {
    if (level == 'Beginner') {
      return [
        {'day': 'Monday',    'focus': 'Full Body (Light Weights)',      'cardio': '20 min brisk walk',   'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Rest + Stretching',              'cardio': 'None',                'type': 'rest'},
        {'day': 'Wednesday', 'focus': 'Full Body (Bodyweight)',         'cardio': '15 min cycling',      'type': 'train'},
        {'day': 'Thursday',  'focus': 'Rest + Light Walk',              'cardio': '20 min walk',         'type': 'rest'},
        {'day': 'Friday',    'focus': 'Upper Body (Light)',             'cardio': '15 min incline walk', 'type': 'train'},
        {'day': 'Saturday',  'focus': 'Lower Body (Light)',             'cardio': '15 min cycling',      'type': 'train'},
        {'day': 'Sunday',    'focus': 'Full Rest',                      'cardio': 'None',                'type': 'rest'},
      ];
    } else if (level == 'Intermediate') {
      return [
        {'day': 'Monday',    'focus': 'Push (Chest, Shoulders, Triceps)', 'cardio': '20 min HIIT',         'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Pull (Back, Biceps)',              'cardio': '15 min incline walk', 'type': 'train'},
        {'day': 'Wednesday', 'focus': 'Legs',                             'cardio': '20 min cycling',      'type': 'train'},
        {'day': 'Thursday',  'focus': 'Core + Conditioning',              'cardio': '15 min row',          'type': 'train'},
        {'day': 'Friday',    'focus': 'Upper Hypertrophy',                'cardio': '20 min HIIT',         'type': 'train'},
        {'day': 'Saturday',  'focus': 'Lower Hypertrophy',                'cardio': '15 min incline walk', 'type': 'train'},
        {'day': 'Sunday',    'focus': 'Rest + Light Activity',            'cardio': '30 min walk',         'type': 'rest'},
      ];
    } else {
      return [
        {'day': 'Monday',    'focus': 'Push + Core',                    'cardio': '25 min HIIT',         'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Pull + Conditioning',            'cardio': '20 min row',          'type': 'train'},
        {'day': 'Wednesday', 'focus': 'Legs + Plyometrics',             'cardio': '20 min cycling',      'type': 'train'},
        {'day': 'Thursday',  'focus': 'Active Recovery + Mobility',     'cardio': '30 min walk',         'type': 'rest'},
        {'day': 'Friday',    'focus': 'Upper Power',                    'cardio': '20 min HIIT',         'type': 'train'},
        {'day': 'Saturday',  'focus': 'Lower Power + Core',             'cardio': '20 min incline walk', 'type': 'train'},
        {'day': 'Sunday',    'focus': 'Full Rest',                      'cardio': 'None',                'type': 'rest'},
      ];
    }
  }

  List<Map<String, dynamic>> _bulkPlan(String level) {
    if (level == 'Beginner') {
      return [
        {'day': 'Monday',    'focus': 'Full Body (Compound Focus)',     'cardio': 'None',            'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Rest + Light Walk',              'cardio': '10 min walk',     'type': 'rest'},
        {'day': 'Wednesday', 'focus': 'Full Body (Volume)',             'cardio': 'None',            'type': 'train'},
        {'day': 'Thursday',  'focus': 'Rest',                           'cardio': 'None',            'type': 'rest'},
        {'day': 'Friday',    'focus': 'Full Body (Strength Focus)',     'cardio': 'None',            'type': 'train'},
        {'day': 'Saturday',  'focus': 'Arms + Core',                   'cardio': 'None',            'type': 'train'},
        {'day': 'Sunday',    'focus': 'Full Rest',                      'cardio': 'None',            'type': 'rest'},
      ];
    } else if (level == 'Intermediate') {
      return [
        {'day': 'Monday',    'focus': 'Heavy Push (Chest, Shoulders)',  'cardio': 'Optional 10 min', 'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Heavy Pull (Back, Biceps)',      'cardio': 'Optional 10 min', 'type': 'train'},
        {'day': 'Wednesday', 'focus': 'Leg Day (Heavy Squats)',         'cardio': 'None',            'type': 'train'},
        {'day': 'Thursday',  'focus': 'Rest or Mobility',               'cardio': 'Light walk',      'type': 'rest'},
        {'day': 'Friday',    'focus': 'Push Hypertrophy',               'cardio': 'Optional 10 min', 'type': 'train'},
        {'day': 'Saturday',  'focus': 'Pull + Arms',                   'cardio': 'Optional 10 min', 'type': 'train'},
        {'day': 'Sunday',    'focus': 'Full Rest',                      'cardio': 'None',            'type': 'rest'},
      ];
    } else {
      return [
        {'day': 'Monday',    'focus': 'Chest + Triceps (Heavy)',        'cardio': 'None', 'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Back + Biceps (Heavy)',          'cardio': 'None', 'type': 'train'},
        {'day': 'Wednesday', 'focus': 'Legs (Heavy Squats + RDL)',      'cardio': 'None', 'type': 'train'},
        {'day': 'Thursday',  'focus': 'Shoulders + Core',               'cardio': 'None', 'type': 'train'},
        {'day': 'Friday',    'focus': 'Chest + Back (Hypertrophy)',     'cardio': 'None', 'type': 'train'},
        {'day': 'Saturday',  'focus': 'Arms + Legs (Hypertrophy)',      'cardio': 'None', 'type': 'train'},
        {'day': 'Sunday',    'focus': 'Full Rest',                      'cardio': 'None', 'type': 'rest'},
      ];
    }
  }

  List<Map<String, dynamic>> _strengthPlan(String level) {
    if (level == 'Beginner') {
      return [
        {'day': 'Monday',    'focus': 'Squat + Press (Light)',          'cardio': '10 min warmup', 'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Rest',                           'cardio': 'None',          'type': 'rest'},
        {'day': 'Wednesday', 'focus': 'Deadlift + Row (Light)',         'cardio': '10 min warmup', 'type': 'train'},
        {'day': 'Thursday',  'focus': 'Rest',                           'cardio': 'None',          'type': 'rest'},
        {'day': 'Friday',    'focus': 'Squat + Bench (Light)',          'cardio': '10 min warmup', 'type': 'train'},
        {'day': 'Saturday',  'focus': 'Accessory Work',                 'cardio': 'None',          'type': 'train'},
        {'day': 'Sunday',    'focus': 'Full Rest',                      'cardio': 'None',          'type': 'rest'},
      ];
    } else if (level == 'Intermediate') {
      return [
        {'day': 'Monday',    'focus': 'Heavy Push (Chest, Shoulders)',  'cardio': '10 min warmup',   'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Heavy Pull (Back, Biceps)',      'cardio': '10 min warmup',   'type': 'train'},
        {'day': 'Wednesday', 'focus': 'Leg Day (Heavy Squats)',         'cardio': 'None',            'type': 'train'},
        {'day': 'Thursday',  'focus': 'Rest or Mobility',               'cardio': 'Light walk',      'type': 'rest'},
        {'day': 'Friday',    'focus': 'Push Hypertrophy',               'cardio': 'Optional 10 min', 'type': 'train'},
        {'day': 'Saturday',  'focus': 'Pull Hypertrophy',               'cardio': 'Optional 10 min', 'type': 'train'},
        {'day': 'Sunday',    'focus': 'Full Rest',                      'cardio': 'None',            'type': 'rest'},
      ];
    } else {
      return [
        {'day': 'Monday',    'focus': 'Max Effort Lower (Squat)',        'cardio': 'None',       'type': 'train'},
        {'day': 'Tuesday',   'focus': 'Max Effort Upper (Bench)',        'cardio': 'None',       'type': 'train'},
        {'day': 'Wednesday', 'focus': 'Rest + Mobility',                 'cardio': 'Light walk', 'type': 'rest'},
        {'day': 'Thursday',  'focus': 'Dynamic Effort Lower (Deadlift)', 'cardio': 'None',       'type': 'train'},
        {'day': 'Friday',    'focus': 'Dynamic Effort Upper (Press)',    'cardio': 'None',       'type': 'train'},
        {'day': 'Saturday',  'focus': 'Accessory + Core',                'cardio': 'None',       'type': 'train'},
        {'day': 'Sunday',    'focus': 'Full Rest',                       'cardio': 'None',       'type': 'rest'},
      ];
    }
  }

  List<Map<String, dynamic>> _maintainPlan() {
    return [
      {'day': 'Monday',    'focus': 'Full Body (Moderate)', 'cardio': '15 min walk',    'type': 'train'},
      {'day': 'Tuesday',   'focus': 'Cardio + Core',        'cardio': '20 min cycling', 'type': 'train'},
      {'day': 'Wednesday', 'focus': 'Upper Body',           'cardio': 'None',           'type': 'train'},
      {'day': 'Thursday',  'focus': 'Rest + Stretching',   'cardio': 'None',           'type': 'rest'},
      {'day': 'Friday',    'focus': 'Lower Body',           'cardio': '15 min walk',    'type': 'train'},
      {'day': 'Saturday',  'focus': 'Full Body (Light)',    'cardio': '20 min walk',    'type': 'train'},
      {'day': 'Sunday',    'focus': 'Full Rest',            'cardio': 'None',           'type': 'rest'},
    ];
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
        title: const Text('Weekly Plan', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      // Firestore se goal aur level fetch karo phir plan build karo
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF22D3A6)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final goal = data?['goal'] ?? 'Maintain';
          final level = data?['level'] ?? 'Beginner';
          final plan = _buildPlan(goal, level);
          final goalColor = _goalColor(goal);
          final today = DateTime.now().weekday;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _headerCard(goal, level, plan, goalColor),
              ...plan.map((day) => _dayCard(day, goalColor, today)),
            ],
          );
        },
      ),
    );
  }

  Widget _headerCard(String goal, String level, List<Map<String, dynamic>> plan, Color goalColor) {
    final trainDays = plan.where((d) => d['type'] == 'train').length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goalColor.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: goalColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(_goalIcon(goal), color: goalColor, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('YOUR TRAINING PLAN', style: TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(height: 3),
              Text('$goal · $level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: goalColor)),
            ],
          ),
          const Spacer(),
          Text('$trainDays days', style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  // har din ka card  aaj ka card highlight hoga
  Widget _dayCard(Map<String, dynamic> dayPlan, Color goalColor, int today) {
    final name = dayPlan['day'] as String;
    final isToday = _dayIndex[name] == today;
    final isRest = dayPlan['type'] == 'rest';
    final cardio = dayPlan['cardio'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? goalColor.withOpacity(0.6) : Colors.white.withOpacity(0.05),
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dayBadge(name, isToday, isRest, goalColor),
            const SizedBox(width: 14),
            Expanded(child: _dayInfo(name, dayPlan, isToday, isRest, cardio, goalColor)),
            Icon(
              isRest ? Icons.bedtime_rounded : Icons.fitness_center_rounded,
              size: 18,
              color: isRest ? Colors.white.withOpacity(0.15) : const Color(0xFF22D3A6).withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayBadge(String name, bool isToday, bool isRest, Color goalColor) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isToday ? goalColor : isRest ? Colors.white.withOpacity(0.06) : const Color(0xFF22D3A6).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              name.substring(0, 3).toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: isToday ? Colors.black : isRest ? Colors.white24 : const Color(0xFF22D3A6)),
            ),
          ),
        ),
        if (isToday) ...[
          const SizedBox(height: 4),
          Container(width: 4, height: 4, decoration: BoxDecoration(color: goalColor, shape: BoxShape.circle)),
        ],
      ],
    );
  }

  Widget _dayInfo(String name, Map<String, dynamic> dayPlan, bool isToday, bool isRest, String cardio, Color goalColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isToday ? goalColor : Colors.white)),
            if (isToday) ...[
              const SizedBox(width: 8),
              // TODAY badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: goalColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text('TODAY', style: TextStyle(fontSize: 9, color: goalColor, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(dayPlan['focus'], style: TextStyle(color: isRest ? Colors.white30 : Colors.white70, fontSize: 13)),
        if (cardio != 'None') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.directions_run_rounded, size: 13, color: const Color(0xFF22D3A6).withOpacity(0.7)),
              const SizedBox(width: 5),
              Text(cardio, style: const TextStyle(color: Color(0xFF22D3A6), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ],
    );
  }
}