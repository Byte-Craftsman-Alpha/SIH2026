import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'n-01',
      'type': 'appointment',
      'title': 'आगामी ओपीडी परामर्श (Upcoming Consultation)',
      'body': 'आपकी अपॉइंटमेंट आज सुबह 10:30 बजे डॉ. राजेश शर्मा के साथ कक्ष 104 में है। टोकन: A-042',
      'time': '15 मिनट पहले',
      'unread': true,
      'route': '/booking/confirm',
    },
    {
      'id': 'n-02',
      'type': 'document',
      'title': 'दवा पर्ची स्कैन पूर्ण (OCR Extracted)',
      'body': 'आपकी पुरानी पर्ची का एआई विश्लेषण पूर्ण हो गया है। 3 दवाइयां व 1 जांच रिपोर्ट सत्यापित की गई।',
      'time': '2 घंटे पहले',
      'unread': true,
      'route': '/documents',
    },
    {
      'id': 'n-03',
      'type': 'consent',
      'title': 'डेटा साझाकरण सूचना (DPDP Consent Notice)',
      'body': 'AIIA नई दिल्ली को परामर्श अवधि के लिए आपका क्लिनिकल सारांश देखने की सहमति सक्रिय है।',
      'time': 'आज सुबह 08:30 बजे',
      'unread': false,
      'route': '/appointments',
    },
    {
      'id': 'n-04',
      'type': 'alert',
      'title': 'आपातकालीन अलर्ट लॉग (Triage Notification)',
      'body': 'रेड-फ्लैग ट्राइएज अलर्ट दर्ज किया गया एवं आपातकालीन संपर्क को एसएमएस अलर्ट प्रेषित किया गया।',
      'time': '2 दिन पहले',
      'unread': false,
      'route': '/emergency',
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['unread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('सभी सूचनाएं पढ़ी गईं (All marked as read)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = _notifications.where((n) {
      if (_selectedFilter == 'all') return true;
      return n['type'] == _selectedFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('सूचनाएं (Notifications)'),
        actions: [
          if (_notifications.any((n) => n['unread'] == true))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('सब पढ़ें'),
            ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'clear') _clearAll();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('सभी हटाएं (Clear All)'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Strip
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildFilterChip('all', 'सभी (All)', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('appointment', 'परामर्श (Appts)', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('document', 'दस्तावेज (Docs)', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('consent', 'सहमति (Consent)', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('alert', 'अलर्ट्स (Alerts)', isDark),
                ],
              ),
            ),
            const Divider(height: 1),

            // Notification List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                          ),
                          const SizedBox(height: 16),
                          Text('कोई सूचना नहीं है', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'No notifications found in this category',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      itemCount: filtered.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _buildNotificationCard(item, isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, bool isDark) {
    final isSelected = _selectedFilter == key;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
            : (isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight),
      ),
      selectedColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
      onSelected: (val) {
        setState(() => _selectedFilter = key);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item, bool isDark) {
    final bool isUnread = item['unread'] == true;
    final String type = item['type'];

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'appointment':
        icon = Icons.calendar_month_outlined;
        iconColor = isDark ? AppColors.accentDark : AppColors.accentLight;
        break;
      case 'document':
        icon = Icons.description_outlined;
        iconColor = isDark ? AppColors.ayushDark : AppColors.ayushLight;
        break;
      case 'consent':
        icon = Icons.shield_outlined;
        iconColor = Colors.blue;
        break;
      case 'alert':
      default:
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.emergencyLight;
        break;
    }

    return InkWell(
      onTap: () {
        setState(() => item['unread'] = false);
        if (item['route'] != null) {
          context.push(item['route']);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? (isDark ? AppColors.accentDark : AppColors.accentLight)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isUnread ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withValues(alpha: 0.15),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['title'],
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.accentDark : AppColors.accentLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['body'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['time'],
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
