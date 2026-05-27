import 'dart:async';

import 'package:flutter/material.dart';

/// Countdown timer overlay for duration-based exercises (D-07).
/// Counts down from durationSeconds to zero.
/// When zero is reached, calls onComplete to enable Next button.
/// Timer is cancelled on dispose (prevents setState-after-dispose).
class TimerCountdownOverlay extends StatefulWidget {
  const TimerCountdownOverlay({
    super.key,
    required this.durationSeconds,
    required this.onComplete,
  });

  final int durationSeconds;
  final VoidCallback onComplete;

  @override
  State<TimerCountdownOverlay> createState() => _TimerCountdownOverlayState();
}

class _TimerCountdownOverlayState extends State<TimerCountdownOverlay> {
  late int _remaining;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        _timer?.cancel();
        setState(() {
          _remaining = 0;
          _completed = true;
        });
        widget.onComplete();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mins = _remaining ~/ 60;
    final secs = _remaining % 60;
    final timeText =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Center(
      child: Semantics(
        label: '$mins minutes $secs seconds remaining',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            timeText,
            style: TextStyle(
              fontSize: 48,
              color: _completed
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
