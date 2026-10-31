part of '../onboarding_screen.dart';

extension _OnboardingLogic on _OnboardingScreenState {
  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onCompleted();
    }
  }

  void _handleSkip() {
    (widget.onSkipToAuth ?? widget.onCompleted).call();
  }
}
