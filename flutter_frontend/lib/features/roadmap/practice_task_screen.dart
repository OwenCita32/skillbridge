import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';

class PracticeTaskScreen extends StatefulWidget {
  const PracticeTaskScreen({
    this.title = 'Update case study portofolio',
    this.durationMinutes = 30,
    this.brief =
        'Perbarui case study "Travel App" dengan menambahkan bagian proses riset dan hasil usability test.',
    this.steps = const [
      'Tulis latar belakang masalah',
      'Tambahkan 2 insight riset',
      'Lampirkan before/after desain',
    ],
    this.apiClient,
    this.roadmapItemId,
    this.onCompleted,
    super.key,
  });

  final String title;
  final int durationMinutes;
  final String brief;
  final List<String> steps;
  final ApiClient? apiClient;
  final int? roadmapItemId;
  final VoidCallback? onCompleted;

  @override
  State<PracticeTaskScreen> createState() => _PracticeTaskScreenState();
}

class _PracticeTaskScreenState extends State<PracticeTaskScreen> {
  final _linkController = TextEditingController();
  late final List<bool> _stepChecked;

  @override
  void initState() {
    super.initState();
    _stepChecked = List.filled(widget.steps.length, false);
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _linkController.text.trim().isNotEmpty || _stepChecked.any((c) => c);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Praktik · ${widget.durationMinutes} menit',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'Praktik',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                children: [
                  // Card 1: Brief tugas
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Brief tugas',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.brief,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13.5,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Card 2: Langkah-langkah
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Langkah-langkah',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        for (int i = 0; i < widget.steps.length; i++) ...[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _stepChecked[i] = !_stepChecked[i];
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _stepChecked[i]
                                          ? const Color(0xFF0057FF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _stepChecked[i]
                                            ? const Color(0xFF0057FF)
                                            : const Color(0xFFCBD5E1),
                                        width: 1.6,
                                      ),
                                    ),
                                    child: _stepChecked[i]
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 15,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      widget.steps[i],
                                      style: TextStyle(
                                        color: _stepChecked[i]
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF334155),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        decoration: _stepChecked[i]
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (i < widget.steps.length - 1) const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Card 3: Kumpulkan hasil
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kumpulkan hasil',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _linkController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Tempel link Figma / GitHub / Behance',
                            hintStyle: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13.5,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
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
                              borderSide: const BorderSide(
                                color: Color(0xFF0057FF),
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Sticky Button: Kirim Hasil Praktik
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
            onPressed: canSubmit ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0057FF),
              disabledBackgroundColor: const Color(0xFF93C5FD).withValues(alpha: 0.7),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Kirim Hasil Praktik',
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
}

