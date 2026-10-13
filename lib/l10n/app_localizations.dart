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

  /// No description provided for @selectSpecialty.
  ///
  /// In en, this message translates to:
  /// **'Select Specialty'**
  String get selectSpecialty;

  /// No description provided for @searchSpecialtyHint.
  ///
  /// In en, this message translates to:
  /// **'Search specialty...'**
  String get searchSpecialtyHint;

  /// No description provided for @noSpecialtiesFound.
  ///
  /// In en, this message translates to:
  /// **'No specialties found'**
  String get noSpecialtiesFound;

  /// No description provided for @otherSpecialties.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherSpecialties;

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

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @hideFilters.
  ///
  /// In en, this message translates to:
  /// **'Hide Filters'**
  String get hideFilters;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// No description provided for @selectFacility.
  ///
  /// In en, this message translates to:
  /// **'Select Hospital & Diagnostic Center'**
  String get selectFacility;

  /// No description provided for @allFacilities.
  ///
  /// In en, this message translates to:
  /// **'All Hospitals & Diagnostics'**
  String get allFacilities;

  /// No description provided for @filterLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filterLocation;

  /// No description provided for @filterDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get filterDistrict;

  /// No description provided for @filterThanaArea.
  ///
  /// In en, this message translates to:
  /// **'Thana / Area'**
  String get filterThanaArea;

  /// No description provided for @allDistricts.
  ///
  /// In en, this message translates to:
  /// **'All Districts'**
  String get allDistricts;

  /// No description provided for @allAreas.
  ///
  /// In en, this message translates to:
  /// **'All Areas'**
  String get allAreas;

  /// No description provided for @clearLocation.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearLocation;

  /// No description provided for @visitingDays.
  ///
  /// In en, this message translates to:
  /// **'Visiting Days'**
  String get visitingDays;

  /// No description provided for @allDays.
  ///
  /// In en, this message translates to:
  /// **'All Days'**
  String get allDays;

  /// No description provided for @doctorGender.
  ///
  /// In en, this message translates to:
  /// **'Doctor Gender'**
  String get doctorGender;

  /// No description provided for @allGenders.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allGenders;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @fulfillment.
  ///
  /// In en, this message translates to:
  /// **'Fulfillment'**
  String get fulfillment;

  /// No description provided for @allFulfillments.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFulfillments;

  /// No description provided for @homeSamplePickup.
  ///
  /// In en, this message translates to:
  /// **'Home Sample Pickup'**
  String get homeSamplePickup;

  /// No description provided for @centerVisitOnly.
  ///
  /// In en, this message translates to:
  /// **'Center Visit Only'**
  String get centerVisitOnly;

  /// No description provided for @ownershipType.
  ///
  /// In en, this message translates to:
  /// **'Ownership Type'**
  String get ownershipType;

  /// No description provided for @anyOwnership.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyOwnership;

  /// No description provided for @privateOwnership.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateOwnership;

  /// No description provided for @govtOwnership.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get govtOwnership;

  /// No description provided for @hospitalAffiliatedOwnership.
  ///
  /// In en, this message translates to:
  /// **'Hospital Affiliated'**
  String get hospitalAffiliatedOwnership;

  /// No description provided for @ngoOwnership.
  ///
  /// In en, this message translates to:
  /// **'NGO'**
  String get ngoOwnership;

  /// No description provided for @allFacilityCategories.
  ///
  /// In en, this message translates to:
  /// **'All Facility Categories'**
  String get allFacilityCategories;

  /// No description provided for @allTestCategories.
  ///
  /// In en, this message translates to:
  /// **'All Test Categories'**
  String get allTestCategories;

  /// No description provided for @activeFilters.
  ///
  /// In en, this message translates to:
  /// **'Active Filters:'**
  String get activeFilters;

  /// No description provided for @applyFiltersWithCount.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters ({count})'**
  String applyFiltersWithCount(int count);

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

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

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get otpInvalid;

  /// No description provided for @otpTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a minute.'**
  String get otpTooManyAttempts;

  /// No description provided for @badgeInstantBooking.
  ///
  /// In en, this message translates to:
  /// **'Instant booking'**
  String get badgeInstantBooking;

  /// No description provided for @badgeBookingByRequest.
  ///
  /// In en, this message translates to:
  /// **'Booking by request'**
  String get badgeBookingByRequest;

  /// No description provided for @badgeBookByPhone.
  ///
  /// In en, this message translates to:
  /// **'Book by phone'**
  String get badgeBookByPhone;

  /// No description provided for @ctaBookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book appointment'**
  String get ctaBookAppointment;

  /// No description provided for @ctaRequestAppointment.
  ///
  /// In en, this message translates to:
  /// **'Request appointment'**
  String get ctaRequestAppointment;

  /// No description provided for @ctaGetPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Get phone number'**
  String get ctaGetPhoneNumber;

  /// No description provided for @ctaSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get ctaSendRequest;

  /// No description provided for @selectSession.
  ///
  /// In en, this message translates to:
  /// **'Select session'**
  String get selectSession;

  /// No description provided for @selectASession.
  ///
  /// In en, this message translates to:
  /// **'Select a session'**
  String get selectASession;

  /// No description provided for @noSessionsForDay.
  ///
  /// In en, this message translates to:
  /// **'No sessions available for this day'**
  String get noSessionsForDay;

  /// No description provided for @noChambers.
  ///
  /// In en, this message translates to:
  /// **'No chambers listed'**
  String get noChambers;

  /// No description provided for @noChambersDesc.
  ///
  /// In en, this message translates to:
  /// **'This doctor has no chambers listed yet.'**
  String get noChambersDesc;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @sessionFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get sessionFull;

  /// No description provided for @sessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get sessionEnded;

  /// No description provided for @sessionClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get sessionClosed;

  /// No description provided for @sessionSeatsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String sessionSeatsLeft(int count);

  /// No description provided for @nextSerialNumber.
  ///
  /// In en, this message translates to:
  /// **'Next serial #{number}'**
  String nextSerialNumber(int number);

  /// No description provided for @approxTime.
  ///
  /// In en, this message translates to:
  /// **'approx. {time}'**
  String approxTime(String time);

  /// No description provided for @tooLateToRequest.
  ///
  /// In en, this message translates to:
  /// **'Too late to request — call the chamber'**
  String get tooLateToRequest;

  /// No description provided for @morningSession.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morningSession;

  /// No description provided for @eveningSession.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get eveningSession;

  /// No description provided for @requestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSentTitle;

  /// No description provided for @requestWillCall.
  ///
  /// In en, this message translates to:
  /// **'{facility} will call you at {phone} to confirm. You\'ll also get an SMS.'**
  String requestWillCall(String facility, String phone);

  /// No description provided for @expectCallBy.
  ///
  /// In en, this message translates to:
  /// **'Expect a call by {deadline}'**
  String expectCallBy(String deadline);

  /// No description provided for @beforeSessionStarts.
  ///
  /// In en, this message translates to:
  /// **'before the session starts'**
  String get beforeSessionStarts;

  /// No description provided for @confirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re booked'**
  String get confirmedTitle;

  /// No description provided for @serialBySms.
  ///
  /// In en, this message translates to:
  /// **'Your serial will come by SMS'**
  String get serialBySms;

  /// No description provided for @bookingIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get bookingIdLabel;

  /// No description provided for @bookingNotFound.
  ///
  /// In en, this message translates to:
  /// **'This booking isn\'t loaded'**
  String get bookingNotFound;

  /// No description provided for @bookingNotLoadedDesc.
  ///
  /// In en, this message translates to:
  /// **'Open the booking again from the doctor\'s profile.'**
  String get bookingNotLoadedDesc;

  /// No description provided for @backToDoctors.
  ///
  /// In en, this message translates to:
  /// **'Back to doctors'**
  String get backToDoctors;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @patientAge.
  ///
  /// In en, this message translates to:
  /// **'Age (optional)'**
  String get patientAge;

  /// No description provided for @patientAgeHint.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get patientAgeHint;

  /// No description provided for @patientGender.
  ///
  /// In en, this message translates to:
  /// **'Gender (optional)'**
  String get patientGender;

  /// No description provided for @sendRequestNote.
  ///
  /// In en, this message translates to:
  /// **'The chamber will call {phone} to confirm'**
  String sendRequestNote(String phone);

  /// No description provided for @nextAvailableShort.
  ///
  /// In en, this message translates to:
  /// **'Next: {day} {time} · {count} left'**
  String nextAvailableShort(String day, String time, int count);

  /// No description provided for @callToBook.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callToBook;

  /// No description provided for @callDuringHours.
  ///
  /// In en, this message translates to:
  /// **'Call during these hours'**
  String get callDuringHours;

  /// No description provided for @weeklyHours.
  ///
  /// In en, this message translates to:
  /// **'Weekly hours'**
  String get weeklyHours;

  /// No description provided for @labWillContact.
  ///
  /// In en, this message translates to:
  /// **'Booking received — the lab will contact you to confirm'**
  String get labWillContact;

  /// No description provided for @serviceNotOffered.
  ///
  /// In en, this message translates to:
  /// **'This hospital doesn\'t offer this service'**
  String get serviceNotOffered;

  /// No description provided for @preferredTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred time'**
  String get preferredTimeLabel;

  /// No description provided for @prefTimeMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning (9 am–12 pm)'**
  String get prefTimeMorning;

  /// No description provided for @prefTimeAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon (12–4 pm)'**
  String get prefTimeAfternoon;

  /// No description provided for @prefTimeEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening (4–8 pm)'**
  String get prefTimeEvening;

  /// No description provided for @prefTimeAny.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get prefTimeAny;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesLabel;

  /// No description provided for @serviceRequestReceived.
  ///
  /// In en, this message translates to:
  /// **'Request received — {facility} will contact you to confirm'**
  String serviceRequestReceived(String facility);

  /// No description provided for @sessionWindow.
  ///
  /// In en, this message translates to:
  /// **'{start}–{end}'**
  String sessionWindow(String start, String end);

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

  /// No description provided for @pickupThana.
  ///
  /// In en, this message translates to:
  /// **'Pickup thana'**
  String get pickupThana;

  /// No description provided for @selectThana.
  ///
  /// In en, this message translates to:
  /// **'Select thana'**
  String get selectThana;

  /// No description provided for @pickupThanaRequired.
  ///
  /// In en, this message translates to:
  /// **'Pickup thana is required'**
  String get pickupThanaRequired;

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

  /// No description provided for @hospitalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Hospital not found'**
  String get hospitalNotFound;

  /// No description provided for @hospitalNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed. Go back and try another hospital.'**
  String get hospitalNotFoundDesc;

  /// No description provided for @doctorsHere.
  ///
  /// In en, this message translates to:
  /// **'Doctors here ({count})'**
  String doctorsHere(int count);

  /// No description provided for @testsHere.
  ///
  /// In en, this message translates to:
  /// **'Tests here ({count})'**
  String testsHere(int count);

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @emergencyPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyPhoneLabel;

  /// No description provided for @ambulancePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulancePhoneLabel;

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

  /// No description provided for @hospitalServiceTag.
  ///
  /// In en, this message translates to:
  /// **'HOSPITAL SERVICE'**
  String get hospitalServiceTag;

  /// No description provided for @statusConfirmedTag.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get statusConfirmedTag;

  /// No description provided for @awaitingConfirmationTag.
  ///
  /// In en, this message translates to:
  /// **'Awaiting confirmation'**
  String get awaitingConfirmationTag;

  /// No description provided for @awaitingLabTag.
  ///
  /// In en, this message translates to:
  /// **'Awaiting lab'**
  String get awaitingLabTag;

  /// No description provided for @awaitingHospitalTag.
  ///
  /// In en, this message translates to:
  /// **'Awaiting hospital'**
  String get awaitingHospitalTag;

  /// No description provided for @notConfirmedInTime.
  ///
  /// In en, this message translates to:
  /// **'Not confirmed in time. If you didn\'t get an SMS, call the chamber.'**
  String get notConfirmedInTime;

  /// No description provided for @toCancelCall.
  ///
  /// In en, this message translates to:
  /// **'To cancel, call {facility}'**
  String toCancelCall(String facility);

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

  /// No description provided for @updateRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequiredTitle;

  /// No description provided for @updateRequiredFallback.
  ///
  /// In en, this message translates to:
  /// **'Please update the app to continue.'**
  String get updateRequiredFallback;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version of the app is available.'**
  String get updateAvailableMessage;

  /// No description provided for @updateSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'This version will stop working soon. Please update.'**
  String get updateSoonMessage;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @errBookingModeCallOnly.
  ///
  /// In en, this message translates to:
  /// **'This chamber takes bookings by phone only. Please call the chamber.'**
  String get errBookingModeCallOnly;

  /// No description provided for @errRequestTooLate.
  ///
  /// In en, this message translates to:
  /// **'Too late to request this session. Please call the chamber.'**
  String get errRequestTooLate;

  /// No description provided for @errNotCallMode.
  ///
  /// In en, this message translates to:
  /// **'This chamber no longer takes phone bookings.'**
  String get errNotCallMode;

  /// No description provided for @errNoNumbers.
  ///
  /// In en, this message translates to:
  /// **'This chamber has no phone number listed yet. Please try another chamber.'**
  String get errNoNumbers;

  /// No description provided for @usualPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Usual price: {price}'**
  String usualPriceLabel(String price);

  /// No description provided for @priceAtCounter.
  ///
  /// In en, this message translates to:
  /// **'Price at counter'**
  String get priceAtCounter;

  /// No description provided for @priceConfirmedAtLab.
  ///
  /// In en, this message translates to:
  /// **'Price confirmed at the lab'**
  String get priceConfirmedAtLab;

  /// No description provided for @currentlyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Currently unavailable'**
  String get currentlyUnavailable;

  /// No description provided for @testNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'This test isn\'t loaded'**
  String get testNotLoaded;

  /// No description provided for @testNotLoadedDesc.
  ///
  /// In en, this message translates to:
  /// **'Open it again from the tests list.'**
  String get testNotLoadedDesc;

  /// No description provided for @backToTests.
  ///
  /// In en, this message translates to:
  /// **'Back to tests'**
  String get backToTests;
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
