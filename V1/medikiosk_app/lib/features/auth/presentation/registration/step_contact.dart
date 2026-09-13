import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class StepContact extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController abhaController;

  const StepContact({
    super.key,
    required this.phoneController,
    required this.emailController,
    required this.abhaController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'संपर्क व आयुष्मान भारत\nContact & ABHA',
            style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'मोबाइल नंबर और आभा (ABHA) हेल्थ आईडी जोड़ें',
            style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
          ),
          const SizedBox(height: 24),

          // Phone Field
          Text('मोबाइल नंबर (Mobile Number)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              prefixText: '+91 ',
              prefixIcon: const Icon(Icons.phone_outlined),
              filled: true,
              fillColor: surfaceColor,
            ),
          ),
          const SizedBox(height: 20),

          // Email Field (Optional)
          Text('ईमेल (Email - Optional)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'name@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: surfaceColor,
            ),
          ),
          const SizedBox(height: 20),

          // ABHA ID Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ayushLight.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.ayushLight.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('आयुष्मान भारत हेल्थ अकाउंट (ABHA)', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '14 अंकों का ABHA नंबर जोड़ने से पुराने अस्पताल रिकॉर्ड्स सुरक्षित लिंक होते हैं।',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: abhaController,
                  style: AppTextStyles.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'उदा: 91-1234-5678-9012',
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
