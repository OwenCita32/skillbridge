// ignore_for_file: invalid_use_of_protected_member
part of '../new_application_screen.dart';

extension _NewApplicationLogic on _NewApplicationScreenState {
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
}
