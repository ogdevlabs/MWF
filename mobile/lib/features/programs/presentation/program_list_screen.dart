import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/programs_repository.dart';
import '../domain/program_model.dart';
import 'program_card_widget.dart';

/// Displays a grid of program cards.
/// Locked programs navigate to /paywall on tap.
/// Unlocked programs navigate to program-detail.
class ProgramListScreen extends ConsumerWidget {
  const ProgramListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programs'),
      ),
      body: programsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load programs',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(programsListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (programs) {
          if (programs.isEmpty) {
            return const Center(
              child: Text('No programs available yet'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(programsListProvider),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return ProgramCard(
                      program: program,
                      onTap: () => _onProgramTap(context, program),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _onProgramTap(BuildContext context, ProgramModel program) {
    if (program.isLocked) {
      // Not subscribed — show paywall
      context.goNamed('paywall');
    } else {
      // Subscribed — navigate to program detail
      context.pushNamed(
        'program-detail',
        pathParameters: {'programId': program.id},
      );
    }
  }
}
