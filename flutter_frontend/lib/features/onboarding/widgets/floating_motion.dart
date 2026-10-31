part of '../onboarding_screen.dart';

/// Reusable sinusoidal floating wrapper that gives cards an organic, 3D hovering feel.
class _FloatingMotion extends StatelessWidget {
  const _FloatingMotion({
    required this.animation,
    required this.child,
    this.phase = 0.0,
    this.verticalAmplitude = 7.0,
    this.horizontalAmplitude = 2.0,
    this.baseRotation = 0.0,
    this.rotationAmplitude = 0.012,
  });

  final Animation<double> animation;
  final Widget child;
  final double phase;
  final double verticalAmplitude;
  final double horizontalAmplitude;
  final double baseRotation;
  final double rotationAmplitude;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, cachedChild) {
          final angle = (animation.value * 2 * math.pi) + phase;
          final dy = math.sin(angle) * verticalAmplitude;
          final dx = math.cos(angle) * horizontalAmplitude;
          final rot = baseRotation + (math.sin(angle + 0.6) * rotationAmplitude);

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: rot,
              child: cachedChild,
            ),
          );
        },
        child: child,
      ),
    );
  }
}

class _StatusPillBadge extends StatelessWidget {
  const _StatusPillBadge({
    required this.iconBgColor,
    required this.label,
  });

  final Color iconBgColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
