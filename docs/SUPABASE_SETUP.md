# Supabase — Guía paso a paso para Ruta Cero

---

## PARTE 1: CREAR CUENTA

1. Abre Chrome/Safari
2. Escribe en la barra de dirección: `https://supabase.com/dashboard`
3. Presiona Enter
4. Verás la página de login de Supabase
5. Click en el botón **"Sign in with GitHub"** (botón negro con logo de GitHub)
6. Si no tienes GitHub: click en **"Sign Up"** abajo y usa tu email
7. Si usaste GitHub: autoriza la app cuando te lo pida
8. Llegarás al dashboard de Supabase — verás una página que dice "Welcome to Supabase"

---

## PARTE 2: CREAR ORGANIZACIÓN

9. Si es tu primera vez, te mostrará un formulario para crear organización
10. Si no te lo muestra, en la sidebar izquierda click en **"New Organization"**
11. En el campo **"Organization name"** escribe: `ruta-cero`
12. En **"Plan"** asegúrate que diga **"Free"** — NO selecciones Pro
13. Click en el botón **"Create organization"**

---

## PARTE 3: CREAR PROYECTO

14. Ahora verás la página de tu organización `ruta-cero`
15. Click en el botón verde **"New Project"**
16. Se abre un formulario. Llena cada campo:
    - **Project name:** escribe `ruta-cero-dev`
    - **Database Password:** click en el botón **"Generate a password"** que está a la derecha del campo
17. **IMPORTANTE:** Copia ese password generado y pégalo en un archivo de texto o nota. Ejemplo: `xK9#mP2$vL7...`. Lo necesitarás solo si quieres conectarte por SQL directo en el futuro.
18. **Region:** click en el dropdown y selecciona **"South America (São Paulo)"** — es la opción que dice `sa-east-1`
19. Click en el botón **"Create new project"**
20. Espera. Verás un loader que dice "Setting up project". Toma entre 1 y 3 minutos.
21. Cuando termine, verás el dashboard del proyecto con un menú lateral a la izquierda.

---

## PARTE 4: COPIAR LA PROJECT URL

22. En la sidebar izquierda, busca y click en **"Settings"** (ícono de engranaje, está abajo en la sidebar)
23. Se abre una página de configuración con un menú lateral propio
24. En ese menú lateral de settings, click en **"Data API"** (puede estar en la sección "Integrations" o "Configuration" dependiendo de tu vista)
25. Si no ves "Data API" ahí, entonces: vuelve a la sidebar principal > click en **"Integrations"** > click en **"Data API"**
26. Busca la sección que dice **"URL"** o **"Project URL"**
27. Verás algo como: `https://abcdefghij.supabase.co`
28. Click en el ícono de copiar (📋) al lado de la URL
29. Pega ese valor en un archivo de texto. Ejemplo:
    ```
    URL: https://abcdefghij.supabase.co
    ```

---

## PARTE 5: COPIAR LA ANON KEY

30. Si estás en Settings, busca en el menú lateral **"API Keys"** y click ahí
31. Si no lo ves, ve a: sidebar principal > **"Settings"** > **"API Keys"**
32. Verás una sección que dice **"Publishable key"** o **"anon"** o **"anon public"**
33. Es un texto largo que empieza con `eyJhbGciOiJIUzI1Ni...`
34. Click en el ícono de copiar (📋) al lado
35. Pega ese valor en tu archivo de texto. Ejemplo:
    ```
    ANON KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSI...
    ```
36. **IGNORA** la otra key que dice **"Secret"** o **"service_role"** — NO la copies, NO la uses en ningún lado de Flutter

---

## PARTE 6: EJECUTAR EL SQL DE LAS TABLAS

37. En la sidebar izquierda del dashboard, click en **"SQL Editor"** (ícono que parece una terminal con `>_`)
38. Se abre un editor de código vacío
39. Si no se abre vacío, click en **"New query"** o el botón **"+"** arriba
40. Ahora ve a tu editor de código (Kiro o VS Code)
41. Abre el archivo: `supabase/schema.sql` (está en la raíz del proyecto)
42. Selecciona todo el contenido: **Cmd + A**
43. Copia: **Cmd + C**
44. Vuelve al navegador donde tienes Supabase SQL Editor
45. Click dentro del área de texto vacía del editor SQL
46. Pega: **Cmd + V**
47. Verás todo el SQL pegado (empieza con `-- RUTA CERO - Schema`)
48. Click en el botón **"Run"** (botón verde, está abajo a la derecha del editor) — o presiona **Cmd + Enter**
49. Espera 2-5 segundos
50. Abajo del editor verás el resultado. Debe decir: **"Success. No rows returned"**
51. Si ves un error que dice "already exists" — no pasa nada, significa que ya se había creado antes

---

## PARTE 7: VERIFICAR QUE LAS TABLAS EXISTEN

52. En la sidebar izquierda, click en **"Table Editor"** (ícono de tabla/grilla, parece un cuadrado con líneas)
53. En el panel izquierdo verás la lista de tablas. Debes ver exactamente estas 7:
    - `audit_logs`
    - `debts`
    - `expenses`
    - `incomes`
    - `payments`
    - `special_events`
    - `user_profiles`
54. Click en `debts` — verás las columnas: id, user_id, name, type, current_balance, etc.
55. La tabla estará vacía — eso es correcto
56. Busca un indicador verde que diga **"RLS Enabled"** o un ícono de escudo/candado. Debe estar verde/activo.

---

## PARTE 8: CONFIGURAR EMAIL AUTH PARA DESARROLLO

57. En la sidebar izquierda, click en **"Authentication"** (ícono de persona con candado)
58. En el menú lateral que aparece, click en **"Providers"**
59. Verás una lista de providers. El primero debe ser **"Email"** — debe tener un toggle verde (enabled)
60. Click en la palabra **"Email"** para expandir las opciones
61. Busca la opción que dice **"Confirm email"**
62. Esa opción estará activada (toggle verde/azul). **Desactívala** — click en el toggle para que quede gris/apagado
63. Click en el botón **"Save"** que aparece abajo

---

## PARTE 9: CREAR USUARIO DE PRUEBA

64. Estando en **"Authentication"**, click en la pestaña **"Users"** (arriba)
65. Click en el botón **"Add User"** > **"Create new user"**
66. Llena:
    - **Email:** `test@rutacero.dev`
    - **Password:** `test123456`
    - Marca/activa **"Auto Confirm User"**
67. Click en **"Create user"**
68. Debes ver el usuario en la lista con status **"Confirmed"** y un ID tipo UUID
69. Si lo ves, todo funciona correctamente

---

## PARTE 10: ENVIARME LAS CREDENCIALES

70. Copia los dos valores que guardaste en los pasos 29 y 35:

```
Project URL: https://xxxxxxxxxx.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.xxxxxxxxxxxxx...
```

71. Pégalos en el chat y yo los configuro en el código

---

## COSAS QUE NO DEBES HACER

- **NO** copies la key que dice "Secret" o "service_role" — esa nunca va en Flutter
- **NO** desactives RLS en ninguna tabla (el candado verde debe quedar verde)
- **NO** elijas otra región que no sea South America (São Paulo)
- **NO** borres las tablas creadas
- **NO** borres al usuario de prueba hasta que yo te diga
- **NO** cambies la sección "URL Configuration" en Auth settings
- **NO** actives otros providers (Google, Apple, Phone) — eso lo haremos después
- **NO** vayas a "Edge Functions" ni "Storage" — eso es para fases posteriores
- **NO** metas tarjeta de crédito ni cambies a plan Pro — Free es suficiente
