import 'package:flutter/material.dart';
import 'package:muscle_rich/screens/workout/exercises_list.dart';

class BodyPartsScreen extends StatelessWidget {
  const BodyPartsScreen({super.key});

  // 6 body parts  har ek ka label, icon, color aur Unsplash image
  static const _bodyParts = [
    {
      'label': 'Chest',
      'icon': Icons.accessibility_new_rounded,
      'color': Color(0xFF22D3A6),
      'image': 'https://images.unsplash.com/photo-1534368959876-26bf04f2c947?w=400&q=80',
    },
    {
      'label': 'Back',
      'icon': Icons.airline_seat_flat_rounded,
      'color': Color(0xFFB45CFF),
      'image': 'https://images.unsplash.com/photo-1603287681836-b174ce5074c2?w=400&q=80',
    },
    {
      'label': 'Legs',
      'icon': Icons.directions_run_rounded,
      'color': Color(0xFF36D1DC),
      'image': 'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?w=400&q=80',
    },
    {
      'label': 'Arms',
      'icon': Icons.fitness_center_rounded,
      'color': Color(0xFFFFB347),
      'image': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=400&q=80',
    },
    {
      'label': 'Shoulders',
      'icon': Icons.sports_gymnastics_rounded,
      'color': Color(0xFFFF6B6B),
      'image': 'https://images.unsplash.com/photo-1532029837206-abbe2b7620e3?w=400&q=80',
    },
    {
      'label': 'Core',
      'icon': Icons.self_improvement_rounded,
      'color': Color(0xFF4ECDC4),
      'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Choose Body Part', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        // 2 column grid  tap karo toh exercises list pe jao
        child: GridView.builder(
          itemCount: _bodyParts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, i) {
            final part = _bodyParts[i];
            final accent = part['color'] as Color;

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExercisesListScreen(bodyPart: part['label'] as String),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // background image Unsplash se
                    Image.network(
                      part['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF141C2F)),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : Container(color: const Color(0xFF141C2F)),
                    ),
                    // dark overlay taaki text readable ho
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.75)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // accent color tint
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accent.withOpacity(0.15), Colors.transparent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // body part name aur icon bottom mein
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: accent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: Icon(part['icon'] as IconData, color: accent, size: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            part['label'] as String,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 6)]),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text('View exercises', style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, size: 12, color: accent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}