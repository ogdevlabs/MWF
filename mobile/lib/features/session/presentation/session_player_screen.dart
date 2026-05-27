import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/database/app_database.dart';
import '../data/session_datasource.dart';
import '../domain/session_model.dart';
import 'cue_text_strip.dart';
import 'exercise_video_player.dart';

/// Main session player screen (FR-005, FR-013).
/// ConsumerStatefulWidget needed for VideoPlayerController lifecycle.
///
/// Layout per UI-SPEC Screen 2:
/// - Expanded video area (Chewie) with overlay zone
/// - Cue text strip below video
/// - Progress indicator + Next button at bottom
///
/// Resume (FR-013, D-15):
/// - On init, loads exercise index from SessionResumeDao
/// - On each Next tap, saves new index to SessionResumeDao
/// - On session complete, clears resume state
class SessionPlayerScreen extends ConsumerStatefulWidget {
  const SessionPlayerScreen({
    super.key,
    required this.programId,
    required this.sessionId,
  });

  final String programId;
  final String sessionId;

  @override
  ConsumerState<SessionPlayerScreen> createState() =>
      _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends ConsumerState<SessionPlayerScreen> {
  List<ExerciseModel> _exercises = [];
  int _currentIndex = 0;
  bool _nextEnabled = false;
  bool _isLoading = true;
  DateTime? _sessionStartTime;

  AppDatabase get _db => ref.read(appDatabaseProvider);

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await ref
        .read(sessionDatasourceProvider)
        .getExercisesBySession(widget.sessionId);

    // Load resume state (FR-013, D-15)
    final resumeState =
        await _db.sessionResumeDao.getResumeState(widget.sessionId);
    final resumeIndex = resumeState?.exerciseIndex ?? 0;

    setState(() {
      _exercises = exercises;
      _currentIndex = exercises.isEmpty
          ? 0
          : resumeIndex.clamp(0, exercises.length - 1);
      _isLoading = false;
      // If exercise is rep-based or timer-based, Next starts disabled
      // If neither (no rep or duration), Next is always enabled
      _nextEnabled = _currentExerciseHasNoTarget();
    });
  }

  bool _currentExerciseHasNoTarget() {
    if (_exercises.isEmpty) return false;
    final ex = _exercises[_currentIndex];
    return ex.repCount == null && ex.durationSeconds == null;
  }

  ExerciseModel? get _currentExercise =>
      _exercises.isNotEmpty ? _exercises[_currentIndex] : null;

  bool get _isLastExercise => _currentIndex == _exercises.length - 1;

  void _onNextTapped() {
    if (_isLastExercise) {
      _completeSession();
    } else {
      _goToExercise(_currentIndex + 1);
    }
  }

  Future<void> _goToExercise(int index) async {
    // Save resume state (FR-013)
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await _db.sessionResumeDao.saveResumeState(
        widget.sessionId,
        user.id,
        index,
      );
    }

    setState(() {
      _currentIndex = index;
      _nextEnabled = _currentExerciseHasNoTarget();
    });
  }

  Future<void> _completeSession() async {
    final durationSeconds = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;

    // Clear resume state on completion
    await _db.sessionResumeDao.clearResumeState(widget.sessionId);

    // Navigate to completion screen with data
    if (mounted) {
      context.goNamed(
        'session-complete',
        pathParameters: {
          'programId': widget.programId,
          'sessionId': widget.sessionId,
        },
        extra: {
          'exerciseCount': _exercises.length,
          'durationSeconds': durationSeconds,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No exercises in this session.')),
      );
    }

    final exercise = _currentExercise!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video area (Expanded, ~65% screen)
            Expanded(
              child: Stack(
                children: [
                  // Video player
                  ExerciseVideoPlayer(
                    key: ValueKey(exercise.id),
                    exercise: exercise,
                    db: _db,
                  ),
                  // Close button (top-right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _buildCloseButton(context),
                  ),
                  // 3D model toggle button (top-left) — shown if model exists
                  if (exercise.modelAssetUrl != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _build3DToggleButton(context),
                    ),
                ],
              ),
            ),
            // Cue text strip (D-08)
            CueTextStrip(cueText: exercise.cueText),
            // Progress + Next button
            Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Text(
                    'Exercise ${_currentIndex + 1} of ${_exercises.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _nextEnabled ? _onNextTapped : null,
                      child: Text(
                        _isLastExercise ? 'Finish Session' : 'Next Exercise',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => context.pop(),
        tooltip: 'Close',
      ),
    );
  }

  Widget _build3DToggleButton(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.view_in_ar, color: Colors.white),
        onPressed: () {
          // Plan 05 implements the 3D model bottom sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('3D model viewer loading...')),
          );
        },
        tooltip: '3D form reference',
      ),
    );
  }
}
