import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';
import '../../../../data/repositories/appointment_repository.dart';

class BookingWizard extends StatefulWidget {
  final String? hospitalId;
  final String? doctorId;
  final String? slot;

  const BookingWizard({
    super.key,
    this.hospitalId,
    this.doctorId,
    this.slot,
  });

  @override
  State<BookingWizard> createState() => _BookingWizardState();
}

class _BookingWizardState extends State<BookingWizard> {
  final _appointmentRepo = AppointmentRepository();
  bool _isBooking = false;
  String _urgency = "regular";
  bool _attachSummary = true;
  bool _attachPrescriptions = true;
  bool _attachLabs = true;
  String _consentScope = "summary_plus_documents"; // "summary_only" | "summary_plus_documents"

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('अपॉइंटमेंट बुकिंग (Confirmation Steps)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Urgency Selector
              Text('1. परामर्श प्राथमिकता (Consultation Urgency)', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildUrgencyCard(
                      val: "regular",
                      title: "सामान्य ओपीडी (Regular)",
                      desc: "नियमित जांच व पुराना फॉलो-अप",
                      emoji: "📅",
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUrgencyCard(
                      val: "urgent",
                      title: "प्राथमिकता (Urgent)",
                      desc: "तीव्र लक्षण / बुखार / असहनीय दर्द",
                      emoji: "⚡",
                      isDark: isDark,
                      surfaceColor: surfaceColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Step 2: Context Attachment Checklist
              Text('2. डॉक्टर के साथ क्या साझा करें? (Clinical Context)', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                'चयनित विवरण डॉक्टर के पास पहले से उपलब्ध होगा जिससे परामर्श समय बचेगा।',
                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
              ),
              const SizedBox(height: 12),

              _buildCheckboxTile(
                title: 'AI क्लिनिकल इतिहास सारांश (Intake Summary)',
                subtitle: 'आज दर्ज की गई मुख्य समस्या व दशाविध विश्लेषण',
                value: _attachSummary,
                onChanged: (v) => setState(() => _attachSummary = v!),
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildCheckboxTile(
                title: 'पुराने पर्चे (Verified Prescriptions - 1 Record)',
                subtitle: 'डॉ. ए. वर्मा का पर्चा (14 Feb 2026)',
                value: _attachPrescriptions,
                onChanged: (v) => setState(() => _attachPrescriptions = v!),
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildCheckboxTile(
                title: 'लैब रिपोर्ट्स (Blood Glucose & HbA1c - 1 Report)',
                subtitle: 'SRL टेस्ट रिपोर्ट (20 Aug 2026)',
                value: _attachLabs,
                onChanged: (v) => setState(() => _attachLabs = v!),
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Step 3: Consent Scope
              Text('3. डॉक्टर एक्सेस विंडो व सहमति दायरा (Consent Scope)', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildConsentOption(
                val: "summary_plus_documents",
                title: "सारांश + पिछले 2 सत्यापित दस्तावेज़ (अनुशंसित)",
                subtitle: "परामर्श समाप्ति के 4 घंटे बाद एक्सेस स्वतः समाप्त हो जाएगा।",
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildConsentOption(
                val: "summary_only",
                title: "केवल आज का सारांश (Summary Only)",
                subtitle: "कोई पुराना पर्चा या लैब रिपोर्ट साझा न करें।",
                surfaceColor: surfaceColor,
                isDark: isDark,
              ),

              const SizedBox(height: 32),

              MkButton(
                text: 'टोकन बुक करें (Confirm & Get Token) ✓',
                isLoading: _isBooking,
                onPressed: () async {
                  setState(() => _isBooking = true);
                  final res = await _appointmentRepo.bookAppointment(
                    hospitalId: widget.hospitalId ?? 'hosp_aiia',
                    doctorId: widget.doctorId ?? 'doc_sharma',
                    slot: widget.slot ?? '11:00 AM',
                    urgency: _urgency,
                    consentScope: _consentScope,
                  );
                  if (!mounted) return;
                  setState(() => _isBooking = false);

                  final token = res?['token_no'] ?? 'A-007';
                  final doctor = res?['doctor_name'] ?? 'Dr. Rajesh Sharma (MD Ayu)';
                  final hospital = res?['hospital_name'] ?? 'All India Institute of Ayurveda (AIIA)';
                  final slot = res?['slot'] ?? 'Today, 11:00 AM - 11:15 AM';

                  if (context.mounted) {
                    context.push('/booking/confirm?token=$token&doctor=$doctor&hospital=$hospital&slot=$slot');
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

  Widget _buildUrgencyCard({
    required String val,
    required String title,
    required String desc,
    required String emoji,
    required bool isDark,
    required Color surfaceColor,
  }) {
    final isSelected = _urgency == val;
    return InkWell(
      onTap: () => setState(() => _urgency = val),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (val == "urgent" ? AppColors.emergencyLight.withValues(alpha: 0.15) : AppColors.ayushLight.withValues(alpha: 0.15))
              : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (val == "urgent" ? AppColors.emergencyLight : AppColors.ayushLight)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariantLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Color surfaceColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: CheckboxListTile(
        value: value,
        activeColor: AppColors.ayushLight,
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariantLight)),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildConsentOption({
    required String val,
    required String title,
    required String subtitle,
    required Color surfaceColor,
    required bool isDark,
  }) {
    final isSelected = _consentScope == val;
    return InkWell(
      onTap: () => setState(() => _consentScope = val),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.ayushLight.withValues(alpha: 0.12)
              : surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.ayushLight : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.ayushLight : (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariantLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
