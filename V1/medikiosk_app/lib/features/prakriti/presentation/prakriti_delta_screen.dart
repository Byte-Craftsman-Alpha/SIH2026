import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';

class PrakritiDeltaScreen extends StatefulWidget {
  const PrakritiDeltaScreen({super.key});

  @override
  State<PrakritiDeltaScreen> createState() => _PrakritiDeltaScreenState();
}

class _PrakritiDeltaScreenState extends State<PrakritiDeltaScreen> {
  bool? _hasChanges;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('प्रकृति त्वरित जांच (Delta Check)'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'वापसी मरीज डेल्टा चेक\nReturning Patient Fast Check',
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'पिछली जांच: वात-पित्त (Vata-Pitta) · 30 दिन पहले\nक्या आपके स्वास्थ्य, वजन या दिनचर्या में कोई बड़ा बदलाव आया है?',
                style: AppTextStyles.bodyMedium.copyWith(height: 1.4, color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
              ),
              const SizedBox(height: 32),

              // Option 1: No major changes
              _buildChoiceCard(
                title: 'नहीं, कोई बड़ा बदलाव नहीं',
                subtitle: 'No significant changes (Fast confirm <15s)',
                emoji: '✓',
                selected: _hasChanges == false,
                onTap: () => setState(() => _hasChanges = false),
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // Option 2: Yes, major changes -> Reassess
              _buildChoiceCard(
                title: 'हाँ, महत्वपूर्ण बदलाव हुए हैं',
                subtitle: 'Significant change in weight, chronic illness or sleep',
                emoji: '🔄',
                selected: _hasChanges == true,
                onTap: () => setState(() => _hasChanges = true),
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),

              const Spacer(),

              MkButton(
                text: _hasChanges == true ? 'नया परीक्षण शुरू करें (Full Re-Assessment) →' : 'पुष्टि करें व आगे बढ़ें (Confirm Baseline)',
                onPressed: _hasChanges == null
                    ? null
                    : () {
                        if (_hasChanges == true) {
                          context.push('/prakriti/question');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('प्रकृति बेसलाइन की पुष्टि की गई (Baseline confirmed)')),
                          );
                          context.go('/home');
                        }
                      },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required String emoji,
    required bool selected,
    required VoidCallback onTap,
    required Color surfaceColor,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.ayushLight.withValues(alpha: 0.15)
              : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.ayushLight : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
