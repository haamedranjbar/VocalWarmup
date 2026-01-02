import 'dart:async';
import 'package:flutter/material.dart';
import '../models/warmup.dart';
import '../theme/app_theme.dart';
import '../services/midi_service.dart';

enum VocalRange {
  bass,
  baritone,
  tenor,
  alto,
  mezzo,
  soprano,
}

class PlayerScreen extends StatefulWidget {
  final Warmup warmup;

  const PlayerScreen({
    super.key,
    required this.warmup,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VocalRange selectedRange = VocalRange.tenor;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration get totalDuration => widget.warmup.duration;
  
  final MidiService _midiService = MidiService();
  Timer? _playbackTimer;
  Timer? _progressTimer;
  int _currentNoteIndex = 0;
  List<int> _scaleNotes = [];
  
  @override
  void initState() {
    super.initState();
    _initializeMidi();
    _updateScaleNotes();
  }
  
  Future<void> _initializeMidi() async {
    try {
      await _midiService.loadSoundFont();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا در بارگذاری صدا: $e')),
        );
      }
    }
  }
  
  void _updateScaleNotes() {
    final rootNote = _getRootNoteForRange(selectedRange);
    _scaleNotes = MidiService.getScaleNotes(rootNote, 'major pentatonic');
    _currentNoteIndex = 0;
  }
  
  String _getRootNoteForRange(VocalRange range) {
    switch (range) {
      case VocalRange.bass:
        return 'C2';
      case VocalRange.baritone:
        return 'C3';
      case VocalRange.tenor:
        return 'C4';
      case VocalRange.alto:
        return 'C4';
      case VocalRange.mezzo:
        return 'C5';
      case VocalRange.soprano:
        return 'C5';
    }
  }
  
  void _startPlayback() {
    if (_scaleNotes.isEmpty) return;
    
    setState(() {
      isPlaying = true;
    });
    
    // تایمر برای پخش نت‌ها بر اساس BPM
    final beatDuration = Duration(milliseconds: (60000 / widget.warmup.bpm).round());
    _playbackTimer = Timer.periodic(beatDuration, (timer) {
      if (!mounted || !isPlaying) {
        timer.cancel();
        return;
      }
      
      // توقف نت قبلی
      if (_currentNoteIndex > 0) {
        _midiService.stopNote(_scaleNotes[_currentNoteIndex - 1]);
      }
      
      // پخش نت جدید
      if (_currentNoteIndex < _scaleNotes.length) {
        _midiService.playNote(_scaleNotes[_currentNoteIndex]);
        _currentNoteIndex++;
      } else {
        // شروع دوباره از ابتدا
        _currentNoteIndex = 0;
        _midiService.playNote(_scaleNotes[_currentNoteIndex]);
        _currentNoteIndex++;
      }
    });
    
    // تایمر برای به‌روزرسانی progress
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted || !isPlaying) {
        timer.cancel();
        return;
      }
      
      setState(() {
        currentPosition = currentPosition + const Duration(milliseconds: 100);
        if (currentPosition >= totalDuration) {
          _stopPlayback();
        }
      });
    });
  }
  
  void _stopPlayback() {
    setState(() {
      isPlaying = false;
      currentPosition = Duration.zero;
      _currentNoteIndex = 0;
    });
    
    _playbackTimer?.cancel();
    _progressTimer?.cancel();
    _midiService.stopAllNotes();
  }
  
  @override
  void dispose() {
    _playbackTimer?.cancel();
    _progressTimer?.cancel();
    _midiService.stopAllNotes();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress => totalDuration.inSeconds > 0
      ? currentPosition.inSeconds / totalDuration.inSeconds
      : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  Material(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Title
                  Expanded(
                    child: Text(
                      widget.warmup.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // More button
                  Material(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 16),
                    // Piano Visualizer
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Piano Keys Container
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final pianoWidth = constraints.maxWidth;
                                  return SizedBox(
                                    height: 128,
                                    child: Stack(
                                      children: [
                                        // White Keys
                                        Row(
                                          children: List.generate(7, (index) {
                                            final isActive = index == 3;
                                            return Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: isActive
                                                      ? Colors.white.withOpacity(0.95)
                                                      : Colors.white.withOpacity(0.9),
                                                  border: Border(
                                                    right: index < 6
                                                        ? BorderSide(
                                                            color: Colors.grey.shade300,
                                                            width: 1,
                                                          )
                                                        : BorderSide.none,
                                                  ),
                                                  borderRadius: index == 0
                                                      ? const BorderRadius.only(
                                                          bottomLeft: Radius.circular(8),
                                                        )
                                                      : null,
                                                ),
                                                child: isActive
                                                    ? Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                            colors: [
                                                              Colors.white,
                                                              AppTheme.primaryColor.withOpacity(0.1),
                                                            ],
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppTheme.primaryColor.withOpacity(0.3),
                                                              blurRadius: 20,
                                                              offset: const Offset(0, -10),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            );
                                          }),
                                        ),
                                        // Black Keys
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: SizedBox(
                                            width: pianoWidth,
                                            height: 80,
                                            child: Stack(
                                              children: [
                                                // Black key 1 (after first white key - C#)
                                                Positioned(
                                                  left: pianoWidth * 0.10 - (pianoWidth * 0.08 / 2),
                                                  width: pianoWidth * 0.08,
                                                  child: Container(
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: const BorderRadius.only(
                                                        bottomLeft: Radius.circular(8),
                                                        bottomRight: Radius.circular(8),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Black key 2 (D#)
                                                Positioned(
                                                  left: pianoWidth * 0.245 - (pianoWidth * 0.08 / 2),
                                                  width: pianoWidth * 0.08,
                                                  child: Container(
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: const BorderRadius.only(
                                                        bottomLeft: Radius.circular(8),
                                                        bottomRight: Radius.circular(8),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Black key 3 (F# - after E-F gap)
                                                Positioned(
                                                  left: pianoWidth * 0.53 - (pianoWidth * 0.08 / 2),
                                                  width: pianoWidth * 0.08,
                                                  child: Container(
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: const BorderRadius.only(
                                                        bottomLeft: Radius.circular(8),
                                                        bottomRight: Radius.circular(8),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Black key 4 (G#)
                                                Positioned(
                                                  left: pianoWidth * 0.675 - (pianoWidth * 0.08 / 2),
                                                  width: pianoWidth * 0.08,
                                                  child: Container(
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: const BorderRadius.only(
                                                        bottomLeft: Radius.circular(8),
                                                        bottomRight: Radius.circular(8),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                // Black key 5 (A#)
                                                Positioned(
                                                  left: pianoWidth * 0.82 - (pianoWidth * 0.08 / 2),
                                                  width: pianoWidth * 0.08,
                                                  child: Container(
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: const BorderRadius.only(
                                                        bottomLeft: Radius.circular(8),
                                                        bottomRight: Radius.circular(8),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              // Visualizer label
                              Text(
                                'VISUALIZER',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Meta Info
                        const SizedBox(height: 32),
                        Text(
                          'Major Pentatonic',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.warmup.bpm} BPM • Key of C',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),

                    // Vocal Range Selector
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Vocal Range',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildVocalRangeChip(VocalRange.bass, 'Bass'),
                              const SizedBox(width: 12),
                              _buildVocalRangeChip(VocalRange.baritone, 'Baritone'),
                              const SizedBox(width: 12),
                              _buildVocalRangeChip(VocalRange.tenor, 'Tenor'),
                              const SizedBox(width: 12),
                              _buildVocalRangeChip(VocalRange.alto, 'Alto'),
                              const SizedBox(width: 12),
                              _buildVocalRangeChip(VocalRange.mezzo, 'Mezzo'),
                              const SizedBox(width: 12),
                              _buildVocalRangeChip(VocalRange.soprano, 'Soprano'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Progress & Controls
                    Column(
                      children: [
                        // Progress Bar
                        Column(
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final progressWidth = constraints.maxWidth;
                                return Stack(
                                  children: [
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: _progress,
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          borderRadius: BorderRadius.circular(3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryColor.withOpacity(0.3),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: (progressWidth * _progress) - 6,
                                      top: -3,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(currentPosition),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(totalDuration),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Playback Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Previous button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.skip_previous,
                                    size: 36,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            // Play/Pause button
                            Material(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(40),
                              child: InkWell(
                                onTap: () {
                                  if (isPlaying) {
                                    _stopPlayback();
                                  } else {
                                    _startPlayback();
                                  }
                                },
                                borderRadius: BorderRadius.circular(40),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.4),
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 48,
                                    color: AppTheme.backgroundDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            // Next button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(24),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Icon(
                                    Icons.skip_next,
                                    size: 36,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget                               _buildVocalRangeChip(VocalRange range, String label) {
    final isSelected = selectedRange == range;

    return Material(
      color: isSelected
          ? AppTheme.primaryColor
          : Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          if (isPlaying) {
            _stopPlayback();
          }
          setState(() {
            selectedRange = range;
            _updateScaleNotes();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          transform: isSelected 
              ? (Matrix4.identity()..scale(1.05)) 
              : Matrix4.identity(),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppTheme.backgroundDark : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

