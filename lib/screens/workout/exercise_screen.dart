import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'workout_screen.dart';

class ExerciseScreen extends StatefulWidget {
  final String title;
  final String description;
  final String videoPath;
  final String bodyPart;

  const ExerciseScreen({
    super.key,
    required this.title,
    required this.description,
    required this.videoPath,
    required this.bodyPart,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late VideoPlayerController _controller;
  bool _videoReady = false;
  bool _playing = false;

  Color get _accent {
    if (widget.bodyPart == 'Chest') return const Color(0xFF22D3A6);
    if (widget.bodyPart == 'Back') return const Color(0xFFB45CFF);
    if (widget.bodyPart == 'Legs') return const Color(0xFF36D1DC);
    if (widget.bodyPart == 'Arms') return const Color(0xFFFFB347);
    if (widget.bodyPart == 'Shoulders') return const Color(0xFFFF6B6B);
    if (widget.bodyPart == 'Core') return const Color(0xFF4ECDC4);
    return const Color(0xFF22D3A6);
  }

  @override
  void initState() {
    super.initState();
    // Firebase Storage URL se video initialize karo aur auto play karo
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        setState(() => _videoReady = true);
        _controller.setLooping(true);
        _controller.play();
        _playing = true;
      }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // play/pause toggle
  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _playing = false;
      } else {
        _controller.play();
        _playing = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // video player  tap karo play/pause ke liye
          GestureDetector(
            onTap: _videoReady ? _togglePlay : null,
            child: Container(
              width: double.infinity,
              height: 240,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF141C2F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _videoReady ? _videoPlayer() : _loadingPlaceholder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    _Tag(label: widget.bodyPart, color: _accent),
                    const SizedBox(width: 8),
                    _Tag(label: 'Exercise Demo', color: Colors.white24),
                  ],
                ),
                const SizedBox(height: 16),
                Text(widget.description, style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.6)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text('Start Workout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    // workout screen pe bhejo  body part aur exercise name pass karo
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutScreen(bodyPart: widget.bodyPart, exerciseName: widget.title),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoPlayer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
        // paused hone pe play icon dikhao
        AnimatedOpacity(
          opacity: _playing ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
            child: Icon(Icons.play_arrow_rounded, color: _accent, size: 32),
          ),
        ),
      ],
    );
  }

  // video load hone tak placeholder
  Widget _loadingPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _accent.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.fitness_center_rounded, color: _accent, size: 40),
        ),
        const SizedBox(height: 12),
        Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Loading video...', style: TextStyle(color: Colors.white38, fontSize: 13)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color == Colors.white24 ? Colors.white54 : color),
      ),
    );
  }
}