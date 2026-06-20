# Arquitectura de Ruta Cero

## Principios

1. **Offline-first** — la app funciona completa sin internet
2. **Motor financiero en código** — cálculos determinísticos, nunca depender de IA para números
3. **Clean Architecture ligera** — dominio separado de infraestructura y presentación
4. **Dinero en enteros** — nunca usar `double` para evitar errores de redondeo
5. **Recálculo automático** — cualquier cambio recalcula el plan completo
6. **Sin strings quemados** — todo texto visible usa i18n (ARB files)
7. **Sin valores mágicos** — todo número/font/color vive en AppConstants o AppColors

## Capas

```
Presentación (Flutter widgets + screens)
      ↓ lee estado via
Providers (Riverpod — StateNotifier + StreamProvider)
      ↓ usa
Dominio (entities + services/engines)
      ↑ implementado por
Datos (repositories + Drift database + Supabase remote)
```

## Archivos principales (67 archivos Dart)

### app/
- `app.dart` — MaterialApp con tema, locale, router
- `bootstrap.dart` — inicialización por ambiente (locale, orientación, Supabase, SSL)
- `providers.dart` — providers globales (database, repository, financial plan, derived data)
- `auth_provider.dart` — estado de autenticación reactivo

### core/
- `config/environment.dart` — EnvConfig para dev/staging/prod con URLs y flags
- `config/dev_http_overrides.dart` — bypass SSL solo en dev (firewalls corporativos)
- `constants/app_colors.dart` — paleta completa con roles (primary, success, warning, danger)
- `constants/app_constants.dart` — tipografía, tamaños, radios, durations, financial defaults
- `formatting/currency_formatter.dart` — formato COP (puntos para miles)
- `formatting/date_formatter.dart` — fechas Colombia
- `formatting/month_names.dart` — nombres de mes localizados via S class
- `l10n/locale_provider.dart` — Riverpod provider para cambiar idioma en runtime
- `router/app_router.dart` — GoRouter con 20 rutas, shell navigation, auth redirect
- `theme/app_theme.dart` — ThemeData dark premium con TextTheme completo

### domain/entities/ (9 entidades)
- `user_profile.dart` — config del usuario (income, reserve, salary day)
- `debt.dart` — deuda con CreditCardDetail (cupo, uso, corte)
- `expense.dart` — gasto fijo con categoría, frecuencia, rango de meses
- `income.dart` — ingreso (salary, bonus, extra)
- `special_event.dart` — gasto puntual de un mes
- `payment.dart` — pago real vs planeado (status: pending/paid/overdue)
- `goal.dart` — meta personal con progreso y meses estimados
- `scenario.dart` — escenario hipotético con overrides
- `scenario_comparison.dart` — resultado de comparar 2 planes
- `audit_entry.dart` — registro de cambio en el historial

### domain/services/ (3 motores)
- `financial_engine.dart` — genera plan mes a mes, aplica estrategias, cierra deudas
- `scenario_engine.dart` — simula escenarios, compara planes, evalúa "¿me alcanza?"
- `post_debt_engine.dart` — presupuesto diario, fondo emergencia, distribución post-deuda

### data/
- `local/database.dart` — Drift schema (7 tablas), queries, streams
- `remote/supabase_service.dart` — inicialización y auth helpers
- `remote/sync_repository.dart` — CRUD remoto con RLS
- `repositories/financial_repository.dart` — bridge entre Drift y domain entities

### features/ (13 módulos)
| Feature | Pantallas | Propósito |
|---|---|---|
| auth | login_screen | Email/password + registro + offline |
| calendar | calendar_screen | Vista mensual con dots de color |
| dashboard | dashboard_screen + 3 widgets | Hero card, pagos del mes, semáforo |
| debts | debts_screen, add_debt_screen | CRUD deudas + tarjeta de crédito |
| events | events_screen, add_event_screen | CRUD eventos especiales |
| expenses | expenses_screen, add_expense_screen | CRUD gastos fijos |
| export | export_screen + 2 services | PDF y CSV compartibles |
| goals | goals_screen, add_goal_screen, discipline_screen | Metas + disciplina + fondo |
| history | history_screen | Timeline de cambios |
| income | income_screen, add_income_screen | CRUD ingresos |
| onboarding | onboarding_screen | Flujo 3 pasos para nuevos usuarios |
| payments | payments_screen | Pagos reales vs planeados |
| planning | plan_screen | Plan mes a mes con semáforo |
| scenarios | scenarios_screen, affordability_screen, create_scenario_screen | Simulador + ¿me alcanza? |
| settings | settings_screen | Idioma, perfil, info |

## Motor financiero — orden de cálculo mensual

1. Cargar ingresos del mes (sueldo + extras)
2. Cargar gastos fijos activos para ese mes
3. Cargar eventos especiales del mes
4. Separar reserva mensual (intocable)
5. Calcular disponible para deuda
6. Pagar mínimos obligatorios de cada deuda
7. Aplicar excedente según estrategia elegida
8. Cerrar deudas que lleguen a cero, redirigir sobrante
9. Calcular dinero libre final
10. Asignar semáforo del mes (verde/amarillo/rojo/azul/morado)
11. Guardar snapshot

## 5 estrategias de pago

| Estrategia | Orden de prioridad |
|---|---|
| Snowball | Menor saldo primero |
| Avalanche | Mayor tasa de interés primero |
| Custom | Prioridad manual del usuario (alta/media/baja) |
| Balanced | Distribuye proporcionalmente entre deudas |
| Conservative | Solo paga mínimos, protege la reserva |

## Reglas inamovibles

- Nunca pagar más que el saldo de una deuda
- Respetar pagos mínimos antes de extras
- La reserva no se toca automáticamente
- Condición de parada: todas las deudas a cero o 60 meses máximo
- Los cambios de IA (futuro) deben pasar por el motor — la IA no calcula sola

## Seguridad

- API keys solo en EnvConfig (no en widgets ni UI)
- Row Level Security en Supabase: cada usuario solo ve sus datos
- SSL bypass solo en ambiente dev
- No se guardan contraseñas bancarias ni números de tarjeta completos
- Los errores técnicos nunca se muestran al usuario (solo en consola de debug)
