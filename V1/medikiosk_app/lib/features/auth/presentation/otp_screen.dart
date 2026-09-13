import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mk_button.dart';
import '../../../core/widgets/mk_audio_button.dart';
import '../../../../data/repositories/auth_repository.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, this.phone = "+91 98765-43210"});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया 4 अंकों का OTP भरें (Please enter 4-digit OTP)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authRepo = AuthRepository();
    final cleanPhone = widget.phone.replaceAll('+91', '').replaceAll(' ', '').replaceAll('-', '').trim();
    final result = await authRepo.verifyOtp(cleanPhone, otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('सफलतापूर्वक सत्यापित! (Authentication Successful)'),
          backgroundColor: AppColors.successLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'गलत OTP दर्ज किया गया (Invalid OTP)'),
          backgroundColor: AppColors.emergencyLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    final onSurface = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: const [
          MkAudioButton(textToRead: "अपना 4 अंकों का वन-टाइम पासवर्ड दर्ज करें। डेमो OTP 1 2 3 4 है।"),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OTP सत्यापन\nOTP Verification',
                style: AppTextStyles.headlineLarge.copyWith(color: onSurface, height: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                'हम ने ${widget.phone} पर 4 अंकों का कोड भेजा है\n(We sent a 4-digit code to your phone)',
                style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariantLight),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚡ Demo OTP: 1234',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                ),
              ),
              const SizedBox(height: 36),

              // 4 OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 64,
                    height: 64,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: surfaceColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (index == 3 && value.isNotEmpty) {
                          _verifyOtp();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 28),

              // Resend Timer
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'पुनः कोड भेजें ($_secondsRemaining सेकंड)\nResend code in $_secondsRemaining s',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariantLight),
                      )
                    : TextButton(
                        onPressed: _startTimer,
                        child: const Text('OTP पुनः भेजें (Resend OTP)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ),

              const Spacer(),

              MkButton(
                text: 'सत्यापित करें (Verify & Enter)',
                isLoading: _isLoading,
                onPressed: _verifyOtp,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
