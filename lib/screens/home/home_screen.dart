import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_rich/screens/auth/auth_gate.dart';
import 'package:muscle_rich/screens/workout/body_parts_screen.dart';
import 'package:muscle_rich/screens/progress/progress_screen.dart';
import 'package:muscle_rich/screens/profile/profile_screen.dart';
import 'package:muscle_rich/screens/plans/weekly_plan_screen.dart';

// main screen  bottom nav bar aur IndexedStack yahan handle hota hai
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  // yeh 4 tabs hain  IndexedStack sab mounted rakhta hai state preserve karne ke liye
  final List<Widget> _pages = const [
    _HomeContent(),
    BodyPartsScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFF22D3A6),
        unselectedItemColor: Colors.white38,
        backgroundColor: const Color(0xFF0B0F1A),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({super.key});

  // time ke hisaab se greeting
  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning'; //noon
    if (h < 17) return 'Good afternoon'; //before 5, after evening 
    return 'Good evening';
  }

  // goal ke hisaab se card ka color  Cut red, Bulk orange, Strength purple
  Color _goalColor(String goal) {
    if (goal == 'Cut') return const Color(0xFFFF6B6B); //red
    if (goal == 'Bulk') return const Color(0xFFFFB347); //orange
    if (goal == 'Strength') return const Color(0xFFB45CFF); //purple 
    return const Color(0xFF22D3A6);
  }

  // aaj ka workout nikalta hai  goal, level aur weekday ke basis pe
  Map<String, String> _todayWorkout(String goal, String level) { //1-7 ke bech ka number dega, usme se ek - hoga
    final day = DateTime.now().weekday - 1; // 0 = Monday

    const cutBeginner = [
      {'title': 'Full Body', 'focus': 'Light Weights'},
      {'title': 'Rest', 'focus': 'Stretching'},
      {'title': 'Full Body', 'focus': 'Bodyweight'},
      {'title': 'Rest', 'focus': 'Light Walk'},
      {'title': 'Upper Body', 'focus': 'Light'},
      {'title': 'Lower Body', 'focus': 'Light'},
      {'title': 'Rest', 'focus': 'Recovery'},
    ];
    const cutIntermediate = [
      {'title': 'Push Day', 'focus': 'Chest • Shoulders • Triceps'},
      {'title': 'Pull Day', 'focus': 'Back • Biceps'},
      {'title': 'Leg Day', 'focus': 'Quads • Glutes • Hamstrings'},
      {'title': 'Core + Conditioning', 'focus': 'Abs • Cardio'},
      {'title': 'Upper Hypertrophy', 'focus': 'Chest • Back • Arms'},
      {'title': 'Lower Hypertrophy', 'focus': 'Legs • Glutes'},
      {'title': 'Rest', 'focus': 'Light Activity'},
    ];
    const cutAdvanced = [
      {'title': 'Push + Core', 'focus': 'Chest • Shoulders • Abs'},
      {'title': 'Pull + Conditioning', 'focus': 'Back • Biceps • Cardio'},
      {'title': 'Legs + Plyometrics', 'focus': 'Quads • Glutes • Power'},
      {'title': 'Active Recovery', 'focus': 'Mobility • Light Walk'},
      {'title': 'Upper Power', 'focus': 'Chest • Back • Shoulders'},
      {'title': 'Lower Power + Core', 'focus': 'Legs • Glutes • Abs'},
      {'title': 'Rest', 'focus': 'Full Recovery'},
    ];
    const bulkBeginner = [
      {'title': 'Full Body', 'focus': 'Compound Focus'},
      {'title': 'Rest', 'focus': 'Light Walk'},
      {'title': 'Full Body', 'focus': 'Volume'},
      {'title': 'Rest', 'focus': 'Recovery'},
      {'title': 'Full Body', 'focus': 'Strength Focus'},
      {'title': 'Arms + Core', 'focus': 'Biceps • Triceps • Abs'},
      {'title': 'Rest', 'focus': 'Full Recovery'},
    ];
    const bulkIntermediate = [
      {'title': 'Heavy Push', 'focus': 'Chest • Shoulders'},
      {'title': 'Heavy Pull', 'focus': 'Back • Biceps'},
      {'title': 'Leg Day', 'focus': 'Heavy Squats'},
      {'title': 'Rest', 'focus': 'Mobility'},
      {'title': 'Push Hypertrophy', 'focus': 'Chest • Shoulders • Triceps'},
      {'title': 'Pull + Arms', 'focus': 'Back • Biceps • Arms'},
      {'title': 'Rest', 'focus': 'Full Recovery'},
    ];
    const bulkAdvanced = [
      {'title': 'Chest + Triceps', 'focus': 'Heavy'},
      {'title': 'Back + Biceps', 'focus': 'Heavy'},
      {'title': 'Legs', 'focus': 'Heavy Squats • RDL'},
      {'title': 'Shoulders + Core', 'focus': 'Deltoids • Abs'},
      {'title': 'Chest + Back', 'focus': 'Hypertrophy'},
      {'title': 'Arms + Legs', 'focus': 'Hypertrophy'},
      {'title': 'Rest', 'focus': 'Full Recovery'},
    ];
    const strengthBeginner = [
      {'title': 'Squat + Press', 'focus': 'Light'},
      {'title': 'Rest', 'focus': 'Recovery'},
      {'title': 'Deadlift + Row', 'focus': 'Light'},
      {'title': 'Rest', 'focus': 'Recovery'},
      {'title': 'Squat + Bench', 'focus': 'Light'},
      {'title': 'Accessory Work', 'focus': 'Arms • Core'},
      {'title': 'Rest', 'focus': 'Full Recovery'},
    ];
    const strengthIntermediate = [
      {'title': 'Heavy Push', 'focus': 'Chest • Shoulders'},
      {'title': 'Heavy Pull', 'focus': 'Back • Biceps'},
      {'title': 'Leg Day', 'focus': 'Heavy Squats'},
      {'title': 'Rest', 'focus': 'Mobility'},
      {'title': 'Push Hypertrophy', 'focus': 'Chest • Shoulders • Triceps'},
      {'title': 'Pull Hypertrophy', 'focus': 'Back • Biceps'},
      {'title': 'Rest', 'focus': 'Full Recovery'},
    ];
    const strengthAdvanced = [
      {'title': 'Max Effort Lower', 'focus': 'Squat'},
      {'title': 'Max Effort Upper', 'focus': 'Bench'},
      {'title': 'Rest + Mobility', 'focus': 'Light Walk'},
      {'title': 'Dynamic Lower', 'focus': 'Deadlift'},
      {'title': 'Dynamic Upper', 'focus': 'Press'},
      {'title': 'Accessory + Core', 'focus': 'Arms • Abs'},
      {'title': 'Rest', 'focus': 'Full Recovery'},
    ];
    const maintain = [
      {'title': 'Full Body', 'focus': 'Moderate'},
      {'title': 'Cardio + Core', 'focus': 'Cycling • Abs'},
      {'title': 'Upper Body', 'focus': 'Chest • Back • Arms'},
      {'title': 'Rest', 'focus': 'Stretching'},
      {'title': 'Lower Body', 'focus': 'Legs • Glutes'},
      {'title': 'Full Body', 'focus': 'Light'},
      {'title': 'Rest', 'focus': 'Full Recovery'},
    ];

    List<Map<String, String>> plan;

    if (goal == 'Cut') {
      if (level == 'Beginner') plan = cutBeginner;
      else if (level == 'Intermediate') plan = cutIntermediate;
      else plan = cutAdvanced;
    } else if (goal == 'Bulk') {
      if (level == 'Beginner') plan = bulkBeginner;
      else if (level == 'Intermediate') plan = bulkIntermediate;
      else plan = bulkAdvanced;
    } else if (goal == 'Strength') {
      if (level == 'Beginner') plan = strengthBeginner;
      else if (level == 'Intermediate') plan = strengthIntermediate;
      else plan = strengthAdvanced;
    } else {
      plan = maintain;
    }

    // weekday se aaj ka plan index karo
    return plan[day];
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'Athlete';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greeting()}, $firstName 👋',
              style: const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w400),
            ),
            const Text(
              'Muscle Rich',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF22D3A6)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white54),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthGate()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      // pehle user ka goal/level Firestore se fetch karo
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, userSnap) {
                final data = userSnap.data?.data() as Map<String, dynamic>?;
                final goal = data?['goal'] ?? 'Maintain';
                final level = data?['level'] ?? 'Beginner';
                final today = _todayWorkout(goal, level);
                final goalColor = _goalColor(goal);

                // phir workouts ka real time stream
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('workouts')
                      .where('userId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, snap) {
                    int totalMins = 0;
                    int totalSessions = 0;
                    final List<int> activeDays = [];

                    if (snap.hasData) {
                      totalSessions = snap.data!.docs.length;
                      for (final doc in snap.data!.docs) {
                        final d = doc.data() as Map<String, dynamic>;
                        final secs = ((d['durationSeconds'] ?? 0) as num).toInt();
                        totalMins += secs ~/ 60;
                        final Timestamp? ts = d['timestamp'];
                        if (ts != null) activeDays.add(ts.toDate().weekday);
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView(
                        children: [
                          const SizedBox(height: 16),
                          _heroCard(context),
                          const SizedBox(height: 20),
                          _statsRow(totalMins, totalSessions),
                          const SizedBox(height: 20),
                          _todayCard(today, goalColor),
                          const SizedBox(height: 20),
                          _weeklyProgress(activeDays),
                          const SizedBox(height: 20),
                          _planBanner(context),
                          const SizedBox(height: 30),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // hero card  start workout button
  Widget _heroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2540), Color(0xFF141C2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22D3A6).withOpacity(0.25)),
      ),
      child: Column(
        children: [
          const Text(
            'Train Hard. Track Progress.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.3),
          ),
          const SizedBox(height: 8),
          const Text('Every session moves you forward.', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Start Workout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BodyPartsScreen())),
            ),
          ),
        ],
      ),
    );
  }

  // minutes aur sessions stats
  Widget _statsRow(int mins, int sessions) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Minutes', value: mins.toString(), icon: Icons.timer_rounded, color: const Color(0xFF22D3A6))),
        const SizedBox(width: 14),
        Expanded(child: _StatCard(label: 'Workouts', value: sessions.toString(), icon: Icons.fitness_center_rounded, color: const Color(0xFFB45CFF))),
      ],
    );
  }

  // aaj ka workout card  goal color se border
  Widget _todayCard(Map<String, String> today, Color goalColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2F),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: goalColor, width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Workout", style: TextStyle(fontSize: 12, color: goalColor, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(today['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(today['focus']!, style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: goalColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.bolt_rounded, color: goalColor, size: 28),
          ),
        ],
      ),
    );
  }

  // weekly progress circles  green agar workout kiya
  Widget _weeklyProgress(List<int> activeDays) {
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayWeekday = DateTime.now().weekday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF141C2F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${activeDays.toSet().length}/7 days', style: const TextStyle(color: Color(0xFF22D3A6), fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = i + 1;
              final done = activeDays.contains(day);
              final isToday = todayWeekday == day;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? const Color(0xFF22D3A6) : isToday ? const Color(0xFF22D3A6).withOpacity(0.15) : Colors.white.withOpacity(0.06),
                      border: isToday && !done ? Border.all(color: const Color(0xFF22D3A6), width: 1.5) : null,
                      boxShadow: done ? [BoxShadow(color: const Color(0xFF22D3A6).withOpacity(0.4), blurRadius: 8, spreadRadius: 1)] : null,
                    ),
                    child: done ? const Icon(Icons.check_rounded, size: 16, color: Colors.black) : null,
                  ),
                  const SizedBox(height: 6),
                  Text(labels[i], style: TextStyle(fontSize: 12, color: isToday ? const Color(0xFF22D3A6) : Colors.white54, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // weekly plan ka banner tap karo toh plan screen pe jao
  Widget _planBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1535), Color(0xFF141C2F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB45CFF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('YOUR WEEKLY PLAN', style: TextStyle(fontSize: 11, color: Color(0xFFB45CFF), fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                const SizedBox(height: 6),
                const Text('Structured training,', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('built around your goal.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyPlanScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFB45CFF), borderRadius: BorderRadius.circular(8)),
                    child: const Text('View Plan →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.calendar_month_rounded, size: 52, color: Color(0xFFB45CFF)),
        ],
      ),
    );
  }
}

// reusable stat card widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141C2F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}