import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';
import '../../../core/widgets/mk_card.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String tokenNo;
  final String doctorName;
  final String hospitalName;
  final String department;
  final String slotTime;
  final String roomNo;

  const BookingConfirmationScreen({
    super.key,
    this.tokenNo = 'A-042',
    this.doctorName = 'Dr. Rajesh Sharma',
    this.hospitalName = 'All India Institute of Ayurveda (AIIA)',
    this.department = 'Kayachikitsa OPD (कायचिकित्सा)',
    this.slotTime = 'Today, 10:30 AM - 10:45 AM',
    this.roomNo = 'Room 104, 1st Floor, OPD Block A',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('पुष्टिकरण (Confirmation)'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Header
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.ayushDark.withValues(alpha: 0.2)
                        : AppColors.ayushLight.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 48,
                    color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'परामर्श सफलतापूर्वक बुक हुआ!',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Appointment Confirmed & Token Generated',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                ),
              ),
              const SizedBox(height: 24),

              // Central Token Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'ओपीडी टोकन नंबर (OPD Token)',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        tokenNo,
                        style: AppTextStyles.displayMedium.copyWith(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.local_hospital_outlined,
                      label: 'अस्पताल (Hospital)',
                      value: hospitalName,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.person_outline,
                      label: 'चिकित्सक (Doctor)',
                      value: doctorName,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.medical_services_outlined,
                      label: 'विभाग (Department)',
                      value: department,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.access_time_rounded,
                      label: 'समय (Slot)',
                      value: slotTime,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.meeting_room_outlined,
                      label: 'कक्ष संख्या (Location)',
                      value: roomNo,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Queue Status Callout
              MkCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 32,
                      color: isDark ? AppColors.accentDark : AppColors.accentLight,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'कतार स्थिति: आपके आगे 4 मरीज हैं',
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'अनुमानित प्रतीक्षा समय: ~20-25 मिनट',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // DPDP Shared Data Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.ayushDark.withValues(alpha: 0.1)
                      : AppColors.ayushLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.ayushDark.withValues(alpha: 0.3)
                        : AppColors.ayushLight.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 20,
                          color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'साझा किया गया स्वास्थ्य विवरण (DPDP Act 2023)',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildShareItem('✓ 12-बिंदु नैदानिक सारांश (Clinical Summary)'),
                    _buildShareItem('✓ वात-पित्त प्रकृति स्कोर एवं जीवनशैली विवरण'),
                    _buildShareItem('✓ पूर्व पर्ची एवं हालिया लैब जांच रिकॉर्ड्स'),
                    const SizedBox(height: 6),
                    Text(
                      'वैधता: इस ओपीडी सत्र तक (अधिकतम 24 घंटे में स्वतः समाप्त)',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Actions
              MkButton(
                text: 'अपॉइंटमेंट सूची देखें (View Appointments)',
                icon: Icons.calendar_month_outlined,
                onPressed: () {
                  context.go('/appointments');
                },
              ),
              const SizedBox(height: 12),
              MkButton(
                text: 'पर्ची डाउनलोड करें (Save Slip)',
                variant: MkButtonVariant.secondary,
                icon: Icons.download_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('डिजिटल ओपीडी पर्ची डाउनलोड हो गई है (Slip saved)'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              MkButton(
                text: 'मुख्य पृष्ठ पर लौटें (Return to Home)',
                variant: MkButtonVariant.outline,
                icon: Icons.home_outlined,
                onPressed: () {
                  context.go('/home');
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildShareItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
      ),
    );
  }
}
