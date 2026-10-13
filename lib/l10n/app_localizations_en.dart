// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Doctors Hub';

  @override
  String get home => 'Home';

  @override
  String get doctors => 'Doctors';

  @override
  String get diagnostics => 'Diagnostics';

  @override
  String get bookings => 'Bookings';

  @override
  String get hospitals => 'Hospitals';

  @override
  String get heroTitle => 'Book doctors and lab tests across Bangladesh';

  @override
  String get heroSubtitle =>
      'No account required. Instant confirmation via SMS.';

  @override
  String get searchTabDoctors => 'Doctors';

  @override
  String get searchTabDiagnostics => 'Diagnostics';

  @override
  String get searchTabHospitals => 'Hospitals';

  @override
  String get allSpecialties => 'All Specialties';

  @override
  String get selectSpecialty => 'Select Specialty';

  @override
  String get searchSpecialtyHint => 'Search specialty...';

  @override
  String get noSpecialtiesFound => 'No specialties found';

  @override
  String get otherSpecialties => 'Other';

  @override
  String get allCategories => 'All Categories';

  @override
  String get allBangladesh => 'All Bangladesh';

  @override
  String get searchButton => 'Search';

  @override
  String get specialtiesSection => 'Specialties';

  @override
  String get popularDoctorsSection => 'Popular Doctors';

  @override
  String get diagnosticTestsSection => 'Diagnostic Tests';

  @override
  String get hospitalsSection => 'Hospitals';

  @override
  String get seeAll => 'See all →';

  @override
  String doctorsCountKicker(int count, String specialty) {
    return '$count DOCTORS · $specialty';
  }

  @override
  String get searchDoctorsPlaceholder =>
      'Search doctor name, hospital, specialty...';

  @override
  String get filterDivision => 'Division';

  @override
  String get filterHospital => 'Hospital';

  @override
  String get filterSpecialty => 'Specialty';

  @override
  String get filters => 'Filters';

  @override
  String get hideFilters => 'Hide Filters';

  @override
  String get filterOptions => 'Filter Options';

  @override
  String get selectFacility => 'Select Hospital & Diagnostic Center';

  @override
  String get allFacilities => 'All Hospitals & Diagnostics';

  @override
  String get filterLocation => 'Location';

  @override
  String get filterDistrict => 'District';

  @override
  String get filterThanaArea => 'Thana / Area';

  @override
  String get allDistricts => 'All Districts';

  @override
  String get allAreas => 'All Areas';

  @override
  String get clearLocation => 'Clear';

  @override
  String get visitingDays => 'Visiting Days';

  @override
  String get allDays => 'All Days';

  @override
  String get doctorGender => 'Doctor Gender';

  @override
  String get allGenders => 'All';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get fulfillment => 'Fulfillment';

  @override
  String get allFulfillments => 'All';

  @override
  String get homeSamplePickup => 'Home Sample Pickup';

  @override
  String get centerVisitOnly => 'Center Visit Only';

  @override
  String get ownershipType => 'Ownership Type';

  @override
  String get anyOwnership => 'Any';

  @override
  String get privateOwnership => 'Private';

  @override
  String get govtOwnership => 'Government';

  @override
  String get hospitalAffiliatedOwnership => 'Hospital Affiliated';

  @override
  String get ngoOwnership => 'NGO';

  @override
  String get allFacilityCategories => 'All Facility Categories';

  @override
  String get allTestCategories => 'All Test Categories';

  @override
  String get activeFilters => 'Active Filters:';

  @override
  String applyFiltersWithCount(int count) {
    return 'Apply Filters ($count)';
  }

  @override
  String get resetAll => 'Reset All';

  @override
  String get clearAllFilters => 'Clear filters';

  @override
  String get noDoctorsFound => 'No doctors found';

  @override
  String get noDoctorsFoundDesc =>
      'Try adjusting your search query or filters.';

  @override
  String experienceYears(String years) {
    return '$years years exp';
  }

  @override
  String ratingReviews(String rating, int count) {
    return '$rating ($count)';
  }

  @override
  String chambersCount(int count) {
    return '$count chambers';
  }

  @override
  String fromFee(String fee) {
    return 'from ৳$fee';
  }

  @override
  String moreChambers(int count) {
    return '+ $count more chambers';
  }

  @override
  String get doctorAbout => 'About';

  @override
  String get doctorChambers => 'Chambers & Schedule';

  @override
  String visitFeeFrom(String fee) {
    return 'Visit fee from ৳$fee';
  }

  @override
  String get bookAVisit => 'Book a visit';

  @override
  String get step1Kicker => 'STEP 1 OF 2';

  @override
  String get whereAndWhen => 'Where and when?';

  @override
  String get selectChamber => 'Select chamber';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectSlot => 'Select appointment time';

  @override
  String get notAtChamberToday => 'Not at this chamber that day';

  @override
  String get noSlotsAvailable => 'No slots available for this day';

  @override
  String get morningShift => 'Morning Shift';

  @override
  String get eveningShift => 'Evening Shift';

  @override
  String get continueButton => 'Continue';

  @override
  String get step2Kicker => 'STEP 2 OF 2';

  @override
  String get almostThere => 'Almost there';

  @override
  String get doctorLabel => 'Doctor';

  @override
  String get whenLabel => 'When';

  @override
  String get whereLabel => 'Where';

  @override
  String get feeLabel => 'Fee';

  @override
  String get patientName => 'Patient Name';

  @override
  String get patientNameHint => 'Enter patient\'s full name';

  @override
  String get patientPhone => 'Mobile Number';

  @override
  String get patientPhoneHint => '01XXXXXXXXX';

  @override
  String get invalidPhone => 'Enter a valid 11-digit Bangladesh mobile number';

  @override
  String get nameRequired => 'Patient name is required';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get payAtCounter => 'Pay at counter';

  @override
  String get payAtCounterDesc =>
      'Pay the consultation fee when you visit the clinic';

  @override
  String get payNow => 'Pay now with bKash / Nagad / Card';

  @override
  String get confirmBooking => 'Confirm booking';

  @override
  String payWithBkash(String fee) {
    return 'Pay ৳$fee with bKash';
  }

  @override
  String get otpTitle => 'Verify Phone Number';

  @override
  String otpSubtitle(String phone) {
    return 'We sent a 6-digit verification code to $phone';
  }

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get verifyAndConfirm => 'Verify & Confirm';

  @override
  String get resendOtp => 'Resend code';

  @override
  String resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpInvalid => 'Enter the 6-digit code';

  @override
  String get otpTooManyAttempts => 'Too many attempts. Please wait a minute.';

  @override
  String get badgeInstantBooking => 'Instant booking';

  @override
  String get badgeBookingByRequest => 'Booking by request';

  @override
  String get badgeBookByPhone => 'Book by phone';

  @override
  String get ctaBookAppointment => 'Book appointment';

  @override
  String get ctaRequestAppointment => 'Request appointment';

  @override
  String get ctaGetPhoneNumber => 'Get phone number';

  @override
  String get ctaSendRequest => 'Send request';

  @override
  String get selectSession => 'Select session';

  @override
  String get selectASession => 'Select a session';

  @override
  String get noSessionsForDay => 'No sessions available for this day';

  @override
  String get noChambers => 'No chambers listed';

  @override
  String get noChambersDesc => 'This doctor has no chambers listed yet.';

  @override
  String get goBack => 'Go back';

  @override
  String get sessionFull => 'Full';

  @override
  String get sessionEnded => 'Ended';

  @override
  String get sessionClosed => 'Closed';

  @override
  String sessionSeatsLeft(int count) {
    return '$count left';
  }

  @override
  String nextSerialNumber(int number) {
    return 'Next serial #$number';
  }

  @override
  String approxTime(String time) {
    return 'approx. $time';
  }

  @override
  String get tooLateToRequest => 'Too late to request — call the chamber';

  @override
  String get morningSession => 'Morning';

  @override
  String get eveningSession => 'Evening';

  @override
  String get requestSentTitle => 'Request sent';

  @override
  String requestWillCall(String facility, String phone) {
    return '$facility will call you at $phone to confirm. You\'ll also get an SMS.';
  }

  @override
  String expectCallBy(String deadline) {
    return 'Expect a call by $deadline';
  }

  @override
  String get beforeSessionStarts => 'before the session starts';

  @override
  String get confirmedTitle => 'You\'re booked';

  @override
  String get serialBySms => 'Your serial will come by SMS';

  @override
  String get bookingIdLabel => 'Booking ID';

  @override
  String get bookingNotFound => 'This booking isn\'t loaded';

  @override
  String get bookingNotLoadedDesc =>
      'Open the booking again from the doctor\'s profile.';

  @override
  String get backToDoctors => 'Back to doctors';

  @override
  String get genderOther => 'Other';

  @override
  String get patientAge => 'Age (optional)';

  @override
  String get patientAgeHint => 'Years';

  @override
  String get patientGender => 'Gender (optional)';

  @override
  String sendRequestNote(String phone) {
    return 'The chamber will call $phone to confirm';
  }

  @override
  String nextAvailableShort(String day, String time, int count) {
    return 'Next: $day $time · $count left';
  }

  @override
  String get callToBook => 'Call';

  @override
  String get callDuringHours => 'Call during these hours';

  @override
  String get weeklyHours => 'Weekly hours';

  @override
  String get labWillContact =>
      'Booking received — the lab will contact you to confirm';

  @override
  String get serviceNotOffered => 'This hospital doesn\'t offer this service';

  @override
  String get preferredTimeLabel => 'Preferred time';

  @override
  String get prefTimeMorning => 'Morning (9 am–12 pm)';

  @override
  String get prefTimeAfternoon => 'Afternoon (12–4 pm)';

  @override
  String get prefTimeEvening => 'Evening (4–8 pm)';

  @override
  String get prefTimeAny => 'Any time';

  @override
  String get notesLabel => 'Notes (optional)';

  @override
  String serviceRequestReceived(String facility) {
    return 'Request received — $facility will contact you to confirm';
  }

  @override
  String sessionWindow(String start, String end) {
    return '$start–$end';
  }

  @override
  String get bookedSuccessTitle => 'You\'re booked!';

  @override
  String get bookingRef => 'Booking Ref';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get forPatient => 'For';

  @override
  String get bookedAt => 'At';

  @override
  String get bookedWhen => 'When';

  @override
  String get paymentStatus => 'Payment';

  @override
  String get successNote =>
      'Please arrive 15 minutes before your scheduled appointment. We\'ve sent details via SMS.';

  @override
  String get seeMyBookings => 'See my bookings';

  @override
  String get backToHome => 'Back to home';

  @override
  String get diagnosticsTitle => 'Diagnostics & Lab Tests';

  @override
  String get searchDiagnosticsPlaceholder =>
      'Search test name (e.g. CBC, Lipid Profile)...';

  @override
  String reportTimeHours(int hours) {
    return 'Report in ${hours}h';
  }

  @override
  String get fastingRequired => 'Fasting required (8–12 hrs)';

  @override
  String get noFastingRequired => 'No fasting required';

  @override
  String usualPriceRange(String min, String max) {
    return 'Usual price: ৳$min – ৳$max';
  }

  @override
  String get homePickup => 'Home pickup';

  @override
  String get atLabOnly => 'At lab only';

  @override
  String moreLabs(int count) {
    return '+ $count more labs offering this test';
  }

  @override
  String get bookTest => 'Book test';

  @override
  String get sampleCollection => 'Sample Collection';

  @override
  String get visitLabOption => 'Visit lab';

  @override
  String homePickupOption(String charge) {
    return 'Home pickup (+৳$charge)';
  }

  @override
  String get pickupThana => 'Pickup thana';

  @override
  String get selectThana => 'Select thana';

  @override
  String get pickupThanaRequired => 'Pickup thana is required';

  @override
  String get pickupAddress => 'Home Pickup Address';

  @override
  String get pickupAddressHint => 'House, Road, Area, Landmark...';

  @override
  String get addressRequired =>
      'Pickup address is required for home collection';

  @override
  String get timeWindow => 'Preferred Time Window';

  @override
  String get hospitalNotFound => 'Hospital not found';

  @override
  String get hospitalNotFoundDesc =>
      'It may have been removed. Go back and try another hospital.';

  @override
  String doctorsHere(int count) {
    return 'Doctors here ($count)';
  }

  @override
  String testsHere(int count) {
    return 'Tests here ($count)';
  }

  @override
  String get servicesTitle => 'Services';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get emergencyPhoneLabel => 'Emergency';

  @override
  String get ambulancePhoneLabel => 'Ambulance';

  @override
  String get hospitalsTitle => 'Hospitals & Diagnostic Centers';

  @override
  String get searchHospitalsPlaceholder => 'Search hospital name or area...';

  @override
  String get myBookingsTitle => 'My Bookings';

  @override
  String upcomingBookingsKicker(int count) {
    return '$count UPCOMING';
  }

  @override
  String get savedOnPhone => 'Saved on this phone';

  @override
  String get doctorVisitTag => 'DOCTOR VISIT';

  @override
  String get labTestTag => 'LAB TEST';

  @override
  String get hospitalServiceTag => 'HOSPITAL SERVICE';

  @override
  String get statusConfirmedTag => 'Confirmed';

  @override
  String get awaitingConfirmationTag => 'Awaiting confirmation';

  @override
  String get awaitingLabTag => 'Awaiting lab';

  @override
  String get awaitingHospitalTag => 'Awaiting hospital';

  @override
  String get notConfirmedInTime =>
      'Not confirmed in time. If you didn\'t get an SMS, call the chamber.';

  @override
  String toCancelCall(String facility) {
    return 'To cancel, call $facility';
  }

  @override
  String get cancelBooking => 'Cancel';

  @override
  String get cancelDialogTitle => 'Cancel Appointment';

  @override
  String cancelDialogMessage(String phone) {
    return 'To cancel your appointment with the chamber, please call the facility directly at $phone.';
  }

  @override
  String get removeBooking => 'Remove from phone';

  @override
  String get callChamber => 'Call Chamber';

  @override
  String get close => 'Close';

  @override
  String get noBookings => 'No bookings yet';

  @override
  String get noBookingsDesc =>
      'Your booked doctor visits and lab tests will be saved here.';

  @override
  String get retry => 'Retry';

  @override
  String get errorOccurred => 'Something went wrong';

  @override
  String get networkError =>
      'Unable to connect. Please check your internet connection.';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get updateRequiredTitle => 'Update required';

  @override
  String get updateRequiredFallback => 'Please update the app to continue.';

  @override
  String get updateAvailableMessage => 'A new version of the app is available.';

  @override
  String get updateSoonMessage =>
      'This version will stop working soon. Please update.';

  @override
  String get updateNow => 'Update now';

  @override
  String get errBookingModeCallOnly =>
      'This chamber takes bookings by phone only. Please call the chamber.';

  @override
  String get errRequestTooLate =>
      'Too late to request this session. Please call the chamber.';

  @override
  String get errNotCallMode => 'This chamber no longer takes phone bookings.';

  @override
  String get errNoNumbers =>
      'This chamber has no phone number listed yet. Please try another chamber.';

  @override
  String usualPriceLabel(String price) {
    return 'Usual price: $price';
  }

  @override
  String get priceAtCounter => 'Price at counter';

  @override
  String get priceConfirmedAtLab => 'Price confirmed at the lab';

  @override
  String get currentlyUnavailable => 'Currently unavailable';

  @override
  String get testNotLoaded => 'This test isn\'t loaded';

  @override
  String get testNotLoadedDesc => 'Open it again from the tests list.';

  @override
  String get backToTests => 'Back to tests';
}
