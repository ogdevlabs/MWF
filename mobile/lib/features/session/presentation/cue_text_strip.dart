import 'package:flutter/material.dart';

/// Persistent strip below the video showing exercise cue text (D-08).
/// Hidden (zero height) when cueText is null or empty.
class CueTextStrip extends StatelessWidget {
  const CueTextStrip({super.key, this.cueText});

  final String? cueText;

  @override
  Widget build(BuildContext context) {
    if (cueText == null || cueText!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        child: Text(
          cueText!,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
