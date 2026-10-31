import 'package:flutter/material.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/app/auth_gate.dart';

void main() {
  runApp(const SkillBridgeApp());
}

class SkillBridgeApp extends StatefulWidget {
  const SkillBridgeApp({super.key});

  @override
  State<SkillBridgeApp> createState() => _SkillBridgeAppState();
}

class _SkillBridgeAppState extends State<SkillBridgeApp> {
  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillBridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AuthGate(apiClient: _apiClient),
    );
  }
}
