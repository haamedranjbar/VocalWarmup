import 'package:flutter/material.dart';
import '../models/warmup.dart';
import '../theme/app_theme.dart';
import 'difficulty_indicator.dart';

class WarmupCard extends StatelessWidget {
  final Warmup warmup;
  final VoidCallback? onTap;

  const WarmupCard({
    super.key,
    required this.warmup,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Difficulty indicator
            const SizedBox(width: 16),
            DifficultyIndicator(difficulty: warmup.difficulty),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    warmup.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${warmup.bpm} BPM',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        warmup.formattedDuration,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Play button
            const SizedBox(width: 16),
            IconButton(
              onPressed: onTap,
              icon: Icon(
                Icons.play_circle_outline,
                size: 44,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              hoverColor: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }
}

