import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ParsingProgressScreen extends StatefulWidget {
  const ParsingProgressScreen({super.key});

  @override
  State<ParsingProgressScreen> createState() => _ParsingProgressScreenState();
}

class _ParsingProgressScreenState extends State<ParsingProgressScreen> {
  int _currentStage = 0;
  Timer? _timer;

  final List<Map<String, String>> _stages = [
    {"title": "दस्तावेज़ स्कैन हो रहा है (Scanning)", "desc": "इमेज प्री-प्रोसेसिंग व ओरिएंटेशन सुधार"},
    {"title": "OCR टेक्स्ट पहचान (Text Recognition)", "desc": "हिंदी व अंग्रेजी हस्तलिखित पर्चा निष्कर्षण"},
    {"title": "क्लिनिकल एंटिटी एक्सट्रैक्शन (Clinical NLP)", "desc": "दवाइयां, खुराक, व जांच परिणामों का वर्गीकरण"},
    {"title": "ड्रग इंटरेक्शन व असामान्यता जांच (Safety Check)", "desc": "असामान्य मान व विपरीत औषधि मिलान"},
  ];

  @override
  void initState() {
    super.initState();
    _startPipeline();
  }

  void _startPipeline() {
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (_currentStage < _stages.length - 1) {
        setState(() => _currentStage++);
      } else {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          context.pushReplacement('/documents/review');
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.ayushLight.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.ayushLight, strokeWidth: 3),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: Text(
                  'दस्तावेज़ का विश्लेषण हो रहा है\nProcessing Document...',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 36),

              // Stages list
              ...List.generate(_stages.length, (index) {
                final isDone = index < _currentStage;
                final isCurrent = index == _currentStage;
                final stage = _stages[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.ayushLight
                              : (isCurrent ? AppColors.accentLight : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight)),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : (isCurrent
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : Text("${index + 1}", style: const TextStyle(fontSize: 12))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage["title"]!,
                              style: TextStyle(
                                fontWeight: (isDone || isCurrent) ? FontWeight.bold : FontWeight.normal,
                                color: (isDone || isCurrent) ? null : AppColors.onSurfaceVariantLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stage["desc"]!,
                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariantLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
