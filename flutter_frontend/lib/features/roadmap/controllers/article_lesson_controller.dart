part of '../article_lesson_screen.dart';

extension _ArticleLessonScreenLogic on ArticleLessonScreen {
  void _finish(BuildContext context) {
    onCompleted?.call();
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Materi bacaan selesai! Status tugas diperbarui.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
