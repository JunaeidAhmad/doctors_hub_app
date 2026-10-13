import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app_config/app_config_providers.dart';
import '../app_config/update_required_screen.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/doctors/presentation/doctors_list_screen.dart';
import '../../features/doctors/presentation/doctor_profile_screen.dart';
import '../../features/booking/presentation/doctor_booking_step1_screen.dart';
import '../../features/booking/presentation/doctor_booking_step2_screen.dart';
import '../../features/booking/presentation/doctor_call_screen.dart';
import '../../features/tests/presentation/tests_catalogue_screen.dart';
import '../../features/tests/presentation/test_booking_screen.dart';
import '../../features/hospitals/presentation/hospital_page_screen.dart';
import '../../features/hospitals/presentation/hospital_service_booking_screen.dart';
import '../../features/hospitals/presentation/hospitals_screen.dart';
import '../../features/bookings/presentation/bookings_screen.dart';
import '../../features/booking/presentation/booking_success_screen.dart';
import '../../features/gallery/presentation/gallery_screen.dart';
import '../../l10n/app_localizations.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

/// Lets pushed screens re-fetch when they regain focus (booking step 1
/// refreshes availability after step 2 pops).
final routeObserver = RouteObserver<ModalRoute<void>>();

final routerProvider = Provider<GoRouter>((ref) {
  final updateRequired = ref.watch(updateRequiredProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    observers: [routeObserver],
    refreshListenable: updateRequired,
    redirect: (context, state) {
      final blocked = updateRequired.value != null;
      final atUpdateScreen = state.matchedLocation == '/update-required';
      if (blocked && !atUpdateScreen) return '/update-required';
      if (!blocked && atUpdateScreen) return '/';
      return null;
    },
    routes: [
      // Stateful shell route for 4 tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppBottomNavShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1: Doctors
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/doctors',
                builder: (context, state) {
                  final q = state.uri.queryParameters;
                  return DoctorsListScreen(
                    initialSpecialty: q['specialty'],
                    initialDivisionId: int.tryParse(q['division_id'] ?? ''),
                    initialFacilityId: q['facility_id'],
                    initialFacilityName: q['facility_name'],
                    initialSearch: q['search'],
                  );
                },
              ),
            ],
          ),
          // Tab 2: Tests
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tests',
                builder: (context, state) {
                  final q = state.uri.queryParameters;
                  return TestsCatalogueScreen(
                    initialCategory: q['category'],
                    initialDivisionId: int.tryParse(q['division_id'] ?? ''),
                    initialLocationId: q['location_id'],
                    initialLocationName: q['location_name'],
                    initialSearch: q['search'],
                  );
                },
              ),
            ],
          ),
          // Tab 3: Hospitals
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/hospitals',
                builder: (context, state) {
                  final q = state.uri.queryParameters;
                  return HospitalsScreen(
                    initialCategory: q['category'],
                    initialDivisionId: int.tryParse(q['division_id'] ?? ''),
                    initialSearch: q['search'],
                  );
                },
              ),
            ],
          ),
          // Tab 4: Bookings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (context, state) => const BookingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen update gate (426 / update_required)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/update-required',
        builder: (context, state) => const UpdateRequiredScreen(),
      ),

      // Pushed above shell (bottom bar hidden)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/hospitals/:idOrSlug',
        builder: (context, state) {
          final idOrSlug = state.pathParameters['idOrSlug']!;
          return HospitalPageScreen(idOrSlug: idOrSlug);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/hospitals/:idOrSlug/services/:serviceId/book',
        builder: (context, state) {
          return HospitalServiceBookingScreen(
            idOrSlug: state.pathParameters['idOrSlug']!,
            serviceId: state.pathParameters['serviceId']!,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/doctors/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DoctorProfileScreen(doctorIdOrSlug: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/doctors/:id/book',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final affiliationId = state.uri.queryParameters['chamber'];
          return DoctorBookingStep1Screen(
            doctorId: id,
            initialChamberId: affiliationId,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/doctors/:id/call',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final chamberId = state.uri.queryParameters['chamber'] ?? '';
          return DoctorCallScreen(doctorId: id, chamberId: chamberId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/doctors/:id/confirm',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DoctorBookingStep2Screen(doctorId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/tests/:testId/labs/:labId/book',
        builder: (context, state) {
          final testId = state.pathParameters['testId']!;
          final labId = state.pathParameters['labId']!;
          return TestBookingScreen(
            testId: testId,
            facilityTestId: labId,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/success',
        builder: (context, state) {
          return const BookingSuccessScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/_gallery',
        builder: (context, state) => const GalleryScreen(),
      ),
    ],
  );
});

class AppBottomNavShell extends ConsumerWidget {
  const AppBottomNavShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingCount = ref.watch(upcomingBookingsCountProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          border: Border(
            top: BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _buildTabItem(
                  context: context,
                  index: 0,
                  label: l10n.home,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                _buildTabItem(
                  context: context,
                  index: 1,
                  label: l10n.doctors,
                  icon: Icons.person_search_outlined,
                  activeIcon: Icons.person_search,
                ),
                _buildTabItem(
                  context: context,
                  index: 2,
                  label: l10n.diagnostics,
                  icon: Icons.science_outlined,
                  activeIcon: Icons.science,
                ),
                _buildTabItem(
                  context: context,
                  index: 3,
                  label: l10n.hospitals,
                  icon: Icons.local_hospital_outlined,
                  activeIcon: Icons.local_hospital,
                ),
                _buildTabItem(
                  context: context,
                  index: 4,
                  label: l10n.bookings,
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  badgeCount: upcomingCount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    int? badgeCount,
  }) {
    final isSelected = navigationShell.currentIndex == index;

    return Expanded(
      child: Material(
        color: isSelected ? AppColors.ink : AppColors.paper,
        child: InkWell(
          onTap: () {
            // Tapping resets the branch stack if already selected
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? activeIcon : icon,
                      size: 20,
                      color: isSelected ? AppColors.paper : AppColors.ink,
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: AppTypography.fontArchivo,
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? AppColors.paper : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        border: Border.all(
                          color: isSelected ? AppColors.paper : AppColors.ink,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.paper,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
