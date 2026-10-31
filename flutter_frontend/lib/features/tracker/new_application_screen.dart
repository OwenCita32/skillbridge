import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import 'application_tracker_screen.dart';

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

  void _save() async {
    final title = _titleController.text.trim();
    final client = _clientController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan judul proyek.')),
      );
      return;
    }

    final budget = _budgetController.text.trim().isEmpty
        ? 'Fleksibel'
        : (_budgetController.text.startsWith('Rp')
            ? _budgetController.text.trim()
            : 'Rp${_budgetController.text.trim()}');

    setState(() => _isSaving = true);

    if (widget.apiClient != null) {
      try {
        final res = await widget.apiClient!.createJobApplication(
          title: title,
          clientName: client.isEmpty ? 'Klien Baru' : client,
          platform: _selectedPlatform,
          budget: budget,
          status: _selectedStatus,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );

        final rawApp = res['application'] as Map<String, dynamic>?;
        final (code, color) = _getBadge(_selectedPlatform);

        final newItem = ApplicationItem(
          id: rawApp?['id'] as int? ?? DateTime.now().millisecondsSinceEpoch,
          title: title,
          client: client.isEmpty ? 'Klien Baru' : client,
          budget: budget,
          platform: _selectedPlatform,
          badgeCode: code,
          badgeColor: color,
          date: 'Hari ini',
          status: _selectedStatus,
        );

        if (mounted) Navigator.of(context).pop(newItem);
        return;
      } catch (err) {
        // Fallback to local
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }

    final (badgeCode, badgeColor) = _getBadge(_selectedPlatform);

    final newItem = ApplicationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      client: client.isEmpty ? 'Klien Baru' : client,
      budget: budget,
      platform: _selectedPlatform,
      badgeCode: badgeCode,
      badgeColor: badgeColor,
      date: 'Hari ini',
      status: _selectedStatus,
    );

    Navigator.of(context).pop(newItem);
  }

  (String, Color) _getBadge(String platform) {
    switch (platform) {
      case 'Upwork':
        return ('Up', const Color(0xFF16A34A));
      case 'Fiverr':
        return ('Fv', const Color(0xFF10B981));
      case 'Sribulancer':
        return ('Sr', const Color(0xFFEA580C));
      case 'Projects.co.id':
        return ('Pr', const Color(0xFF2563EB));
      case 'LinkedIn':
        return ('In', const Color(0xFF0A66C2));
      default:
        return ('Ln', const Color(0xFF64748B));
    }
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                      color: const Color(0xFF0F172A),
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Catat Lamaran Baru',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Form Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                children: [
                  // Blue Top Info Callout
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ini akan jadi lamaran ke-$nextNumber hari ini',
                          style: const TextStyle(
                            color: Color(0xFF0057FF),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$nextNumber/5',
                          style: const TextStyle(
                            color: Color(0xFF0057FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Platform Grid
                  const Text(
                    'Platform',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _platforms.map((platform) {
                      final isSelected = _selectedPlatform == platform;
                      return SizedBox(
                        width: (MediaQuery.of(context).size.width - 40 - 20) / 3,
                        height: 44,
                        child: InkWell(
                          onTap: () => setState(() => _selectedPlatform = platform),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0057FF)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              platform,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF0057FF)
                                    : const Color(0xFF334155),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Judul Proyek
                  const Text(
                    'Judul proyek *',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextInput(
                    controller: _titleController,
                    hint: 'cth. Redesign aplikasi kasir',
                  ),
                  const SizedBox(height: 18),

                  // Nama Klien
                  const Text(
                    'Nama klien *',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextInput(
                    controller: _clientController,
                    hint: 'cth. PT Maju Jaya',
                  ),
                  const SizedBox(height: 18),

                  // Budget (Rp)
                  const Text(
                    'Budget (Rp)',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextInput(
                    controller: _budgetController,
                    hint: 'cth. 2.000.000',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Status
                  const Text(
                    'Status',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusToggle(
                          label: 'Menunggu',
                          isSelected: _selectedStatus == 'Menunggu',
                          activeColor: const Color(0xFFD97706),
                          activeBg: const Color(0xFFFFFBEB),
                          onTap: () => setState(() => _selectedStatus = 'Menunggu'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusToggle(
                          label: 'Interview',
                          isSelected: _selectedStatus == 'Interview',
                          activeColor: const Color(0xFF0057FF),
                          activeBg: const Color(0xFFEFF6FF),
                          onTap: () => setState(() => _selectedStatus = 'Interview'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Catatan
                  const Text(
                    'Catatan',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextInput(
                    controller: _notesController,
                    hint: 'Poin penting dari proposal yang kamu kirim',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Submit Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0057FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Simpan Lamaran',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0057FF), width: 1.8),
        ),
      ),
    );
  }

  Widget _buildStatusToggle({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

