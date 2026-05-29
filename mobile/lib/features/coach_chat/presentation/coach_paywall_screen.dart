import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shown when the student does not have a premium subscription.
/// Displays a lock icon, heading, description, and CTA to upgrade.
class CoachPaywallScreen extends StatelessWidget {
  const CoachPaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Coach Chat',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available on Premium',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Get direct feedback from your coach after every session.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () => context.goNamed('paywall'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                    child: Semantics(
                      label: 'Upgrade to Premium subscription',
                      child: const Text('Upgrade to Premium'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
