import 'package:flutter/material.dart';

/// Tap-to-count overlay for rep-based exercises (D-06).
/// Displays "current / target reps". Each tap increments count.
/// When count reaches target, calls onTargetReached to enable Next button.
/// Full overlay area is the tap target (GestureDetector).
class RepCounterOverlay extends StatefulWidget {
  const RepCounterOverlay({
    super.key,
    required this.target,
    required this.onTargetReached,
  });

  final int target;
  final VoidCallback onTargetReached;

  @override
  State<RepCounterOverlay> createState() => _RepCounterOverlayState();
}

class _RepCounterOverlayState extends State<RepCounterOverlay> {
  int _count = 0;
  bool _targetHit = false;

  void _increment() {
    if (_targetHit) return;
    setState(() => _count++);
    if (_count >= widget.target) {
      _targetHit = true;
      widget.onTargetReached();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _increment,
      behavior: HitTestBehavior.translucent,
      child: Center(
        child: Semantics(
          label: '$_count of ${widget.target} reps, tap to increment',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_count / ${widget.target} reps',
                  style: TextStyle(
                    fontSize: 32,
                    color: _targetHit
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!_targetHit)
                  Text(
                    '(tap anywhere)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
