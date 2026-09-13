import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_decorations.dart';

class KioskWelcomeScreen extends ConsumerWidget {
  const KioskWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent),
                  label: Text(l10n.kioskCallAttendant),
                ),
              ),
              const Spacer(),
              Text(
                l10n.kioskWelcome,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 64),
              Row(
                children: [
                  Expanded(
                    child: _buildBigButton(
                      context,
                      l10n.kioskNewPatient,
                      Icons.person_add_alt_1,
                      () => context.go('/register'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildBigButton(
                      context,
                      l10n.kioskReturningPatient,
                      Icons.fingerprint,
                      () => context.go('/login'),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 200,
        decoration: AppDecorations.softCard(context).copyWith(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
