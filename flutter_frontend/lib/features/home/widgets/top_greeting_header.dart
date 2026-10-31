part of '../dashboard_screen.dart';

// ============================================================================
// 1. TOP GREETING HEADER
// ============================================================================
class _TopGreetingHeader extends StatelessWidget {
  const _TopGreetingHeader({
    required this.userName,
    this.avatarUrl,
    this.unreadCount = 0,
    this.onTapNotification,
  });

  final String userName;
  final String? avatarUrl;
  final int unreadCount;
  final VoidCallback? onTapNotification;

  String _greetingText() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  Widget _buildInitialFallback() {
    return Center(
      child: Text(
        userName.characters.first.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF0057FF),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Row(
      children: [
        // User Avatar Photo (or Initial Fallback)
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE0EAFF), Color(0xFFDBEAFE)],
            ),
            border: Border.all(color: Colors.white, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasAvatar
              ? ClipOval(
                  child: Image.network(
                    avatarUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitialFallback(),
                  ),
                )
              : _buildInitialFallback(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingText(),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        // Interactive White Notification Button with Yellow Dot
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTapNotification,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF1E293B),
                    size: 22,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
