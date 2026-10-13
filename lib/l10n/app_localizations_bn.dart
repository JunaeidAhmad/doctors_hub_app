// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'ডক্টরস হাব';

  @override
  String get home => 'হোম';

  @override
  String get doctors => 'ডাক্তার';

  @override
  String get diagnostics => 'ডায়াগনস্টিক';

  @override
  String get bookings => 'বুকিং';

  @override
  String get hospitals => 'হাসপাতাল';

  @override
  String get heroTitle => 'সারা বাংলাদেশে ডাক্তার ও ল্যাব টেস্ট বুক করুন';

  @override
  String get heroSubtitle =>
      'অ্যাকাউন্ট খোলার ঝামেলা নেই। এসএমএস-এ নিশ্চিতকরণ।';

  @override
  String get searchTabDoctors => 'ডাক্তার';

  @override
  String get searchTabDiagnostics => 'ডায়াগনস্টিক';

  @override
  String get searchTabHospitals => 'হাসপাতাল';

  @override
  String get allSpecialties => 'সকল বিশেষজ্ঞ';

  @override
  String get selectSpecialty => 'বিশেষজ্ঞ নির্বাচন করুন';

  @override
  String get searchSpecialtyHint => 'বিশেষজ্ঞ খুঁজুন...';

  @override
  String get noSpecialtiesFound => 'কোন বিশেষজ্ঞ পাওয়া যায়নি';

  @override
  String get otherSpecialties => 'অন্যান্য';

  @override
  String get allCategories => 'সকল ক্যাটাগরি';

  @override
  String get allBangladesh => 'সমগ্র বাংলাদেশ';

  @override
  String get searchButton => 'অনুসন্ধান';

  @override
  String get specialtiesSection => 'বিশেষজ্ঞ বিভাগ';

  @override
  String get popularDoctorsSection => 'জনপ্রিয় ডাক্তারগণ';

  @override
  String get diagnosticTestsSection => 'ডায়াগনস্টিক টেস্ট';

  @override
  String get hospitalsSection => 'হাসপাতাল ও সেন্টার';

  @override
  String get seeAll => 'সব দেখুন →';

  @override
  String doctorsCountKicker(int count, String specialty) {
    return '$count জন ডাক্তার · $specialty';
  }

  @override
  String get searchDoctorsPlaceholder =>
      'ডাক্তার, হাসপাতাল বা বিশেষজ্ঞ খুঁজুন...';

  @override
  String get filterDivision => 'বিভাগ';

  @override
  String get filterHospital => 'হাসপাতাল';

  @override
  String get filterSpecialty => 'বিশেষজ্ঞ';

  @override
  String get filters => 'ফিল্টার';

  @override
  String get hideFilters => 'ফিল্টার লুকান';

  @override
  String get filterOptions => 'ফিল্টার অপশন';

  @override
  String get selectFacility => 'হাসপাতাল ও ডায়াগনস্টিক সেন্টার নির্বাচন করুন';

  @override
  String get allFacilities => 'সকল হাসপাতাল ও ডায়াগনস্টিক';

  @override
  String get filterLocation => 'অবস্থান';

  @override
  String get filterDistrict => 'জেলা';

  @override
  String get filterThanaArea => 'থানা / এলাকা';

  @override
  String get allDistricts => 'সকল জেলা';

  @override
  String get allAreas => 'সকল এলাকা';

  @override
  String get clearLocation => 'মুছুন';

  @override
  String get visitingDays => 'রোগী দেখার দিন';

  @override
  String get allDays => 'সকল দিন';

  @override
  String get doctorGender => 'ডাক্তারের লিঙ্গ';

  @override
  String get allGenders => 'সকল';

  @override
  String get genderMale => 'পুরুষ';

  @override
  String get genderFemale => 'মহিলা';

  @override
  String get fulfillment => 'পরিসেবার ধরণ';

  @override
  String get allFulfillments => 'সকল';

  @override
  String get homeSamplePickup => 'হোম স্যাম্পল কালেকশন';

  @override
  String get centerVisitOnly => 'সেন্টারে এসে টেস্ট';

  @override
  String get ownershipType => 'মালিকানার ধরণ';

  @override
  String get anyOwnership => 'সকল';

  @override
  String get privateOwnership => 'বেসরকারি';

  @override
  String get govtOwnership => 'সরকারি';

  @override
  String get hospitalAffiliatedOwnership => 'হাসপাতাল অনুমোদিত';

  @override
  String get ngoOwnership => 'এনজিও';

  @override
  String get allFacilityCategories => 'সকল ক্যাটাগরি';

  @override
  String get allTestCategories => 'সকল টেস্ট ক্যাটাগরি';

  @override
  String get activeFilters => 'সক্রিয় ফিল্টার:';

  @override
  String applyFiltersWithCount(int count) {
    return 'ফিল্টার প্রয়োগ করুন ($count)';
  }

  @override
  String get resetAll => 'সব রিসেট করুন';

  @override
  String get clearAllFilters => 'ফিল্টার মুছুন';

  @override
  String get noDoctorsFound => 'কোন ডাক্তার পাওয়া যায়নি';

  @override
  String get noDoctorsFoundDesc =>
      'অনুগ্রহ করে আপনার অনুসন্ধানের শব্দ বা ফিল্টার পরিবর্তন করুন।';

  @override
  String experienceYears(String years) {
    return '$years বছরের অভিজ্ঞতা';
  }

  @override
  String ratingReviews(String rating, int count) {
    return '$rating ($count)';
  }

  @override
  String chambersCount(int count) {
    return '$count টি চেম্বার';
  }

  @override
  String fromFee(String fee) {
    return '৳$fee থেকে';
  }

  @override
  String moreChambers(int count) {
    return '+ আরও $count টি চেম্বার';
  }

  @override
  String get doctorAbout => 'পরিচিতি';

  @override
  String get doctorChambers => 'চেম্বার ও সময়সূচী';

  @override
  String visitFeeFrom(String fee) {
    return 'ভিজিট ফি ৳$fee থেকে';
  }

  @override
  String get bookAVisit => 'অ্যাপয়েন্টমেন্ট নিন';

  @override
  String get step1Kicker => 'ধাপ ১ / ২';

  @override
  String get whereAndWhen => 'স্থান ও সময় নির্বাচন';

  @override
  String get selectChamber => 'চেম্বার নির্বাচন করুন';

  @override
  String get selectDate => 'তারিখ নির্বাচন করুন';

  @override
  String get selectSlot => 'সময় নির্বাচন করুন';

  @override
  String get notAtChamberToday => 'এই দিনে এই চেম্বারে রোগী দেখেন না';

  @override
  String get noSlotsAvailable => 'এই দিনের কোন স্লট খালি নেই';

  @override
  String get morningShift => 'সকাল শিফট';

  @override
  String get eveningShift => 'সন্ধ্যা শিফট';

  @override
  String get continueButton => 'পরবর্তী ধাপ';

  @override
  String get step2Kicker => 'ধাপ ২ / ২';

  @override
  String get almostThere => 'প্রায় সম্পন্ন';

  @override
  String get doctorLabel => 'ডাক্তার';

  @override
  String get whenLabel => 'সময়';

  @override
  String get whereLabel => 'স্থান';

  @override
  String get feeLabel => 'ভিজিট ফি';

  @override
  String get patientName => 'রোগীর নাম';

  @override
  String get patientNameHint => 'রোগীর পুরো নাম লিখুন';

  @override
  String get patientPhone => 'মোবাইল নম্বর';

  @override
  String get patientPhoneHint => '০১XXXXXXXXX';

  @override
  String get invalidPhone => 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন';

  @override
  String get nameRequired => 'রোগীর নাম আবশ্যক';

  @override
  String get paymentMethod => 'পেমেন্ট মাধ্যম';

  @override
  String get payAtCounter => 'চেম্বারে গিয়ে ফি প্রদান';

  @override
  String get payAtCounterDesc =>
      'চেম্বারে উপস্থিত হয়ে সরাসরি কাউন্টারে ফি দিন';

  @override
  String get payNow => 'বিকাশ / নগদ / কার্ড দিয়ে পরিশোধ';

  @override
  String get confirmBooking => 'বুকিং নিশ্চিত করুন';

  @override
  String payWithBkash(String fee) {
    return 'বিকাশে ৳$fee পরিশোধ করুন';
  }

  @override
  String get otpTitle => 'মোবাইল নম্বর যাচাই';

  @override
  String otpSubtitle(String phone) {
    return 'আমরা আপনার $phone নম্বরে ৬ ডিজিটের কোড পাঠিয়েছি';
  }

  @override
  String get enterOtp => 'ওটিপি কোড দিন';

  @override
  String get verifyAndConfirm => 'যাচাই ও নিশ্চিত করুন';

  @override
  String get resendOtp => 'কোড পুনরায় পাঠান';

  @override
  String resendIn(int seconds) {
    return '$seconds সেকেন্ড পর পুনরায় পাঠান';
  }

  @override
  String get otpInvalid => '৬ ডিজিটের কোডটি লিখুন';

  @override
  String get otpTooManyAttempts =>
      'অনেকবার চেষ্টা করা হয়েছে। এক মিনিট অপেক্ষা করুন।';

  @override
  String get badgeInstantBooking => 'সাথে সাথে বুকিং';

  @override
  String get badgeBookingByRequest => 'অনুরোধে বুকিং';

  @override
  String get badgeBookByPhone => 'ফোনে বুকিং';

  @override
  String get ctaBookAppointment => 'অ্যাপয়েন্টমেন্ট বুক করুন';

  @override
  String get ctaRequestAppointment => 'অ্যাপয়েন্টমেন্টের অনুরোধ করুন';

  @override
  String get ctaGetPhoneNumber => 'ফোন নম্বর নিন';

  @override
  String get ctaSendRequest => 'অনুরোধ পাঠান';

  @override
  String get selectSession => 'সেশন নির্বাচন করুন';

  @override
  String get selectASession => 'একটি সেশন নির্বাচন করুন';

  @override
  String get noSessionsForDay => 'এই দিনে কোন সেশন নেই';

  @override
  String get noChambers => 'কোন চেম্বার নেই';

  @override
  String get noChambersDesc =>
      'এই ডাক্তারের চেম্বারের তথ্য এখনো যোগ করা হয়নি।';

  @override
  String get goBack => 'ফিরে যান';

  @override
  String get sessionFull => 'পূর্ণ';

  @override
  String get sessionEnded => 'শেষ';

  @override
  String get sessionClosed => 'বন্ধ';

  @override
  String sessionSeatsLeft(int count) {
    return '$count টি বাকি';
  }

  @override
  String nextSerialNumber(int number) {
    return 'পরবর্তী সিরিয়াল #$number';
  }

  @override
  String approxTime(String time) {
    return 'আনুমানিক $time';
  }

  @override
  String get tooLateToRequest =>
      'অনুরোধ করার সময় পার হয়ে গেছে — চেম্বারে কল করুন';

  @override
  String get morningSession => 'সকাল';

  @override
  String get eveningSession => 'বিকাল';

  @override
  String get requestSentTitle => 'অনুরোধ পাঠানো হয়েছে';

  @override
  String requestWillCall(String facility, String phone) {
    return '$facility নিশ্চিত করতে $phone নম্বরে কল করবে। একটি এসএমএসও পাবেন।';
  }

  @override
  String expectCallBy(String deadline) {
    return '$deadline এর মধ্যে কল আশা করুন';
  }

  @override
  String get beforeSessionStarts => 'সেশন শুরুর আগে';

  @override
  String get confirmedTitle => 'আপনি বুক হয়ে গেছেন';

  @override
  String get serialBySms => 'আপনার সিরিয়াল এসএমএসে জানানো হবে';

  @override
  String get bookingIdLabel => 'বুকিং আইডি';

  @override
  String get bookingNotFound => 'এই বুকিংটি লোড হয়নি';

  @override
  String get bookingNotLoadedDesc =>
      'ডাক্তারের প্রোফাইল থেকে আবার বুকিং শুরু করুন।';

  @override
  String get backToDoctors => 'ডাক্তার তালিকায় ফিরুন';

  @override
  String get genderOther => 'অন্যান্য';

  @override
  String get patientAge => 'বয়স (ঐচ্ছিক)';

  @override
  String get patientAgeHint => 'বছর';

  @override
  String get patientGender => 'লিঙ্গ (ঐচ্ছিক)';

  @override
  String sendRequestNote(String phone) {
    return 'নিশ্চিত করতে চেম্বার $phone নম্বরে কল করবে';
  }

  @override
  String nextAvailableShort(String day, String time, int count) {
    return 'পরবর্তী: $day $time · $count টি বাকি';
  }

  @override
  String get callToBook => 'কল করুন';

  @override
  String get callDuringHours => 'এই সময়ে কল করুন';

  @override
  String get weeklyHours => 'সাপ্তাহিক সময়সূচি';

  @override
  String get labWillContact =>
      'বুকিং পেয়েছি — নিশ্চিত করতে ল্যাব যোগাযোগ করবে';

  @override
  String get serviceNotOffered => 'এই হাসপাতালে এই সেবাটি নেই';

  @override
  String get preferredTimeLabel => 'পছন্দের সময়';

  @override
  String get prefTimeMorning => 'সকাল (৯টা–১২টা)';

  @override
  String get prefTimeAfternoon => 'দুপুর (১২টা–৪টা)';

  @override
  String get prefTimeEvening => 'বিকাল (৪টা–৮টা)';

  @override
  String get prefTimeAny => 'যেকোনো সময়';

  @override
  String get notesLabel => 'নোট (ঐচ্ছিক)';

  @override
  String serviceRequestReceived(String facility) {
    return 'অনুরোধ পেয়েছি — নিশ্চিত করতে $facility যোগাযোগ করবে';
  }

  @override
  String sessionWindow(String start, String end) {
    return '$start–$end';
  }

  @override
  String get bookedSuccessTitle => 'বুকিং সফল হয়েছে!';

  @override
  String get bookingRef => 'বুকিং রেফারেন্স';

  @override
  String get serialNumber => 'সিরিয়াল নম্বর';

  @override
  String get forPatient => 'রোগী';

  @override
  String get bookedAt => 'স্থান';

  @override
  String get bookedWhen => 'তারিখ ও সময়';

  @override
  String get paymentStatus => 'পেমেন্ট';

  @override
  String get successNote =>
      'নির্ধারিত সময়ের ১৫ মিনিট পূর্বে উপস্থিত থাকুন। এসএমএস এর মাধ্যমে বিস্তারিত পাঠানো হয়েছে।';

  @override
  String get seeMyBookings => 'আমার বুকিং দেখুন';

  @override
  String get backToHome => 'হোমে ফিরে যান';

  @override
  String get diagnosticsTitle => 'ডায়াগনস্টিক ও ল্যাব টেস্ট';

  @override
  String get searchDiagnosticsPlaceholder =>
      'টেস্টের নাম লিখে খুঁজুন (উদাঃ CBC)...';

  @override
  String reportTimeHours(int hours) {
    return 'রিপোর্ট $hours ঘণ্টায়';
  }

  @override
  String get fastingRequired => 'না খেয়ে থাকা আবশ্যক (৮-১২ ঘণ্টা)';

  @override
  String get noFastingRequired => 'না খেয়ে থাকার প্রয়োজন নেই';

  @override
  String usualPriceRange(String min, String max) {
    return 'আনুমানিক খরচ: ৳$min – ৳$max';
  }

  @override
  String get homePickup => 'হোম স্যাম্পল কালেকশন';

  @override
  String get atLabOnly => 'শুধুমাত্র ল্যাবে';

  @override
  String moreLabs(int count) {
    return '+ আরও $count টি ল্যাবে এই টেস্টটি আছে';
  }

  @override
  String get bookTest => 'টেস্ট বুক করুন';

  @override
  String get sampleCollection => 'স্যাম্পল কালেকশন পদ্ধতি';

  @override
  String get visitLabOption => 'ল্যাবে গিয়ে';

  @override
  String homePickupOption(String charge) {
    return 'হোম পিকআপ (+৳$charge)';
  }

  @override
  String get pickupThana => 'পিকআপ থানা';

  @override
  String get selectThana => 'থানা নির্বাচন করুন';

  @override
  String get pickupThanaRequired => 'পিকআপ থানার তথ্য প্রয়োজন';

  @override
  String get pickupAddress => 'হোম পিকআপ ঠিকানা';

  @override
  String get pickupAddressHint => 'বাড়ি, রোড, এলাকা, ল্যান্ডমার্ক...';

  @override
  String get addressRequired => 'হোম পিকআপের জন্য ঠিকানা প্রয়োজন';

  @override
  String get timeWindow => 'পছন্দের সময়';

  @override
  String get hospitalNotFound => 'হাসপাতাল পাওয়া যায়নি';

  @override
  String get hospitalNotFoundDesc =>
      'এটি সরিয়ে ফেলা হতে পারে। ফিরে গিয়ে অন্য হাসপাতাল দেখুন।';

  @override
  String doctorsHere(int count) {
    return 'এখানকার ডাক্তার ($count)';
  }

  @override
  String testsHere(int count) {
    return 'এখানকার টেস্ট ($count)';
  }

  @override
  String get servicesTitle => 'সেবাসমূহ';

  @override
  String get phoneLabel => 'ফোন';

  @override
  String get emergencyPhoneLabel => 'ইমার্জেন্সি';

  @override
  String get ambulancePhoneLabel => 'অ্যাম্বুলেন্স';

  @override
  String get hospitalsTitle => 'হাসপাতাল ও ডায়াগনস্টিক সেন্টার';

  @override
  String get searchHospitalsPlaceholder => 'হাসপাতাল বা এলাকার নাম খুঁজুন...';

  @override
  String get myBookingsTitle => 'আমার বুকিংসমূহ';

  @override
  String upcomingBookingsKicker(int count) {
    return '$count টি আসন্ন বুকিং';
  }

  @override
  String get savedOnPhone => 'এই ফোনে সংরক্ষিত';

  @override
  String get doctorVisitTag => 'ডাক্তার ভিজিট';

  @override
  String get labTestTag => 'ল্যাব টেস্ট';

  @override
  String get hospitalServiceTag => 'হাসপাতাল সেবা';

  @override
  String get statusConfirmedTag => 'নিশ্চিত';

  @override
  String get awaitingConfirmationTag => 'নিশ্চিতকরণের অপেক্ষায়';

  @override
  String get awaitingLabTag => 'ল্যাবের অপেক্ষায়';

  @override
  String get awaitingHospitalTag => 'হাসপাতালের অপেক্ষায়';

  @override
  String get notConfirmedInTime =>
      'সময়ের মধ্যে নিশ্চিত হয়নি। এসএমএস না পেলে চেম্বারে কল করুন।';

  @override
  String toCancelCall(String facility) {
    return 'বাতিল করতে $facility নম্বরে কল করুন';
  }

  @override
  String get cancelBooking => 'বাতিল';

  @override
  String get cancelDialogTitle => 'অ্যাপয়েন্টমেন্ট বাতিল';

  @override
  String cancelDialogMessage(String phone) {
    return 'অ্যাপয়েন্টমেন্ট বাতিল করতে অনুগ্রহ করে সরাসরি চেম্বারে $phone নম্বরে যোগাযোগ করুন।';
  }

  @override
  String get removeBooking => 'তালিকা থেকে সরান';

  @override
  String get callChamber => 'চেম্বারে কল করুন';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get noBookings => 'কোন বুকিং নেই';

  @override
  String get noBookingsDesc =>
      'আপনার সকল ডাক্তার অ্যাপয়েন্টমেন্ট ও ল্যাব টেস্টের তথ্য এখানে দেখতে পাবেন।';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get errorOccurred => 'কিছু সমস্যা হয়েছে';

  @override
  String get networkError =>
      'ইন্টারনেট সংযোগ নেই। সংযোগ পরীক্ষা করে পুনরায় চেষ্টা করুন।';

  @override
  String get language => 'ভাষা';

  @override
  String get english => 'English';

  @override
  String get bangla => 'বাংলা';

  @override
  String get updateRequiredTitle => 'আপডেট প্রয়োজন';

  @override
  String get updateRequiredFallback =>
      'চালিয়ে যেতে অনুগ্রহ করে অ্যাপটি আপডেট করুন।';

  @override
  String get updateAvailableMessage => 'অ্যাপের নতুন সংস্করণ এসেছে।';

  @override
  String get updateSoonMessage =>
      'এই সংস্করণটি শীঘ্রই বন্ধ হয়ে যাবে। অনুগ্রহ করে আপডেট করুন।';

  @override
  String get updateNow => 'এখনই আপডেট করুন';

  @override
  String get errBookingModeCallOnly =>
      'এই চেম্বারে শুধু ফোনে বুকিং নেওয়া হয়। অনুগ্রহ করে চেম্বারে কল করুন।';

  @override
  String get errRequestTooLate =>
      'এই সেশনের জন্য অনুরোধ করার সময় পার হয়ে গেছে। অনুগ্রহ করে চেম্বারে কল করুন।';

  @override
  String get errNotCallMode => 'এই চেম্বারে আর ফোনে বুকিং নেওয়া হয় না।';

  @override
  String get errNoNumbers =>
      'এই চেম্বারের কোনো ফোন নম্বর এখনো যোগ করা হয়নি। অনুগ্রহ করে অন্য চেম্বার দেখুন।';

  @override
  String usualPriceLabel(String price) {
    return 'আনুমানিক খরচ: $price';
  }

  @override
  String get priceAtCounter => 'কাউন্টারে মূল্য';

  @override
  String get priceConfirmedAtLab => 'মূল্য ল্যাবে নিশ্চিত করা হবে';

  @override
  String get currentlyUnavailable => 'বর্তমানে পাওয়া যাচ্ছে না';

  @override
  String get testNotLoaded => 'এই টেস্টের তথ্য লোড হয়নি';

  @override
  String get testNotLoadedDesc => 'টেস্ট তালিকা থেকে আবার খুলুন।';

  @override
  String get backToTests => 'টেস্ট তালিকায় ফিরুন';
}
