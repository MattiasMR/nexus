# Nexus Flutter - Aplicación para Personal Médico

Aplicación móvil nativa diseñada para médicos y profesionales de la salud del sistema Nexus. Permite gestionar atenciones médicas, consultas, recetas y seguimiento de pacientes en los hospitales donde el profesional está asignado.

## 🏥 Propósito de la Aplicación

**Nexus Flutter** es parte de un ecosistema multi-aplicación:

- **Flutter (esta app)**: Para **personal médico** (doctores, enfermeras, especialistas)
  - Gestionar consultas de pacientes en hospitales asignados
  - Crear y actualizar fichas médicas
  - Prescribir recetas médicas
  - Solicitar exámenes de laboratorio
  - Registrar hospitalizaciones
  - Ver historial médico de pacientes bajo su cuidado

- **Laravel Web**: Para **administradores hospitalarios y super admins**
  - Gestión de usuarios y permisos
  - Administración de catálogos (medicamentos, exámenes)
  - Reportes y estadísticas del hospital
  - Configuración del sistema

- **Ionic Mobile**: Para **pacientes**
  - Ver su propia ficha médica completa
  - Acceder a recetas y exámenes
  - Subir resultados de exámenes
  - Consultar historial de atenciones

## 🔐 Sistema de Autenticación

Utiliza **Firebase Authentication** con base de datos **Firestore** compartida entre las tres aplicaciones.

### Roles y Permisos

El personal médico puede:
- ✅ Ver y gestionar pacientes en **hospitales asignados solamente**
- ✅ Crear consultas médicas
- ✅ Prescribir recetas
- ✅ Solicitar exámenes
- ✅ Registrar hospitalizaciones
- ❌ NO puede ver datos de hospitales no asignados
- ❌ NO puede gestionar usuarios o configuraciones del sistema

### Multi-Hospital

Un profesional médico puede:
- Estar asignado a **múltiples hospitales** simultáneamente
- Ver pacientes que se han atendido en **cualquiera de sus hospitales**
- Los datos se filtran automáticamente según `hospitalesAsignados`

## 🚀 Tecnologías

- **Flutter**: SDK 3.9.2+
- **Dart**: 3.9.2+
- **Firebase Auth**: Autenticación unificada
- **Cloud Firestore**: Base de datos en tiempo real
- **Platforms**: Android, iOS, Web, Windows, Linux, macOS

## ✨ Características Implementadas

- ✅ Lista de Pacientes con datos en tiempo real
- ✅ Detalles de Paciente
- ✅ Formulario de Paciente (Crear/Editar)
- ✅ Lista de Fichas Médicas
- ✅ Integración con Firebase Firestore
- ✅ Widget de Clima (API pública)
- ✅ Diseño Material 3
- ✅ Navegación fluida

## 🔜 Próximas Características (Autenticación y Control de Acceso)

- [ ] **Login Screen** con Firebase Auth
- [ ] **Gestión de sesión** y persistencia
- [ ] **Selector de hospital** (para médicos multi-hospital)
- [ ] **Verificación de permisos** granulares
- [ ] **Filtrado automático** por hospitales asignados
- [ ] **Perfil de usuario** médico
- [ ] **Logout y cambio de hospital**

## 📁 Estructura del Proyecto

```
lib/
├── features/              # Módulos por funcionalidad
│   ├── auth/             # 🆕 Autenticación y login
│   │   ├── login_page.dart
│   │   ├── hospital_selector_page.dart
│   │   └── profile_page.dart
│   ├── pacientes/        # Gestión de pacientes
│   │   ├── patient_list_page.dart
│   │   ├── patient_detail_page.dart
│   │   └── patient_form_page.dart
│   ├── consultas/        # 🆕 Gestión de consultas médicas
│   ├── recetas/          # 🆕 Prescripción de recetas
│   └── examenes/         # 🆕 Solicitud de exámenes
├── models/               # Modelos de datos
│   ├── usuario.dart      # 🆕 Modelo de usuario/médico
│   ├── hospital.dart     # 🆕 Modelo de hospital
│   ├── paciente.dart
│   ├── ficha_medica.dart
│   ├── consulta.dart     # 🆕
│   └── receta.dart       # 🆕
├── services/             # Servicios de datos
│   ├── auth_service.dart         # 🆕 Autenticación
│   ├── permisos_service.dart     # 🆕 Verificación de permisos
│   ├── hospitales_service.dart   # 🆕 Gestión de hospitales
│   ├── pacientes_service.dart    
│   ├── fichas_medicas_service.dart
│   ├── consultas_service.dart    # 🆕
│   └── weather_service.dart
├── shared/               # Componentes compartidos
│   └── widgets/
│       ├── custom_button.dart
│       ├── empty_state.dart
│       ├── protected_route.dart  # 🆕 Protección de rutas
│       └── weather_widget.dart
├── utils/                # Utilidades
│   ├── app_colors.dart
│   ├── avatar_utils.dart
│   ├── validators.dart
│   └── permission_constants.dart # 🆕 Constantes de permisos
├── firebase_options.dart
└── main.dart
```

## 🛠️ Instalación

### Requisitos previos

- Flutter SDK 3.9.2 o superior
- Dart 3.9.2 o superior
- Android Studio / Xcode (para desarrollo móvil)
- Cuenta de Firebase configurada

### Pasos de instalación

1. **Instalar dependencias:**
```bash
flutter pub get
```

2. **Configurar Firebase:**
   - El proyecto ya incluye `firebase_options.dart`
   - Asegúrate de tener los archivos de configuración:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

3. **Verificar instalación:**
```bash
flutter doctor
```

## 🎯 Desarrollo

### Ejecutar en modo desarrollo

```bash
# Android
flutter run

# iOS (requiere macOS)
flutter run -d ios

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# Específicar dispositivo
flutter devices
flutter run -d <device-id>
```

### Build para producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle (para Play Store)
flutter build appbundle --release

# iOS (requiere macOS)
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

### Ejecutar tests

```bash
flutter test
```

### Análisis de código

```bash
flutter analyze
```

## 📱 Plataformas Soportadas

| Plataforma | Estado | Notas |
|------------|--------|-------|
| Android    | ✅     | API 21+ |
| iOS        | ✅     | iOS 12+ |
| Web        | ✅     | Navegadores modernos |
| Windows    | ✅     | Windows 10+ |
| Linux      | ✅     | Ubuntu 20.04+ |
| macOS      | ✅     | macOS 10.14+ |

## 🎨 Paleta de Colores

```dart
Primary: #3880ff
Primary Light: #5598ff
Success: #2dd36f
Warning: #ffc409
Danger: #eb445a
Dark: #222428
Medium: #92949c
Light: #f4f5f8
```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter: sdk
  
  # Firebase
  firebase_core: ^4.2.0
  firebase_auth: ^5.3.3          # 🆕 Autenticación
  cloud_firestore: ^6.0.3
  
  # Estado y Navigation
  provider: ^6.1.2               # 🆕 Gestión de estado
  go_router: ^14.0.0             # 🆕 Navegación y rutas protegidas
  
  # Utilidades
  intl: ^0.19.0
  http: ^1.2.0
  shared_preferences: ^2.2.0     # 🆕 Persistencia local
  
  # UI
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^5.0.0
```

## 🔥 Firebase

### Colecciones utilizadas

- `usuarios`: Autenticación y datos de usuarios del sistema
- `hospitales`: Información de hospitales del sistema
- `permisos-usuario`: Permisos granulares por usuario y hospital
- `pacientes`: Datos de pacientes (filtrado por hospitalesAsignados)
- `profesionales`: Datos del personal médico
- `fichas-medicas`: Fichas médicas de pacientes
- `consultas`: Consultas médicas (filtradas por hospitalesAsignados)
- `recetas`: Recetas médicas prescritas
- `examenes`: Órdenes de exámenes solicitados
- `hospitalizaciones`: Registros de hospitalizaciones

### Reglas de Seguridad Firestore

El sistema implementa reglas de seguridad basadas en:
- **Rol del usuario** (`custom claims` en Firebase Auth)
- **Hospitales asignados** (array en documento de usuario)
- **Permisos granulares** (colección `permisos-usuario`)

Ejemplo de regla para médicos:
```javascript
// Solo puede ver pacientes de hospitales asignados
match /pacientes/{pacienteId} {
  allow read: if request.auth != null 
    && request.auth.token.rol == 'medico'
    && request.auth.token.hospitalesAsignados.hasAny(
      resource.data.hospitalesAtendido
    );
}

// Solo puede crear consultas en hospitales asignados
match /consultas/{consultaId} {
  allow create: if request.auth != null
    && request.auth.token.rol == 'medico'
    && request.auth.token.hospitalesAsignados.hasAny([
      request.resource.data.idHospital
    ]);
}
```

## 🚧 Próximas Características

### Fase 1: Autenticación (En Progreso)
- [ ] Login con Firebase Auth (email/password)
- [ ] Gestión de sesión persistente
- [ ] Selector de hospital activo (para médicos multi-hospital)
- [ ] Pantalla de perfil de usuario
- [ ] Logout y manejo de tokens
- [ ] Verificación de permisos en tiempo real

### Fase 2: Gestión Médica
- [ ] Gestión de Consultas (CRUD completo)
- [ ] Prescripción de Recetas
- [ ] Solicitud de Exámenes de Laboratorio
- [ ] Registro de Hospitalizaciones
- [ ] Vista detallada de historial médico por paciente

### Fase 3: Funcionalidades Avanzadas
- [ ] Dashboard con estadísticas del médico
- [ ] Búsqueda avanzada de pacientes
- [ ] Filtros por hospital activo
- [ ] Notificaciones push para alertas médicas
- [ ] Modo offline con sincronización
- [ ] Exportar reportes médicos (PDF)
- [ ] Firma digital de documentos médicos

## 🔐 Flujo de Autenticación

### 1. Login
```dart
// Usuario ingresa email/password
final userCredential = await FirebaseAuth.instance
    .signInWithEmailAndPassword(email: email, password: password);

// Se obtienen los datos del usuario desde Firestore
final userDoc = await FirebaseFirestore.instance
    .collection('usuarios')
    .doc(userCredential.user!.uid)
    .get();

// Se verifican custom claims
final idTokenResult = await userCredential.user!.getIdTokenResult();
final rol = idTokenResult.claims?['rol'];
final hospitalesAsignados = idTokenResult.claims?['hospitalesAsignados'];

// Solo médicos pueden acceder a Flutter
if (rol != 'medico') {
  throw Exception('Acceso denegado: Solo personal médico');
}
```

### 2. Selector de Hospital (si tiene múltiples)
```dart
// Si hospitalesAsignados.length > 1
// Mostrar pantalla de selección
HospitalSelectorPage(hospitales: hospitalesAsignados);

// Guardar hospital activo en estado de la app
Provider.of<AuthProvider>(context, listen: false)
    .setActiveHospital(selectedHospital);
```

### 3. Verificación de Permisos
```dart
// Antes de crear una consulta
final hasPermission = await PermisosService.verificarPermiso(
  hospitalId: activeHospital,
  permiso: 'crear_consultas'
);

if (!hasPermission) {
  showDialog(/* No tienes permiso */);
  return;
}

// Proceder con la acción
await ConsultasService.crearConsulta(data);
```

### 4. Filtrado Automático
```dart
// Todas las queries se filtran por hospitales asignados
Query<Map<String, dynamic>> getPacientesQuery() {
  final hospitales = currentUser.hospitalesAsignados;
  
  return FirebaseFirestore.instance
      .collection('pacientes')
      .where('hospitalesAtendido', arrayContainsAny: hospitales);
}
```

## 📝 Notas de Desarrollo

### Windows específico
El proyecto incluye un workaround para problemas de snapshot streams en Windows, usando polling como fallback.

### Hot Reload
Flutter soporta hot reload para desarrollo rápido:
- `r`: Hot reload
- `R`: Hot restart
- `q`: Quit

## 🤝 Contribución

1. Crear rama para tu feature
2. Commits descriptivos
3. Tests para nuevas funcionalidades
4. Flutter analyze sin errores
5. Pull Request

## 📄 Licencia

Proyecto académico - UDD 2025
