import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/mk_button.dart';
import '../../../../core/widgets/mk_step_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/auth_repository.dart';
import 'step_identity.dart';
import 'step_contact.dart';
import 'step_emergency.dart';
import 'step_consent.dart';
import 'step_review.dart';

class RegistrationWizard extends ConsumerStatefulWidget {
  const RegistrationWizard({super.key});

  @override
  ConsumerState<RegistrationWizard> createState() => _RegistrationWizardState();
}

class _RegistrationWizardState extends ConsumerState<RegistrationWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form State
  final TextEditingController _nameController = TextEditingController(text: "Ramesh Kumar");
  DateTime? _selectedDob = DateTime(1962, 4, 11);
  String _selectedGender = "male";

  final TextEditingController _phoneController = TextEditingController(text: "9876543210");
  final TextEditingController _emailController = TextEditingController(text: "ramesh.kumar@example.com");
  final TextEditingController _abhaController = TextEditingController(text: "91-1234-5678-9012");

  final TextEditingController _contact1NameController = TextEditingController(text: "Sita Devi");
  final TextEditingController _contact1PhoneController = TextEditingController(text: "9876543299");
  final TextEditingController _contact1RelationController = TextEditingController(text: "Wife (पत्नी)");
  final TextEditingController _contact2NameController = TextEditingController(text: "Dr. Mehta");
  final TextEditingController _contact2PhoneController = TextEditingController(text: "9876543288");
  bool _preConsentEnabled = true;

  bool _dataCaptureConsent = true;
  bool _docDigitizeConsent = true;
  bool _analyticsConsent = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _abhaController.dispose();
    _contact1NameController.dispose();
    _contact1PhoneController.dispose();
    _contact1RelationController.dispose();
    _contact2NameController.dispose();
    _contact2PhoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _submitRegistration() async {
    setState(() => _isSubmitting = true);

    final authRepo = AuthRepository();
    final dobIso = _selectedDob != null
        ? "${_selectedDob!.year.toString().padLeft(4, '0')}-${_selectedDob!.month.toString().padLeft(2, '0')}-${_selectedDob!.day.toString().padLeft(2, '0')}"
        : "1990-01-01";

    final emergencyContacts = [
      if (_contact1NameController.text.isNotEmpty)
        {
          'name': _contact1NameController.text,
          'phone': _contact1PhoneController.text,
          'relation': _contact1RelationController.text,
          'consent_flag': _preConsentEnabled,
        },
      if (_contact2NameController.text.isNotEmpty)
        {
          'name': _contact2NameController.text,
          'phone': _contact2PhoneController.text,
          'relation': 'Physician',
          'consent_flag': true,
        },
    ];

    final consent = {
      'data_capture': _dataCaptureConsent,
      'document_digitize': _docDigitizeConsent,
      'analytics': _analyticsConsent,
      'audio_guidance': true,
    };

    final result = await authRepo.register(
      name: _nameController.text.trim(),
      dob: dobIso,
      gender: _selectedGender,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      abhaId: _abhaController.text.trim(),
      emergencyContacts: emergencyContacts,
      consent: consent,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'पंजीकरण सफल! (Registration Successful)'),
          backgroundColor: AppColors.successLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'पंजीकरण विफल (Registration Failed)'),
          backgroundColor: AppColors.emergencyLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
        title: Text('नया मरीज पंजीकरण (Step ${_currentStep + 1} of 5)'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              MkStepIndicator(currentStep: _currentStep, totalSteps: 5),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentStep = i),
                  children: [
                    StepIdentity(
                      nameController: _nameController,
                      selectedDob: _selectedDob,
                      selectedGender: _selectedGender,
                      onDobChanged: (d) => setState(() => _selectedDob = d),
                      onGenderChanged: (g) => setState(() => _selectedGender = g),
                    ),
                    StepContact(
                      phoneController: _phoneController,
                      emailController: _emailController,
                      abhaController: _abhaController,
                    ),
                    StepEmergency(
                      contact1NameController: _contact1NameController,
                      contact1PhoneController: _contact1PhoneController,
                      contact1RelationController: _contact1RelationController,
                      contact2NameController: _contact2NameController,
                      contact2PhoneController: _contact2PhoneController,
                      preConsentEnabled: _preConsentEnabled,
                      onPreConsentChanged: (v) => setState(() => _preConsentEnabled = v),
                    ),
                    StepConsent(
                      dataCaptureConsent: _dataCaptureConsent,
                      docDigitizeConsent: _docDigitizeConsent,
                      analyticsConsent: _analyticsConsent,
                      onDataCaptureChanged: (v) => setState(() => _dataCaptureConsent = v),
                      onDocDigitizeChanged: (v) => setState(() => _docDigitizeConsent = v),
                      onAnalyticsChanged: (v) => setState(() => _analyticsConsent = v),
                    ),
                    StepReview(
                      name: _nameController.text,
                      gender: _selectedGender,
                      dob: _selectedDob,
                      phone: _phoneController.text,
                      email: _emailController.text,
                      abha: _abhaController.text,
                      contact1Name: _contact1NameController.text,
                      contact1Phone: _contact1PhoneController.text,
                      onEditStep: (step) => _pageController.jumpToPage(step),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: MkButton(
                        text: 'पीछे (Back)',
                        variant: MkButtonVariant.outline,
                        onPressed: _previousStep,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: MkButton(
                      text: _currentStep == 4 ? 'पूर्ण करें (Confirm & Submit)' : 'आगे बढ़ें (Next Step) →',
                      isLoading: _isSubmitting,
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
