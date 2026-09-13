import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile & Settings',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome / Greeting Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'नमस्ते, रमेश जी!',
                              style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'आज आप कैसा महसूस कर रहे हैं?',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.ayushDark.withValues(alpha: 0.2)
                                : AppColors.ayushLight.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'प्रकृति: वात-पित्त',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Active Visit Card CTA
                    InkWell(
                      onTap: () => context.push('/chat'),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'नया परामर्श शुरू करें (Start Intake)',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    'आवाज या स्पर्श द्वारा लक्षण बताएं',
                                    style: AppTextStyles.caption.copyWith(
                                      color: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4 Main Feature Navigation Tiles
              Text(
                'त्वरित सेवाएं (Quick Services)',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.25,
                children: [
                  _buildTile(
                    context,
                    title: 'एआई स्वास्थ्य संवाद',
                    subtitle: 'Clinical Intake Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    color: isDark ? AppColors.accentDark : AppColors.accentLight,
                    onTap: () => context.push('/chat'),
                  ),
                  _buildTile(
                    context,
                    title: 'दस्तावेज व पर्चियां',
                    subtitle: 'Medical Records',
                    icon: Icons.folder_shared_outlined,
                    color: isDark ? AppColors.ayushDark : AppColors.ayushLight,
                    onTap: () => context.push('/documents'),
                  ),
                  _buildTile(
                    context,
                    title: 'ओपीडी अपॉइंटमेंट',
                    subtitle: 'Appointments & Tokens',
                    icon: Icons.calendar_month_outlined,
                    color: Colors.blueAccent,
                    onTap: () => context.push('/appointments'),
                  ),
                  _buildTile(
                    context,
                    title: 'आयुष प्रकृति परीक्षण',
                    subtitle: 'Dosha Assessment',
                    icon: Icons.spa_outlined,
                    color: Colors.purpleAccent,
                    onTap: () => context.push('/prakriti'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Upcoming Appointment Banner
              MkCard(
                padding: const EdgeInsets.all(16),
                onTap: () => context.push('/appointments'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'A-042',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'आज की ओपीडी: डॉ. राजेश शर्मा',
                            style: AppTextStyles.titleMedium.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '10:30 AM • कायचिकित्सा OPD, AIIA',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Emergency Banner
              InkWell(
                onTap: () => context.push('/emergency'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.emergencyLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.emergencyLight.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emergency, color: AppColors.emergencyLight, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'आपातकालीन सहायता (Emergency / Call 108)',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.emergencyLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'सीने में दर्द, सांस फूलना या तीव्र समस्या होने पर तुरंत टैप करें',
                              style: AppTextStyles.caption.copyWith(
                                color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward, color: AppColors.emergencyLight, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0:
              break;
            case 1:
              context.push('/chat');
              break;
            case 2:
              context.push('/documents');
              break;
            case 3:
              context.push('/appointments');
              break;
            case 4:
              context.push('/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Records'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Appts'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, size: 22, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
