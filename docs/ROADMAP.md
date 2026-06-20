# Roadmap — Funcionalidades futuras

Todo lo listado aquí NO está implementado actualmente. Son mejoras que requieren servicios pagos, cuentas de tiendas, o trabajo adicional.

---

## Requiere presupuesto

### Asistente financiero con IA
- Interpretar cambios en lenguaje natural ("me llegó menos sueldo")
- Proponer ajustes al plan
- Explicar escenarios en texto claro
- Flujo: Flutter → Supabase Edge Function → OpenAI API → motor financiero → respuesta
- **Costo estimado:** desde $20.000 COP/mes en uso bajo (GPT-4o mini)

### OCR / Escaneo de recibos
- Subir foto de extracto bancario
- Detectar valores, fechas y entidades
- Sugerir transacciones para confirmar
- **Opciones:** Google ML Kit (gratis en dispositivo) o OpenAI Vision (pago)

### Publicación Google Play Store
- Costo único: USD 25 (~$86.000 COP)
- Configurar firma de release APK
- Crear ficha de la app con capturas

### Publicación Apple App Store
- Costo anual: USD 99 (~$342.000 COP/año)
- Configurar certificados y provisioning profiles

### Monetización (RevenueCat)
- Plan gratuito: gastos básicos, 1 estrategia, plan limitado
- Plan Pro: escenarios ilimitados, exportaciones, historial completo
- Plan Premium IA: asistente, OCR, resúmenes automáticos
- RevenueCat es gratis hasta USD 2.500/mes de ingresos

### WhatsApp reminders (Twilio)
- Avisos de pagos próximos por WhatsApp
- Costo variable por mensaje
- Solo implementar si hay monetización activa

### Email transaccional (Resend)
- Reportes semanales/mensuales por correo
- Free: 3.000 emails/mes
- Pro: USD 20/mes

---

## Gratuito pero requiere trabajo adicional

### Notificaciones push locales
- Paquete: flutter_local_notifications (ya instalado)
- Recordatorios de pagos próximos
- Alertas de presupuesto diario
- **Estado:** paquete incluido, falta implementar scheduling

### Google Calendar sync
- Sincronizar fechas de pago como eventos
- Cuotas gratuitas: 10.000 requests/min
- Requiere OAuth y configuración de proyecto Google Cloud

### Reconocimiento de voz
- Dictar "agrega un gasto de $50.000"
- Usar speech-to-text nativo del dispositivo (gratis)
- No requiere API externa

### Gráficas de avance
- Paquete: fl_chart (ya incluido en pubspec)
- Mostrar reducción de deuda mes a mes
- Flujo de dinero mensual
- Cumplimiento del plan
- **Estado:** paquete incluido, falta crear los widgets de gráficas

### Widget móvil
- Mostrar dinero disponible hoy en la pantalla de inicio
- Paquete: home_widget
- Solo Android inicialmente

### Modo pareja/familia
- Gastos compartidos con otro usuario
- Roles y permisos en Supabase
- Requiere diseño de UX multi-usuario

### Modo empresa pequeña
- Ingresos variables
- Gastos operativos
- Cuentas por pagar/cobrar

### Comparación mes actual vs anterior
- Detectar mejoras o retrocesos
- Mostrar diferencias en gastos y deuda pagada

### Ranking de gastos por impacto
- Ordenar gastos de mayor a menor
- Sugerir qué reducir primero

### Copia de seguridad manual
- Exportar toda la base SQLite como archivo
- Importar en otro dispositivo

---

## Correcciones conocidas

### iOS build
- CocoaPods no funciona desde redes con firewall corporativo (Skyhigh)
- Solución: ejecutar `pod install` desde red libre (casa/hotspot)
- Una vez resuelto, iOS compila normalmente

### Supabase schema
- El SQL en `supabase/schema.sql` debe ejecutarse manualmente desde el SQL Editor de Supabase
- Requiere red sin firewall para acceder al dashboard
- Guía completa en `docs/SUPABASE_SETUP.md`

### Sincronización real
- `SyncRepository` está implementado pero no conectado al flujo de datos
- Actualmente la app trabaja 100% offline con SQLite local
- Para activar sync: conectar los providers a SyncRepository cuando haya red disponible

### Persistencia de escenarios y metas
- Actualmente se guardan en memoria (StateNotifier)
- Para persistir: agregar tablas `scenarios` y `goals` al schema de Drift y Supabase
- El modelo de datos ya está definido en domain/entities
