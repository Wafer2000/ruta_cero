import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../services/pdf_export_service.dart';
import '../../services/csv_export_service.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppConstants.screenHorizontalPadding, 16, AppConstants.screenHorizontalPadding, 8),
                child: Text(l.exportTitle, style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
                child: Column(
                  children: [
                    _ExportOption(
                      icon: Icons.picture_as_pdf_rounded,
                      color: AppColors.danger,
                      title: l.exportPdf,
                      subtitle: l.exportPdfDescription,
                      onTap: () => _exportPdf(context, ref),
                    ),
                    const SizedBox(height: 12),
                    _ExportOption(
                      icon: Icons.table_chart_rounded,
                      color: AppColors.success,
                      title: l.exportCsv,
                      subtitle: l.exportCsvDescription,
                      onTap: () => _exportCsv(context, ref, 'plan'),
                    ),
                    const SizedBox(height: 12),
                    _ExportOption(
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                      title: l.exportDebts,
                      subtitle: l.exportDebtsDescription,
                      onTap: () => _exportCsv(context, ref, 'debts'),
                    ),
                    const SizedBox(height: 12),
                    _ExportOption(
                      icon: Icons.receipt_long_rounded,
                      color: AppColors.warning,
                      title: l.exportExpenses,
                      subtitle: l.exportExpensesDescription,
                      onTap: () => _exportCsv(context, ref, 'expenses'),
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

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(userProfileProvider).valueOrNull;
    final plan = ref.read(financialPlanProvider).valueOrNull;
    final debts = ref.read(debtsProvider).valueOrNull ?? [];
    final expenses = ref.read(expensesProvider).valueOrNull ?? [];
    final totalDebt = ref.read(totalDebtProvider);

    if (plan == null) return;

    const service = PdfExportService();
    final bytes = await service.generatePlanReport(
      userName: profile?.name ?? '',
      totalDebt: totalDebt,
      debtFreeMonth: plan.debtFreeMonth,
      months: plan.months,
      debts: debts,
      expenses: expenses,
      labels: PdfLabels(
        totalDebt: S.of(context).totalDebt,
        debtFree: S.of(context).debtFree,
        debts: S.of(context).debtsTitle,
        expenses: S.of(context).expensesTitle,
        plan: S.of(context).planTitle,
        name: S.of(context).expenseName,
        balance: S.of(context).currentBalance,
        monthlyPayment: S.of(context).targetPayment,
        value: S.of(context).value,
        month: S.of(context).navPlan,
        income: S.of(context).income,
        toDebt: S.of(context).toDebt,
        free: S.of(context).free,
      ),
    );

    await Printing.sharePdf(bytes: bytes, filename: 'ruta_cero_plan.pdf');
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref, String type) async {
    const service = CsvExportService();
    String csvContent;
    String filename;

    switch (type) {
      case 'plan':
        final plan = ref.read(financialPlanProvider).valueOrNull;
        if (plan == null) return;
        csvContent = service.generatePlanCsv(plan.months);
        filename = 'ruta_cero_plan.csv';
        break;
      case 'debts':
        final debts = ref.read(debtsProvider).valueOrNull ?? [];
        csvContent = service.generateDebtsCsv(debts);
        filename = 'ruta_cero_deudas.csv';
        break;
      case 'expenses':
        final expenses = ref.read(expensesProvider).valueOrNull ?? [];
        csvContent = service.generateExpensesCsv(expenses);
        filename = 'ruta_cero_gastos.csv';
        break;
      default:
        return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(csvContent);
    await Share.shareXFiles([XFile(file.path)], text: filename);
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceDark,
      borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardSecondaryBorderRadius),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontFamily: AppConstants.fontPrimary, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontFamily: AppConstants.fontSecondary, fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
