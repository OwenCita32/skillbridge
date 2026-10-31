import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../careers/career_selection_screen.dart';
import '../home/dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../roadmap/roadmap_screen.dart';

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
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _careerSelected(Map<String, dynamic> career) async {
    setState(() {
      _user = {
        ..._user,
        'career_goal': {
          'career_id': career['id'],
          'career_title': career['title'],
        },
      };
      _isChoosingCareer = false;
      _selectedIndex = 0;
      _refreshKey++;
    });
  }

  void _refreshHome() {
    setState(() => _refreshKey++);
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
      body: switch (_selectedIndex) {
        0 => DashboardScreen(
          key: ValueKey('dashboard-$_refreshKey'),
          apiClient: widget.apiClient,
          user: _user,
          onOpenRoadmap: () => setState(() => _selectedIndex = 1),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route_rounded),
            label: 'Roadmap',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
