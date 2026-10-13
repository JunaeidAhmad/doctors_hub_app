import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/doctors/presentation/doctors_list_screen.dart';
import '../../features/doctors/presentation/doctor_profile_screen.dart';
import '../../features/booking/presentation/doctor_booking_step1_screen.dart';
import '../../features/booking/presentation/doctor_booking_step2_screen.dart';
import '../../features/tests/presentation/tests_catalogue_screen.dart';
import '../../features/tests/presentation/test_booking_screen.dart';
import '../../features/hospitals/presentation/hospitals_screen.dart';
import '../../features/bookings/presentation/bookings_screen.dart';
import '../../features/booking/presentation/booking_success_screen.dart';
import '../../features/gallery/presentation/gallery_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
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
                  final specialty = state.uri.queryParameters['specialty'];
                  final division = state.uri.queryParameters['division'];
                  final hospital = state.uri.queryParameters['hospital'];
                  final search = state.uri.queryParameters['search'];
                  return DoctorsListScreen(
                    initialSpecialty: specialty,
                    initialDivision: division,
                    initialHospital: hospital,
                    initialSearch: search,
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
                  final category = state.uri.queryParameters['category'];
                  final search = state.uri.queryParameters['search'];
                  return TestsCatalogueScreen(
                    initialCategory: category,
                    initialSearch: search,
                  );
                },
              ),
            ],
          ),
          // Tab 3: Bookings
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

      // Pushed above shell (bottom bar hidden)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/hospitals',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          final division = state.uri.queryParameters['division'];
          final search = state.uri.queryParameters['search'];
          return HospitalsScreen(
            initialCategory: category,
            initialDivision: division,
            initialSearch: search,
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
            initialAffiliationId: affiliationId,
          );
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
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                _buildTabItem(
                  context: context,
                  index: 1,
                  label: 'Doctors',
                  icon: Icons.person_search_outlined,
                  activeIcon: Icons.person_search,
                ),
                _buildTabItem(
                  context: context,
                  index: 2,
                  label: 'Diagnostics',
                  icon: Icons.science_outlined,
                  activeIcon: Icons.science,
                ),
                _buildTabItem(
                  context: context,
                  index: 3,
                  label: 'Bookings',
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
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTypography.fontArchivo,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? AppColors.paper : AppColors.ink,
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
