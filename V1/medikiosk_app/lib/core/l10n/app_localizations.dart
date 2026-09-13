import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MediKiosk'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Aapki sehat, aapki zubani'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navDocs.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get navDocs;

  /// No description provided for @navAppts.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get navAppts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @kioskWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MediKiosk'**
  String get kioskWelcome;

  /// No description provided for @kioskNewPatient.
  ///
  /// In en, this message translates to:
  /// **'New Patient'**
  String get kioskNewPatient;

  /// No description provided for @kioskReturningPatient.
  ///
  /// In en, this message translates to:
  /// **'Returning Patient'**
  String get kioskReturningPatient;

  /// No description provided for @kioskCallAttendant.
  ///
  /// In en, this message translates to:
  /// **'Call Attendant'**
  String get kioskCallAttendant;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginTitle;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get loginPhoneHint;

  /// No description provided for @loginSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get loginSendOtp;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpTitle;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String otpResend(String seconds);

  /// No description provided for @regStepIdentity.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get regStepIdentity;

  /// No description provided for @regStepContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get regStepContact;

  /// No description provided for @regStepEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get regStepEmergency;

  /// No description provided for @regStepConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get regStepConsent;

  /// No description provided for @regStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get regStepReview;

  /// No description provided for @regName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get regName;

  /// No description provided for @regDob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get regDob;

  /// No description provided for @regGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get regGender;

  /// No description provided for @regEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get regEmail;

  /// No description provided for @regAbha.
  ///
  /// In en, this message translates to:
  /// **'ABHA ID'**
  String get regAbha;

  /// No description provided for @regAadhaar.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Number'**
  String get regAadhaar;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get btnBack;

  /// No description provided for @btnSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get btnSubmit;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btnRetry;

  /// No description provided for @consentIUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Main samajh gaya (I understand)'**
  String get consentIUnderstand;

  /// No description provided for @prakritiIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Ayurvedic Profile'**
  String get prakritiIntroTitle;

  /// No description provided for @prakritiIntroDesc.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions to determine your Prakriti (Body Type).'**
  String get prakritiIntroDesc;

  /// No description provided for @prakritiStart.
  ///
  /// In en, this message translates to:
  /// **'Start Assessment'**
  String get prakritiStart;

  /// No description provided for @prakritiResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Prakriti'**
  String get prakritiResultTitle;

  /// No description provided for @chatModeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Mode'**
  String get chatModeGeneral;

  /// No description provided for @chatModeAyush.
  ///
  /// In en, this message translates to:
  /// **'AYUSH Mode'**
  String get chatModeAyush;

  /// No description provided for @chatMicListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get chatMicListening;

  /// No description provided for @docHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get docHistoryTitle;

  /// No description provided for @docUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get docUploadTitle;

  /// No description provided for @docUploadCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get docUploadCamera;

  /// No description provided for @docUploadGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get docUploadGallery;

  /// No description provided for @docUploadPdf.
  ///
  /// In en, this message translates to:
  /// **'Select PDF'**
  String get docUploadPdf;

  /// No description provided for @apptHospitalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Hospital'**
  String get apptHospitalsTitle;

  /// No description provided for @apptDoctorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Doctor'**
  String get apptDoctorsTitle;

  /// No description provided for @apptBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get apptBookingTitle;

  /// No description provided for @emergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Action'**
  String get emergencyTitle;

  /// No description provided for @emergencyCall108.
  ///
  /// In en, this message translates to:
  /// **'Call 108'**
  String get emergencyCall108;

  /// No description provided for @emergencyAlertFamily.
  ///
  /// In en, this message translates to:
  /// **'Alert Family'**
  String get emergencyAlertFamily;

  /// No description provided for @emergencyNearestER.
  ///
  /// In en, this message translates to:
  /// **'Nearest ER'**
  String get emergencyNearestER;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileTitle;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get profileAccessibility;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get errorRequired;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
