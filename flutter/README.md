# Nexus Flutter - Portal del Paciente

Aplicación móvil nativa diseñada para **pacientes** del sistema Nexus Medical. Permite a los pacientes gestionar su salud de manera fácil y segura: ver su ficha médica, subir documentos, consultar recetas y agendar citas.

## 🏥 Propósito de la Aplicación

**Nexus Flutter** es parte de un ecosistema multi-aplicación:

- **Flutter (esta app)**: Para **PACIENTES**
  - Ver mi ficha médica completa
  - Acceder a mis recetas médicas
  - Ver resultados de exámenes
  - Subir documentos médicos (imágenes, PDFs)
  - Agendar y gestionar citas médicas
  - Consultar historial de atenciones
  - Actualizar datos personales

- **Ionic Mobile**: Para **MÉDICOS** (doctores, enfermeras, especialistas)
  - Gestionar consultas de pacientes
  - Crear y actualizar fichas médicas
  - Prescribir recetas médicas
  - Solicitar exámenes de laboratorio
  - Registrar hospitalizaciones

- **Laravel Web**: Para **ADMINISTRADORES** hospitalarios y super admins
  - Gestión de usuarios y permisos
  - Administración de catálogos (medicamentos, exámenes)
  - Reportes y estadísticas del hospital
  - Configuración del sistema

## 🔐 Sistema de Autenticación

Utiliza **Firebase Authentication** con base de datos **Firestore** compartida entre las tres aplicaciones.

### Funcionalidades de Autenticación

- ✅ **Registro de nuevos pacientes** con email y contraseña
- ✅ **Inicio de sesión** con credenciales
- ✅ **Recuperación de contraseña** por email
- ✅ **Recordar sesión** en el dispositivo
- ✅ **Cierre de sesión** seguro

### Datos del Paciente

Cada paciente tiene:
- Información personal (nombre, apellido, RUT, teléfono)
- Email de acceso
- Fecha de nacimiento y sexo (opcional)
- Previsión de salud (opcional)
- Contacto de emergencia (opcional)
- Foto de perfil (opcional)

## 🚀 Tecnologías

- **Flutter**: SDK 3.9.2+
- **Dart**: 3.9.2+
- **Firebase Auth**: Autenticación de pacientes
- **Cloud Firestore**: Base de datos en tiempo real
- **Provider**: Gestión de estado
- **go_router**: Navegación declarativa
- **Platforms**: Android, iOS, Web

## ✨ Características Implementadas

### Autenticación
- ✅ Pantalla de Login
- ✅ Pantalla de Registro
- ✅ Recuperación de contraseña
- ✅ Gestión de sesión persistente
- ✅ AuthProvider con Provider pattern

### Dashboard
- ✅ Pantalla principal con accesos rápidos
- ✅ Bienvenida personalizada
- ✅ Grid de opciones principales

## 🔜 Próximas Características

### Ficha Médica
- [ ] Ver historial de consultas
- [ ] Ver diagnósticos
- [ ] Ver antecedentes médicos
- [ ] Actualizar información personal

### Documentos
- [ ] Subir documentos (imágenes, PDFs)
- [ ] Ver documentos subidos
- [ ] Compartir documentos con médicos
- [ ] Categorizar documentos

### Citas Médicas
- [ ] Agendar nueva cita
- [ ] Ver citas programadas
- [ ] Cancelar o reprogramar citas
- [ ] Notificaciones de recordatorio

### Recetas
- [ ] Ver recetas activas
- [ ] Ver historial de recetas
- [ ] Detalles de medicamentos

## 📁 Estructura del Proyecto

```
lib/
├── features/              # Módulos por funcionalidad
│   ├── auth/             # ✅ Autenticación
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── ficha_medica/     # 🔜 Mi ficha médica
│   ├── documentos/       # 🔜 Mis documentos
│   ├── citas/            # 🔜 Mis citas
│   └── recetas/          # 🔜 Mis recetas
├── models/               # Modelos de datos
│   ├── usuario.dart      # ✅ Modelo de paciente
│   ├── documento.dart    # 🔜 Modelo de documento
│   ├── cita.dart         # 🔜 Modelo de cita
│   └── receta.dart       # 🔜 Modelo de receta
├── services/             # Servicios de datos
│   ├── auth_service.dart         # ✅ Autenticación
│   ├── documentos_service.dart   # 🔜 Gestión de documentos
│   ├── citas_service.dart        # 🔜 Gestión de citas
│   └── recetas_service.dart      # 🔜 Gestión de recetas
├── providers/            # State management
│   └── auth_provider.dart        # ✅ Provider de autenticación
├── shared/               # Componentes compartidos
│   └── widgets/
│       ├── custom_button.dart
│       └── empty_state.dart
├── utils/                # Utilidades
│   ├── app_colors.dart
│   └── validators.dart
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
## 📦 Dependencias Principales

```yaml
dependencies:
  flutter: sdk
  
  # Firebase
  firebase_core: ^4.0.1
  firebase_auth: ^6.0.3          # ✅ Autenticación
  cloud_firestore: ^6.0.3
  
  # Estado y Navigation
  provider: ^6.1.2               # ✅ Gestión de estado
  go_router: ^14.6.2             # ✅ Navegación declarativa
  
  # Utilidades
  intl: ^0.19.0
  shared_preferences: ^2.3.3     # ✅ Persistencia local
  
  # UI
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^5.0.0
```

## 🔥 Firebase

### Colecciones utilizadas

- `pacientes`: **Datos del paciente** (documento por usuario autenticado)
  - Información personal (nombre, RUT, teléfono, etc.)
  - Datos de contacto de emergencia
  - Previsión de salud
  
- `fichas-medicas`: **Ficha médica del paciente**
  - Antecedentes médicos
  - Alergias
  - Enfermedades crónicas
  
- `consultas`: **Historial de consultas médicas**
  - Diagnósticos
  - Tratamientos
  - Notas médicas
  
- `documentos-paciente`: **Documentos subidos por el paciente**
  - Exámenes de laboratorio
  - Imágenes médicas
  - PDFs y archivos
  
- `recetas`: **Recetas médicas del paciente**
  - Medicamentos prescritos
  - Dosificación
  - Vigencia

- `citas`: **Citas médicas agendadas**
  - Fecha y hora
  - Médico asignado
  - Hospital
  - Estado (pendiente, confirmada, cancelada)

### Reglas de Seguridad Firestore

El sistema implementa reglas de seguridad basadas en:
- **Autenticación del usuario** (debe estar logueado)
- **UID del paciente** (solo puede ver sus propios datos)

Ejemplo de reglas para pacientes:
```javascript
// Solo puede ver su propia ficha médica
match /pacientes/{pacienteId} {
  allow read, write: if request.auth != null 
    && request.auth.uid == pacienteId;
}

// Solo puede ver sus propias consultas
match /consultas/{consultaId} {
  allow read: if request.auth != null
    && request.auth.uid == resource.data.idPaciente;
}

// Puede subir sus propios documentos
match /documentos-paciente/{documentoId} {
  allow create: if request.auth != null
    && request.auth.uid == request.resource.data.idPaciente;
  allow read, update, delete: if request.auth != null
    && request.auth.uid == resource.data.idPaciente;
}
```

## 🚧 Roadmap de Desarrollo

### ✅ Fase 1: Autenticación (COMPLETADA)
- ✅ Login con Firebase Auth (email/password)
- ✅ Registro de nuevos pacientes
- ✅ Gestión de sesión persistente
- ✅ Recuperación de contraseña
- ✅ AuthProvider con Provider pattern
- ✅ Navegación con go_router

### 🔜 Fase 2: Información Personal
- [ ] Ver perfil completo del paciente
- [ ] Editar información personal
- [ ] Actualizar foto de perfil
- [ ] Agregar contacto de emergencia

### 🔜 Fase 3: Ficha Médica
- [ ] Ver ficha médica completa
- [ ] Ver historial de consultas
- [ ] Ver diagnósticos y tratamientos
- [ ] Agregar alergias y antecedentes

### 🔜 Fase 4: Documentos Médicos
- [ ] Subir documentos (cámara/galería)
- [ ] Subir PDFs
- [ ] Categorizar documentos
- [ ] Compartir con médicos
- [ ] Eliminar documentos

### 🔜 Fase 5: Citas Médicas
- [ ] Agendar nueva cita
- [ ] Ver citas programadas
- [ ] Cancelar/reprogramar citas
- [ ] Notificaciones de recordatorio
- [ ] Ver ubicación del hospital

### 🔜 Fase 6: Recetas Médicas
- [ ] Ver recetas activas
- [ ] Ver historial de recetas
- [ ] Información de medicamentos
- [ ] Descargar recetas (PDF)

## 🔐 Flujo de Autenticación

### 1. Registro de Nuevo Paciente
```dart
// Usuario completa formulario de registro
final userCredential = await FirebaseAuth.instance
    .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

// Se crea documento en Firestore (colección pacientes)
await FirebaseFirestore.instance
    .collection('pacientes')
    .doc(userCredential.user!.uid)
    .set({
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'rut': rut,
      'telefono': telefono,
      'activo': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
```

### 2. Login
```dart
// Usuario ingresa email/password
final userCredential = await FirebaseAuth.instance
    .signInWithEmailAndPassword(email: email, password: password);

// Se obtienen los datos del paciente desde Firestore
final pacienteDoc = await FirebaseFirestore.instance
    .collection('pacientes')
    .doc(userCredential.user!.uid)
    .get();

// Verificar que esté activo
if (!pacienteDoc.data()?['activo']) {
  throw Exception('Usuario inactivo');
}

// Actualizar último acceso
await pacienteDoc.reference.update({
  'ultimoAcceso': FieldValue.serverTimestamp(),
});
```

### 3. Sesión Persistente
```dart
// Al iniciar la app, verificar si hay sesión activa
final currentUser = FirebaseAuth.instance.currentUser;

if (currentUser != null) {
  // Cargar datos del paciente
  final paciente = await getPacienteData(currentUser.uid);
  
  // Actualizar estado de la app
  authProvider.setCurrentUser(paciente);
}
```

### 4. Recuperación de Contraseña
```dart
// Enviar email de recuperación
await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

// Firebase envía email automáticamente con link de reset
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
