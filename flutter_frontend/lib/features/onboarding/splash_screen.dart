import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/skillbridge_logo.dart';

part 'widgets/splash_wave_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    this.enableLoopingAnimation,
    super.key,
  });

  final bool? enableLoopingAnimation;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _shouldLoop {
    if (widget.enableLoopingAnimation != null) {
      return widget.enableLoopingAnimation!;
    }
    final bindingName = WidgetsBinding.instance.runtimeType.toString();
    return !bindingName.contains('AutomatedTest');
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (_shouldLoop) {
      _controller.repeat();
    } else {
      _controller.value = 0.35;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations && _controller.isAnimating) {
      _controller.stop();
    } else if (!disableAnimations && _shouldLoop && !_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0057FF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient + abstract decorative curved lines
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A60FF),
                  Color(0xFF0055FF),
                  Color(0xFF004CE6),
                ],
              ),
            ),
          ),
          const CustomPaint(
            painter: _SplashWavePainter(),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                // Centered logo + wordmark + tagline
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final floatOffset =
                        math.sin(_controller.value * 2 * math.pi) * 6.0;
                    return Transform.translate(
                      offset: Offset(0, floatOffset),
                      child: child,
                    );
                  },
                  child: const SkillBridgeLogoMark(
                    size: 86,
                    borderRadius: 24,
                    iconColor: Color(0xFF0057FF),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'SkillBridge',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Jembatan menuju karier impianmu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.80),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                  ),
                ),
                const Spacer(flex: 5),
                // Three pulsing dots at the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 42),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final phase =
                              (_controller.value * 2 * math.pi) - (index * 0.9);
                          final wave = (math.sin(phase) + 1) / 2;
                          final opacity = 0.35 + (wave * 0.65);
                          final scale = 0.85 + (wave * 0.25);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.5),
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 6.5,
                                height: 6.5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: opacity),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
