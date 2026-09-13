import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../../data/repositories/document_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _docRepo = DocumentRepository();
  bool _isLoading = false;
  String _selectedFilter = "all";
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _timelineItems = [];

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);
    final items = await _docRepo.getTimeline();
    if (!mounted) return;
    setState(() {
      _timelineItems = items;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    final filtered = _timelineItems.where((i) {
      if (_selectedFilter == "all") return true;
      return i["type"] == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('स्वास्थ्य इतिहास व दस्तावेज़ (Records)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'DPDP डेटा एक्सपोर्ट (Export JSON)',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('DPDP Act 2023 डेटा पोर्टेबिलिटी एक्सपोर्ट तैयार हो रहा है...')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/documents/upload'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text('पर्चा अपलोड करें (Upload)'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'पर्चे, टेस्ट रिपोर्ट या बीमारी खोजें...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  _buildFilterChip("all", "सभी (All Records)"),
                  const SizedBox(width: 8),
                  _buildFilterChip("prescription", "💊 पर्चे (Prescriptions)"),
                  const SizedBox(width: 8),
                  _buildFilterChip("lab_report", "🧪 लैब रिपोर्ट (Lab)"),
                  const SizedBox(width: 8),
                  _buildFilterChip("visit_summary", "📋 ओपीडी सारांश (Visits)"),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Timeline List
            Expanded(
              child: _isLoading && _timelineItems.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadTimeline,
                      child: filtered.isEmpty
                          ? ListView(
                              children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.folder_open_outlined, size: 64, color: AppColors.onSurfaceVariantLight),
                                SizedBox(height: 12),
                                Text(
                                  "कोई रिकॉर्ड नहीं मिला\n(No records found)",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.onSurfaceVariantLight),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isAbnormal = item["badge"].toString().contains("Abnormal");

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: InkWell(
                              onTap: () => context.push('/documents/detail'),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isAbnormal
                                        ? AppColors.emergencyLight.withValues(alpha: 0.3)
                                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(item["icon"], style: const TextStyle(fontSize: 20)),
                                            const SizedBox(width: 8),
                                            Text(item["date"], style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight)),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: isAbnormal
                                                ? AppColors.emergencyLight.withValues(alpha: 0.15)
                                                : AppColors.ayushLight.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item["badge"],
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isAbnormal ? AppColors.emergencyLight : AppColors.ayushLight,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item["title"],
                                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item["doctor"],
                                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark ? AppColors.surfaceDark : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item["preview"],
                                        style: const TextStyle(fontSize: 12, height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AppColors.ayushLight.withValues(alpha: 0.2),
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = key);
      },
    );
  }
}
