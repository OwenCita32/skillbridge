part of '../practice_task_screen.dart';

extension _PracticeTaskScreenLogic on _PracticeTaskScreenState {
  void _submit() async {
    final link = _linkController.text.trim();
    if (link.isEmpty && !_stepChecked.any((c) => c)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Centang langkah atau tempel link hasil tugasmu.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final completedSteps = <String>[];
    for (int i = 0; i < widget.steps.length; i++) {
      if (_stepChecked[i]) completedSteps.add(widget.steps[i]);
    }

    if (widget.apiClient != null) {
      widget.apiClient!.submitPortfolioTask(
        title: widget.title,
        submissionLink: link.isNotEmpty ? link : null,
        checklistCompleted: completedSteps,
        roadmapItemId: widget.roadmapItemId,
      ).catchError((_) => <String, dynamic>{});
    }

    widget.onCompleted?.call();
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hasil praktik berhasil dikirim & disimpan di database!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
