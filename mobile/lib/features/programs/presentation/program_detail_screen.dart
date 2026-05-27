import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../data/programs_repository.dart';
import '../domain/program_model.dart';
import '../../session/domain/session_model.dart';
import '../../session/data/session_providers.dart';
import '../../session/presentation/session_list_tile.dart';

/// Program detail screen showing:
/// - Header image/thumbnail
/// - Title, description, difficulty badge, duration
/// - Enroll/Continue CTA
/// - Session list placeholder (Phase 4 will add real sessions)
class ProgramDetailScreen extends ConsumerWidget {
  const ProgramDetailScreen({
    super.key,
    required this.programId,
  });

  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programsListProvider);

    return programsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error loading program: $error')),
      ),
      data: (programs) {
        final program =
            programs.where((p) => p.id == programId).firstOrNull;
        if (program == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Program not found')),
          );
        }
        return _ProgramDetailBody(program: program);
      },
    );
  }
}

class _ProgramDetailBody extends ConsumerWidget {
  const _ProgramDetailBody({required this.program});
  final ProgramModel program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing header with thumbnail
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(program.title),
              background: program.thumbnailUrl != null
                  ? Image.network(
                      program.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Metadata row
                Row(
                  children: [
                    _buildDifficultyChip(context),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${program.durationWeeks} weeks',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                if (program.description != null) ...[
                  Text(
                    program.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                ],
                // Enrollment state
                if (program.isEnrolled) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Progress',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: program.currentDay /
                                (program.durationWeeks * 7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Day ${program.currentDay} of ${program.durationWeeks * 7}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Session list header
                Text('Sessions',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                // Real session list (FR-004, D-09)
                if (program.isEnrolled)
                  Consumer(
                    builder: (context, ref, _) {
                      final sessionsAsync = ref.watch(
                        sessionsWithStateProvider(
                          programId: program.id,
                          currentDay: program.currentDay,
                        ),
                      );
                      return sessionsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Error loading sessions: $e'),
                          ),
                        ),
                        data: (sessions) => Column(
                          children: sessions
                              .map((session) => SessionListTile(
                                    session: session,
                                    onTap: () => context.goNamed(
                                      'session-player',
                                      pathParameters: {
                                        'programId': program.id,
                                        'sessionId': session.id,
                                      },
                                    ),
                                  ))
                              .toList(),
                        ),
                      );
                    },
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Enroll to see sessions.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
      // Bottom CTA
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildCTA(context, ref),
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context, WidgetRef ref) {
    if (program.isLocked) {
      return FilledButton(
        onPressed: () => context.goNamed('paywall'),
        child: const Text('Subscribe to Access'),
      );
    }
    if (program.isEnrolled) {
      final sessionsAsync = ref.watch(
        sessionsWithStateProvider(
          programId: program.id,
          currentDay: program.currentDay,
        ),
      );
      return sessionsAsync.when(
        loading: () => const FilledButton(
          onPressed: null,
          child: Text('Loading...'),
        ),
        error: (_, _) => const FilledButton(
          onPressed: null,
          child: Text('Continue Program'),
        ),
        data: (sessions) {
          final currentSession = sessions
              .where((s) => s.state == SessionState.current)
              .firstOrNull;
          return FilledButton(
            onPressed: currentSession != null
                ? () => context.goNamed(
                      'session-player',
                      pathParameters: {
                        'programId': program.id,
                        'sessionId': currentSession.id,
                      },
                    )
                : null,
            child: Text(
              program.currentDay == 1 ? 'Start Program' : 'Continue Program',
            ),
          );
        },
      );
    }
    // Subscribed but not enrolled
    return FilledButton(
      onPressed: () => _enroll(context, ref),
      child: const Text('Enroll in Program'),
    );
  }

  Future<void> _enroll(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(programsRepositoryProvider).enrollStudent(
            studentId: user.id,
            programId: program.id,
          );
      ref.invalidate(programsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enrolled successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enrollment failed: $e')),
        );
      }
    }
  }

  Widget _buildDifficultyChip(BuildContext context) {
    final color = switch (program.difficulty.toLowerCase()) {
      'beginner' => Colors.green,
      'intermediate' => Colors.orange,
      'advanced' => Colors.red,
      _ => Colors.grey,
    };
    return Chip(
      label: Text(program.difficulty),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      labelStyle: TextStyle(color: color, fontSize: 12),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
