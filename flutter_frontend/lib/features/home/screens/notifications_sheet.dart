part of '../dashboard_screen.dart';

// ============================================================================
// NOTIFICATIONS BOTTOM SHEET (Self-hosted In-App Notification Center)
// ============================================================================
class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet({
    required this.apiClient,
    required this.onUnreadCountChanged,
    required this.onActionTriggered,
  });

  final ApiClient apiClient;
  final ValueChanged<int> onUnreadCountChanged;
  final void Function(String actionType, dynamic payload) onActionTriggered;

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await widget.apiClient.getNotifications();
      final list = (res['data'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
      final unread = (res['unread_count'] as num?)?.toInt() ?? 0;
      if (mounted) {
        setState(() {
          _items = list;
          _unreadCount = unread;
          _isLoading = false;
        });
        widget.onUnreadCountChanged(unread);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await widget.apiClient.markAllNotificationsAsRead();
      if (mounted) {
        setState(() {
          for (final item in _items) {
            item['read'] = true;
          }
          _unreadCount = 0;
        });
        widget.onUnreadCountChanged(0);
      }
    } catch (_) {}
  }

  Future<void> _markSingleRead(int index) async {
    final item = _items[index];
    if (item['read'] == true) return;
    final id = item['id'];
    if (id is! int) return;

    setState(() {
      item['read'] = true;
      if (_unreadCount > 0) _unreadCount--;
    });
    widget.onUnreadCountChanged(_unreadCount);

    try {
      await widget.apiClient.markNotificationAsRead(id);
    } catch (_) {}
  }

  Future<void> _deleteItem(int index) async {
    final item = _items[index];
    final id = item['id'];
    if (id is! int) return;

    final wasUnread = item['read'] != true;
    setState(() {
      _items.removeAt(index);
      if (wasUnread && _unreadCount > 0) {
        _unreadCount--;
      }
    });
    widget.onUnreadCountChanged(_unreadCount);

    try {
      await widget.apiClient.deleteNotification(id);
    } catch (_) {}
  }

  IconData _iconForType(String? type) {
    return switch (type) {
      'certificate' => Icons.verified_rounded,
      'quiz' => Icons.bolt_rounded,
      'github' => Icons.code_rounded,
      'roadmap' => Icons.alt_route_rounded,
      'tracker' => Icons.work_outline_rounded,
      _ => Icons.notifications_active_rounded,
    };
  }

  Color _iconColorForType(String? type) {
    return switch (type) {
      'certificate' => const Color(0xFFD97706),
      'quiz' => const Color(0xFF6366F1),
      'github' => const Color(0xFF0F172A),
      'roadmap' => const Color(0xFF0057FF),
      'tracker' => const Color(0xFF059669),
      _ => const Color(0xFF0D9488),
    };
  }

  Color _iconBgForType(String? type) {
    return switch (type) {
      'certificate' => const Color(0xFFFEF3C7),
      'quiz' => const Color(0xFFEEF2FF),
      'github' => const Color(0xFFF1F5F9),
      'roadmap' => const Color(0xFFDBEAFE),
      'tracker' => const Color(0xFFD1FAE5),
      _ => const Color(0xFFCCFBF1),
    };
  }

  String _actionLabelForType(String? actionType) {
    return switch (actionType) {
      'roadmap' => 'Buka Roadmap',
      'quiz' => 'Mulai Kuis',
      'certificates' => 'Lihat Sertifikat',
      'profile' => 'Buka Profil',
      'tracker' => 'Buka Tracker',
      _ => 'Lihat',
    };
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.82;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 8),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF0057FF),
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      '$_unreadCount Baru',
                      style: const TextStyle(
                        color: Color(0xFF0057FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (_unreadCount > 0)
                  TextButton(
                    onPressed: _markAllRead,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Tandai dibaca',
                      style: TextStyle(
                        color: Color(0xFF0057FF),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 22,
                  ),
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // List or Empty
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0057FF),
                      strokeWidth: 2.5,
                    ),
                  )
                : _items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Belum Ada Notifikasi Baru',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Pembaruan tentang kuis, sertifikat, dan target kariermu akan muncul di sini secara otomatis.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isRead = item['read'] == true;
                          final type = item['type'] as String?;
                          final actionType = item['action_type'] as String?;

                          return InkWell(
                            onTap: () => _markSingleRead(index),
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.white
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isRead
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFFBFDBFE),
                                  width: isRead ? 1 : 1.2,
                                ),
                                boxShadow: isRead
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: const Color(0xFF0057FF)
                                              .withValues(alpha: 0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  // Category Icon Avatar
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: _iconBgForType(type),
                                      borderRadius:
                                          BorderRadius.circular(13),
                                    ),
                                    child: Icon(
                                      _iconForType(type),
                                      color: _iconColorForType(type),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Text Content & Action
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['title'] as String? ??
                                                    '',
                                                style: TextStyle(
                                                  color: const Color(
                                                      0xFF0F172A),
                                                  fontSize: 14,
                                                  fontWeight: isRead
                                                      ? FontWeight.w600
                                                      : FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                            if (!isRead)
                                              Container(
                                                width: 7,
                                                height: 7,
                                                margin: const EdgeInsets.only(
                                                    left: 6, right: 4),
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Color(0xFF0057FF),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            IconButton(
                                              onPressed: () =>
                                                  _deleteItem(index),
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                size: 16,
                                                color: Color(0xFF94A3B8),
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(
                                                      minWidth: 22,
                                                      minHeight: 22),
                                              splashRadius: 16,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['message'] as String? ?? '',
                                          style: const TextStyle(
                                            color: Color(0xFF475569),
                                            fontSize: 12.5,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              item['created_at_human']
                                                      as String? ??
                                                  'Baru saja',
                                              style: const TextStyle(
                                                color: Color(0xFF94A3B8),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (actionType != null)
                                              InkWell(
                                                onTap: () {
                                                  _markSingleRead(index);
                                                  widget.onActionTriggered(
                                                    actionType,
                                                    item['action_payload'],
                                                  );
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration:
                                                      BoxDecoration(
                                                    color: const Color(
                                                        0xFF0057FF),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        _actionLabelForType(
                                                            actionType),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11.5,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 4),
                                                      const Icon(
                                                        Icons
                                                            .arrow_forward_rounded,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
