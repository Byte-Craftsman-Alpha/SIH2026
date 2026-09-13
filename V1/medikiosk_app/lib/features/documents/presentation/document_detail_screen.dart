import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DocumentDetailScreen extends StatelessWidget {
  const DocumentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('दस्तावेज़ विवरण (Document Detail)'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'निष्कर्षित डेटा (Parsed)'),
              Tab(text: 'मूल स्कैन (Original)'),
              Tab(text: 'ऑडिट ट्रेल (History)'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.emergencyLight),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('दस्तावेज़ हटा दिया गया (Deleted)')),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Parsed
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('डॉक्टर का पर्चा (Prescription)', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          const Text('14 Feb 2026', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight)),
                        ],
                      ),
                      const Divider(height: 20),
                      const Text('चिकित्सक: डॉ. ए. वर्मा (चरक पालिका अस्पताल)', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      const Text('सत्यापन स्थिति: पूर्ण सत्यापित (Verified ✓)', style: TextStyle(color: AppColors.ayushLight, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('दवाइयां (Prescribed Medicines)', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildMedItem("Metformin 500mg", "दिन में 2 बार भोजन के बाद (BD)", surfaceColor),
                _buildMedItem("Amlodipine 5mg", "प्रतिदिन 1 बार सुबह (OD)", surfaceColor),
                _buildMedItem("Triphala Churna 5g", "रात को गुनगुने पानी के साथ (Bedtime)", surfaceColor),
              ],
            ),

            // Tab 2: Original Scan Placeholder
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 64, color: AppColors.primaryLight),
                    SizedBox(height: 16),
                    Text('मूल पर्चा स्कैन (Original Scan Preview)', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('prescription_feb2026.pdf (1.2 MB)', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight)),
                  ],
                ),
              ),
            ),

            // Tab 3: History & Audit
            ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                ListTile(
                  leading: Icon(Icons.check_circle, color: AppColors.ayushLight),
                  title: Text('सत्यापित किया गया (Verified)'),
                  subtitle: Text('मरीज द्वारा पुष्टि · 12 Sep 2026, 10:15 AM'),
                ),
                ListTile(
                  leading: Icon(Icons.document_scanner, color: AppColors.primaryLight),
                  title: Text('OCR द्वारा निष्कर्षण पूर्ण'),
                  subtitle: Text('हिंदी-अंग्रेज़ी मॉडल v2.1 · 86% विश्वास स्तर'),
                ),
                ListTile(
                  leading: Icon(Icons.cloud_upload_outlined),
                  title: Text('अपलोड किया गया'),
                  subtitle: Text('कियोस्क स्कैनर द्वारा अपलोड · 14 Feb 2026'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedItem(String name, String timing, Color surfaceColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('💊', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(timing, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
