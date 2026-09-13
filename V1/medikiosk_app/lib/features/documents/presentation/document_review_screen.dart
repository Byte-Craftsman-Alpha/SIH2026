import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';

class DocumentReviewScreen extends StatefulWidget {
  const DocumentReviewScreen({super.key});

  @override
  State<DocumentReviewScreen> createState() => _DocumentReviewScreenState();
}

class _DocumentReviewScreenState extends State<DocumentReviewScreen> {
  final List<Map<String, dynamic>> _extractedMeds = [
    {"name": "Metformin Hydrochloride", "dose": "500 mg", "freq": "दिन में 2 बार (BD)", "confidence": 0.94, "verified": true},
    {"name": "Amlodipine Besylate", "dose": "5 mg", "freq": "दिन में 1 बार सुबह (OD)", "confidence": 0.88, "verified": true},
    {"name": "Triphala Churna (त्रिफला चूर्ण)", "dose": "5 ग्राम", "freq": "रात को सोते समय गुनगुने जल से", "confidence": 0.76, "verified": true},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('दस्तावेज़ समीक्षा (Verify Extraction)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.ayushLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.ayushLight.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI निष्कर्षों की पुष्टि करें', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          const Text(
                            'कृपया निष्कर्षित दवाओं व जांचों की जांच करें। गलत विवरण पर टैप करके सुधारें।',
                            style: TextStyle(fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Drug interaction callout
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentLight.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚠️', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'औषधि परामर्श: त्रिफला चूर्ण और मेटफॉर्मिन का एक साथ सेवन ब्लड शुगर को तेजी से कम कर सकता है। डॉक्टर को सूचित किया गया।',
                        style: TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('पहचानी गई दवाइयां (Extracted Medications)', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              ...List.generate(_extractedMeds.length, (index) {
                final med = _extractedMeds[index];
                final conf = (med["confidence"] as double);
                final confPercent = (conf * 100).toInt();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Text('💊', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med["name"], style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text("${med['dose']} · ${med['freq']}", style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: conf > 0.8 ? AppColors.ayushLight.withValues(alpha: 0.15) : AppColors.accentLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$confPercent% OCR",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: conf > 0.8 ? AppColors.ayushLight : AppColors.accentLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: AppColors.ayushLight, size: 22),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 28),

              MkButton(
                text: 'सत्यापित करें व रिकॉर्ड में जोड़ें (Confirm & Save) ✓',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('पर्चा सत्यापित कर रिकॉर्ड में जोड़ दिया गया!')),
                  );
                  context.go('/documents');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
