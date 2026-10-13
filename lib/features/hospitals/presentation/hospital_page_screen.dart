import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/app_failure.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/phone_launcher.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/models/hospital.dart';
import 'hospital_service_selection.dart';

final hospitalDetailsProvider =
    FutureProvider.family<Hospital, String>((ref, idOrSlug) async {
  return ref.watch(hospitalRepositoryProvider).getHospital(idOrSlug);
});

class HospitalPageScreen extends ConsumerWidget {
  const HospitalPageScreen({super.key, required this.idOrSlug});

  final String idOrSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalAsync = ref.watch(hospitalDetailsProvider(idOrSlug));

    return hospitalAsync.when(
      data: (hospital) => _HospitalPageBody(hospital: hospital),
      loading: () => const DhScaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonRow(height: 140),
                SizedBox(height: 16),
                SkeletonRow(height: 90),
                SizedBox(height: 16),
                SkeletonRow(height: 200),
              ],
            ),
          ),
        ),
      ),
      error: (err, _) {
        final l10n = AppLocalizations.of(context)!;
        final notFound = err is NotFoundFailure;
        return DhScaffold(
          body: SafeArea(
            child: EmptyState(
              title: notFound ? l10n.hospitalNotFound : l10n.errorOccurred,
              message: notFound
                  ? l10n.hospitalNotFoundDesc
                  : err.toString(),
              actionLabel: notFound ? l10n.backToHome : l10n.retry,
              onAction: notFound
                  ? () => context.go('/hospitals')
                  : () => ref.invalidate(hospitalDetailsProvider(idOrSlug)),
            ),
          ),
        );
      },
    );
  }
}

class _HospitalPageBody extends ConsumerWidget {
  const _HospitalPageBody({required this.hospital});

  final Hospital hospital;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final isBn = locale.languageCode == 'bn';
    final area = hospital.localizedArea(isBn ? 'bn' : 'en');
    final district = hospital.localizedDistrict(isBn ? 'bn' : 'en');
    final locationLine = [area, district]
        .where((part) => part.isNotEmpty)
        .join(', ');

    return DhScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                color: AppColors.paper,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.ink,
                    width: AppColors.borderWidth,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.hospitalsTitle,
                      style: AppTypography.h2.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hospital.category != null &&
                        hospital.category!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Kicker(hospital.category!),
                      ),
                    Text(
                      hospital.displayName,
                      style: AppTypography.h1.copyWith(fontSize: 24),
                    ),
                    if (locationLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(locationLine, style: AppTypography.secondary),
                    ],
                    if (hospital.address != null &&
                        hospital.address!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(hospital.address!, style: AppTypography.secondary),
                    ],
                    if (hospital.openTiming != null &&
                        hospital.openTiming!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(hospital.openTiming!, style: AppTypography.body),
                    ],
                    const SizedBox(height: 16),

                    // Contact numbers
                    if (hospital.phone != null &&
                        hospital.phone!.isNotEmpty)
                      _buildCallRow(
                        context,
                        label: l10n.phoneLabel,
                        phone: hospital.phone!,
                      ),
                    if (hospital.emergencyPhone != null &&
                        hospital.emergencyPhone!.isNotEmpty)
                      _buildCallRow(
                        context,
                        label: l10n.emergencyPhoneLabel,
                        phone: hospital.emergencyPhone!,
                      ),
                    if (hospital.ambulancePhone != null &&
                        hospital.ambulancePhone!.isNotEmpty)
                      _buildCallRow(
                        context,
                        label: l10n.ambulancePhoneLabel,
                        phone: hospital.ambulancePhone!,
                      ),

                    if (hospital.description != null &&
                        hospital.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(hospital.description!, style: AppTypography.body),
                    ],

                    if (hospital.services.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        l10n.servicesTitle,
                        style: AppTypography.h2.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ...hospital.services.map(
                        (service) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.paper,
                            border: Border.all(
                              color: AppColors.ink,
                              width: AppColors.borderWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  service.name,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(hospitalServiceSelectionProvider
                                          .notifier)
                                      .state = HospitalServiceSelection(
                                    hospital: hospital,
                                    service: service,
                                  );
                                  context.push(
                                    '/hospitals/${hospital.id}/services/${service.id}/book',
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  color: AppColors.ink,
                                  child: Text(
                                    isBn ? 'বুক করুন' : 'Book',
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontArchivo,
                                      fontSize: 12,
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
                    ],

                    const SizedBox(height: 24),

                    if ((hospital.doctorCount ?? 0) > 0)
                      _buildLinkRow(
                        label: l10n.doctorsHere(hospital.doctorCount!),
                        onTap: () => context.push(
                          '/doctors?facility_id=${hospital.id}&facility_name=${Uri.encodeComponent(hospital.displayName)}',
                        ),
                      ),
                    if ((hospital.testCount ?? 0) > 0)
                      _buildLinkRow(
                        label: l10n.testsHere(hospital.testCount!),
                        onTap: () => context.push(
                          '/tests?location_id=${hospital.id}&location_name=${Uri.encodeComponent(hospital.displayName)}',
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallRow(
    BuildContext context, {
    required String label,
    required String phone,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => launchPhone(phone),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(
              color: AppColors.ink,
              width: AppColors.borderWidth,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.phone, size: 16, color: AppColors.ink),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.kicker.copyWith(fontSize: 10),
                ),
              ),
              Text(
                phone,
                style: const TextStyle(
                  fontFamily: AppTypography.fontMono,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkRow({
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.paper,
            border: Border.all(
              color: AppColors.ink,
              width: AppColors.borderWidth,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: AppTypography.bodyMedium),
              ),
              const Icon(Icons.chevron_right, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}
