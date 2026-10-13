import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_config/app_config_providers.dart';
import '../models/facility_summary.dart';
import '../network/api_client.dart';
import '../storage/local_booking_store.dart';
import '../../features/location/data/location_repository.dart';
import '../../features/doctors/data/doctor_repository.dart';
import '../../features/tests/data/test_repository.dart';
import '../../features/hospitals/data/hospital_repository.dart';
import '../../features/booking/data/booking_repository.dart';
import '../../features/location/domain/models/division.dart';
import '../../features/location/domain/models/district.dart';
import '../../features/location/domain/models/thana.dart';
import '../../features/doctors/domain/models/specialty.dart';
import '../../features/tests/domain/models/test_category.dart';
import '../../features/hospitals/domain/models/hospital_category.dart';
import '../../features/bookings/domain/models/booking_item.dart';

// SharedPreferences (overridden in ProviderScope in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be initialized');
});

// Build number for `X-App-Build`, read once at startup in main.dart.
final appBuildNumberProvider = Provider<int>((ref) => 0);

// `X-App-Platform` header value.
final appPlatformProvider = Provider<String>((ref) {
  try {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
  } catch (_) {
    // Non-mobile (tests, desktop): fall through.
  }
  return 'android';
});

// ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    appBuild: ref.watch(appBuildNumberProvider),
    platform: ref.watch(appPlatformProvider),
    onUpdateRequired: (failure) {
      ref.read(updateRequiredProvider).value = failure;
    },
  );
  final locale = ref.watch(localeProvider);
  client.setLocale(locale.languageCode);
  return client;
});

// Local Booking Store
final localBookingStoreProvider = Provider<LocalBookingStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalBookingStore(prefs);
});

// Repositories
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.watch(apiClientProvider));
});

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository(ref.watch(apiClientProvider));
});

final testRepositoryProvider = Provider<TestRepository>((ref) {
  return TestRepository(ref.watch(apiClientProvider));
});

final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepository(ref.watch(apiClientProvider));
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(apiClientProvider));
});

// Locale State Notifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(const Locale('en')) {
    final savedCode = _prefs.getString('dh_user_locale');
    if (savedCode != null && (savedCode == 'en' || savedCode == 'bn')) {
      state = Locale(savedCode);
    }
  }

  final SharedPreferences _prefs;

  void toggleLocale() {
    if (state.languageCode == 'en') {
      setLocale(const Locale('bn'));
    } else {
      setLocale(const Locale('en'));
    }
  }

  void setLocale(Locale locale) {
    state = locale;
    _prefs.setString('dh_user_locale', locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

// Local Bookings List State Notifier
class LocalBookingsNotifier extends StateNotifier<List<BookingItem>> {
  LocalBookingsNotifier(this._store) : super([]) {
    refresh();
  }

  final LocalBookingStore _store;

  void refresh() {
    state = _store.getBookings();
  }

  Future<void> addBooking(BookingItem booking) async {
    await _store.saveBooking(booking);
    refresh();
  }

  Future<void> removeBooking(String bookingId) async {
    await _store.removeBooking(bookingId);
    refresh();
  }
}

final localBookingsProvider =
    StateNotifierProvider<LocalBookingsNotifier, List<BookingItem>>((ref) {
  final store = ref.watch(localBookingStoreProvider);
  return LocalBookingsNotifier(store);
});

final upcomingBookingsCountProvider = Provider<int>((ref) {
  final bookings = ref.watch(localBookingsProvider);
  return bookings.where((b) => b.isUpcoming).length;
});

// Async Taxonomies
final divisionsProvider = FutureProvider<List<Division>>((ref) async {
  return ref.watch(locationRepositoryProvider).getDivisions();
});

final specialtiesProvider = FutureProvider<List<Specialty>>((ref) async {
  return ref.watch(doctorRepositoryProvider).getSpecialties();
});

final testCategoriesProvider = FutureProvider<List<TestCategory>>((ref) async {
  return ref.watch(testRepositoryProvider).getCategories();
});

final hospitalCategoriesProvider =
    FutureProvider<List<HospitalCategory>>((ref) async {
  return ref.watch(hospitalRepositoryProvider).getCategories();
});

final districtsProvider =
    FutureProvider.family<List<District>, int?>((ref, divisionId) async {
  return ref
      .watch(locationRepositoryProvider)
      .getDistricts(divisionId: divisionId);
});

final thanasProvider =
    FutureProvider.family<List<Thana>, int?>((ref, districtId) async {
  return ref.watch(locationRepositoryProvider).getThanas(districtId: districtId);
});

final facilitiesProvider = FutureProvider<List<FacilitySummary>>((ref) async {
  return ref.watch(locationRepositoryProvider).getFacilities();
});

