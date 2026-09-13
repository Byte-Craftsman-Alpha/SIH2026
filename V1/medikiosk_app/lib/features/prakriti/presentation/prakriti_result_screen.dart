import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';
import '../../../core/widgets/mk_donut_chart.dart';
import '../../../core/widgets/mk_audio_button.dart';

class PrakritiResultScreen extends StatelessWidget {
  final double vata;
  final double pitta;
  final double kapha;
  final String dominant;

  const PrakritiResultScreen({
    super.key,
    this.vata = 0.55,
    this.pitta = 0.30,
    this.kapha = 0.15,
    this.dominant = "Vata-Pitta (वात-पित्त)",
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रकृति परिणाम (Prakriti Result)'),
        actions: const [
          MkAudioButton(textToRead: "आपका प्रकृति परिणाम वात पित्त है। इसमें 55 प्रतिशत वात, 30 प्रतिशत पित्त और 15 प्रतिशत कफ पाया गया है।"),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.ayushLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.ayushLight.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Text('🌿', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Text(
                      'आपकी प्रधान प्रकृति\nYour Dominant Constitution',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariantLight),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      dominant,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.ayushLight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'सत्त्व: प्रवर (Pravara) · संहनन: मध्यम (Madhyama)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Donut Breakdown Chart
              Text('दोषों का आनुपातिक संतुलन (Dosha Ratio)', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Center(
                child: MkDonutChart(
                  vata: vata,
                  pitta: pitta,
                  kapha: kapha,
                ),
              ),
              const SizedBox(height: 28),

              // Recommendations Section
              Text('दैनिक आहार व जीवनशैली सुझाव (Ayurvedic Guidance)', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildGuidanceCard(
                emoji: '🍲',
                title: 'आहार (Diet)',
                desc: 'गर्म, ताजा, घी और तेल युक्त सुपाच्य भोजन लें। अत्यधिक ठंडे या सूखे खाद्य पदार्थों से बचें।',
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildGuidanceCard(
                emoji: '🧘‍♂️',
                title: 'विहार व दिनचर्या (Lifestyle)',
                desc: 'नियमित समय पर सोएं और जागें। प्रतिदिन तिल के तेल से अभ्यंग (मालिश) वात शमन में लाभकारी है।',
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildGuidanceCard(
                emoji: '🍵',
                title: 'आयुष पेय (Herbal Infusion)',
                desc: 'अश्वगंधा, मुलेठी और सौंफ का हल्का गुनगुना काढ़ा पाचन अग्नि और मानसिक शांति के लिए उत्तम है।',
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),

              const SizedBox(height: 32),

              MkButton(
                text: 'स्वास्थ्य प्रोफाइल में सहेजें (Save & Done) ✓',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('प्रकृति प्रोफाइल सफलतापूर्वक सुरक्षित की गई!')),
                  );
                  context.go('/home');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidanceCard({
    required String emoji,
    required String title,
    required String desc,
    required Color surfaceColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
