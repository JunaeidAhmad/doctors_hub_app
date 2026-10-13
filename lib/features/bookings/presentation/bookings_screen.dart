import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/phone_launcher.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../l10n/app_localizations.dart';
import '../../booking/domain/models/booking_result.dart';
import '../domain/models/booking_item.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    BookingItem booking,
    bool isBn,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final facilityPhone = booking.facilityPhone;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.paper,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            isBn ? 'অ্যাপয়েন্টমেন্ট বাতিল' : 'Cancel Appointment',
            style: AppTypography.h2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.toCancelCall(booking.facilityName),
                style: AppTypography.body,
              ),
              if (facilityPhone != null && facilityPhone.isNotEmpty) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => launchPhone(facilityPhone),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    color: AppColors.fill,
                    child: Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: AppColors.ink),
                        const SizedBox(width: 8),
                        Text(
                          facilityPhone,
                          style: const TextStyle(
                            fontFamily: AppTypography.fontMono,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                isBn
                    ? 'আপনি চাইলে এই ফোন থেকে এই রেকর্ডটি মুছে ফেলতে পারেন।'
                    : 'You can remove this booking record from your phone.',
                style: AppTypography.secondary,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                isBn ? 'বন্ধ করুন' : 'Close',
                style: const TextStyle(
                  fontFamily: AppTypography.fontArchivo,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.paper,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                ref.read(localBookingsProvider.notifier).removeBooking(booking.id);
                Navigator.pop(context);
              },
              child: Text(
                isBn ? 'ফোন থেকে মুছুন' : 'Remove from phone',
                style: const TextStyle(
                  fontFamily: AppTypography.fontArchivo,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _statusTag(BookingItem booking, AppLocalizations l10n) {
    if (booking.status == BookingStatus.confirmed &&
        booking.type == 'doctor') {
      return l10n.statusConfirmedTag;
    }
    if (booking.status == BookingStatus.pending) {
      if (booking.type == 'doctor') return l10n.awaitingConfirmationTag;
      if (booking.type == 'test') return l10n.awaitingLabTag;
      if (booking.type == 'service') return l10n.awaitingHospitalTag;
    }
    return null;
  }

  bool _isPastDeadline(BookingItem booking) {
    final deadline = booking.confirmDeadline;
    if (booking.status != BookingStatus.pending ||
        booking.type != 'doctor' ||
        deadline == null ||
        deadline.isEmpty) {
      return false;
    }
    final parsed = DateTime.tryParse(deadline);
    return parsed != null && parsed.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(localBookingsProvider);
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';

    final upcomingCount = bookings.where((b) => b.isUpcoming).length;

    return DhScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header
            Container(
              color: AppColors.paper,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Kicker(
                    isBn
                        ? '$upcomingCount টি আসন্ন অ্যাপয়েন্টমেন্ট'
                        : '$upcomingCount UPCOMING BOOKINGS',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn ? 'আমার বুকিংসমূহ' : 'My Bookings',
                    style: AppTypography.h1.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBn ? 'এই ফোনে সংরক্ষিত' : 'Saved on this phone',
                    style: AppTypography.secondary,
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.ink, height: 1),

            // Content
            Expanded(
              child: bookings.isEmpty
                  ? EmptyState(
                      icon: Icons.calendar_today_outlined,
                      title: isBn ? 'কোন বুকিং নেই' : 'No bookings yet',
                      message: isBn
                          ? 'আপনার বুক করা সকল ডাক্তার ও টেস্ট এখানে দেখতে পাবেন।'
                          : 'Bookings you make will be saved here on your device.',
                      actionLabel: isBn ? 'ডাক্তার খুঁজুন' : 'Find a doctor',
                      onAction: () => context.go('/doctors'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return _buildBookingCard(context, ref, booking, isBn);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    WidgetRef ref,
    BookingItem booking,
    bool isBn,
  ) {
    final isDoctor = booking.type == 'doctor';
    final isUpcoming = booking.isUpcoming;

    final dateDayName = DateFormat('EEE').format(booking.appointmentDate).toUpperCase();
    final dateDayNum = DateFormat('d').format(booking.appointmentDate);
    final dateMonth = DateFormat('MMM').format(booking.appointmentDate).toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(
          color: isUpcoming ? AppColors.ink : AppColors.lineSoft,
          width: AppColors.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header: Type Tag & Ref
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isUpcoming ? AppColors.fill : AppColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      color: isDoctor ? AppColors.accentWash : AppColors.fill,
                      child: Text(
                        isDoctor
                            ? (isBn ? 'ডাক্তার অ্যাপয়েন্টমেন্ট' : 'DOCTOR VISIT')
                            : booking.type == 'service'
                                ? (isBn ? 'হাসপাতাল সেবা' : 'HOSPITAL SERVICE')
                                : (isBn ? 'ল্যাব টেস্ট' : 'LAB TEST'),
                        style: TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDoctor ? AppColors.accentDeep : AppColors.ink,
                        ),
                      ),
                    ),
                    if (booking.status == BookingStatus.confirmed &&
                        booking.type == 'doctor' &&
                        booking.serialDisplay != null &&
                        booking.serialDisplay!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        booking.serialDisplay!,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                    if (_statusTag(booking, AppLocalizations.of(context)!) !=
                        null) ...[
                      const SizedBox(width: 8),
                      Text(
                        _statusTag(booking, AppLocalizations.of(context)!)!,
                        style: AppTypography.tag.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  booking.bookingRef,
                  style: const TextStyle(
                    fontFamily: AppTypography.fontMono,
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.lineSoft, height: 1),

          // Main Info with Date Tile
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Tile
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isUpcoming ? AppColors.paper : AppColors.fillOff,
                    border: Border.all(
                      color: isUpcoming ? AppColors.ink : AppColors.lineSoft,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dateMonth,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      Text(
                        dateDayNum,
                        style: TextStyle(
                          fontFamily: AppTypography.fontArchivo,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isUpcoming ? AppColors.ink : AppColors.mutedLight,
                        ),
                      ),
                      Text(
                        dateDayName,
                        style: const TextStyle(
                          fontFamily: AppTypography.fontMono,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.title,
                        style: AppTypography.h2.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking.subtitle} · ${booking.facilityName}',
                        style: AppTypography.secondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              booking.estimatedTime == null ||
                                      booking.estimatedTime!.isEmpty
                                  ? booking.timeSlot
                                  : '${booking.timeSlot} · ${AppLocalizations.of(context)!.approxTime(booking.estimatedTime!)}',
                              style: AppTypography.bodyMedium
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      if (_isPastDeadline(booking)) ...[
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context)!.notConfirmedInTime,
                          style: AppTypography.tagAccent,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        'For: ${booking.patientName} (${booking.patientPhone})',
                        style: AppTypography.secondary.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.lineSoft, height: 1),

          // Bottom Action: Fee & Cancel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (booking.fee != null)
                  Text(
                    isBn
                        ? 'ফি: ${CurrencyFormatter.format(booking.fee, locale: 'bn')}'
                        : 'Fee: ${CurrencyFormatter.format(booking.fee, locale: 'en')}',
                    style: AppTypography.secondaryBold
                        .copyWith(color: AppColors.accent),
                  )
                else
                  const SizedBox.shrink(),
                InkWell(
                  onTap: () => _showCancelDialog(context, ref, booking, isBn),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      isBn ? 'বাতিল করুন' : 'Cancel',
                      style: const TextStyle(
                        fontFamily: AppTypography.fontArchivo,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
