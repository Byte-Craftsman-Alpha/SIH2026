import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/theme_providers.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_colors.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.language, size: 80, color: AppColors.accentLight),
              const SizedBox(height: 32),
              Text(
                'Choose your language\nअपनी भाषा चुनें',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 48),
              _buildLangCard(context, ref, 'English', 'en'),
              const SizedBox(height: 16),
              _buildLangCard(context, ref, 'हिंदी (Hindi)', 'hi'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangCard(BuildContext context, WidgetRef ref, String title, String code) {
    return InkWell(
      onTap: () async {
        final storage = ref.read(storageServiceProvider);
        await storage.setString('app_language', code);
        ref.read(localeProvider.notifier).state = Locale(code);
        
        if (context.mounted) {
          context.go('/kiosk');
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: AppDecorations.softCard(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
