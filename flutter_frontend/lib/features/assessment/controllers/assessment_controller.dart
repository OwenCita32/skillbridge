part of '../assessment_screen.dart';

extension _AssessmentLogic on _AssessmentScreenState {
  Future<void> _loadAssessment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final career = await widget.apiClient.career(widget.careerId);
      final gaps = await widget.apiClient.skillGaps();
      final skills = gaps['skills'] as List<dynamic>? ?? [];
      for (final value in skills) {
        final skillGap = Map<String, dynamic>.from(value as Map);
        final skill = Map<String, dynamic>.from(skillGap['skill'] as Map);
        final currentLevel = skillGap['current_level'];
        if (currentLevel is int) {
          _answers[skill['id'] as int] = currentLevel;
        }
      }
      if (mounted) {
        setState(() {
          _career = career;
          _scale = career['assessment_scale'] as List<dynamic>? ?? [];
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

  Future<void> _submit() async {
    final skills = _career?['skills'] as List<dynamic>? ?? [];
    if (_answers.length != skills.length) {
      setState(
        () => _error = 'Pilih level untuk setiap skill sebelum menyimpan.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final answers = skills.map((value) {
      final skill = Map<String, dynamic>.from(value as Map);
      final id = skill['id'] as int;
      return {'skill_id': id, 'level': _answers[id]!};
    }).toList();

    try {
      await widget.apiClient.submitAssessment(answers);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Self-assessment tersimpan.')),
        );
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
