import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/date_strip.dart';
import '../../../core/widgets/dh_dropdown.dart';
import '../../../core/widgets/dh_scaffold.dart';
import '../../../core/widgets/dh_search_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/filter_chip_dark.dart';
import '../../../core/widgets/ink_border_box.dart';
import '../../../core/widgets/kicker.dart';
import '../../../core/widgets/photo_placeholder.dart';
import '../../../core/widgets/primary_cta_button.dart';
import '../../../core/widgets/radio_row.dart';
import '../../../core/widgets/rule_grid.dart';
import '../../../core/widgets/skeleton_row.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String? _dropdownVal = '1';
  int _radioVal = 1;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return DhScaffold(
      appBar: AppBar(
        title: const Text('Design System Gallery'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Kicker('KICKER COMPONENT'),
            const SizedBox(height: 8),
            const Text('H1 Heading 32/800', style: AppTypography.h1),
            const SizedBox(height: 8),
            const Text('H2 Heading 18/800', style: AppTypography.h2),
            const SizedBox(height: 8),
            const Text('Body regular text 15/400', style: AppTypography.body),
            const SizedBox(height: 8),
            const Text('Secondary muted text 13/400', style: AppTypography.secondary),
            const SizedBox(height: 16),

            const Kicker('BUTTONS & CONTROLS'),
            const SizedBox(height: 10),
            PrimaryCtaButton(
              label: 'Primary CTA Button',
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            PrimaryCtaButton(
              label: 'Disabled CTA Button',
              isEnabled: false,
              onPressed: () {},
            ),
            const SizedBox(height: 16),

            const Kicker('SEARCH & DROPDOWNS'),
            const SizedBox(height: 10),
            const DhSearchField(hintText: 'Search field placeholder...'),
            const SizedBox(height: 10),
            DhDropdown<String>(
              value: _dropdownVal,
              items: const [
                DhDropdownItem(value: '1', label: 'Dhaka Division'),
                DhDropdownItem(value: '2', label: 'Chattogram Division'),
              ],
              onChanged: (val) => setState(() => _dropdownVal = val),
            ),
            const SizedBox(height: 16),

            const Kicker('CHIPS & TAGS'),
            const SizedBox(height: 10),
            Row(
              children: [
                FilterChipDark(
                  label: 'Dhaka',
                  onDeleted: () {},
                ),
                const SizedBox(width: 8),
                DhSelectChip(
                  label: 'Hospital',
                  isSelected: true,
                  onSelected: (_) {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Kicker('PHOTO PLACEHOLDER'),
            const SizedBox(height: 10),
            const Row(
              children: [
                PhotoPlaceholder(name: 'A B Siddique', width: 64, height: 64),
                SizedBox(width: 12),
                PhotoPlaceholder(name: 'Popular Diagnostic', width: 64, height: 64),
              ],
            ),
            const SizedBox(height: 16),

            const Kicker('RADIO ROW'),
            const SizedBox(height: 10),
            RadioRow<int>(
              value: 1,
              groupValue: _radioVal,
              title: 'Popular Diagnostic Centre, Dhanmondi',
              subtitle: 'House 16, Road 2, Dhanmondi',
              fee: '৳1200',
              onChanged: (val) => setState(() => _radioVal = val),
            ),
            const SizedBox(height: 16),

            const Kicker('DATE STRIP'),
            const SizedBox(height: 10),
            DateStrip(
              dates: List.generate(7, (i) {
                final d = DateTime.now().add(Duration(days: i));
                return DateStripItem(date: d, isAvailable: i % 2 == 0);
              }),
              selectedDate: _selectedDate,
              onDateSelected: (d) => setState(() => _selectedDate = d),
            ),
            const SizedBox(height: 16),

            const Kicker('RULE GRID (2PX RULES)'),
            const SizedBox(height: 10),
            RuleGrid(
              crossAxisCount: 2,
              itemCount: 4,
              childAspectRatio: 2.5,
              itemBuilder: (context, i) {
                return Container(
                  color: AppColors.paper,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  child: Text('Grid Item ${i + 1}'),
                );
              },
            ),
            const SizedBox(height: 16),

            const Kicker('INK BORDER BOX'),
            const SizedBox(height: 10),
            const InkBorderBox(
              padding: EdgeInsets.all(12),
              child: Text('Square Box with 2px Ink Border'),
            ),
            const SizedBox(height: 16),

            const Kicker('SKELETON ROW (LOADING)'),
            const SizedBox(height: 10),
            const SkeletonRow(height: 48),
            const SizedBox(height: 16),

            const Kicker('EMPTY STATE'),
            const SizedBox(height: 10),
            EmptyState(
              title: 'No Data Found',
              message: 'Try adjusting your filters',
              actionLabel: 'Reset',
              onAction: () {},
            ),
            const SizedBox(height: 16),

            const Kicker('ERROR STATE'),
            const SizedBox(height: 10),
            ErrorState(
              message: 'Failed to load content from the server',
              onRetry: () {},
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
