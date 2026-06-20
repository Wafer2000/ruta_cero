import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../domain/entities/plan_month.dart';

/// Badge visual del semáforo mensual
class MonthStatusBadge extends StatelessWidget {
  final MonthStatus status;

  const MonthStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(_label(l), style: TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, fontWeight: FontWeight.w600, color: _color)),
        ],
      ),
    );
  }

  Color get _color {
    switch (status) {
      case MonthStatus.green: return AppColors.success;
      case MonthStatus.yellow: return AppColors.warning;
      case MonthStatus.red: return AppColors.danger;
      case MonthStatus.blue: return AppColors.secondary;
      case MonthStatus.purple: return AppColors.primary;
    }
  }

  String _label(S l) {
    switch (status) {
      case MonthStatus.green: return l.statusHealthy;
      case MonthStatus.yellow: return l.statusTight;
      case MonthStatus.red: return l.statusRisk;
      case MonthStatus.blue: return l.statusExtraIncome;
      case MonthStatus.purple: return l.statusEvent;
    }
  }
}
