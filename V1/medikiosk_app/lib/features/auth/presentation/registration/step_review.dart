import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class StepReview extends StatelessWidget {
  final String name;
  final String gender;
  final DateTime? dob;
  final String phone;
  final String email;
  final String abha;
  final String contact1Name;
  final String contact1Phone;
  final ValueChanged<int> onEditStep;

  const StepReview({
    super.key,
    required this.name,
    required this.gender,
    required this.dob,
    required this.phone,
    required this.email,
    required this.abha,
    required this.contact1Name,
    required this.contact1Phone,
    required this.onEditStep,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    final dobStr = dob != null ? "${dob!.day}/${dob!.month}/${dob!.year}" : "Not set";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'विवरण की समीक्षा करें\nReview & Confirm',
            style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'पंजीकरण पूरा करने से पहले कृपया अपनी जानकारी जांच लें',
            style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
          ),
          const SizedBox(height: 20),

          // Identity Review Card
          _buildReviewCard(
            title: 'व्यक्तिगत पहचान (Identity)',
            icon: '👤',
            onEdit: () => onEditStep(0),
            surfaceColor: surfaceColor,
            isDark: isDark,
            items: [
              MapEntry('नाम (Name)', name.isNotEmpty ? name : 'रमेश कुमार'),
              MapEntry('लिंग (Gender)', gender.toUpperCase()),
              MapEntry('जन्मतिथि (DOB)', dobStr),
            ],
          ),
          const SizedBox(height: 14),

          // Contact Review Card
          _buildReviewCard(
            title: 'संपर्क व ABHA (Contact & ABHA)',
            icon: '📱',
            onEdit: () => onEditStep(1),
            surfaceColor: surfaceColor,
            isDark: isDark,
            items: [
              MapEntry('फ़ोन (Phone)', "+91 $phone"),
              if (email.isNotEmpty) MapEntry('ईमेल (Email)', email),
              MapEntry('ABHA ID', abha.isNotEmpty ? abha : '91-1234-5678-9012 (Demo Linked)'),
            ],
          ),
          const SizedBox(height: 14),

          // Emergency Review Card
          _buildReviewCard(
            title: 'आपातकालीन संपर्क (Emergency)',
            icon: '🚨',
            onEdit: () => onEditStep(2),
            surfaceColor: surfaceColor,
            isDark: isDark,
            items: [
              MapEntry('प्राथमिक (Family)', contact1Name.isNotEmpty ? "$contact1Name ($contact1Phone)" : "सीता देवी (+91 98765-43299)"),
              const MapEntry('स्वचालित SMS चेतावनी', 'सक्रिय (Active)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required String icon,
    required VoidCallback onEdit,
    required Color surfaceColor,
    required bool isDark,
    required List<MapEntry<String, String>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
                tooltip: 'बदलें (Edit)',
              ),
            ],
          ),
          const Divider(height: 16),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariantLight)),
                    Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
