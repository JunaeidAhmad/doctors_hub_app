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
import '../../bookings/domain/models/booking_item.dart';

final lastBookingSuccessProvider = StateProvider<BookingItem?>((ref) => null);

class BookingSuccessScreen extends ConsumerWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(lastBookingSuccessProvider);
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';

    return DhScaffold(
      statusBarColor: AppColors.accent,
      statusBarIconBrightness: Brightness.light,
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Red Status Top Banner
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
                      border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.accent,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isBn ? 'বুকিং সফল হয়েছে!' : 'You\'re booked!',
                    style: const TextStyle(
                      fontFamily: AppTypography.fontArchivo,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.paper,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isBn
                        ? 'আপনার মোবাইল নম্বরে কনফার্মেশন পাঠানো হয়েছে।'
                        : 'Details have been sent to your mobile via SMS.',
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

            // Booking Details Card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        border: Border.all(color: AppColors.ink, width: AppColors.borderWidth),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reference & Serial
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isBn ? 'বুকিং রেফারেন্স' : 'BOOKING REF',
                                    style: AppTypography.kicker.copyWith(
                                      color: AppColors.muted,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking?.bookingRef ?? 'DH-78291',
                                    style: const TextStyle(
                                      fontFamily: AppTypography.fontMono,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                              if (booking?.serialDisplay != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
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
                                        booking!.serialDisplay!,
                                        style: const TextStyle(
                                          fontFamily: AppTypography.fontMono,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accentDeep,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: AppColors.lineSoft, height: 1),
                          const SizedBox(height: 16),

                          _buildDetailRow(
                            label: isBn ? 'রোগী' : 'FOR',
                            value: booking?.patientName ?? 'Patient',
                            subValue: booking?.patientPhone != null
                                ? '+88 ${booking!.patientPhone}'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            label: isBn ? 'অ্যাপয়েন্টমেন্ট' : 'AT',
                            value: booking?.title ?? 'Doctor Visit',
                            subValue: '${booking?.subtitle ?? ''} · ${booking?.facilityName ?? ''}',
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            label: isBn ? 'তারিখ ও সময়' : 'WHEN',
                            value: booking != null
                                ? '${DateFormat('EEE, d MMM yyyy').format(booking.appointmentDate)} — ${booking.timeSlot}'
                                : 'Today',
                          ),
                          const SizedBox(height: 14),
                          _buildDetailRow(
                            label: isBn ? 'পেমেন্ট' : 'PAY',
                            value: booking?.paymentMethod == 'online'
                                ? (isBn ? 'অনলাইনে পরিশোধিত' : 'Paid online')
                                : (isBn ? 'চেম্বারে সরাসরি পরিশোধ' : 'Pay at counter'),
                            subValue: booking != null
                                ? CurrencyFormatter.format(booking.fee, locale: isBn ? 'bn' : 'en')
                                : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Contextual note
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppColors.fill,
                        border: Border(
                          left: BorderSide(color: AppColors.ink, width: 3),
                        ),
                      ),
                      child: Text(
                        isBn
                            ? 'অনুগ্রহ করে নির্ধারিত সময়ের ১৫ মিনিট পূর্বে উপস্থিত থাকুন। প্রয়োজনে চেম্বারের সাথে যোগাযোগ করুন।'
                            : 'Please arrive 15 minutes before your scheduled appointment time.',
                        style: AppTypography.secondary.copyWith(color: AppColors.ink),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // See my bookings
                    PrimaryCtaButton(
                      label: isBn ? 'আমার বুকিং দেখুন' : 'See my bookings',
                      trailingIcon: '→',
                      onPressed: () {
                        context.go('/bookings');
                      },
                    ),

                    const SizedBox(height: 12),

                    // Back to home
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        side: const BorderSide(color: AppColors.ink, width: AppColors.borderWidth),
                        backgroundColor: AppColors.paper,
                      ),
                      onPressed: () {
                        context.go('/');
                      },
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
        if (subValue != null) ...[
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
