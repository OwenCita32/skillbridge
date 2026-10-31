part of '../career_selection_screen.dart';

extension _CareerSelectionLogic on _CareerSelectionScreenState {
  Future<void> _loadCareers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final careers = await widget.apiClient.careers();
      if (mounted) {
        setState(() {
          _careers = careers;
          _isLoading = false;
        });
      }
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveGoal() async {
    final customText = _customController.text.trim();
    final hasCustom = customText.isNotEmpty;
    final hasSelectedId = _selectedId != null;
    final hasPreset = _selectedPresetTitle != null;

    if (!hasCustom && !hasSelectedId && !hasPreset) return;

    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> career;
      if (hasCustom) {
        career = await widget.apiClient.setCareerGoal(null, customText);
      } else if (hasSelectedId) {
        career = await widget.apiClient.setCareerGoal(_selectedId, null);
      } else {
        career =
            await widget.apiClient.setCareerGoal(null, _selectedPresetTitle!);
      }

      if (mounted) widget.onSelected(career);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _onSelectPreset(String title) {
    setState(() {
      _selectedPresetTitle = title;
      _selectedId = null;
      _customController.text = title;
    });
  }

  void _onSelectDbCareer(int id, String title) {
    setState(() {
      _selectedId = id;
      _selectedPresetTitle = null;
      _customController.clear();
    });
  }
}
