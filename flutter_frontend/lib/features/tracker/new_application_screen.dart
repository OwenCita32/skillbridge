// ignore_for_file: unused_field
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import 'application_tracker_screen.dart';

part 'controllers/new_application_controller.dart';
part 'screens/new_application_form.dart';

class NewApplicationScreen extends StatefulWidget {
  const NewApplicationScreen({
    required this.currentTodayCount,
    this.apiClient,
    super.key,
  });

  final int currentTodayCount;
  final ApiClient? apiClient;

  @override
  State<NewApplicationScreen> createState() => _NewApplicationScreenState();
}

class _NewApplicationScreenState extends State<NewApplicationScreen> {
  final _titleController = TextEditingController();
  final _clientController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  String _selectedPlatform = 'Upwork';
  String _selectedStatus = 'Menunggu';

  static const _platforms = [
    'Upwork',
    'Fiverr',
    'Sribulancer',
    'Projects.co.id',
    'LinkedIn',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _clientController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextNumber = widget.currentTodayCount + 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            _buildTopAppBar(context),

            // Form Body
            Expanded(
              child: _buildFormBody(context, nextNumber),
            ),
          ],
        ),
      ),

      // Bottom Submit Button
      bottomNavigationBar: _buildBottomSubmitBar(),
    );
  }
}
