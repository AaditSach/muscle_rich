import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'exercise_screen.dart';

class ExercisesListScreen extends StatelessWidget {
  final String bodyPart;

  const ExercisesListScreen({super.key, required this.bodyPart});

  // body part ke hisaab se accent color
  Color _accentFor(String part) {
    if (part == 'Chest') return const Color(0xFF22D3A6);
    if (part == 'Back') return const Color(0xFFB45CFF);
    if (part == 'Legs') return const Color(0xFF36D1DC);
    if (part == 'Arms') return const Color(0xFFFFB347);
    if (part == 'Shoulders') return const Color(0xFFFF6B6B);
    if (part == 'Core') return const Color(0xFF4ECDC4);
    return const Color(0xFF22D3A6);
  }

  Color _levelColor(String level) {
    if (level == 'Beginner') return const Color(0xFF22D3A6);
    if (level == 'Intermediate') return const Color(0xFFFFB347);
    if (level == 'Advanced') return const Color(0xFFFF6B6B);
    return Colors.white38;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(bodyPart);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('$bodyPart Exercises', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      // Firestore se is body part ke exercises real time mein fetch karo
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exercises')
            .where('bodyPart', isEqualTo: bodyPart)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading exercises'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF22D3A6)));

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center_rounded, size: 48, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  const Text('No exercises found', style: TextStyle(color: Colors.white38, fontSize: 16)),
                ],
              ),
            );
          }

          // exercises ko difficulty level se group karo
          final beginner = docs.where((d) => d['Level'] == 'Beginner').toList();
          final intermediate = docs.where((d) => d['Level'] == 'Intermediate').toList();
          final advanced = docs.where((d) => d['Level'] == 'Advanced').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _section(context, 'Beginner', beginner, accent),
              _section(context, 'Intermediate', intermediate, accent),
              _section(context, 'Advanced', advanced, accent),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // ek difficulty section  title aur exercise cards
  Widget _section(BuildContext context, String title, List<QueryDocumentSnapshot> docs, Color accent) {
    if (docs.isEmpty) return const SizedBox();

    final lColor = _levelColor(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: lColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: lColor.withOpacity(0.4))),
              child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: lColor, letterSpacing: 0.5)),
            ),
            const SizedBox(width: 10),
            Text('${docs.length} exercise${docs.length > 1 ? 's' : ''}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        ...docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Exercise';
          final description = data['description'] ?? '';
          final videoPath = data['videoPath'] ?? '';

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExerciseScreen(
                  title: name,
                  description: description,
                  videoPath: videoPath,
                  bodyPart: bodyPart,
                ),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF141C2F), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Row(
                children: [
                  // video ka thumbnail - Firebase Storage URL se generate hota hai
                  _VideoThumbnail(videoUrl: videoPath, accent: accent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white38)),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: accent.withOpacity(0.7)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// video thumbnail widget 500ms pe seek karke first frame capture karta hai
class _VideoThumbnail extends StatefulWidget {
  final String videoUrl;
  final Color accent;

  const _VideoThumbnail({required this.videoUrl, required this.accent});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.isEmpty) return;
    // Firebase Storage URL se video load karo  500ms pe seek karke thumbnail banao
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (!mounted) return;
        _controller!.seekTo(const Duration(milliseconds: 500));
        setState(() => _ready = true);
      }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 64,
        height: 64,
        child: _ready
            ? Stack(
                fit: StackFit.expand,
                children: [
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                  Container(color: Colors.black.withOpacity(0.25)),
                  Center(child: Icon(Icons.play_circle_fill_rounded, color: Colors.white.withOpacity(0.9), size: 24)),
                ],
              )
            // video load nahi hua toh placeholder icon
            : Container(
                color: widget.accent.withOpacity(0.12),
                child: Center(child: Icon(Icons.fitness_center_rounded, color: widget.accent, size: 24)),
              ),
      ),
    );
  }
}