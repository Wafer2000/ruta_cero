# Ruta Cero

App de seguimiento financiero personal, simulación de pagos y decisiones inteligentes.

Ruta Cero no es una simple app de gastos. Es una herramienta de toma de decisiones financieras: te dice cuánto pagar, qué deuda priorizar, qué pasa si aparece un gasto, cuándo llegas a cero deudas y qué hacer después de quedar libre.

## Capturas

> Modo oscuro premium con identidad neo-fintech. Gradiente violeta → cian → verde menta.

## Características principales

- **Motor financiero determinístico** — recalcula automáticamente el plan mes a mes ante cualquier cambio
- **5 estrategias de pago** — snowball, avalanche, custom, balanced, conservative
- **Simulador de escenarios** — prueba cambios hipotéticos sin afectar el plan real
- **¿Me alcanza?** — evalúa si una compra conviene con semáforo visual
- **Calendario de pagos** — vista mensual con dots de color por estado
- **Metas personales** — viajes, tecnología, negocio, fondo de emergencia
- **Modo disciplina** — presupuesto diario, alerta de tarjeta, reserva protegida
- **Exportar PDF/CSV** — reportes compartibles compatibles con Excel
- **3 idiomas** — español, inglés, portugués
- **3 ambientes** — dev, staging, producción
- **Offline-first** — funciona sin internet con SQLite local
- **Supabase backend** — auth, sync y RLS (gratis)

## Stack técnico

| Capa | Tecnología |
|---|---|
| Framework | Flutter 3.24+ |
| Estado | Riverpod |
| Navegación | GoRouter |
| Base local | Drift (SQLite) |
| Backend | Supabase (PostgreSQL + Auth + RLS) |
| PDF | pdf + printing |
| Exportación | csv + share_plus |
| Arquitectura | Clean Architecture ligera |

## Estructura del proyecto

```
lib/
├── app/              → bootstrap, providers globales, app widget
├── core/
│   ├── config/       → ambientes, HTTP overrides
│   ├── constants/    → colores, constantes, tipografía
│   ├── formatting/   → COP, fechas, meses localizados
│   ├── l10n/         → locale provider
│   ├── router/       → GoRouter con todas las rutas
│   └── theme/        → tema dark/light premium
├── data/
│   ├── local/        → Drift database + generated
│   ├── remote/       → Supabase service + sync repository
│   └── repositories/ → financial repository (local ↔ domain)
├── domain/
│   ├── entities/     → debt, expense, income, goal, payment, etc.
│   └── services/     → financial_engine, scenario_engine, post_debt_engine
├── features/
│   ├── auth/         → login/registro
│   ├── calendar/     → vista mensual con dots
│   ├── dashboard/    → hero card, pagos, semáforo
│   ├── debts/        → CRUD deudas + tarjeta crédito
│   ├── events/       → eventos especiales
│   ├── expenses/     → gastos fijos
│   ├── export/       → PDF + CSV
│   ├── goals/        → metas + disciplina + fondo emergencia
│   ├── history/      → timeline de cambios
│   ├── income/       → ingresos (sueldo, prima, extra)
│   ├── onboarding/   → flujo inicial 3 pasos
│   ├── payments/     → pagos reales vs planeados
│   ├── planning/     → plan mes a mes
│   ├── scenarios/    → simulador + ¿me alcanza?
│   └── settings/     → config + idioma
├── shared/           → widgets reutilizables
├── l10n/             → archivos ARB (es, en, pt)
├── main.dart         → entry point producción
├── main_dev.dart     → entry point desarrollo
└── main_staging.dart → entry point staging
```

## Cómo correr

```bash
# Desarrollo (Android)
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=.env.dev

# Producción
flutter run --flavor prod -t lib/main.dart --dart-define-from-file=.env.prod
```

## Ambientes

| Ambiente | Entry point | App ID |
|---|---|---|
| dev | `lib/main_dev.dart` | `com.rutacero.ruta_cero.dev` |
| staging | `lib/main_staging.dart` | `com.rutacero.ruta_cero.stg` |
| prod | `lib/main.dart` | `com.rutacero.ruta_cero` |

## Configuración inicial

1. Clonar el repo
2. Copiar `.env.example` a `.env.dev` y establecer los valores de desarrollo local (nunca subirlos a Git). Para producción usar `.env.prod` con la configuración correspondiente.
3. `flutter pub get`
4. `dart run build_runner build --delete-conflicting-outputs`
5. `flutter gen-l10n`
6. Configurar Supabase → ver [docs/SUPABASE_SETUP.md](docs/SUPABASE_SETUP.md)

## Documentación

- [Guía de arquitectura](docs/ARCHITECTURE.md)
- [Configuración de Supabase](docs/SUPABASE_SETUP.md)
- [Manual de usuario](docs/USER_MANUAL.md)
- [Roadmap futuro](docs/ROADMAP.md)

## Seguridad y publicación

- No subir `.env.dev`, `.env.prod` ni credenciales de acceso.
- La clave **anon/publishable** de Supabase está diseñada para clientes, pero la seguridad de los datos depende de reglas RLS y permisos apropiados.
- Antes de cambiar la visibilidad del repositorio, revisar historial Git, datos de prueba, licencias, configuraciones y autorizaciones de terceros.
- Este cambio de configuración se preparó en una rama de revisión; no se considera prueba de una publicación segura.

## Licencia

Proyecto privado. Todos los derechos reservados.
