import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/onboarding_prefs_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      title: 'Coach-Designed Programs',
      subtitle: 'Follow structured multi-week Mat Pilates programs created by your coach.',
      icon: Icons.fitness_center,
    ),
    _SlideData(
      title: 'Video + 3D Guidance',
      subtitle: 'Every exercise includes video demonstrations and 3D form references.',
      icon: Icons.play_circle_outline,
    ),
    _SlideData(
      title: 'Track Your Progress',
      subtitle: 'Log body metrics, build streaks, and watch your improvement over time.',
      icon: Icons.trending_up,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final service = ref.read(onboardingPrefsServiceProvider);
    await service.markOnboardingSeen();
    ref.invalidate(onboardingSeenProvider);
    if (mounted) {
      context.goNamed('programs');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(slide.icon, size: 80, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.subtitle,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == i
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _currentPage == _slides.length - 1
                      ? _completeOnboarding
                      : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(
                    _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
            if (_currentPage < _slides.length - 1)
              TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Skip'),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;
}
