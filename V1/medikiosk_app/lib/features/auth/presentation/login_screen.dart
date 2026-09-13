import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';
import '../../../../data/repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController(text: "9876543210");
  final _authRepo = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया 10 अंकों का मान्य फ़ोन नंबर दर्ज करें (Please enter 10-digit phone)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await _authRepo.sendOtp(phone);
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP +91 $phone पर भेजा गया है (Demo OTP: 1234)'),
        backgroundColor: AppColors.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.push('/otp?phone=$phone');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.loginTitle,
                style: AppTextStyles.headlineLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'पंजीकृत फ़ोन नंबर से तत्काल लॉगिन करें (Login with Phone)',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixText: '+91 ',
                  hintText: l10n.loginPhoneHint,
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                maxLength: 10,
              ),
              const SizedBox(height: 24),
              MkButton(
                text: l10n.loginSendOtp,
                isLoading: _isLoading,
                onPressed: _handleSendOtp,
              ),
              const SizedBox(height: 32),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('या (OR)', style: TextStyle(color: AppColors.onSurfaceVariantLight)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 32),
              MkButton(
                text: 'नया मरीज़? यहाँ पंजीकरण करें (Register Here) 📝',
                variant: MkButtonVariant.outline,
                onPressed: () {
                  context.push('/register');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
