import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/language');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_rounded,
                size: 100,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.appTagline,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          String envLabel = 'Beta (Local DB)';
          try {
            final storage = ref.read(storageServiceProvider);
            final env = storage.getEnvironment();
            envLabel = env == AppEnvironment.normal ? 'Normal (Vercel Cloud)' : 'Beta (Local DB)';
          } catch (_) {}

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    'v2.0.0 • $envLabel',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
