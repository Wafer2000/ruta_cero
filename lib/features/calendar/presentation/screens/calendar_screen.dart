import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/formatting/month_names.dart';
import '../../../../domain/entities/debt.dart';
import '../../../../domain/entities/special_event.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final debts = ref.watch(debtsProvider).valueOrNull ?? [];
    final events = ref.watch(specialEventsProvider).valueOrNull ?? [];
    final dayMarkers = _buildDayMarkers(debts, events);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 16, AppConstants.screenHorizontalPadding, 8),
              child: Text(l.calendarTitle, style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          // Month navigation
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenHorizontalPadding),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1)),
                      icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${MonthNames.full(l, _currentMonth.month)} ${_currentMonth.year}',
                      style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1)),
                      icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // Calendar grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenHorizontalPadding),
              child: _CalendarGrid(currentMonth: _currentMonth, dayMarkers: dayMarkers),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Legend
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenHorizontalPadding),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _LegendItem(color: AppColors.success, label: l.paid),
                  _LegendItem(color: AppColors.warning, label: l.upcoming),
                  _LegendItem(color: AppColors.danger, label: l.overdue),
                  _LegendItem(color: AppColors.primary, label: l.statusEvent),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Map<int, List<Color>> _buildDayMarkers(List<Debt> debts, List<SpecialEvent> events) {
    final markers = <int, List<Color>>{};
    final now = DateTime.now();

    for (final debt in debts.where((d) => d.isActive)) {
      final day = debt.paymentDay;
      final paymentDate = DateTime(_currentMonth.year, _currentMonth.month, day);
      final color = paymentDate.isBefore(now) ? AppColors.danger : AppColors.warning;
      markers.putIfAbsent(day, () => []).add(color);
    }

    for (final event in events) {
      if (event.date.year == _currentMonth.year && event.date.month == _currentMonth.month) {
        markers.putIfAbsent(event.date.day, () => []).add(AppColors.primary);
      }
    }

    return markers;
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final Map<int, List<Color>> dayMarkers;

  const _CalendarGrid({required this.currentMonth, required this.dayMarkers});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday;
    final today = DateTime.now();
    final isCurrentMonth = today.year == currentMonth.year && today.month == currentMonth.month;
    const weekdayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdayLabels.map((d) => SizedBox(
              width: 36,
              child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            )).toList(),
          ),
          const SizedBox(height: 8),
          ..._buildWeeks(daysInMonth, firstWeekday, isCurrentMonth, today.day),
        ],
      ),
    );
  }

  List<Widget> _buildWeeks(int daysInMonth, int firstWeekday, bool isCurrentMonth, int todayDay) {
    final weeks = <Widget>[];
    var dayCounter = 1;
    final offset = firstWeekday - 1;

    for (var week = 0; week < 6; week++) {
      if (dayCounter > daysInMonth) break;
      final cells = <Widget>[];
      for (var col = 0; col < 7; col++) {
        final index = week * 7 + col;
        if (index < offset || dayCounter > daysInMonth) {
          cells.add(const SizedBox(width: 36, height: 44));
        } else {
          final day = dayCounter;
          final isToday = isCurrentMonth && day == todayDay;
          final markers = dayMarkers[day] ?? [];
          cells.add(_DayCell(day: day, isToday: isToday, markers: markers));
          dayCounter++;
        }
      }
      weeks.add(Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: cells)));
    }
    return weeks;
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final List<Color> markers;

  const _DayCell({required this.day, required this.isToday, required this.markers});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28, height: 28,
            decoration: isToday ? BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)) : null,
            alignment: Alignment.center,
            child: Text('$day', style: TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 13, fontWeight: isToday ? FontWeight.w700 : FontWeight.w400, color: AppColors.textPrimary)),
          ),
          if (markers.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: markers.take(3).map((c) => Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 2, right: 1), decoration: BoxDecoration(color: c, shape: BoxShape.circle))).toList(),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
