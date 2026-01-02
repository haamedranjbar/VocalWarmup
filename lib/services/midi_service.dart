import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';

class MidiService {
  static final MidiService _instance = MidiService._internal();
  factory MidiService() => _instance;
  MidiService._internal();

  final FlutterMidi _flutterMidi = FlutterMidi();
  bool _isInitialized = false;

  /// بارگذاری SoundFont
  Future<void> loadSoundFont() async {
    if (_isInitialized) return;

    try {
      final ByteData byteData = await rootBundle.load('assets/piano.sf2');
      await _flutterMidi.prepare(sf2: byteData);
      _isInitialized = true;
    } catch (e) {
      throw Exception('خطا در بارگذاری SoundFont: $e');
    }
  }

  /// پخش یک نت MIDI
  /// [midiNote]: شماره نت MIDI (0-127)
  void playNote(int midiNote) {
    if (!_isInitialized) {
      throw Exception('SoundFont هنوز بارگذاری نشده است');
    }
    _flutterMidi.playMidiNote(midi: midiNote);
  }

  /// توقف یک نت MIDI
  void stopNote(int midiNote) {
    if (!_isInitialized) return;
    _flutterMidi.stopMidiNote(midi: midiNote);
  }

  /// توقف تمام نت‌ها
  void stopAllNotes() {
    if (!_isInitialized) return;
    // متوقف کردن نت‌های رایج (C0 تا C8)
    for (int i = 0; i <= 127; i++) {
      _flutterMidi.stopMidiNote(midi: i);
    }
  }

  /// تبدیل نام نت به شماره MIDI
  /// مثال: noteToMidi('C4') => 60
  static int noteToMidi(String note) {
    final noteMap = {
      'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3,
      'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8,
      'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11,
    };

    final regex = RegExp(r'^([A-G][#b]?)(\d+)$');
    final match = regex.firstMatch(note);
    if (match == null) {
      throw ArgumentError('فرمت نام نت نامعتبر: $note');
    }

    final noteName = match.group(1)!;
    final octave = int.parse(match.group(2)!);

    final noteValue = noteMap[noteName];
    if (noteValue == null) {
      throw ArgumentError('نام نت نامعتبر: $noteName');
    }

    return (octave + 1) * 12 + noteValue;
  }

  /// تبدیل شماره MIDI به نام نت
  /// مثال: midiToNote(60) => 'C4'
  static String midiToNote(int midi) {
    if (midi < 0 || midi > 127) {
      throw ArgumentError('شماره MIDI باید بین 0 تا 127 باشد');
    }

    final noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final octave = (midi ~/ 12) - 1;
    final note = midi % 12;
    return '${noteNames[note]}$octave';
  }

  /// دریافت نت‌های یک گام (scale)
  /// مثال: getScaleNotes('C', 'major') => [60, 62, 64, 65, 67, 69, 71]
  static List<int> getScaleNotes(String rootNote, String scaleType) {
    final rootMidi = noteToMidi(rootNote);
    final intervals = _getScaleIntervals(scaleType);
    
    return intervals.map((interval) => rootMidi + interval).toList();
  }

  static List<int> _getScaleIntervals(String scaleType) {
    switch (scaleType.toLowerCase()) {
      case 'major':
      case 'major pentatonic':
        return [0, 2, 4, 7, 9]; // Pentatonic Major
      case 'minor':
        return [0, 2, 3, 5, 7, 8, 10];
      case 'minor pentatonic':
        return [0, 3, 5, 7, 10];
      case 'chromatic':
        return List.generate(12, (i) => i);
      default:
        return [0, 2, 4, 7, 9]; // پیش‌فرض: Major Pentatonic
    }
  }

  /// پاک کردن منابع
  void dispose() {
    stopAllNotes();
    _isInitialized = false;
  }
}

