import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class StepEmergency extends StatelessWidget {
  final TextEditingController contact1NameController;
  final TextEditingController contact1PhoneController;
  final TextEditingController contact1RelationController;
  final TextEditingController contact2NameController;
  final TextEditingController contact2PhoneController;
  final bool preConsentEnabled;
  final ValueChanged<bool> onPreConsentChanged;

  const StepEmergency({
    super.key,
    required this.contact1NameController,
    required this.contact1PhoneController,
    required this.contact1RelationController,
    required this.contact2NameController,
    required this.contact2PhoneController,
    required this.preConsentEnabled,
    required this.onPreConsentChanged,
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
            'आपातकालीन संपर्क\nEmergency Contacts',
            style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'किसी गंभीर लक्षण की स्थिति में अस्पताल तुरंत इन नंबरों पर सूचना भेज सकेगा',
            style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
          ),
          const SizedBox(height: 20),

          // Contact 1: Family
          Container(
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
                  children: [
                    const Text('👨‍👩‍👦', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text('प्राथमिक संपर्क (परिवार / Family)', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contact1NameController,
                  decoration: const InputDecoration(hintText: 'नाम (Name) — उदा: सीता देवी', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: contact1PhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: 'फ़ोन (Phone)', prefixIcon: Icon(Icons.phone_outlined)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: contact1RelationController,
                        decoration: const InputDecoration(hintText: 'रिश्ता (Relation)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contact 2: Family Doctor / Relative
          Container(
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
                  children: [
                    const Text('🩺', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('द्वितीयक संपर्क (पारिवारिक डॉक्टर / Relative)', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contact2NameController,
                  decoration: const InputDecoration(hintText: 'नाम (Name) — उदा: डॉ. मेहता', prefixIcon: Icon(Icons.medical_services_outlined)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contact2PhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'फ़ोन (Phone)', prefixIcon: Icon(Icons.phone_outlined)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pre-consent toggle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.emergencyLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.emergencyLight.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: preConsentEnabled,
                  activeColor: AppColors.emergencyLight,
                  onChanged: (val) => onPreConsentChanged(val ?? true),
                ),
                const Expanded(
                  child: Text(
                    'आपातकाल में इन संपर्कों को स्वचालित SMS चेतावनी भेजने की अनुमति दें (DPDP Act §7(c) Emergency Exemption)',
                    style: TextStyle(fontSize: 12, height: 1.3),
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
