import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../quiz/quiz_intro_screen.dart';

part 'controllers/profile_controller.dart';
part 'screens/profile_edit_modals.dart';
part 'screens/profile_portfolio_modals.dart';
part 'screens/profile_certificates_modal.dart';
part 'screens/profile_body.dart';
part 'widgets/profile_hero_card.dart';
part 'widgets/profile_connect_cards.dart';
part 'widgets/imported_github_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.apiClient,
    required this.user,
    required this.onChangeCareer,
    required this.onLogout,
    super.key,
  });

  final ApiClient apiClient;
  final Map<String, dynamic> user;
  final VoidCallback onChangeCareer;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> _userData;
  List<dynamic> _importedRepos = [];
  List<Map<String, dynamic>> _certificates = [];
  int _readinessScore = 52;
  bool _isLoggingOut = false;
  bool _isSyncingGithub = false;
  bool _linkedInConnected = true;

  static const _brandBlue = Color(0xFF0057FF);

  void _rebuild(VoidCallback fn) => setState(fn);

  int get _earnedCertificateCount {
    final earned = _certificates.where((c) => c['is_earned'] == true).length;
    return _certificates.isEmpty ? 0 : earned;
  }

  @override
  void initState() {
    super.initState();
    _userData = Map<String, dynamic>.from(widget.user);
    final rawRepos = _userData['github_repos'];
    if (rawRepos is List && rawRepos.isNotEmpty) {
      _importedRepos = List<dynamic>.from(rawRepos);
    } else {
      // Data repositori awal terkurasi
      _importedRepos = [
        {
          'name': 'design-system-kit',
          'description': 'Reusable UI component library dan token sistem desain.',
          'language': 'TypeScript',
          'stars': 48,
          'html_url': 'https://github.com/rakapratama/design-system-kit',
        },
        {
          'name': 'freelance-marketplace-app',
          'description': 'Aplikasi web interaktif dengan arsitektur REST API & state management.',
          'language': 'Dart',
          'stars': 34,
          'html_url': 'https://github.com/rakapratama/freelance-marketplace-app',
        },
        {
          'name': 'portfolio-showcase-v2',
          'description': 'Website portofolio live dengan optimasi performa.',
          'language': 'Next.js',
          'stars': 19,
          'html_url': 'https://github.com/rakapratama/portfolio-showcase-v2',
        },
      ];
    }

    final careerGoal = _userData['career_goal'] as Map?;
    final rawCareerTitle = (careerGoal?['career_title'] as String?)?.trim() ?? '';
    final careerLabel = rawCareerTitle.isEmpty ? 'UI/UX Designer' : rawCareerTitle;
    _certificates = _getInitialCertificates(careerLabel);
    _loadCertificates();
    _refreshProfileAndRepos();
  }

  @override
  Widget build(BuildContext context) => _buildProfileScaffold(context);
}
