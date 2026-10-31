part of '../app_shell.dart';

extension _AppShellLogic on _AppShellState {
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
}
