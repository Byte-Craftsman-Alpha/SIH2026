import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  String _selectedType = "prescription";
  DateTime _selectedDate = DateTime.now();
  String? _selectedFileName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('दस्तावेज़ अपलोड (Upload Record)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'पुराना पर्चा या टेस्ट रिपोर्ट जोड़ें\nAdd Health Document',
                style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'मेडीकियोस्क OCR तकनीक से पर्चे को पढ़कर डॉक्टरों के लिए डिजिटल सारांश तैयार करेगा',
                style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
              ),
              const SizedBox(height: 24),

              // Upload Source Picker Box
              InkWell(
                onTap: () {
                  setState(() => _selectedFileName = "prescription_scan_feb2026.jpg");
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedFileName != null ? AppColors.ayushLight : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _selectedFileName != null ? Icons.check_circle : Icons.camera_alt_outlined,
                          size: 36,
                          color: _selectedFileName != null ? AppColors.ayushLight : AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _selectedFileName != null ? 'फाइल चयनित: $_selectedFileName' : 'फोटो खीचें या गैलरी से चुनें',
                        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG, PNG या PDF (Camera, Gallery, or Files)',
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Document Type Selection
              Text('दस्तावेज़ का प्रकार (Document Type)', style: AppTextStyles.labelLarge),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildTypeChip("prescription", "💊 डॉक्टर का पर्चा\nPrescription", isDark),
                  const SizedBox(width: 8),
                  _buildTypeChip("lab_report", "🧪 लैब रिपोर्ट\nLab Report", isDark),
                  const SizedBox(width: 8),
                  _buildTypeChip("discharge", "🏥 डिस्चार्ज सारांश\nDischarge", isDark),
                ],
              ),
              const SizedBox(height: 24),

              // Date Picker
              Text('पर्चे की तारीख (Document Date)', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                        style: AppTextStyles.bodyLarge,
                      ),
                      const Icon(Icons.calendar_today_outlined, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Consent Micro-Note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.ayushLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('🔒', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'यह दस्तावेज़ आपके परामर्श हेतु डॉक्टर के साथ सुरक्षित साझा किया जाएगा। (DPDP Act 2023 Secure)',
                        style: TextStyle(fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              MkButton(
                text: 'अपलोड करें व OCR शुरू करें (Upload & Process) →',
                onPressed: () {
                  context.push('/documents/parsing');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, bool isDark) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? AppColors.surfaceDark : Colors.white)
                    : (isDark ? Colors.white : AppColors.onSurfaceLight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
