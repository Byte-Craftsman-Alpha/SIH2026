import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AyushContextChip extends StatelessWidget {
  final String prakriti;
  const AyushContextChip({super.key, this.prakriti = "Vata-Pitta (वात-पित्त)"});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ayushLight.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ayushLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🌿', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            'आयुष मोड · प्रकृति बेसलाइन: $prakriti',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.ayushLight,
            ),
          ),
        ],
      ),
    );
  }
}
