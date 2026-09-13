import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/mk_severity_slider.dart';

class ChatQuestionArea extends StatelessWidget {
  final Map<String, dynamic> question;
  final ValueChanged<Map<String, dynamic>> onAnswer;

  const ChatQuestionArea({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  IconData _resolveOptionIcon(Map<String, dynamic>? opt, int index) {
    final iconStr = opt?["icon"]?.toString().toLowerCase();
    final combinedText = "${opt?["label_hi"] ?? ''} ${opt?["label_en"] ?? ''} ${opt?["label"] ?? ''}".toLowerCase();

    if (iconStr == "sun" || combinedText.contains("सुबह") || combinedText.contains("morning") || combinedText.contains("dhoop")) {
      return Icons.wb_sunny_rounded;
    }
    if (iconStr == "moon" || combinedText.contains("शाम") || combinedText.contains("रात") || combinedText.contains("evening") || combinedText.contains("night")) {
      return Icons.nightlight_round;
    }
    if (iconStr == "clock" || combinedText.contains("लगातार") || combinedText.contains("पूरे दिन") || combinedText.contains("दिनभर") || combinedText.contains("constant")) {
      return Icons.access_time_rounded;
    }
    if (iconStr == "calendar" || combinedText.contains("दिन") || combinedText.contains("हफ्ते") || combinedText.contains("हफ़्ते") || combinedText.contains("महीने") || combinedText.contains("today") || combinedText.contains("days") || combinedText.contains("week")) {
      return Icons.calendar_today_rounded;
    }
    if (iconStr == "thermostat" || combinedText.contains("बुखार") || combinedText.contains("तापमान") || combinedText.contains("fever") || combinedText.contains("temperature") || combinedText.contains("hot")) {
      return Icons.thermostat_rounded;
    }
    if (iconStr == "chills" || combinedText.contains("ठंड") || combinedText.contains("कंपकंपी") || combinedText.contains("chills") || combinedText.contains("shiver") || combinedText.contains("cold")) {
      return Icons.ac_unit_rounded;
    }
    if (iconStr == "sweat" || combinedText.contains("पसीना") || combinedText.contains("sweat") || combinedText.contains("perspiration")) {
      return Icons.water_drop_rounded;
    }
    if (iconStr == "pain" || combinedText.contains("दर्द") || combinedText.contains("सिर") || combinedText.contains("pain") || combinedText.contains("ache")) {
      return Icons.healing_rounded;
    }
    if (iconStr == "medicine" || combinedText.contains("दवा") || combinedText.contains("गोली") || combinedText.contains("medicine") || combinedText.contains("pill") || combinedText.contains("tablet")) {
      return Icons.medication_rounded;
    }
    if (iconStr == "food" || combinedText.contains("भूख") || combinedText.contains("पाचन") || combinedText.contains("खाना") || combinedText.contains("food") || combinedText.contains("appetite") || combinedText.contains("digestion") || combinedText.contains("agni")) {
      return Icons.restaurant_rounded;
    }
    if (iconStr == "breath" || combinedText.contains("सांस") || combinedText.contains("खांसी") || combinedText.contains("cough") || combinedText.contains("breath") || combinedText.contains("throat") || combinedText.contains("gala")) {
      return Icons.air_rounded;
    }
    if (iconStr == "check" || combinedText.contains("हाँ") || combinedText.contains("yes") || combinedText.contains("theek") || combinedText.contains("जारी")) {
      return Icons.check_circle_outline_rounded;
    }
    if (iconStr == "cross" || combinedText.contains("नहीं") || combinedText.contains("no") || combinedText.contains("समाप्त")) {
      return Icons.cancel_outlined;
    }
    if (iconStr == "help" || combinedText.contains("मालूम नहीं") || combinedText.contains("पता नहीं") || combinedText.contains("unsure") || combinedText.contains("help")) {
      return Icons.help_outline_rounded;
    }
    if (iconStr == "warning" || combinedText.contains("गंभीर") || combinedText.contains("severe") || combinedText.contains("emergency")) {
      return Icons.warning_amber_rounded;
    }

    const fallbackIcons = [
      Icons.health_and_safety_outlined,
      Icons.medical_information_outlined,
      Icons.healing_outlined,
      Icons.monitor_heart_outlined,
    ];
    return fallbackIcons[index % fallbackIcons.length];
  }

  @override
  Widget build(BuildContext context) {
    final inputType = (question["input_type"] ?? question["input"] ?? "mcq").toString().toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (inputType == "slider") {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            MkSeveritySlider(
              initialValue: 5,
              onChanged: (val) {
                // Slider value
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => onAnswer({"severity": 6, "label": "6 / 10 (मध्यम तीव्रता)"}),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                foregroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('तीव्रता दर्ज करें (Submit Severity) ✓'),
            ),
          ],
        ),
      );
    }

    if (inputType == "yes_no" || inputType == "yesno") {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'हाँ (Yes)',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.ayushLight,
              onTap: () => onAnswer({"value": true, "label": "हाँ (Yes)"}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              label: 'नहीं (No)',
              icon: Icons.cancel_outlined,
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              textColor: isDark ? Colors.white : AppColors.onSurfaceLight,
              onTap: () => onAnswer({"value": false, "label": "नहीं (No)"}),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              label: 'मालूम नहीं',
              icon: Icons.help_outline_rounded,
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
              textColor: AppColors.onSurfaceVariantLight,
              onTap: () => onAnswer({"value": null, "label": "मालूम नहीं (Unsure)"}),
            ),
          ),
        ],
      );
    }

    // Default MCQ with visual icons and Hindi labels
    final options = question["options"] as List<dynamic>? ?? [];
    const fallbackLetters = ["A", "B", "C", "D", "E", "F"];

    return Column(
      children: options.asMap().entries.map<Widget>((entry) {
        final idx = entry.key;
        final opt = entry.value;

        final rawKey = opt is Map ? opt["key"]?.toString() : null;
        final key = (rawKey != null && rawKey.length <= 2)
            ? rawKey
            : fallbackLetters[idx % fallbackLetters.length];

        final labelHi = opt is Map
            ? (opt["label_hi"] ?? opt["label"] ?? opt["label_en"] ?? key)
            : opt.toString();
        final labelEn = opt is Map ? opt["label_en"] : null;
        final iconData = _resolveOptionIcon(opt is Map ? opt as Map<String, dynamic> : null, idx);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: InkWell(
            onTap: () => onAnswer({
              "key": key,
              "label": labelHi,
              "label_hi": labelHi,
              "label_en": labelEn,
              "text": labelHi
            }),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  // 1. Rich Visual Icon Box
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.ayushLight.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.ayushLight.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        size: 22,
                        color: AppColors.ayushLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. Option Letter Badge Chip (A, B, C...)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 3. Bilingual Text (Hindi bold primary + English sublabel)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labelHi.toString(),
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (labelEn != null && labelEn.toString().isNotEmpty && labelEn.toString() != labelHi.toString())
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              labelEn.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariantLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 4. Chevron Action Indicator
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.onSurfaceVariantLight),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor ?? Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: textColor ?? Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
