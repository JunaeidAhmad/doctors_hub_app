import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/slot_generator.dart';
import '../../../core/widgets/date_strip.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/radio_row.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../../../core/widgets/slot_grid.dart';
import '../../../core/widgets/sticky_cta_bar.dart';
import '../../doctors/domain/models/affiliation.dart';
import '../../doctors/presentation/doctor_profile_screen.dart';

class DoctorBookingStep1Screen extends ConsumerStatefulWidget {
  const DoctorBookingStep1Screen({
    super.key,
    required this.doctorId,
    this.initialAffiliationId,
  });

  final String doctorId;
  final String? initialAffiliationId;

  @override
  ConsumerState<DoctorBookingStep1Screen> createState() =>
      _DoctorBookingStep1ScreenState();
}

class _DoctorBookingStep1ScreenState
    extends ConsumerState<DoctorBookingStep1Screen> {
  DoctorAffiliation? _selectedAffiliation;
  DateTime _selectedDate = DateTime.now();
  TimeSlot? _selectedSlot;

  List<DateStripItem> _dateStripItems = [];
  List<ShiftSlotGroup> _slotGroups = [];

  @override
  void initState() {
    super.initState();
    _initDates();
  }

  void _initDates() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _rebuildDateStrip();
  }

  void _rebuildDateStrip() {
    final schedules = _selectedAffiliation?.schedules ?? [];
    final items = <DateStripItem>[];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      final isAvailable = schedules.isEmpty ||
          SlotGenerator.isChamberAvailableOnDate(schedules, date);
      items.add(DateStripItem(date: date, isAvailable: isAvailable));
    }

    _dateStripItems = items;

    // If current selected date is not available, pick first available date
    final currAvailable = schedules.isEmpty ||
        SlotGenerator.isChamberAvailableOnDate(schedules, _selectedDate);
    if (!currAvailable) {
      final firstAvail = items.firstWhere(
        (it) => it.isAvailable,
        orElse: () => items.first,
      );
      _selectedDate = firstAvail.date;
    }

    _rebuildSlots();
  }

  void _rebuildSlots() {
    final schedules = _selectedAffiliation?.schedules ?? [];
    _slotGroups = SlotGenerator.generateSlotsForDate(
      schedules: schedules,
      date: _selectedDate,
    );
    _selectedSlot = null;
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorDetailsProvider(widget.doctorId));
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';

    return doctorAsync.when(
      data: (doctor) {
        if (_selectedAffiliation == null && doctor.affiliations.isNotEmpty) {
          if (widget.initialAffiliationId != null) {
            _selectedAffiliation = doctor.affiliations.firstWhere(
              (a) => a.id == widget.initialAffiliationId,
              orElse: () => doctor.affiliations.first,
            );
          } else {
            _selectedAffiliation = doctor.affiliations.first;
          }
          _rebuildDateStrip();
        }

        final canContinue = _selectedAffiliation != null && _selectedSlot != null;

        final formattedDate = DateFormat('EEE d MMM').format(_selectedDate);
        final ctaSubtitle = _selectedSlot != null
            ? '$formattedDate — ${_selectedSlot!.displayLabel}'
            : (isBn ? 'সময় নির্বাচন করুন' : 'Select a time slot');

        return DhScaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header bar
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
                      Text(
                        isBn ? 'ধাপ ১ / ২: স্থান ও সময়' : 'Step 1 of 2: Where & when',
                        style: AppTypography.h2.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Kicker(isBn ? 'ধাপ ১ / ২' : 'STEP 1 OF 2'),
                        const SizedBox(height: 4),
                        Text(
                          isBn ? 'স্থান ও সময় নির্বাচন' : 'Where and when?',
                          style: AppTypography.h1.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 20),

                        // Section 1: Chambers
                        Text(
                          isBn ? 'চেম্বার নির্বাচন করুন' : 'Select chamber',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        ...doctor.affiliations.map((aff) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RadioRow<DoctorAffiliation>(
                              value: aff,
                              groupValue: _selectedAffiliation,
                              title: aff.fullDisplayName,
                              subtitle: aff.addressLine,
                              fee: '৳${aff.fee.toInt()}',
                              onChanged: (val) {
                                setState(() {
                                  _selectedAffiliation = val;
                                  _rebuildDateStrip();
                                });
                              },
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        // Section 2: Date Strip
                        Text(
                          isBn ? 'তারিখ নির্বাচন করুন' : 'Select date',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        DateStrip(
                          dates: _dateStripItems,
                          selectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                              _rebuildSlots();
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // Section 3: Time Slot Grid
                        Text(
                          isBn ? 'সময় নির্বাচন করুন' : 'Select appointment time',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        SlotGrid(
                          groups: _slotGroups,
                          selectedSlot: _selectedSlot?.timeString,
                          onSlotSelected: (slot) {
                            setState(() => _selectedSlot = slot);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Bar
                StickyCtaBar(
                  kicker: isBn ? 'নির্বাচিত সময়' : 'SELECTED TIME',
                  subtitle: ctaSubtitle,
                  buttonLabel: isBn ? 'পরবর্তী ধাপ' : 'Continue',
                  isEnabled: canContinue,
                  onPressed: () {
                    if (!canContinue) return;
                    final queryParams = {
                      'chamber': _selectedAffiliation!.id,
                      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
                      'slot': _selectedSlot!.timeString,
                      'displaySlot': _selectedSlot!.displayLabel,
                    };
                    context.push(
                      Uri(
                        path: '/doctors/${doctor.id}/confirm',
                        queryParameters: queryParams,
                      ).toString(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const DhScaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonRow(height: 120),
                SizedBox(height: 16),
                SkeletonRow(height: 72),
                SizedBox(height: 16),
                SkeletonRow(height: 120),
              ],
            ),
          ),
        ),
      ),
      error: (err, _) => DhScaffold(
        body: SafeArea(
          child: ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(doctorDetailsProvider(widget.doctorId)),
          ),
        ),
      ),
    );
  }
}
