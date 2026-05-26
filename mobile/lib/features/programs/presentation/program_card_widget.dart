import 'package:flutter/material.dart';

import '../domain/program_model.dart';

/// Reusable program card showing thumbnail, title, difficulty badge,
/// duration, and lock overlay when not subscribed.
class ProgramCard extends StatelessWidget {
  const ProgramCard({
    super.key,
    required this.program,
    required this.onTap,
  });

  final ProgramModel program;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail with lock overlay
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (program.thumbnailUrl != null)
                    Image.network(
                      program.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.fitness_center, size: 40),
                      ),
                    )
                  else
                    Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.fitness_center, size: 40),
                    ),
                  // Lock overlay for non-subscribed users
                  if (program.isLocked)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 32),
                      ),
                    ),
                ],
              ),
            ),
            // Title + metadata
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _DifficultyBadge(difficulty: program.difficulty),
                      const SizedBox(width: 8),
                      Text(
                        '${program.durationWeeks} weeks',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (program.isEnrolled && program.canAccess) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: program.currentDay / (program.durationWeeks * 7),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Day ${program.currentDay}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty.toLowerCase()) {
      'beginner' => Colors.green,
      'intermediate' => Colors.orange,
      'advanced' => Colors.red,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        difficulty.substring(0, 1).toUpperCase() + difficulty.substring(1),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
