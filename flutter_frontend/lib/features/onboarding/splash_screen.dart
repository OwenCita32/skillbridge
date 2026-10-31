import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../shared/widgets/skillbridge_logo.dart';

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

class _SplashWavePainter extends CustomPainter {
  const _SplashWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final thinLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final softerLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    // Top-right concentric decorative circles
    final topCircleCenter = Offset(size.width * 0.85, size.height * 0.07);
    canvas.drawCircle(topCircleCenter, size.width * 0.30, softerLinePaint);
    canvas.drawCircle(topCircleCenter, size.width * 0.42, thinLinePaint);

    // Upper sweeping curve
    final topWave = Path()
      ..moveTo(0, size.height * 0.26)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.31,
        size.width * 0.62,
        size.height * 0.17,
        size.width,
        size.height * 0.21,
      );
    canvas.drawPath(topWave, thinLinePaint);

    // Lower wave 1
    final bottomWave1 = Path()
      ..moveTo(0, size.height * 0.67)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.61,
        size.width * 0.68,
        size.height * 0.72,
        size.width,
        size.height * 0.63,
      );
    canvas.drawPath(bottomWave1, thinLinePaint);

    // Lower wave 2
    final bottomWave2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.69,
        size.width * 0.68,
        size.height * 0.80,
        size.width,
        size.height * 0.71,
      );
    canvas.drawPath(bottomWave2, softerLinePaint);

    // Bottom-left subtle rounded contour
    final bottomLeftArc = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.36,
        size.height * 0.81,
        size.width * 0.46,
        size.height * 0.86,
        size.width * 0.34,
        size.height,
      );
    canvas.drawPath(bottomLeftArc, softerLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

