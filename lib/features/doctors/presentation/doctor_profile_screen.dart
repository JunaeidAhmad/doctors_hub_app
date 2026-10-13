import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/photo_placeholder.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../../../core/widgets/sticky_cta_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/domain/booking_mode.dart';
import '../domain/models/chamber.dart';
import '../domain/models/doctor.dart';

final doctorDetailsProvider =
    FutureProvider.family<Doctor, String>((ref, idOrSlug) async {
  final repo = ref.watch(doctorRepositoryProvider);
  return repo.getDoctorDetails(idOrSlug);
});

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({
    super.key,
    required this.doctorIdOrSlug,
  });

  final String doctorIdOrSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(doctorDetailsProvider(doctorIdOrSlug));
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';

    return doctorAsync.when(
      data: (doctor) => _buildProfile(context, doctor, isBn),
      loading: () => const DhScaffold(
        appBar: null,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonRow(height: 160),
                SizedBox(height: 16),
                SkeletonRow(height: 80),
                SizedBox(height: 16),
                SkeletonRow(height: 200),
              ],
            ),
          ),
        ),
      ),
      error: (err, _) => DhScaffold(
        body: SafeArea(
          child: ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(doctorDetailsProvider(doctorIdOrSlug)),
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, Doctor doctor, bool isBn) {
    final minFee = doctor.minFee;
    final l10n = AppLocalizations.of(context)!;
    final primaryChamber = doctor.primaryChamber;
    final view = primaryChamber == null
        ? null
        : bookingModeView(primaryChamber);

    return DhScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Nav bar with back arrow
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: AppColors.paper,
                border: Border(
                  bottom: BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  // Share / Bookmark placeholder
                ],
              ),
            ),

            // Scrollable Profile content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Doctor Header Block
                    Container(
                      color: AppColors.paper,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PhotoPlaceholder(
                                name: doctor.name,
                                imageUrl: doctor.image,
                                width: 84,
                                height: 84,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Kicker(doctor.primarySpecialtyName),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor.localizedName(isBn ? 'bn' : 'en'),
                                      style: AppTypography.h1.copyWith(fontSize: 22),
                                    ),
                                    if (doctor.academicTitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        doctor.academicTitle!,
                                        style: AppTypography.secondaryBold,
                                      ),
                                    ],
                                    if (doctor.institution != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        doctor.institution!,
                                        style: AppTypography.secondary,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (doctor.qualification != null &&
                              doctor.qualification!.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.fill,
                              ),
                              child: Text(
                                doctor.qualification!,
                                style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Stats Row (Years / Rating / Chambers)
                    Container(
                      color: AppColors.paper,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        children: [
                          _buildStatItem(
                            label: isBn ? 'অভিজ্ঞতা' : 'EXPERIENCE',
                            value: doctor.experience != null &&
                                    doctor.experience!.isNotEmpty
                                ? doctor.experience!
                                : '—',
                          ),
                          _buildStatDivider(),
                          _buildStatItem(
                            label: isBn ? 'রেটিং' : 'RATING',
                            value: doctor.rating != null && doctor.rating! > 0
                                ? '★ ${doctor.rating!.toStringAsFixed(1)}'
                                : '—',
                          ),
                          _buildStatDivider(),
                          _buildStatItem(
                            label: isBn ? 'চেম্বার' : 'CHAMBERS',
                            value: '${doctor.chambers.length}',
                          ),
                        ],
                      ),
                    ),

                    // About Section
                    if (doctor.about != null && doctor.about!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        color: AppColors.paper,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'পরিচিতি' : 'About',
                              style: AppTypography.h2,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doctor.about!,
                              style: AppTypography.body,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Chambers & Schedule Section
                    const SizedBox(height: 12),
                    Container(
                      color: AppColors.paper,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'চেম্বার ও সময়সূচী' : 'Chambers & Schedule',
                            style: AppTypography.h2,
                          ),
                          const SizedBox(height: 14),
                          ...doctor.chambers.map((aff) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.ink,
                                  width: AppColors.borderWidth,
                                ),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          aff.fullDisplayName,
                                          style: AppTypography.h2.copyWith(fontSize: 16),
                                        ),
                                      ),
                                      if (aff.fee != null)
                                        Text(
                                          '৳${aff.fee!.toInt()}',
                                          style: AppTypography.h2.copyWith(
                                            fontSize: 16,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (aff.facility.address != null &&
                                      aff.facility.address!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      aff.facility.address!,
                                      style: AppTypography.secondary,
                                    ),
                                  ],
                                  if (bookingModeLabel(
                                        bookingModeView(aff).badgeKey,
                                        l10n,
                                      ) !=
                                      null) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: AppColors.fill,
                                      ),
                                      child: Text(
                                        bookingModeLabel(
                                          bookingModeView(aff).badgeKey,
                                          l10n,
                                        )!,
                                        style: AppTypography.tag,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  const Divider(color: AppColors.lineSoft, height: 1),
                                  const SizedBox(height: 10),
                                  // Schedules list
                                  if (aff.schedules.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: aff.schedules.map((s) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 72,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.fill,
                                                ),
                                                child: Text(
                                                  s.dayOfWeek.substring(0, 3).toUpperCase(),
                                                  style: const TextStyle(
                                                    fontFamily: AppTypography.fontMono,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                '${s.startTime.substring(0, 5)} - ${s.endTime.substring(0, 5)}',
                                                style: AppTypography.body,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  else
                                    Text(
                                      isBn
                                          ? 'সরাসরি চেম্বারে যোগাযোগ করুন'
                                          : 'Schedule available upon inquiry',
                                      style: AppTypography.secondary,
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA Bar (no CTA for unknown booking modes)
            if (view != null &&
                primaryChamber != null &&
                (view.canBook || view.mode == BookingMode.callOnly))
              StickyCtaBar(
                kicker: minFee != null
                    ? (isBn
                        ? 'ভিজিট ফি ৳${minFee.toInt()} থেকে'
                        : 'Visit fee from ৳${minFee.toInt()}')
                    : null,
                subtitle: doctor.localizedName(isBn ? 'bn' : 'en'),
                buttonLabel: bookingModeLabel(view.buttonKey, l10n) ??
                    (isBn ? 'অ্যাপয়েন্টমেন্ট নিন' : 'Book a visit'),
                onPressed: () {
                  if (view.canBook) {
                    context.push(
                      '/doctors/${doctor.id}/book?chamber=${primaryChamber.id}',
                    );
                  } else {
                    context.push(
                      '/doctors/${doctor.id}/call?chamber=${primaryChamber.id}',
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required String label, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTypography.fontMono,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.h2.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.lineSoft,
    );
  }
}
