import 'package:flutter/material.dart';
import '../models/warmup.dart';
import '../theme/app_theme.dart';

class DifficultyIndicator extends StatelessWidget {
  final Difficulty difficulty;

  const DifficultyIndicator({
    super.key,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getDifficultyColor(difficulty);
    final shadow = AppTheme.getDifficultyShadow(difficulty);

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [shadow],
      ),
    );
  }
}




