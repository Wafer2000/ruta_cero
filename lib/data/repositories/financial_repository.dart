import 'package:uuid/uuid.dart';
import '../local/database.dart';
import '../../domain/entities/income.dart' as domain;
import '../../domain/entities/expense.dart' as domain;
import '../../domain/entities/debt.dart' as domain;
import '../../domain/entities/special_event.dart' as domain;
import '../../domain/entities/user_profile.dart' as domain;
import '../../domain/entities/audit_entry.dart' as domain;
import 'package:drift/drift.dart';

const _uuid = Uuid();

/// Repositorio principal para datos financieros
/// Convierte entre entidades de dominio y modelos de Drift
class FinancialRepository {
  final AppDatabase _db;

  FinancialRepository(this._db);

  // ===== USER PROFILE =====

  Future<domain.UserProfile?> getUserProfile() async {
    final row = await _db.getUserProfile();
    if (row == null) return null;
    return _mapUserProfile(row);
  }

  Future<void> saveUserProfile(domain.UserProfile profile) async {
    await _db.insertUserProfile(UserProfilesCompanion(
      id: Value(profile.id),
      name: Value(profile.name),
      currency: Value(profile.currency),
      locale: Value(profile.locale),
      timezone: Value(profile.timezone),
      monthlyIncome: Value(profile.monthlyIncome),
      defaultReserve: Value(profile.defaultReserve),
      salaryDay: Value(profile.salaryDay),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ===== INCOMES =====

  Future<List<domain.Income>> getAllIncomes() async {
    final rows = await _db.getAllIncomes();
    return rows.map(_mapIncome).toList();
  }

  Stream<List<domain.Income>> watchIncomes() {
    return _db.watchAllIncomes().map((rows) => rows.map(_mapIncome).toList());
  }

  Future<void> saveIncome(domain.Income income) async {
    await _db.insertIncome(IncomesCompanion(
      id: Value(income.id),
      name: Value(income.name),
      amount: Value(income.amount),
      type: Value(income.type.name),
      month: Value(income.month),
      recurring: Value(income.recurring),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteIncome(String id) => _db.deleteIncome(id);

  // ===== EXPENSES =====

  Future<List<domain.Expense>> getAllExpenses() async {
    final rows = await _db.getAllExpenses();
    return rows.map(_mapExpense).toList();
  }

  Stream<List<domain.Expense>> watchExpenses() {
    return _db.watchAllExpenses().map((rows) => rows.map(_mapExpense).toList());
  }

  Future<void> saveExpense(domain.Expense expense) async {
    await _db.insertExpense(ExpensesCompanion(
      id: Value(expense.id),
      name: Value(expense.name),
      amount: Value(expense.amount),
      category: Value(expense.category.name),
      frequency: Value(expense.frequency.name),
      dueDay: Value(expense.dueDay),
      active: Value(expense.active),
      startMonth: Value(expense.startMonth),
      endMonth: Value(expense.endMonth),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteExpense(String id) => _db.deleteExpense(id);

  // ===== DEBTS =====

  Future<List<domain.Debt>> getAllDebts() async {
    final rows = await _db.getAllDebts();
    return rows.map(_mapDebt).toList();
  }

  Stream<List<domain.Debt>> watchDebts() {
    return _db.watchAllDebts().map((rows) => rows.map(_mapDebt).toList());
  }

  Future<void> saveDebt(domain.Debt debt) async {
    await _db.insertDebt(DebtsCompanion(
      id: Value(debt.id),
      name: Value(debt.name),
      type: Value(debt.type.name),
      currentBalance: Value(debt.currentBalance),
      minimumPayment: Value(debt.minimumPayment),
      targetPayment: Value(debt.targetPayment),
      priority: Value(debt.priority.name),
      dueDay: Value(debt.dueDay),
      interestRateBps: Value(debt.interestRateBps),
      status: Value(debt.status.name),
      creditLimit: Value(debt.creditCardDetail?.creditLimit),
      availableCredit: Value(debt.creditCardDetail?.availableCredit),
      cutoffDay: Value(debt.creditCardDetail?.cutoffDay),
      paymentDueDay: Value(debt.creditCardDetail?.paymentDueDay),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteDebt(String id) => _db.deleteDebt(id);

  // ===== SPECIAL EVENTS =====

  Future<List<domain.SpecialEvent>> getAllSpecialEvents() async {
    final rows = await _db.getAllSpecialEvents();
    return rows.map(_mapSpecialEvent).toList();
  }

  Stream<List<domain.SpecialEvent>> watchSpecialEvents() {
    return _db
        .watchAllSpecialEvents()
        .map((rows) => rows.map(_mapSpecialEvent).toList());
  }

  Future<void> saveSpecialEvent(domain.SpecialEvent event) async {
    await _db.insertSpecialEvent(SpecialEventsCompanion(
      id: Value(event.id),
      name: Value(event.name),
      amount: Value(event.amount),
      month: Value(event.month),
      category: Value(event.category.name),
      flexible: Value(event.flexible),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteSpecialEvent(String id) => _db.deleteSpecialEvent(id);

  // ===== AUDIT LOG =====

  Future<void> logChange({
    required String entity,
    required String entityId,
    required String action,
    String? beforeJson,
    String? afterJson,
    String? impactJson,
  }) async {
    await _db.insertAuditLog(AuditLogsCompanion(
      id: Value(_uuid.v4()),
      entity: Value(entity),
      entityId: Value(entityId),
      action: Value(action),
      beforeJson: Value(beforeJson),
      afterJson: Value(afterJson),
      impactJson: Value(impactJson),
    ));
  }

  Stream<List<domain.AuditEntry>> watchAuditLogs() {
    return _db.watchAuditLogs().map((rows) => rows.map((r) => domain.AuditEntry(
      id: r.id,
      entity: r.entity,
      entityId: r.entityId,
      action: r.action,
      description: r.beforeJson,
      createdAt: r.createdAt,
    )).toList());
  }

  // ===== MAPPERS =====

  domain.UserProfile _mapUserProfile(UserProfile row) {
    return domain.UserProfile(
      id: row.id,
      name: row.name,
      currency: row.currency,
      locale: row.locale,
      timezone: row.timezone,
      monthlyIncome: row.monthlyIncome,
      defaultReserve: row.defaultReserve,
      salaryDay: row.salaryDay,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  domain.Income _mapIncome(Income row) {
    return domain.Income(
      id: row.id,
      name: row.name,
      amount: row.amount,
      type: domain.IncomeType.values.firstWhere(
        (t) => t.name == row.type,
        orElse: () => domain.IncomeType.extra,
      ),
      month: row.month,
      recurring: row.recurring,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  domain.Expense _mapExpense(Expense row) {
    return domain.Expense(
      id: row.id,
      name: row.name,
      amount: row.amount,
      category: domain.ExpenseCategory.values.firstWhere(
        (c) => c.name == row.category,
        orElse: () => domain.ExpenseCategory.other,
      ),
      frequency: domain.ExpenseFrequency.values.firstWhere(
        (f) => f.name == row.frequency,
        orElse: () => domain.ExpenseFrequency.monthly,
      ),
      dueDay: row.dueDay,
      active: row.active,
      startMonth: row.startMonth,
      endMonth: row.endMonth,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  domain.Debt _mapDebt(Debt row) {
    domain.CreditCardDetail? creditCard;
    if (row.creditLimit != null) {
      creditCard = domain.CreditCardDetail(
        creditLimit: row.creditLimit!,
        availableCredit: row.availableCredit ?? 0,
        cutoffDay: row.cutoffDay ?? 1,
        paymentDueDay: row.paymentDueDay ?? 15,
      );
    }

    return domain.Debt(
      id: row.id,
      name: row.name,
      type: domain.DebtType.values.firstWhere(
        (t) => t.name == row.type,
        orElse: () => domain.DebtType.other,
      ),
      currentBalance: row.currentBalance,
      minimumPayment: row.minimumPayment,
      targetPayment: row.targetPayment,
      priority: domain.DebtPriority.values.firstWhere(
        (p) => p.name == row.priority,
        orElse: () => domain.DebtPriority.medium,
      ),
      dueDay: row.dueDay,
      interestRateBps: row.interestRateBps,
      status: domain.DebtStatus.values.firstWhere(
        (s) => s.name == row.status,
        orElse: () => domain.DebtStatus.active,
      ),
      creditCardDetail: creditCard,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  domain.SpecialEvent _mapSpecialEvent(SpecialEvent row) {
    return domain.SpecialEvent(
      id: row.id,
      name: row.name,
      amount: row.amount,
      month: row.month,
      category: domain.EventCategory.values.firstWhere(
        (c) => c.name == row.category,
        orElse: () => domain.EventCategory.other,
      ),
      flexible: row.flexible,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
