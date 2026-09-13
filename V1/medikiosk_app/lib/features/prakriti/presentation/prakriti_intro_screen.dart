import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';
import '../../../core/widgets/mk_audio_button.dart';

class PrakritiIntroScreen extends StatelessWidget {
  const PrakritiIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [
          MkAudioButton(textToRead: "प्रकृति परीक्षण आपके शरीर के वात, पित्त और कफ दोषों का विश्लेषण करता है। इसमें 18 प्रश्न हैं और 10 से 12 मिनट लगते हैं।"),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.ayushLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text('🌿', style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('प्रकृति परीक्षण', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text('Prakriti Assessment', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariantLight)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'आपकी कुदरती प्रकृति क्या है?\nDiscover Your Constitution',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'आयुर्वेद के अनुसार हर व्यक्ति का शरीर वात, पित्त और कफ के अनूठे संतुलन से बना होता है। यह परीक्षण आपकी व्यक्तिगत जीवनशैली और उपचार निर्धारण में सहायता करता है।',
                style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
              ),
              const SizedBox(height: 24),

              // Info Cards
              _buildFeatureTile('⏱️', 'अनुमानित समय (Duration)', '18 प्रश्न · लगभग 10 से 12 मिनट', isDark),
              const SizedBox(height: 12),
              _buildFeatureTile('🔊', 'आवाज़ से उत्तर दें (Voice Enabled)', 'पढ़ने के साथ-साथ आप बोलकर भी चुन सकते हैं', isDark),
              const SizedBox(height: 12),
              _buildFeatureTile('🏛️', 'मान्यता प्राप्त (CCRAS Standard)', 'आयुष मंत्रालय और CCRAS मानकीकृत प्रश्नावली', isDark),

              const Spacer(),

              MkButton(
                text: 'परीक्षण शुरू करें (Start Assessment) →',
                onPressed: () => context.push('/prakriti/questions'),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/prakriti/delta'),
                  child: const Text('पहले किया हुआ है? डेल्टा चेक करें (Delta Check)'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(String emoji, String title, String desc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
