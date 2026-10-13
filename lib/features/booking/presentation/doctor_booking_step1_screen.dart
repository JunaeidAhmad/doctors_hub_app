import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/dhaka_time.dart';
import '../../../core/widgets/date_strip.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/radio_row.dart';
import '../../../core/widgets/skeleton_row.dart';
import '../../../core/widgets/sticky_cta_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../doctors/domain/models/availability.dart';
import '../../doctors/domain/models/chamber.dart';
import '../../doctors/presentation/doctor_profile_screen.dart';
import '../domain/booking_mode.dart';

class DoctorBookingStep1Screen extends ConsumerStatefulWidget {
  const DoctorBookingStep1Screen({
    super.key,
    required this.doctorId,
    this.initialChamberId,
  });

  final String doctorId;
  final String? initialChamberId;

  @override
  ConsumerState<DoctorBookingStep1Screen> createState() =>
      _DoctorBookingStep1ScreenState();
}

class _DoctorBookingStep1ScreenState extends ConsumerState<DoctorBookingStep1Screen>
    with RouteAware {
  Chamber? _selectedChamber;
  AffiliationAvailability? _availability;
  AvailabilityDate? _selectedDate;
  AvailabilitySession? _selectedSession;
  bool _isLoadingAvailability = false;
  String? _availabilityError;
  String? _loadedForChamberId;
  bool _didInitChamber = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Step 2 popped back: refresh availability so a just-booked session
    // doesn't look open.
    final chamber = _selectedChamber;
    if (chamber != null) {
      _loadAvailability(chamber);
    }
  }

  Future<void> _loadAvailability(Chamber chamber) async {
    setState(() {
      _isLoadingAvailability = true;
      _availabilityError = null;
      _selectedSession = null;
      _loadedForChamberId = chamber.id;
    });

    try {
      final repo = ref.read(doctorRepositoryProvider);
      final days = math.min(chamber.advanceBookingDays ?? 14, 14);
      final availability = await repo.getAvailability(
        chamber.id,
        from: DhakaTime.todayIso(),
        days: days,
      );
      if (!mounted || _loadedForChamberId != chamber.id) return;
      setState(() {
        _availability = availability;
        _isLoadingAvailability = false;
        _selectedDate = _firstAvailableDate(availability);
      });
    } catch (e) {
      if (!mounted || _loadedForChamberId != chamber.id) return;
      setState(() {
        _isLoadingAvailability = false;
        _availabilityError = e.toString();
      });
    }
  }

  AvailabilityDate? _firstAvailableDate(AffiliationAvailability availability) {
    for (final date in availability.dates) {
      if (date.isBookable) return date;
    }
    return availability.dates.isNotEmpty ? availability.dates.first : null;
  }

  void _selectChamber(Chamber chamber) {
    setState(() {
      _selectedChamber = chamber;
      _availability = null;
      _selectedDate = null;
    });
    _loadAvailability(chamber);
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorDetailsProvider(widget.doctorId));
    final locale = ref.watch(localeProvider);
    final isBn = locale.languageCode == 'bn';
    final l10n = AppLocalizations.of(context)!;

    return doctorAsync.when(
      data: (doctor) {
        if (!_didInitChamber && doctor.chambers.isNotEmpty) {
          _didInitChamber = true;
          final initial = widget.initialChamberId == null
              ? null
              : doctor.chambers
                  .where((c) => c.id == widget.initialChamberId)
                  .firstOrNull;
          final bookable = doctor.chambers
              .where((c) => bookingModeView(c).canBook)
              .toList();
          final selected =
              (initial != null && bookingModeView(initial).canBook)
                  ? initial
                  : (bookable.isNotEmpty ? bookable.first : doctor.chambers.first);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _selectChamber(selected);
          });
        }

        if (doctor.chambers.isEmpty) {
          return DhScaffold(
            body: SafeArea(
              child: EmptyState(
                title: l10n.noChambers,
                message: l10n.noChambersDesc,
                actionLabel: l10n.goBack,
                onAction: () => context.pop(),
              ),
            ),
          );
        }

        return DhScaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isBn, l10n),
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
                        Text(
                          isBn ? 'চেম্বার নির্বাচন করুন' : 'Select chamber',
                          style: AppTypography.h2.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        ...doctor.chambers.map(_buildChamberRow),
                        const SizedBox(height: 24),
                        if (_isLoadingAvailability)
                          const Column(
                            children: [
                              SkeletonRow(height: 72),
                              SizedBox(height: 12),
                              SkeletonRow(height: 120),
                            ],
                          )
                        else if (_availabilityError != null)
                          ErrorState(
                            message: _availabilityError!,
                            onRetry: () {
                              final chamber = _selectedChamber;
                              if (chamber != null) _loadAvailability(chamber);
                            },
                          )
                        else if (_availability != null)
                          _buildDateAndSessions(context, isBn, l10n),
                      ],
                    ),
                  ),
                ),
                if (_selectedChamber != null &&
                    bookingModeView(_selectedChamber!).canBook)
                  StickyCtaBar(
                    kicker: isBn ? 'নির্বাচিত সময়' : 'SELECTED TIME',
                    subtitle: _ctaSubtitle(context, isBn, l10n),
                    buttonLabel: isBn ? 'পরবর্তী ধাপ' : 'Continue',
                    isEnabled: _selectedSession != null,
                    onPressed: _selectedSession == null
                        ? null
                        : () => _continueToStep2(doctor.id),
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

  Widget _buildHeader(BuildContext context, bool isBn, AppLocalizations l10n) {
    return Container(
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
          const SizedBox(width: 8),
          Text(
            isBn ? 'ধাপ ১ / ২: স্থান ও সময়' : 'Step 1 of 2: Where & when',
            style: AppTypography.h2.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChamberRow(Chamber chamber) {
    final l10n = AppLocalizations.of(context)!;
    final view = bookingModeView(chamber);
    final badge = bookingModeLabel(view.badgeKey, l10n);
    final isSelected = _selectedChamber?.id == chamber.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadioRow<Chamber>(
            value: chamber,
            groupValue: _selectedChamber,
            title: chamber.fullDisplayName,
            subtitle: chamber.facility.address,
            badge: badge,
            fee: chamber.fee == null ? null : '৳${chamber.fee!.toInt()}',
            onChanged: (value) {
              if (!view.canBook) return;
              if (isSelected) return;
              _selectChamber(value);
            },
          ),
          if (view.mode == BookingMode.callOnly)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => context.push(
                  '/doctors/${widget.doctorId}/call?chamber=${chamber.id}',
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    border: Border.all(
                      color: AppColors.ink,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    l10n.ctaGetPhoneNumber,
                    style: const TextStyle(
                      fontFamily: AppTypography.fontArchivo,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.paper,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateAndSessions(
    BuildContext context,
    bool isBn,
    AppLocalizations l10n,
  ) {
    final availability = _availability!;
    final selectedDate = _selectedDate;
    final items = availability.dates.map((date) {
      final dateTime = DateTime.parse(date.date);
      String? label;
      if (date.status == AvailabilityDateStatus.full) {
        label = l10n.sessionFull;
      } else if (!date.hasSchedule ||
          date.status == AvailabilityDateStatus.closed ||
          date.status == AvailabilityDateStatus.ended) {
        label = l10n.notAtChamberToday;
      }
      return DateStripItem(
        date: dateTime,
        isAvailable: date.isBookable,
        label: label,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isBn ? 'তারিখ নির্বাচন করুন' : 'Select date',
          style: AppTypography.h2.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        DateStrip(
          dates: items,
          selectedDate: selectedDate == null ? null : DateTime.parse(selectedDate.date),
          onDateSelected: (date) {
            final match = availability.dates.firstWhere(
              (d) => d.date == DhakaTime.isoDate(date),
              orElse: () => availability.dates.first,
            );
            setState(() {
              _selectedDate = match;
              _selectedSession = null;
            });
          },
        ),
        const SizedBox(height: 24),
        Text(
          isBn ? 'সেশন নির্বাচন করুন' : 'Select session',
          style: AppTypography.h2.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (selectedDate == null || selectedDate.sessions.isEmpty)
          Text(
            l10n.noSessionsForDay,
            style: AppTypography.secondary,
          )
        else
          ...selectedDate.sessions.map(
            (session) => _buildSessionRow(selectedDate, session, isBn, l10n),
          ),
      ],
    );
  }

  Widget _buildSessionRow(
    AvailabilityDate date,
    AvailabilitySession session,
    bool isBn,
    AppLocalizations l10n,
  ) {
    final mode = _selectedChamber?.bookingMode ?? BookingMode.unknown;
    final view = bookingModeView(_selectedChamber ?? const Chamber.empty());
    final isSelected = _selectedSession?.sessionKey == session.sessionKey;
    final window = _formatWindow(session);

    String? disabledReason;
    if (!session.isAvailable) {
      switch (session.status) {
        case AvailabilitySessionStatus.full:
          disabledReason = l10n.sessionFull;
          break;
        case AvailabilitySessionStatus.ended:
          disabledReason = l10n.sessionEnded;
          break;
        case AvailabilitySessionStatus.closed:
          disabledReason = l10n.sessionClosed;
          break;
        case AvailabilitySessionStatus.unknown:
        case AvailabilitySessionStatus.available:
          disabledReason = null;
          break;
      }
    } else if (mode == BookingMode.request &&
        DhakaTime.startsWithinHour(
          now: DateTime.now().toUtc(),
          dateIso: date.date,
          sessionStart:
              session.sessionStart.isNotEmpty ? session.sessionStart : session.startTime,
        )) {
      disabledReason = l10n.tooLateToRequest;
    }

    final isDisabled = disabledReason != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: isDisabled
            ? null
            : () => setState(() => _selectedSession = session),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentWash : AppColors.paper,
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.ink,
              width: AppColors.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_shiftLabel(session, l10n)} · $window',
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                  if (view.showSeatCounts && session.isAvailable)
                    Text(
                      l10n.sessionSeatsLeft(session.remaining),
                      style: AppTypography.secondaryBold,
                    ),
                ],
              ),
              if (view.showSerial &&
                  session.isAvailable &&
                  session.nextSerial != null) ...[
                const SizedBox(height: 4),
                Text(
                  [
                    l10n.nextSerialNumber(session.nextSerial!),
                    if (session.estimatedTime.isNotEmpty)
                      l10n.approxTime(_formatHm(session.estimatedTime)),
                    if (view.showSeatCounts)
                      l10n.sessionSeatsLeft(session.remaining),
                  ].join(' · '),
                  style: AppTypography.secondary,
                ),
              ] else if (view.showSeatCounts &&
                  session.isAvailable &&
                  mode == BookingMode.request) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.sessionSeatsLeft(session.remaining),
                  style: AppTypography.secondary,
                ),
              ],
              if (session.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(session.note, style: AppTypography.secondary),
              ],
              if (disabledReason != null) ...[
                const SizedBox(height: 4),
                Text(
                  disabledReason,
                  style: AppTypography.tagAccent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _shiftLabel(AvailabilitySession session, AppLocalizations l10n) {
    final start = session.sessionStart.isNotEmpty
        ? session.sessionStart
        : session.startTime;
    final hour = int.tryParse(start.split(':').first) ?? 0;
    return hour < 12 ? l10n.morningSession : l10n.eveningSession;
  }

  String _formatHm(String time) {
    final parts = time.split(':');
    if (parts.isEmpty) return time;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    final date = DateTime(2000, 1, 1, hour, minute);
    return DateFormat('h:mm a').format(date);
  }

  String _formatWindow(AvailabilitySession session) {
    final start = session.sessionStart.isNotEmpty
        ? session.sessionStart
        : session.startTime;
    final end = session.sessionEnd.isNotEmpty ? session.sessionEnd : session.endTime;
    return '${_formatHm(start)}–${_formatHm(end)}';
  }

  String _ctaSubtitle(
    BuildContext context,
    bool isBn,
    AppLocalizations l10n,
  ) {
    final session = _selectedSession;
    final date = _selectedDate;
    if (session == null || date == null) {
      return l10n.selectASession;
    }
    final dateLabel = DateFormat('EEE d').format(DateTime.parse(date.date));
    return '$dateLabel · ${_formatWindow(session)}';
  }

  void _continueToStep2(String doctorId) {
    final chamber = _selectedChamber!;
    final session = _selectedSession!;
    final date = _selectedDate!;
    context.push(
      Uri(
        path: '/doctors/$doctorId/confirm',
        queryParameters: {
          'chamber': chamber.id,
          'date': date.date,
          'session_key': session.sessionKey,
          'displaySlot': _formatWindow(session),
        },
      ).toString(),
    );
  }
}
