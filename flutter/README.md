# Nexus Flutter - Aplicación Móvil Nativa

Aplicación móvil nativa para el sistema de gestión médica Nexus, desarrollada con Flutter.

## 🚀 Tecnologías

- **Flutter**: SDK 3.9.2+
- **Dart**: 3.9.2+
- **Firebase**: Core, Cloud Firestore
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

## 📁 Estructura del Proyecto

```
lib/
├── features/           # Módulos por funcionalidad
│   └── pacientes/     # Gestión de pacientes
│       ├── patient_list_page.dart
│       ├── patient_detail_page.dart
│       └── patient_form_page.dart
├── models/            # Modelos de datos
│   ├── paciente.dart
│   └── ficha_medica.dart
├── services/          # Servicios de datos
│   ├── pacientes_service.dart
│   ├── fichas_medicas_service.dart
│   └── weather_service.dart
├── shared/            # Componentes compartidos
│   └── widgets/
│       ├── custom_button.dart
│       ├── empty_state.dart
│       └── weather_widget.dart
├── utils/             # Utilidades
│   ├── app_colors.dart
│   ├── avatar_utils.dart
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
  firebase_core: ^4.2.0
  cloud_firestore: ^6.0.3
  intl: ^0.19.0
  http: ^1.2.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^5.0.0
```

## 🔥 Firebase

### Colecciones utilizadas

- `pacientes`: Datos de pacientes
- `fichas-medicas`: Fichas médicas
- `consultas`: Consultas médicas (próximamente)
- `examenes`: Órdenes de exámenes (próximamente)
- `medicamentos`: Catálogo de medicamentos (próximamente)

### Reglas de seguridad

Ver `firebase.json` para la configuración de Firebase.

## 🚧 Próximas Características

- [ ] Gestión de Fichas Médicas (CRUD completo)
- [ ] Gestión de Consultas
- [ ] Gestión de Exámenes
- [ ] Gestión de Recetas
- [ ] Catálogo de Medicamentos
- [ ] Dashboard con estadísticas
- [ ] Autenticación de usuarios
- [ ] Modo offline con sincronización
- [ ] Notificaciones push
- [ ] Búsqueda y filtros avanzados

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
