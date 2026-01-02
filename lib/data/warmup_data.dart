import '../models/warmup.dart';

class WarmupData {
  static List<Warmup> getWarmups() {
    return [
      // Spec data
      Warmup(
        id: '1',
        title: 'Lip Roll Warmup',
        difficulty: Difficulty.beginner,
        bpm: 120,
        duration: const Duration(minutes: 2, seconds: 15),
        type: 'Lip Roll',
      ),
      Warmup(
        id: '2',
        title: 'Short & Easy',
        difficulty: Difficulty.beginner,
        bpm: 110,
        duration: const Duration(minutes: 3, seconds: 35),
        type: 'Basic',
      ),
      Warmup(
        id: '3',
        title: 'Essential Warmup',
        difficulty: Difficulty.intermediate,
        bpm: 135,
        duration: const Duration(minutes: 5, seconds: 0),
        type: 'Fundamental',
      ),
      Warmup(
        id: '4',
        title: 'Extended Range',
        difficulty: Difficulty.advanced,
        bpm: 160,
        duration: const Duration(minutes: 7, seconds: 45),
        type: 'Range',
      ),
    ];
  }
}




