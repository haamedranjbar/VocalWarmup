enum Difficulty {
  beginner,
  intermediate,
  advanced,
}

class Warmup {
  final String id;
  final String title;
  final Difficulty difficulty;
  final int bpm;
  final Duration duration;
  final String? description;
  final String? type; // Lip Roll, Hum, Ma, etc.

  Warmup({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.bpm,
    required this.duration,
    this.description,
    this.type,
  });

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}




