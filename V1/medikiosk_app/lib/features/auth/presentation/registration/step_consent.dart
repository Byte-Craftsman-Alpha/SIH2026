import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/mk_audio_button.dart';

class StepConsent extends StatelessWidget {
  final bool dataCaptureConsent;
  final bool docDigitizeConsent;
  final bool analyticsConsent;
  final ValueChanged<bool> onDataCaptureChanged;
  final ValueChanged<bool> onDocDigitizeChanged;
  final ValueChanged<bool> onAnalyticsChanged;

  const StepConsent({
    super.key,
    required this.dataCaptureConsent,
    required this.docDigitizeConsent,
    required this.analyticsConsent,
    required this.onDataCaptureChanged,
    required this.onDocDigitizeChanged,
    required this.onAnalyticsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'सहमति व डेटा सुरक्षा\nConsent & Privacy',
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const MkAudioButton(
                textToRead: "यह सहमति डिजिटल व्यक्तिगत डेटा संरक्षण अधिनियम के तहत आपकी गोपनीयता की रक्षा करती है। आप किसी भी समय अपनी सहमति वापस ले सकते हैं।",
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'DPDP Act 2023 के तहत आपकी स्पष्ट सहमति आवश्यक है। आप इसे कभी भी सेटिंग्स से बदल सकते हैं।',
            style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
          ),
          const SizedBox(height: 20),

          // Consent 1: Clinical History
          _buildConsentTile(
            title: '1. क्लिनिकल हिस्ट्री संग्रह (Clinical Intake)',
            desc: 'डॉक्टर के परामर्श हेतु आवाज़ और टच द्वारा आपकी स्वास्थ्य समस्या का मसौदा तैयार करने की अनुमति।',
            value: dataCaptureConsent,
            onChanged: onDataCaptureChanged,
            isDark: isDark,
            isRequired: true,
          ),
          const SizedBox(height: 14),

          // Consent 2: Document OCR
          _buildConsentTile(
            title: '2. मेडिकल पर्चों का डिजिटलीकरण (Document Digitization)',
            desc: 'पुराने पर्चों और टेस्ट रिपोर्टों को OCR द्वारा पढ़कर डिजिटल सारांश में जोड़ने की अनुमति।',
            value: docDigitizeConsent,
            onChanged: onDocDigitizeChanged,
            isDark: isDark,
            isRequired: false,
          ),
          const SizedBox(height: 14),

          // Consent 3: Research / Analytics
          _buildConsentTile(
            title: '3. गुमनाम शोध विश्लेषण (Anonymous Analytics)',
            desc: 'आयुष और CCRAS स्वास्थ्य सुधार हेतु बिना पहचान के डेटा के शोध उपयोग की अनुमति (वैकल्पिक)।',
            value: analyticsConsent,
            onChanged: onAnalyticsChanged,
            isDark: isDark,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildConsentTile({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? AppColors.ayushLight : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.ayushLight,
            onChanged: isRequired ? null : onChanged,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.ayushLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('अनिवार्य', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.ayushLight)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
