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
  String get pickupAddress => 'হোম পিকআপ ঠিকানা';

  @override
  String get pickupAddressHint => 'বাড়ি, রোড, এলাকা, ল্যান্ডমার্ক...';

  @override
  String get addressRequired => 'হোম পিকআপের জন্য ঠিকানা প্রয়োজন';

  @override
  String get timeWindow => 'পছন্দের সময়';

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
}
