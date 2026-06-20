import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/remote/supabase_service.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/planning/presentation/screens/plan_screen.dart';
import '../../features/debts/presentation/screens/debts_screen.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/scenarios/presentation/screens/scenarios_screen.dart';
import '../../features/scenarios/presentation/screens/affordability_screen.dart';
import '../../features/scenarios/presentation/screens/create_scenario_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/goals/presentation/screens/add_goal_screen.dart';
import '../../features/goals/presentation/screens/discipline_screen.dart';
import '../../features/export/presentation/screens/export_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/screens/add_event_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/debts/presentation/screens/add_debt_screen.dart';
import '../../features/expenses/presentation/screens/add_expense_screen.dart';
import '../../features/income/presentation/screens/add_income_screen.dart';
import '../../shared/layout/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  redirect: (context, state) {
    // Si Supabase está configurado pero no hay sesión, ir a login
    if (SupabaseService.isInitialized && !SupabaseService.isAuthenticated) {
      final goingToLogin = state.uri.toString() == '/login';
      if (!goingToLogin) return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/export',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExportScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/plan',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlanScreen(),
          ),
        ),
        GoRoute(
          path: '/debts',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DebtsScreen(),
          ),
        ),
        GoRoute(
          path: '/expenses',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ExpensesScreen(),
          ),
        ),
        GoRoute(
          path: '/payments',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PaymentsScreen(),
          ),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CalendarScreen(),
          ),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryScreen(),
          ),
        ),
        GoRoute(
          path: '/scenarios',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ScenariosScreen(),
          ),
        ),
        GoRoute(
          path: '/goals',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GoalsScreen(),
          ),
        ),
        GoRoute(
          path: '/discipline',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DisciplineScreen(),
          ),
        ),
        GoRoute(
          path: '/events',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: EventsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    // Rutas fuera del shell
    GoRoute(
      path: '/add-debt',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddDebtScreen(),
    ),
    GoRoute(
      path: '/add-expense',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/add-income',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddIncomeScreen(),
    ),
    GoRoute(
      path: '/affordability',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AffordabilityScreen(),
    ),
    GoRoute(
      path: '/create-scenario',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateScenarioScreen(),
    ),
    GoRoute(
      path: '/add-goal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddGoalScreen(),
    ),
    GoRoute(
      path: '/events/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddEventScreen(),
    ),
  ],
);
