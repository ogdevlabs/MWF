import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../coach_chat/presentation/feedback_compose_bottom_sheet.dart';
import '../../metrics/presentation/metric_log_bottom_sheet.dart';

/// Full-screen session completion screen (D-12, FR-012).
/// Shows: title, duration, exercise count, streak badge, three CTAs.
/// Animations: fade-in over 400ms, stat cards stagger slide-up.
class SessionCompletionScreen extends ConsumerStatefulWidget {
  const SessionCompletionScreen({
    super.key,
    required this.programId,
    required this.sessionId,
    required this.sessionTitle,
    required this.durationSeconds,
    required this.exerciseCount,
    required this.streak,
    this.studentId,
  });

  final String programId;
  final String sessionId;
  final String sessionTitle;
  final int durationSeconds;
  final int exerciseCount;
  final int streak;
  /// Optional studentId to enable the Log Metrics prompt (FR-008 / US4).
  final String? studentId;

  @override
  ConsumerState<SessionCompletionScreen> createState() =>
      _SessionCompletionScreenState();
}

class _SessionCompletionScreenState
    extends ConsumerState<SessionCompletionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _staggerController;
  late final Animation<double> _fadeAnimation;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimations = List.generate(3, (i) {
      final start = i * 0.33;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Title
                Text(
                  'Session Complete',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.sessionTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Stat cards (3 in a row, staggered)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SlideTransition(
                      position: _slideAnimations[0],
                      child: _buildStatCard(
                        theme,
                        _formatDuration(widget.durationSeconds),
                        'duration',
                      ),
                    ),
                    SlideTransition(
                      position: _slideAnimations[1],
                      child: _buildStatCard(
                        theme,
                        '${widget.exerciseCount}',
                        'exercises',
                      ),
                    ),
                    SlideTransition(
                      position: _slideAnimations[2],
                      child: _buildStatCard(
                        theme,
                        '\u{1F525} ${widget.streak}',
                        'day streak',
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                // CTAs
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (sheetContext) => FeedbackComposeBottomSheet(
                          sessionId: widget.sessionId,
                          sessionTitle: widget.sessionTitle,
                        ),
                      );
                    },
                    child: const Text('Send Feedback to Coach'),
                  ),
                ),
                const SizedBox(height: 12),
                // FR-008 / US4: Non-blocking metric log prompt
                if (widget.studentId != null)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => const MetricLogBottomSheet(),
                      ),
                      icon: const Icon(Icons.monitor_weight_outlined),
                      label: const Text('Log Today\'s Metrics'),
                    ),
                  ),
                if (widget.studentId != null) const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      // D-14: Back to program detail
                      context.go('/programs/${widget.programId}');
                    },
                    child: const Text('Back to Program'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String value, String label) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 100,
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
