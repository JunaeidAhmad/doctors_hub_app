import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Doctors Hub'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnostics;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @hospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get hospitals;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Book doctors and lab tests across Bangladesh'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No account required. Instant confirmation via SMS.'**
  String get heroSubtitle;

  /// No description provided for @searchTabDoctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get searchTabDoctors;

  /// No description provided for @searchTabDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get searchTabDiagnostics;

  /// No description provided for @searchTabHospitals.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get searchTabHospitals;

  /// No description provided for @allSpecialties.
  ///
  /// In en, this message translates to:
  /// **'All Specialties'**
  String get allSpecialties;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @allBangladesh.
  ///
  /// In en, this message translates to:
  /// **'All Bangladesh'**
  String get allBangladesh;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @specialtiesSection.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialtiesSection;

  /// No description provided for @popularDoctorsSection.
  ///
  /// In en, this message translates to:
  /// **'Popular Doctors'**
  String get popularDoctorsSection;

  /// No description provided for @diagnosticTestsSection.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Tests'**
  String get diagnosticTestsSection;

  /// No description provided for @hospitalsSection.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get hospitalsSection;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all →'**
  String get seeAll;

  /// No description provided for @doctorsCountKicker.
  ///
  /// In en, this message translates to:
  /// **'{count} DOCTORS · {specialty}'**
  String doctorsCountKicker(int count, String specialty);

  /// No description provided for @searchDoctorsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search doctor name, hospital, specialty...'**
  String get searchDoctorsPlaceholder;

  /// No description provided for @filterDivision.
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get filterDivision;

  /// No description provided for @filterHospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get filterHospital;

  /// No description provided for @filterSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get filterSpecialty;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearAllFilters;

  /// No description provided for @noDoctorsFound.
  ///
  /// In en, this message translates to:
  /// **'No doctors found'**
  String get noDoctorsFound;

  /// No description provided for @noDoctorsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search query or filters.'**
  String get noDoctorsFoundDesc;

  /// No description provided for @experienceYears.
  ///
  /// In en, this message translates to:
  /// **'{years} years exp'**
  String experienceYears(String years);

  /// No description provided for @ratingReviews.
  ///
  /// In en, this message translates to:
  /// **'{rating} ({count})'**
  String ratingReviews(String rating, int count);

  /// No description provided for @chambersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chambers'**
  String chambersCount(int count);

  /// No description provided for @fromFee.
  ///
  /// In en, this message translates to:
  /// **'from ৳{fee}'**
  String fromFee(String fee);

  /// No description provided for @moreChambers.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more chambers'**
  String moreChambers(int count);

  /// No description provided for @doctorAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get doctorAbout;

  /// No description provided for @doctorChambers.
  ///
  /// In en, this message translates to:
  /// **'Chambers & Schedule'**
  String get doctorChambers;

  /// No description provided for @visitFeeFrom.
  ///
  /// In en, this message translates to:
  /// **'Visit fee from ৳{fee}'**
  String visitFeeFrom(String fee);

  /// No description provided for @bookAVisit.
  ///
  /// In en, this message translates to:
  /// **'Book a visit'**
  String get bookAVisit;

  /// No description provided for @step1Kicker.
  ///
  /// In en, this message translates to:
  /// **'STEP 1 OF 2'**
  String get step1Kicker;

  /// No description provided for @whereAndWhen.
  ///
  /// In en, this message translates to:
  /// **'Where and when?'**
  String get whereAndWhen;

  /// No description provided for @selectChamber.
  ///
  /// In en, this message translates to:
  /// **'Select chamber'**
  String get selectChamber;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectSlot.
  ///
  /// In en, this message translates to:
  /// **'Select appointment time'**
  String get selectSlot;

  /// No description provided for @notAtChamberToday.
  ///
  /// In en, this message translates to:
  /// **'Not at this chamber that day'**
  String get notAtChamberToday;

  /// No description provided for @noSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No slots available for this day'**
  String get noSlotsAvailable;

  /// No description provided for @morningShift.
  ///
  /// In en, this message translates to:
  /// **'Morning Shift'**
  String get morningShift;

  /// No description provided for @eveningShift.
  ///
  /// In en, this message translates to:
  /// **'Evening Shift'**
  String get eveningShift;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @step2Kicker.
  ///
  /// In en, this message translates to:
  /// **'STEP 2 OF 2'**
  String get step2Kicker;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get almostThere;

  /// No description provided for @doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctorLabel;

  /// No description provided for @whenLabel.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get whenLabel;

  /// No description provided for @whereLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get whereLabel;

  /// No description provided for @feeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get feeLabel;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientName;

  /// No description provided for @patientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter patient\'s full name'**
  String get patientNameHint;

  /// No description provided for @patientPhone.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get patientPhone;

  /// No description provided for @patientPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get patientPhoneHint;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 11-digit Bangladesh mobile number'**
  String get invalidPhone;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Patient name is required'**
  String get nameRequired;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @payAtCounter.
  ///
  /// In en, this message translates to:
  /// **'Pay at counter'**
  String get payAtCounter;

  /// No description provided for @payAtCounterDesc.
  ///
  /// In en, this message translates to:
  /// **'Pay the consultation fee when you visit the clinic'**
  String get payAtCounterDesc;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now with bKash / Nagad / Card'**
  String get payNow;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm booking'**
  String get confirmBooking;

  /// No description provided for @payWithBkash.
  ///
  /// In en, this message translates to:
  /// **'Pay ৳{fee} with bKash'**
  String payWithBkash(String fee);

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit verification code to {phone}'**
  String otpSubtitle(String phone);

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @verifyAndConfirm.
  ///
  /// In en, this message translates to:
  /// **'Verify & Confirm'**
  String get verifyAndConfirm;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendOtp;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @bookedSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re booked!'**
  String get bookedSuccessTitle;

  /// No description provided for @bookingRef.
  ///
  /// In en, this message translates to:
  /// **'Booking Ref'**
  String get bookingRef;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// No description provided for @forPatient.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get forPatient;

  /// No description provided for @bookedAt.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get bookedAt;

  /// No description provided for @bookedWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get bookedWhen;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentStatus;

  /// No description provided for @successNote.
  ///
  /// In en, this message translates to:
  /// **'Please arrive 15 minutes before your scheduled appointment. We\'ve sent details via SMS.'**
  String get successNote;

  /// No description provided for @seeMyBookings.
  ///
  /// In en, this message translates to:
  /// **'See my bookings'**
  String get seeMyBookings;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @diagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics & Lab Tests'**
  String get diagnosticsTitle;

  /// No description provided for @searchDiagnosticsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search test name (e.g. CBC, Lipid Profile)...'**
  String get searchDiagnosticsPlaceholder;

  /// No description provided for @reportTimeHours.
  ///
  /// In en, this message translates to:
  /// **'Report in {hours}h'**
  String reportTimeHours(int hours);

  /// No description provided for @fastingRequired.
  ///
  /// In en, this message translates to:
  /// **'Fasting required (8–12 hrs)'**
  String get fastingRequired;

  /// No description provided for @noFastingRequired.
  ///
  /// In en, this message translates to:
  /// **'No fasting required'**
  String get noFastingRequired;

  /// No description provided for @usualPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Usual price: ৳{min} – ৳{max}'**
  String usualPriceRange(String min, String max);

  /// No description provided for @homePickup.
  ///
  /// In en, this message translates to:
  /// **'Home pickup'**
  String get homePickup;

  /// No description provided for @atLabOnly.
  ///
  /// In en, this message translates to:
  /// **'At lab only'**
  String get atLabOnly;

  /// No description provided for @moreLabs.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more labs offering this test'**
  String moreLabs(int count);

  /// No description provided for @bookTest.
  ///
  /// In en, this message translates to:
  /// **'Book test'**
  String get bookTest;

  /// No description provided for @sampleCollection.
  ///
  /// In en, this message translates to:
  /// **'Sample Collection'**
  String get sampleCollection;

  /// No description provided for @visitLabOption.
  ///
  /// In en, this message translates to:
  /// **'Visit lab'**
  String get visitLabOption;

  /// No description provided for @homePickupOption.
  ///
  /// In en, this message translates to:
  /// **'Home pickup (+৳{charge})'**
  String homePickupOption(String charge);

  /// No description provided for @pickupAddress.
  ///
  /// In en, this message translates to:
  /// **'Home Pickup Address'**
  String get pickupAddress;

  /// No description provided for @pickupAddressHint.
  ///
  /// In en, this message translates to:
  /// **'House, Road, Area, Landmark...'**
  String get pickupAddressHint;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Pickup address is required for home collection'**
  String get addressRequired;

  /// No description provided for @timeWindow.
  ///
  /// In en, this message translates to:
  /// **'Preferred Time Window'**
  String get timeWindow;

  /// No description provided for @hospitalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hospitals & Diagnostic Centers'**
  String get hospitalsTitle;

  /// No description provided for @searchHospitalsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search hospital name or area...'**
  String get searchHospitalsPlaceholder;

  /// No description provided for @myBookingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Bookings'**
  String get myBookingsTitle;

  /// No description provided for @upcomingBookingsKicker.
  ///
  /// In en, this message translates to:
  /// **'{count} UPCOMING'**
  String upcomingBookingsKicker(int count);

  /// No description provided for @savedOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Saved on this phone'**
  String get savedOnPhone;

  /// No description provided for @doctorVisitTag.
  ///
  /// In en, this message translates to:
  /// **'DOCTOR VISIT'**
  String get doctorVisitTag;

  /// No description provided for @labTestTag.
  ///
  /// In en, this message translates to:
  /// **'LAB TEST'**
  String get labTestTag;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBooking;

  /// No description provided for @cancelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelDialogTitle;

  /// No description provided for @cancelDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'To cancel your appointment with the chamber, please call the facility directly at {phone}.'**
  String cancelDialogMessage(String phone);

  /// No description provided for @removeBooking.
  ///
  /// In en, this message translates to:
  /// **'Remove from phone'**
  String get removeBooking;

  /// No description provided for @callChamber.
  ///
  /// In en, this message translates to:
  /// **'Call Chamber'**
  String get callChamber;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get noBookings;

  /// No description provided for @noBookingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your booked doctor visits and lab tests will be saved here.'**
  String get noBookingsDesc;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Please check your internet connection.'**
  String get networkError;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get bangla;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
