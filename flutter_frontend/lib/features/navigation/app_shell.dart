import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../careers/career_selection_screen.dart';
import '../home/dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../roadmap/roadmap_screen.dart';

part 'controllers/app_shell_controller.dart';
part 'widgets/floating_nav_destination.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.apiClient,
    required this.user,
    required this.onLogout,
    super.key,
  });

  final ApiClient apiClient;
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late Map<String, dynamic> _user;
  int _selectedIndex = 0;
  bool _isChoosingCareer = false;
  int _refreshKey = 0;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final careerGoal = _user['career_goal'];
    if (_isChoosingCareer || careerGoal is! Map) {
      return CareerSelectionScreen(
        apiClient: widget.apiClient,
        onSelected: _careerSelected,
        onCancel: careerGoal is Map
            ? () => setState(() => _isChoosingCareer = false)
            : null,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      body: switch (_selectedIndex) {
        0 => DashboardScreen(
          key: ValueKey('dashboard-$_refreshKey'),
          apiClient: widget.apiClient,
          user: _user,
          onOpenRoadmap: () => setState(() => _selectedIndex = 1),
          onOpenProfile: () => setState(() => _selectedIndex = 2),
        ),
        1 => RoadmapScreen(
          key: ValueKey('roadmap-$_refreshKey'),
          apiClient: widget.apiClient,
          onChanged: _refreshHome,
        ),
        _ => ProfileScreen(
          apiClient: widget.apiClient,
          user: _user,
          onChangeCareer: () => setState(() => _isChoosingCareer = true),
          onLogout: widget.onLogout,
        ),
      },
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            height: 70,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FloatingNavDestination(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_outlined,
                    label: 'Beranda',
                    selected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                ),
                Expanded(
                  child: _FloatingNavDestination(
                    icon: Icons.map_outlined,
                    selectedIcon: Icons.map_outlined,
                    label: 'Roadmap',
                    selected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
                Expanded(
                  child: _FloatingNavDestination(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_outline_rounded,
                    label: 'Profil',
                    selected: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
