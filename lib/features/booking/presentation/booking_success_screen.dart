import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/primary_cta_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../bookings/domain/models/booking_item.dart';
import '../domain/models/booking_result.dart';

final lastBookingSuccessProvider = StateProvider<BookingItem?>((ref) => null);

class BookingSuccessScreen extends ConsumerWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(lastBookingSuccessProvider);
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';
    final l10n = AppLocalizations.of(context)!;

    if (booking == null) {
      return DhScaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.bookingNotFound, style: AppTypography.h2),
            ),
          ),
        ),
      );
    }

    final isConfirmedDoctor = booking.type == 'doctor' &&
        booking.status == BookingStatus.confirmed;
    return DhScaffold(
      statusBarColor: AppColors.accent,
      statusBarIconBrightness: Brightness.light,
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      border: Border.all(
                        color: AppColors.ink,
                        width: AppColors.borderWidth,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.accent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _headline(l10n, booking),
                    style: const TextStyle(
                      fontFamily: AppTypography.fontArchivo,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.paper,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subHeadline(l10n, booking),
                    style: const TextStyle(
                      fontFamily: AppTypography.fontArchivo,
                      fontSize: 13,
                      color: AppColors.paper,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        border: Border.all(
                          color: AppColors.ink,
                          width: AppColors.borderWidth,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.bookingIdLabel.toUpperCase(),
                                    style: AppTypography.kicker.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.bookingRef,
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontMono,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              if (isConfirmedDoctor &&
                                  booking.serialDisplay != null &&
                                  booking.serialDisplay!.isNotEmpty)
                                _buildSerialBadge(booking.serialDisplay!, isBn),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.lineSoft, height: 1),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            label: isBn ? 'রোগী' : 'FOR',
                            value: booking.patientName,
                            subValue: booking.patientPhone.isNotEmpty
                                ? '+88 ${booking.patientPhone}'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            label: isBn ? 'অ্যাপয়েন্টমেন্ট' : 'AT',
                            value: booking.title,
                            subValue: booking.type == 'doctor'
                                ? booking.facilityName
                                : (booking.subtitle.isNotEmpty
                                    ? booking.subtitle
                                    : booking.facilityName),
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            label: isBn ? 'তারিখ' : 'DATE',
                            value: DateFormat('EEE, d MMM yyyy')
                                .format(booking.appointmentDate),
                            subValue: _timeLine(booking),
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            label: isBn ? 'পেমেন্ট' : 'PAY',
                            value: booking.paymentMethod == 'online'
                                ? (isBn ? 'অনলাইনে পরিশোধিত' : 'Paid online')
                                : (isBn
                                    ? 'চেম্বারে সরাসরি পরিশোধ'
                                    : 'Pay at counter'),
                            subValue: booking.fee == null
                                ? null
                                : CurrencyFormatter.format(
                                    booking.fee,
                                    locale: isBn ? 'bn' : 'en',
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_note(l10n, booking) != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: AppColors.fill,
                          border: Border(
                            left: BorderSide(color: AppColors.ink, width: 3),
                          ),
                        ),
                        child: Text(
                          _note(l10n, booking)!,
                          style: AppTypography.secondary
                              .copyWith(color: AppColors.ink),
                        ),
                      ),
                    const SizedBox(height: 24),
                    PrimaryCtaButton(
                      label: isBn ? 'আমার বুকিং দেখুন' : 'See my bookings',
                      trailingIcon: '→',
                      onPressed: () => context.go('/bookings'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        side: const BorderSide(
                          color: AppColors.ink,
                          width: AppColors.borderWidth,
                        ),
                        backgroundColor: AppColors.paper,
                      ),
                      onPressed: () => context.go('/'),
                      child: Text(
                        isBn ? 'হোমে ফিরে যান' : 'Back to home',
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _headline(AppLocalizations l10n, BookingItem booking) {
    if (booking.status == BookingStatus.confirmed) return l10n.confirmedTitle;
    if (booking.status == BookingStatus.pending) {
      return l10n.requestSentTitle;
    }
    return l10n.bookedSuccessTitle;
  }

  String _subHeadline(AppLocalizations l10n, BookingItem booking) {
    if (booking.status == BookingStatus.confirmed) {
      if (booking.serialDisplay == null || booking.serialDisplay!.isEmpty) {
        return l10n.serialBySms;
      }
      return l10n.sessionWindow(
        _formatTime(booking.sessionStart),
        _formatTime(booking.sessionEnd),
      );
    }
    if (booking.status == BookingStatus.pending && booking.type == 'doctor') {
      return l10n.requestWillCall(booking.facilityName, booking.patientPhone);
    }
    if (booking.type == 'test') {
      return l10n.labWillContact;
    }
    return l10n.serviceRequestReceived(booking.facilityName);
  }

  String? _note(AppLocalizations l10n, BookingItem booking) {
    if (booking.status == BookingStatus.pending &&
        booking.type == 'doctor' &&
        booking.confirmDeadline != null) {
      final deadline = _formatDeadline(booking.confirmDeadline!);
      final urgent =
          booking.isUrgent ? ' — ${l10n.beforeSessionStarts}' : '';
      return '${l10n.expectCallBy(deadline)}$urgent';
    }
    if (booking.status == BookingStatus.confirmed) {
      return l10n.successNote;
    }
    return null;
  }

  String? _timeLine(BookingItem booking) {
    final parts = <String>[];
    if (booking.timeSlot.isNotEmpty) parts.add(booking.timeSlot);
    if (booking.estimatedTime != null && booking.estimatedTime!.isNotEmpty) {
      parts.add('approx. ${_formatTime(booking.estimatedTime)}');
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return '';
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateFormat('h:mm a').format(DateTime(2000, 1, 1, hour, minute));
  }

  String _formatDeadline(String iso) {
    try {
      final parsed = DateTime.parse(iso);
      return DateFormat('EEE d MMM, h:mm a').format(parsed);
    } catch (_) {
      return iso;
    }
  }

  Widget _buildSerialBadge(String serial, bool isBn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentWash,
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            isBn ? 'সিরিয়াল' : 'SERIAL',
            style: AppTypography.kicker.copyWith(fontSize: 9),
          ),
          Text(
            serial,
            style: const TextStyle(
              fontFamily: AppTypography.fontMono,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.accentDeep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    String? subValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.kicker.copyWith(
            color: AppColors.muted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(fontSize: 14),
        ),
        if (subValue != null && subValue.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subValue,
            style: AppTypography.secondary,
          ),
        ],
      ],
    );
  }
}
