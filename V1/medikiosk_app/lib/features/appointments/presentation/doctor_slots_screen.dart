import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';

class DoctorSlotsScreen extends StatefulWidget {
  const DoctorSlotsScreen({super.key});

  @override
  State<DoctorSlotsScreen> createState() => _DoctorSlotsScreenState();
}

class _DoctorSlotsScreenState extends State<DoctorSlotsScreen> {
  int _selectedDateIndex = 0;
  String? _selectedSlot = "10:30 AM";

  final List<String> _morningSlots = ["09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM"];
  final List<String> _afternoonSlots = ["02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM"];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('डॉक्टर व समय चुनें (Select Slot)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor profile card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.ayushLight,
                      ),
                      child: const Center(child: Text('👨‍⚕️', style: TextStyle(fontSize: 28))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'डॉ. राजेश शर्मा (MD Ayurveda)',
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'कायचिकित्सा व मधुमेह विशेषज्ञ · AIIA New Delhi',
                            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Text('🗣️ भाषा: हिंदी, English', style: TextStyle(fontSize: 11)),
                              SizedBox(width: 12),
                              Text('⭐ 4.9 (420+ मरीज)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Horizontal Date Strip
              Text('परामर्श तिथि (Select Date)', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(5, (idx) {
                    final isSelected = _selectedDateIndex == idx;
                    final dayNum = 12 + idx;
                    final dayName = ["आज", "कल", "सोम", "मंगल", "बुध"][idx];

                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: InkWell(
                        onTap: () => setState(() => _selectedDateIndex = idx),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 68,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                                : surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                                      : AppColors.onSurfaceVariantLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$dayNum Sep",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Morning Slots Grid
              Text('सुबह की कतार (Morning Slots)', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _morningSlots.map((s) => _buildSlotChip(s, isDark, surfaceColor)).toList(),
              ),
              const SizedBox(height: 20),

              // Afternoon Slots Grid
              Text('दोपहर की कतार (Afternoon Slots)', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _afternoonSlots.map((s) => _buildSlotChip(s, isDark, surfaceColor)).toList(),
              ),

              const SizedBox(height: 36),

              MkButton(
                text: 'आगे बढ़ें (Proceed to Booking Wizard) →',
                onPressed: _selectedSlot == null
                    ? null
                    : () {
                        context.push('/booking?slot=$_selectedSlot&hospitalId=hosp_aiia&doctorId=doc_sharma');
                      },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotChip(String slot, bool isDark, Color surfaceColor) {
    final isSelected = _selectedSlot == slot;
    return InkWell(
      onTap: () => setState(() => _selectedSlot = slot),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ayushLight : surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.ayushLight : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          slot,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.onSurfaceLight),
          ),
        ),
      ),
    );
  }
}
