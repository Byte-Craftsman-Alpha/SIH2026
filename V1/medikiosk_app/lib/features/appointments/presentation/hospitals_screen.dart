import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  String _filter = "all";
  String _searchQuery = "";

  final List<Map<String, dynamic>> _hospitals = [
    {
      "id": "hosp_aiia",
      "name": "All India Institute of Ayurveda (AIIA)",
      "address": "Mathura Road, Sarita Vihar, New Delhi",
      "distance": "2.4 km",
      "is_ayush": true,
      "queue": "Moderate (15 min wait)",
      "departments": "कायचिकित्सा (Internal Med) · पंचकर्म · शल्य तंत्र",
    },
    {
      "id": "hosp_charak",
      "name": "Charak Palika Ayurvedic Hospital",
      "address": "Moti Bagh I, New Delhi",
      "distance": "5.1 km",
      "is_ayush": true,
      "queue": "Low (5 min wait)",
      "departments": "कायचिकित्सा · स्वस्थवृत्त · पंचकर्म",
    },
    {
      "id": "hosp_aiims",
      "name": "All India Institute of Medical Sciences (AIIMS)",
      "address": "Ansari Nagar, Sri Aurobindo Marg, New Delhi",
      "distance": "6.8 km",
      "is_ayush": false,
      "queue": "Heavy (45 min wait)",
      "departments": "General Medicine · Cardiology · Endocrinology",
    },
    {
      "id": "hosp_safdarjung",
      "name": "Safdarjung Hospital & VMMC",
      "address": "Ring Road, opposite AIIMS, New Delhi",
      "distance": "7.0 km",
      "is_ayush": false,
      "queue": "High (35 min wait)",
      "departments": "Emergency & Trauma · Internal Medicine · Pulmonary",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    final list = _hospitals.where((h) {
      if (_filter == "ayush" && h["is_ayush"] != true) return false;
      if (_filter == "allopathy" && h["is_ayush"] != false) return false;
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = (h["name"] as String).toLowerCase().contains(q);
        final deptMatch = (h["departments"] as String).toLowerCase().contains(q);
        return nameMatch || deptMatch;
      }
      return true;
    }).toList();

    debugPrint("🚨 HOSPITALS_SCREEN BUILD: list length = ${list.length}, filter = $_filter");

    return Scaffold(
      appBar: AppBar(
        title: const Text('अस्पताल खोजें (Find Hospitals)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/appointments');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Search box
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'अस्पताल या विभाग का नाम खोजें...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: surfaceColor,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip("all", "सभी अस्पताल (All)"),
                const SizedBox(width: 8),
                _buildChip("ayush", "🌿 केवल आयुष (AYUSH Only)"),
                const SizedBox(width: 8),
                _buildChip("allopathy", "🏥 एलोपैथी (Allopathy)"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Empty state
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Text(
                  'कोई अस्पताल नहीं मिला',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                  ),
                ),
              ),
            ),

          // Hospital Cards
          for (final h in list)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (h["is_ayush"] == true)
                      ? AppColors.ayushLight.withValues(alpha: 0.3)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (h["is_ayush"] == true)
                              ? AppColors.ayushLight.withValues(alpha: 0.15)
                              : AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (h["is_ayush"] == true) ? "🌿 AYUSH INSTITUTE" : "🏥 MULTI-SPECIALTY",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: (h["is_ayush"] == true) ? AppColors.ayushLight : AppColors.primaryLight,
                          ),
                        ),
                      ),
                      Text(
                        "📍 ${h['distance']}",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariantLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    h["name"] as String,
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    h["address"] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "प्रमुख विभाग: ${h['departments']}",
                    style: const TextStyle(fontSize: 11, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "कतार स्थिति: ${h['queue']}",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ayushLight),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.push('/doctors/slots'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          foregroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('डॉक्टर चुनें →', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String key, String label) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AppColors.ayushLight.withValues(alpha: 0.2),
      onSelected: (val) {
        if (val) setState(() => _filter = key);
      },
    );
  }
}
