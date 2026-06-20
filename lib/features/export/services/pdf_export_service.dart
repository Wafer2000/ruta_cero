import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/app_constants.dart';
import '../../../core/formatting/currency_formatter.dart';
import '../../../domain/entities/plan_month.dart';
import '../../../domain/entities/debt.dart';
import '../../../domain/entities/expense.dart';

/// Servicio de generación de PDF del plan financiero
class PdfExportService {
  const PdfExportService();

  /// Genera un PDF con el resumen del plan financiero
  Future<Uint8List> generatePlanReport({
    required String userName,
    required int totalDebt,
    required String? debtFreeMonth,
    required List<PlanMonth> months,
    required List<Debt> debts,
    required List<Expense> expenses,
    required PdfLabels labels,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(userName),
        build: (context) => [
          _buildSummarySection(totalDebt, debtFreeMonth, labels),
          pw.SizedBox(height: 20),
          _buildDebtsSection(debts, labels),
          pw.SizedBox(height: 20),
          _buildExpensesSection(expenses, labels),
          pw.SizedBox(height: 20),
          _buildPlanSection(months, labels),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(String userName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          AppConstants.appName,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          userName,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildSummarySection(int totalDebt, String? debtFreeMonth, PdfLabels labels) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(labels.totalDebt, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(CurrencyFormatter.format(totalDebt), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(labels.debtFree, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text(debtFreeMonth ?? '---', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDebtsSection(List<Debt> debts, PdfLabels labels) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(labels.debts, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _cell(labels.name, bold: true),
                _cell(labels.balance, bold: true),
                _cell(labels.monthlyPayment, bold: true),
              ],
            ),
            ...debts.where((d) => d.isActive).map((d) => pw.TableRow(
                  children: [
                    _cell(d.name),
                    _cell(CurrencyFormatter.format(d.currentBalance)),
                    _cell(CurrencyFormatter.format(d.targetPayment)),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildExpensesSection(List<Expense> expenses, PdfLabels labels) {
    final active = expenses.where((e) => e.active).toList();
    final total = active.fold<int>(0, (s, e) => s + e.amount);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(labels.expenses, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text('${labels.expenses}: ${CurrencyFormatter.format(total)}', style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _cell(labels.name, bold: true),
                _cell(labels.value, bold: true),
              ],
            ),
            ...active.map((e) => pw.TableRow(
                  children: [
                    _cell(e.name),
                    _cell(CurrencyFormatter.format(e.amount)),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPlanSection(List<PlanMonth> months, PdfLabels labels) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(labels.plan, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _cell(labels.month, bold: true),
                _cell(labels.income, bold: true),
                _cell(labels.expenses, bold: true),
                _cell(labels.toDebt, bold: true),
                _cell(labels.free, bold: true),
              ],
            ),
            ...months.map((m) => pw.TableRow(
                  children: [
                    _cell(m.monthKey),
                    _cell(CurrencyFormatter.format(m.incomeTotal)),
                    _cell(CurrencyFormatter.format(m.expenseTotal)),
                    _cell(CurrencyFormatter.format(m.debtPaymentTotal)),
                    _cell(CurrencyFormatter.format(m.freeMoney)),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        '${AppConstants.appName} - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
      ),
    );
  }

  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}


/// Etiquetas localizadas para el PDF
class PdfLabels {
  final String totalDebt;
  final String debtFree;
  final String debts;
  final String expenses;
  final String plan;
  final String name;
  final String balance;
  final String monthlyPayment;
  final String value;
  final String month;
  final String income;
  final String toDebt;
  final String free;

  const PdfLabels({
    required this.totalDebt,
    required this.debtFree,
    required this.debts,
    required this.expenses,
    required this.plan,
    required this.name,
    required this.balance,
    required this.monthlyPayment,
    required this.value,
    required this.month,
    required this.income,
    required this.toDebt,
    required this.free,
  });
}
