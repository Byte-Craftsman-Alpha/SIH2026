// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MediKiosk';

  @override
  String get appTagline => 'Aapki sehat, aapki zubani';

  @override
  String get navHome => 'Home';

  @override
  String get navChat => 'Chat';

  @override
  String get navDocs => 'Documents';

  @override
  String get navAppts => 'Appointments';

  @override
  String get navProfile => 'Profile';

  @override
  String get kioskWelcome => 'Welcome to MediKiosk';

  @override
  String get kioskNewPatient => 'New Patient';

  @override
  String get kioskReturningPatient => 'Returning Patient';

  @override
  String get kioskCallAttendant => 'Call Attendant';

  @override
  String get loginTitle => 'Login to your account';

  @override
  String get loginPhoneHint => 'Enter Phone Number';

  @override
  String get loginSendOtp => 'Send OTP';

  @override
  String get otpTitle => 'Verify OTP';

  @override
  String otpResend(String seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get regStepIdentity => 'Personal Info';

  @override
  String get regStepContact => 'Contact Info';

  @override
  String get regStepEmergency => 'Emergency';

  @override
  String get regStepConsent => 'Consent';

  @override
  String get regStepReview => 'Review';

  @override
  String get regName => 'Full Name';

  @override
  String get regDob => 'Date of Birth';

  @override
  String get regGender => 'Gender';

  @override
  String get regEmail => 'Email Address';

  @override
  String get regAbha => 'ABHA ID';

  @override
  String get regAadhaar => 'Aadhaar Number';

  @override
  String get btnNext => 'Next';

  @override
  String get btnBack => 'Back';

  @override
  String get btnSubmit => 'Submit';

  @override
  String get btnSave => 'Save';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnRetry => 'Retry';

  @override
  String get consentIUnderstand => 'Main samajh gaya (I understand)';

  @override
  String get prakritiIntroTitle => 'Ayurvedic Profile';

  @override
  String get prakritiIntroDesc =>
      'Answer a few questions to determine your Prakriti (Body Type).';

  @override
  String get prakritiStart => 'Start Assessment';

  @override
  String get prakritiResultTitle => 'Your Prakriti';

  @override
  String get chatModeGeneral => 'General Mode';

  @override
  String get chatModeAyush => 'AYUSH Mode';

  @override
  String get chatMicListening => 'Listening...';

  @override
  String get docHistoryTitle => 'Medical History';

  @override
  String get docUploadTitle => 'Upload Document';

  @override
  String get docUploadCamera => 'Take Photo';

  @override
  String get docUploadGallery => 'Choose from Gallery';

  @override
  String get docUploadPdf => 'Select PDF';

  @override
  String get apptHospitalsTitle => 'Select Hospital';

  @override
  String get apptDoctorsTitle => 'Select Doctor';

  @override
  String get apptBookingTitle => 'Book Appointment';

  @override
  String get emergencyTitle => 'Emergency Action';

  @override
  String get emergencyCall108 => 'Call 108';

  @override
  String get emergencyAlertFamily => 'Alert Family';

  @override
  String get emergencyNearestER => 'Nearest ER';

  @override
  String get profileTitle => 'Profile & Settings';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileAccessibility => 'Accessibility';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorRequired => 'This field is required.';

  @override
  String get loading => 'Loading...';
}
