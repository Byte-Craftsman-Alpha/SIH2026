// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'मेडीकियोस्क';

  @override
  String get appTagline => 'आपकी सेहत, आपकी ज़ुबानी';

  @override
  String get navHome => 'होम';

  @override
  String get navChat => 'चैट';

  @override
  String get navDocs => 'दस्तावेज़';

  @override
  String get navAppts => 'अपॉइंटमेंट';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get kioskWelcome => 'मेडीकियोस्क में आपका स्वागत है';

  @override
  String get kioskNewPatient => 'नया मरीज़';

  @override
  String get kioskReturningPatient => 'पुराना मरीज़';

  @override
  String get kioskCallAttendant => 'सहायक को बुलाएं';

  @override
  String get loginTitle => 'अपने खाते में लॉगिन करें';

  @override
  String get loginPhoneHint => 'फ़ोन नंबर दर्ज करें';

  @override
  String get loginSendOtp => 'OTP भेजें';

  @override
  String get otpTitle => 'OTP जांचें';

  @override
  String otpResend(String seconds) {
    return '$seconds सेकंड में फिर से भेजें';
  }

  @override
  String get regStepIdentity => 'व्यक्तिगत जानकारी';

  @override
  String get regStepContact => 'संपर्क जानकारी';

  @override
  String get regStepEmergency => 'आपातकालीन';

  @override
  String get regStepConsent => 'सहमति';

  @override
  String get regStepReview => 'समीक्षा';

  @override
  String get regName => 'पूरा नाम';

  @override
  String get regDob => 'जन्म तिथि';

  @override
  String get regGender => 'लिंग';

  @override
  String get regEmail => 'ईमेल पता';

  @override
  String get regAbha => 'आभा आईडी';

  @override
  String get regAadhaar => 'आधार नंबर';

  @override
  String get btnNext => 'आगे';

  @override
  String get btnBack => 'पीछे';

  @override
  String get btnSubmit => 'जमा करें';

  @override
  String get btnSave => 'सेव करें';

  @override
  String get btnCancel => 'रद्द करें';

  @override
  String get btnRetry => 'फिर कोशिश करें';

  @override
  String get consentIUnderstand => 'मैं समझ गया';

  @override
  String get prakritiIntroTitle => 'आयुर्वेदिक प्रोफ़ाइल';

  @override
  String get prakritiIntroDesc =>
      'अपनी प्रकृति (शरीर का प्रकार) जानने के लिए कुछ सवालों के जवाब दें।';

  @override
  String get prakritiStart => 'जांच शुरू करें';

  @override
  String get prakritiResultTitle => 'आपकी प्रकृति';

  @override
  String get chatModeGeneral => 'सामान्य मोड';

  @override
  String get chatModeAyush => 'आयुष मोड';

  @override
  String get chatMicListening => 'सुन रहा हूँ...';

  @override
  String get docHistoryTitle => 'मेडिकल इतिहास';

  @override
  String get docUploadTitle => 'दस्तावेज़ अपलोड करें';

  @override
  String get docUploadCamera => 'फ़ोटो लें';

  @override
  String get docUploadGallery => 'गैलरी से चुनें';

  @override
  String get docUploadPdf => 'PDF चुनें';

  @override
  String get apptHospitalsTitle => 'अस्पताल चुनें';

  @override
  String get apptDoctorsTitle => 'डॉक्टर चुनें';

  @override
  String get apptBookingTitle => 'अपॉइंटमेंट बुक करें';

  @override
  String get emergencyTitle => 'आपातकालीन स्थिति';

  @override
  String get emergencyCall108 => '108 पर कॉल करें';

  @override
  String get emergencyAlertFamily => 'परिवार को सूचित करें';

  @override
  String get emergencyNearestER => 'नज़दीकी अस्पताल';

  @override
  String get profileTitle => 'प्रोफ़ाइल और सेटिंग्स';

  @override
  String get profileLogout => 'लॉग आउट';

  @override
  String get profileAccessibility => 'पहुंच-योग्यता';

  @override
  String get errorGeneric => 'कुछ गलत हो गया। कृपया फिर से कोशिश करें।';

  @override
  String get errorNetwork => 'इंटरनेट कनेक्शन नहीं है।';

  @override
  String get errorRequired => 'यह जानकारी आवश्यक है।';

  @override
  String get loading => 'लोड हो रहा है...';
}
