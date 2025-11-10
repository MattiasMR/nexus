# Plan de Implementación - Nexus Flutter
## Sistema de Gestión Médica Móvil

**Objetivo**: Alcanzar 70% de funcionalidad completa  
**Fecha Inicio**: 10 de Noviembre, 2025  
**Tecnologías**: Flutter 3.35+, Firebase (Firestore + Auth), Material Design 3

---

## 📊 Estado Actual del Proyecto

### ✅ Completado (20%)
- [x] Configuración inicial de Flutter + Firebase
- [x] Estructura base del proyecto (features, models, services, utils)
- [x] Módulo de Pacientes (CRUD completo)
  - Lista de pacientes con búsqueda
  - Formulario crear/editar paciente
  - Vista detalle de paciente
- [x] Modelo de Ficha Médica (básico)
- [x] Servicio de Fichas Médicas (básico)
- [x] Diseño Material 3 con paleta de colores
- [x] Widget de clima (demo)

### 🚧 Estado Inicial
- **16 archivos Dart**
- **1 feature completo**: Pacientes
- **2 modelos**: Paciente, Ficha Médica
- **3 servicios**: Pacientes, Fichas Médicas, Weather

---

## 🎯 Plan de Implementación (Para alcanzar 70%)

### FASE 1: Autenticación y Seguridad (PRIORIDAD MÁXIMA)
**Tiempo estimado**: 2-3 días  
**Funcionalidad objetivo**: 30%

#### 1.1 Inicio de Sesión Seguro ⭐ **EMPEZAR AQUÍ**
**Prioridad**: CRÍTICA  
**Requisito**: "Pantalla de acceso con control de permisos específicos para el perfil médico/enfermera"

**Tareas**:
- [ ] **1.1.1** Configurar Firebase Authentication
  - Habilitar Email/Password en Firebase Console
  - Configurar reglas de seguridad de Firestore
  
- [ ] **1.1.2** Crear modelos de autenticación
  - `lib/models/user.dart` - Modelo de usuario con roles
  - `lib/models/user_role.dart` - Enum de roles (Médico, Enfermera, Admin)
  
- [ ] **1.1.3** Implementar servicio de autenticación
  - `lib/services/auth_service.dart`
  - Login con email/password
  - Logout
  - Verificación de sesión activa
  - Manejo de roles y permisos
  
- [ ] **1.1.4** Crear UI de Login
  - `lib/features/auth/pages/login_page.dart`
  - Formulario de login con validación
  - Manejo de errores (usuario/contraseña incorrecta)
  - Indicador de carga
  - Diseño responsive
  
- [ ] **1.1.5** Implementar pantalla de bienvenida/splash
  - `lib/features/auth/pages/splash_page.dart`
  - Verificar sesión al iniciar
  - Redirigir a Login o Home según estado
  
- [ ] **1.1.6** Crear guards de navegación
  - `lib/core/guards/auth_guard.dart`
  - Proteger rutas que requieren autenticación
  - Verificar permisos por rol

**Entregables**:
- ✅ Login funcional con Firebase Auth
- ✅ Control de sesión persistente
- ✅ Redirección automática según estado de autenticación
- ✅ Sistema de roles básico (Médico/Enfermera)

---

### FASE 2: Búsqueda y Visualización de Pacientes (Mejorar existente)
**Tiempo estimado**: 1-2 días  
**Funcionalidad objetivo**: 40%

#### 2.1 Búsqueda y Acceso a Pacientes Mejorado
**Requisito**: "Buscador rápido de pacientes asignados o recientes con filtros esenciales"

**Tareas**:
- [ ] **2.1.1** Mejorar búsqueda en lista de pacientes
  - Búsqueda por nombre, RUT, número de ficha
  - Filtros: Estado (activo/inactivo), Grupo sanguíneo, Edad
  - Vista de pacientes recientes (últimos 10)
  - Vista de pacientes asignados al usuario logueado
  
- [ ] **2.1.2** Optimizar UI de lista de pacientes
  - Añadir indicadores visuales (alertas, estado)
  - Mejorar cards con más información relevante
  - Añadir acciones rápidas (llamar, mensajes)
  
- [ ] **2.1.3** Implementar caché local
  - Guardar pacientes frecuentes en local
  - Sincronización offline básica

**Entregables**:
- ✅ Búsqueda mejorada con múltiples criterios
- ✅ Filtros funcionales
- ✅ Vista de pacientes recientes/asignados

---

### FASE 3: Visualización Detallada de Ficha Médica
**Tiempo estimado**: 3-4 días  
**Funcionalidad objetivo**: 55%

#### 3.1 Pantalla de Ficha Médica Completa ⭐ **CORE FEATURE**
**Requisito**: "Pantalla que muestra el resumen de la ficha, historial médico, alertas y planes de tratamiento activos"

**Tareas**:
- [ ] **3.1.1** Expandir modelo de Ficha Médica
  - Añadir campos faltantes (antecedentes, alergias, tratamientos)
  - Relación con consultas, exámenes, recetas
  
- [ ] **3.1.2** Crear página de visualización de ficha
  - `lib/features/fichas_medicas/pages/ficha_medica_detail_page.dart`
  - Tabs: Resumen, Historial, Alertas, Tratamientos, Exámenes
  
- [ ] **3.1.3** Tab: Resumen
  - Datos demográficos del paciente
  - Grupo sanguíneo, alergias destacadas
  - Última consulta
  - Estado actual
  
- [ ] **3.1.4** Tab: Historial Médico
  - Timeline de consultas ordenadas por fecha
  - Cards con resumen de cada consulta
  - Navegación a detalle de consulta
  
- [ ] **3.1.5** Tab: Alertas
  - Lista de alertas activas
  - Tipos: Alergia, Medicación, Próxima cita, Resultado crítico
  - Indicadores visuales por severidad
  
- [ ] **3.1.6** Tab: Tratamientos Activos
  - Planes de tratamiento en curso
  - Medicamentos actuales
  - Duración y dosis

**Entregables**:
- ✅ Vista completa de ficha médica con tabs
- ✅ Historial médico navegable
- ✅ Sistema de alertas visual
- ✅ Visualización de tratamientos activos

---

### FASE 4: Registro de Atención Médica
**Tiempo estimado**: 3-4 días  
**Funcionalidad objetivo**: 70%

#### 4.1 Módulo de Consultas/Atenciones ⭐ **CORE FEATURE**
**Requisito**: "Formulario para ingresar nuevas atenciones, diagnósticos y procedimientos realizados"

**Tareas**:
- [ ] **4.1.1** Crear modelos necesarios
  - `lib/models/consulta.dart` (ampliar si existe)
  - `lib/models/diagnostico.dart`
  - `lib/models/procedimiento.dart`
  - `lib/models/atencion_medica.dart`
  
- [ ] **4.1.2** Implementar servicio de consultas
  - `lib/services/consultas_service.dart`
  - CRUD completo de consultas
  - Asociación con paciente y ficha médica
  
- [ ] **4.1.3** Crear formulario de nueva atención
  - `lib/features/consultas/pages/nueva_atencion_page.dart`
  - Formulario multi-step (3 pasos)
  
- [ ] **4.1.4** Step 1: Información General
  - Fecha y hora
  - Motivo de consulta
  - Síntomas principales
  - Signos vitales (presión, temperatura, etc.)
  
- [ ] **4.1.5** Step 2: Diagnóstico y Evaluación
  - Diagnóstico principal
  - Diagnósticos secundarios
  - Procedimientos realizados
  - Observaciones
  
- [ ] **4.1.6** Step 3: Plan de Tratamiento
  - Indicaciones médicas
  - Medicamentos recetados
  - Exámenes solicitados
  - Próximo control
  
- [ ] **4.1.7** Implementar validaciones
  - Campos obligatorios
  - Formatos correctos
  - Confirmación antes de guardar

**Entregables**:
- ✅ Formulario completo de atención médica
- ✅ Proceso multi-step guiado
- ✅ Guardado en Firestore con relaciones correctas
- ✅ Validación de datos

---

## 📋 Backlog (Para el 30% restante - Futuro)

### FASE 5: Gestión de Órdenes y Recetas (15%)
- Módulo para generar recetas médicas
- Órdenes de exámenes
- Impresión/envío digital (PDF)

### FASE 6: Evolución y Notas Clínicas (5%)
- Secciones para agregar notas de evolución
- Comentarios en timeline de atenciones
- Historial de cambios

### FASE 7: Alertas y Notificaciones (5%)
- Notificaciones push
- Alertas sobre citas próximas
- Resultados críticos
- Tareas pendientes

### FASE 8: Módulo de Tareas/Pendientes (5%)
- Lista de pacientes con seguimiento
- Tareas asignadas por rol
- Sistema de recordatorios

---

## 🗂️ Estructura de Carpetas Propuesta

```
lib/
├── core/                          # ⭐ NUEVO
│   ├── guards/
│   │   └── auth_guard.dart
│   └── constants/
│       └── app_constants.dart
│
├── features/
│   ├── auth/                      # ⭐ NUEVO - FASE 1
│   │   ├── pages/
│   │   │   ├── login_page.dart
│   │   │   └── splash_page.dart
│   │   └── widgets/
│   │       └── login_form.dart
│   │
│   ├── pacientes/                 # ✅ Existente - Mejorar en FASE 2
│   │   ├── pages/
│   │   │   ├── patient_list_page.dart
│   │   │   ├── patient_detail_page.dart
│   │   │   └── patient_form_page.dart
│   │   └── widgets/
│   │       ├── patient_card.dart
│   │       └── patient_search_bar.dart
│   │
│   ├── fichas_medicas/            # ⭐ NUEVO - FASE 3
│   │   ├── pages/
│   │   │   └── ficha_medica_detail_page.dart
│   │   └── widgets/
│   │       ├── ficha_resumen_tab.dart
│   │       ├── ficha_historial_tab.dart
│   │       ├── ficha_alertas_tab.dart
│   │       └── ficha_tratamientos_tab.dart
│   │
│   ├── consultas/                 # ⭐ NUEVO - FASE 4
│   │   ├── pages/
│   │   │   ├── nueva_atencion_page.dart
│   │   │   └── consulta_detail_page.dart
│   │   └── widgets/
│   │       ├── atencion_step1_form.dart
│   │       ├── atencion_step2_form.dart
│   │       └── atencion_step3_form.dart
│   │
│   └── home/                      # ⭐ NUEVO - Reorganizar
│       └── pages/
│           └── home_page.dart
│
├── models/
│   ├── paciente.dart             # ✅ Existente
│   ├── ficha_medica.dart         # ✅ Existente - Ampliar
│   ├── user.dart                 # ⭐ NUEVO - FASE 1
│   ├── user_role.dart            # ⭐ NUEVO - FASE 1
│   ├── consulta.dart             # ⭐ NUEVO - FASE 4
│   ├── diagnostico.dart          # ⭐ NUEVO - FASE 4
│   ├── procedimiento.dart        # ⭐ NUEVO - FASE 4
│   ├── atencion_medica.dart      # ⭐ NUEVO - FASE 4
│   ├── alerta.dart               # ⭐ NUEVO - FASE 3
│   └── tratamiento.dart          # ⭐ NUEVO - FASE 3
│
├── services/
│   ├── auth_service.dart         # ⭐ NUEVO - FASE 1
│   ├── pacientes_service.dart    # ✅ Existente
│   ├── fichas_medicas_service.dart # ✅ Existente - Ampliar
│   ├── consultas_service.dart    # ⭐ NUEVO - FASE 4
│   └── weather_service.dart      # ✅ Existente
│
├── shared/
│   └── widgets/
│       ├── custom_button.dart    # ✅ Existente
│       ├── empty_state.dart      # ✅ Existente
│       ├── weather_widget.dart   # ✅ Existente
│       ├── loading_indicator.dart # ⭐ NUEVO
│       └── alert_badge.dart      # ⭐ NUEVO - FASE 3
│
└── utils/
    ├── app_colors.dart           # ✅ Existente
    ├── avatar_utils.dart         # ✅ Existente
    ├── validators.dart           # ✅ Existente
    └── date_formatter.dart       # ⭐ NUEVO
```

---

## 📈 Progreso Estimado por Fase

| Fase | Funcionalidad | % Acumulado | Tiempo | Prioridad |
|------|---------------|-------------|---------|-----------|
| **Estado Actual** | Pacientes CRUD | **20%** | - | - |
| **FASE 1** | Auth + Seguridad | **30%** | 2-3 días | ⭐⭐⭐ CRÍTICA |
| **FASE 2** | Búsqueda Mejorada | **40%** | 1-2 días | ⭐⭐ ALTA |
| **FASE 3** | Ficha Médica Completa | **55%** | 3-4 días | ⭐⭐⭐ CRÍTICA |
| **FASE 4** | Registro Atenciones | **70%** | 3-4 días | ⭐⭐⭐ CRÍTICA |
| **FASE 5-8** | Features adicionales | **100%** | Futuro | ⭐ MEDIA |

**Tiempo total estimado**: 9-13 días de desarrollo  
**Meta**: 70% de funcionalidad

---

## 🎯 Objetivos Claros por Fase

### Al completar FASE 1 (30%):
- ✅ Usuario puede hacer login
- ✅ Sesión se mantiene al cerrar/abrir app
- ✅ Sistema distingue entre Médico y Enfermera
- ✅ Solo usuarios autenticados acceden a la app

### Al completar FASE 2 (40%):
- ✅ Búsqueda rápida y efectiva de pacientes
- ✅ Filtros por múltiples criterios
- ✅ Vista de pacientes recientes y asignados

### Al completar FASE 3 (55%):
- ✅ Vista completa de ficha médica del paciente
- ✅ Historial médico navegable
- ✅ Sistema de alertas funcional
- ✅ Visualización de tratamientos activos

### Al completar FASE 4 (70%): 🎯 **META OBJETIVO**
- ✅ Médicos pueden registrar nuevas atenciones
- ✅ Formulario completo con validación
- ✅ Datos guardados correctamente en Firestore
- ✅ Relaciones entre paciente-ficha-consulta funcionando

---

## 🚀 Siguiente Paso Inmediato

### ⭐ EMPEZAR POR: FASE 1.1.1 - Configurar Firebase Authentication

**Acción inmediata**:
1. Ir a Firebase Console
2. Habilitar Authentication > Email/Password
3. Configurar reglas de Firestore para seguridad
4. Crear colección `users` en Firestore

**Comando para preparar**:
```bash
cd flutter
flutter pub add firebase_auth
flutter pub get
```

¿Quieres que comencemos con la implementación de la FASE 1 (Autenticación)?
