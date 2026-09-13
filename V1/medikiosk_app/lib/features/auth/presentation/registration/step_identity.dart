import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class StepIdentity extends StatelessWidget {
  final TextEditingController nameController;
  final DateTime? selectedDob;
  final String selectedGender;
  final ValueChanged<DateTime> onDobChanged;
  final ValueChanged<String> onGenderChanged;

  const StepIdentity({
    super.key,
    required this.nameController,
    required this.selectedDob,
    required this.selectedGender,
    required this.onDobChanged,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'आपका नाम व पहचान\nYour Identity',
            style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'कृपया अपना पूरा नाम और जन्मतिथि भरें (Enter your full name and date of birth)',
            style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
          ),
          const SizedBox(height: 24),

          // Name Field
          Text('पूरा नाम (Full Name)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'उदा: रमेश कुमार (e.g. Ramesh Kumar)',
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
            ),
          ),
          const SizedBox(height: 20),

          // DOB Picker
          Text('जन्मतिथि (Date of Birth)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDob ?? DateTime(1980, 1, 1),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                onDobChanged(picked);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    selectedDob != null
                        ? "${selectedDob!.day}/${selectedDob!.month}/${selectedDob!.year}"
                        : 'जन्मतिथि चुनें (Select DOB)',
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Gender Selection
          Text('लिंग (Gender)', style: AppTextStyles.labelLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildGenderChip('male', 'पुरुष\nMale', '👨', isDark),
              const SizedBox(width: 12),
              _buildGenderChip('female', 'महिला\nFemale', '👩', isDark),
              const SizedBox(width: 12),
              _buildGenderChip('other', 'अन्य\nOther', '🧑', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String val, String label, String emoji, bool isDark) {
    final isSelected = selectedGender == val;
    return Expanded(
      child: InkWell(
        onTap: () => onGenderChanged(val),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                      : (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
