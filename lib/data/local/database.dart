import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ===== TABLAS =====

/// Perfil del usuario
class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get currency => text().withDefault(const Constant('COP'))();
  TextColumn get locale => text().withDefault(const Constant('es_CO'))();
  TextColumn get timezone => text().withDefault(const Constant('America/Bogota'))();
  IntColumn get monthlyIncome => integer().withDefault(const Constant(0))();
  IntColumn get defaultReserve => integer().withDefault(const Constant(500000))();
  IntColumn get salaryDay => integer().withDefault(const Constant(30))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Ingresos
class Incomes extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amount => integer()();
  TextColumn get type => text()(); // salary, bonus, extra
  TextColumn get month => text()(); // "2026-06"
  BoolColumn get recurring => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Gastos fijos
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amount => integer()();
  TextColumn get category => text()(); // housing, food, etc
  TextColumn get frequency => text().withDefault(const Constant('monthly'))();
  IntColumn get dueDay => integer().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get startMonth => text().nullable()();
  TextColumn get endMonth => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Deudas
class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // creditCard, freeCredit, etc
  IntColumn get currentBalance => integer()();
  IntColumn get minimumPayment => integer()();
  IntColumn get targetPayment => integer()();
  TextColumn get priority => text().withDefault(const Constant('medium'))();
  IntColumn get dueDay => integer().nullable()();
  IntColumn get interestRateBps => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  // Credit card fields
  IntColumn get creditLimit => integer().nullable()();
  IntColumn get availableCredit => integer().nullable()();
  IntColumn get cutoffDay => integer().nullable()();
  IntColumn get paymentDueDay => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Eventos especiales
class SpecialEvents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amount => integer()();
  TextColumn get month => text()(); // "2026-10"
  TextColumn get category => text().withDefault(const Constant('other'))();
  BoolColumn get flexible => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Registro de cambios (Audit Log)
class AuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get entity => text()(); // expense, debt, income, etc
  TextColumn get entityId => text()();
  TextColumn get action => text()(); // create, update, delete
  TextColumn get beforeJson => text().nullable()();
  TextColumn get afterJson => text().nullable()();
  TextColumn get impactJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ===== DATABASE =====

@DriftDatabase(tables: [
  UserProfiles,
  Incomes,
  Expenses,
  Debts,
  SpecialEvents,
  AuditLogs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ===== USER PROFILE =====
  Future<UserProfile?> getUserProfile() =>
      (select(userProfiles)..limit(1)).getSingleOrNull();

  Future<int> insertUserProfile(UserProfilesCompanion profile) =>
      into(userProfiles).insert(profile, mode: InsertMode.insertOrReplace);

  Future<bool> updateUserProfile(UserProfilesCompanion profile) =>
      update(userProfiles).replace(profile);

  // ===== INCOMES =====
  Future<List<Income>> getAllIncomes() => select(incomes).get();

  Stream<List<Income>> watchAllIncomes() => select(incomes).watch();

  Future<List<Income>> getIncomesForMonth(String month) =>
      (select(incomes)..where((i) => i.month.equals(month) | i.recurring.equals(true)))
          .get();

  Future<int> insertIncome(IncomesCompanion income) =>
      into(incomes).insert(income, mode: InsertMode.insertOrReplace);

  Future<int> deleteIncome(String id) =>
      (delete(incomes)..where((i) => i.id.equals(id))).go();

  // ===== EXPENSES =====
  Future<List<Expense>> getAllExpenses() => select(expenses).get();

  Stream<List<Expense>> watchAllExpenses() => select(expenses).watch();

  Future<List<Expense>> getActiveExpenses() =>
      (select(expenses)..where((e) => e.active.equals(true))).get();

  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense, mode: InsertMode.insertOrReplace);

  Future<int> deleteExpense(String id) =>
      (delete(expenses)..where((e) => e.id.equals(id))).go();

  // ===== DEBTS =====
  Future<List<Debt>> getAllDebts() => select(debts).get();

  Stream<List<Debt>> watchAllDebts() => select(debts).watch();

  Future<List<Debt>> getActiveDebts() =>
      (select(debts)..where((d) => d.status.equals('active'))).get();

  Future<int> insertDebt(DebtsCompanion debt) =>
      into(debts).insert(debt, mode: InsertMode.insertOrReplace);

  Future<int> deleteDebt(String id) =>
      (delete(debts)..where((d) => d.id.equals(id))).go();

  // ===== SPECIAL EVENTS =====
  Future<List<SpecialEvent>> getAllSpecialEvents() =>
      select(specialEvents).get();

  Stream<List<SpecialEvent>> watchAllSpecialEvents() =>
      select(specialEvents).watch();

  Future<List<SpecialEvent>> getEventsForMonth(String month) =>
      (select(specialEvents)..where((e) => e.month.equals(month))).get();

  Future<int> insertSpecialEvent(SpecialEventsCompanion event) =>
      into(specialEvents).insert(event, mode: InsertMode.insertOrReplace);

  Future<int> deleteSpecialEvent(String id) =>
      (delete(specialEvents)..where((e) => e.id.equals(id))).go();

  // ===== AUDIT LOG =====
  Future<int> insertAuditLog(AuditLogsCompanion log) =>
      into(auditLogs).insert(log);

  Future<List<AuditLog>> getRecentAuditLogs({int limit = 50}) =>
      (select(auditLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();

  Stream<List<AuditLog>> watchAuditLogs({int limit = 50}) =>
      (select(auditLogs)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .watch();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ruta_cero.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
