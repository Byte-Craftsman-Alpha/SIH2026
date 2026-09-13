import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ComplaintGrid extends StatelessWidget {
  final ValueChanged<Map<String, String>> onComplaintSelected;

  const ComplaintGrid({super.key, required this.onComplaintSelected});

  static const List<Map<String, String>> complaints = [
    {"key": "fever", "label_hi": "बुखार (Fever)", "icon": "🌡️"},
    {"key": "headache", "label_hi": "सिर दर्द (Headache)", "icon": "🤕"},
    {"key": "abdominal_pain", "label_hi": "पेट दर्द (Abdominal Pain)", "icon": "🤢"},
    {"key": "cough", "label_hi": "खांसी व जुकाम (Cough/Cold)", "icon": "🤧"},
    {"key": "chest_pain", "label_hi": "सीने में दर्द (Chest Pain)", "icon": "💔"},
    {"key": "joint_pain", "label_hi": "जोड़ों में दर्द (Joint Pain)", "icon": "🦵"},
    {"key": "skin_rash", "label_hi": "त्वचा पर दाने (Skin Rash)", "icon": "🩹"},
    {"key": "indigestion", "label_hi": "गैस / अपच (Indigestion)", "icon": "🥣"},
    {"key": "weakness", "label_hi": "कमज़ोरी / थकान (Fatigue)", "icon": "🥱"},
    {"key": "eye_issue", "label_hi": "आँखों की समस्या (Eye Issue)", "icon": "👁️"},
    {"key": "toothache", "label_hi": "दांत दर्द (Toothache)", "icon": "🦷"},
    {"key": "other", "label_hi": "अन्य समस्या (Other)", "icon": "📋"},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'मुख्य समस्या चुनें (Tap Your Chief Complaint):',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: complaints.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final c = complaints[index];
            final isCritical = c["key"] == "chest_pain";

            return InkWell(
              onTap: () => onComplaintSelected(c),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isCritical
                      ? AppColors.emergencyLight.withValues(alpha: 0.12)
                      : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCritical
                        ? AppColors.emergencyLight.withValues(alpha: 0.4)
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                ),
                child: Row(
                  children: [
                    Text(c["icon"]!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c["label_hi"]!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCritical ? AppColors.emergencyLight : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
