import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons.dart';

/// Onboarding screen — 3 slides with PageView
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = const [
    _Slide(icon: Icons.people_rounded, title: 'Find Sports Friends', subtitle: 'Connect with people who share your passion for sports, near you.'),
    _Slide(icon: Icons.groups_rounded, title: 'Join Communities', subtitle: 'Be part of active sports communities. Play together, grow together.'),
    _Slide(icon: Icons.event_available_rounded, title: 'Create Activities', subtitle: 'Organize events, track attendance, and book courts seamlessly.'),
  ];

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Skip', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ),
            ),
            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                      child: Icon(slide.icon, size: 56, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 32),
                    Text(slide.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text(slide.subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
                  ]);
                },
              ),
            ),
            // Dots
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 24 : 8, height: 8,
              decoration: BoxDecoration(
                color: _currentPage == i ? AppColors.buttonPrimary : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
            ))),
            const SizedBox(height: 32),
            // Button
            PrimaryButton(
              label: _currentPage == 2 ? 'Get Started' : 'Next',
              onPressed: () {
                if (_currentPage < 2) {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                } else {
                  context.go('/login');
                }
              },
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Slide({required this.icon, required this.title, required this.subtitle});
}
