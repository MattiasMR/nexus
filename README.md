# 🏥 Nexus Medical - Sistema Completo

Sistema médico multi-aplicación con arquitectura distribuida para pacientes, médicos y administradores.

## 📱 Aplicaciones del Sistema

### 1. **Flutter** - Portal del Paciente ✅ COMPLETADO
- **Usuarios**: Pacientes
- **Ubicación**: `flutter/`
- **Estado**: ✅ Autenticación implementada y funcional
- **Tecnologías**: Flutter 3.9+, Provider, go_router, Firebase
- **Features**:
  - ✅ Login y Registro
  - ✅ Dashboard personalizado
  - 🔜 Mi Ficha Médica
  - 🔜 Subir Documentos
  - 🔜 Mis Citas
  - 🔜 Mis Recetas
- **Docs**: Ver `flutter/README.md` y `flutter/TESTING.md`

### 2. **Ionic** - App para Médicos 🔜 PENDIENTE
- **Usuarios**: Médicos, Enfermeras, Especialistas
- **Ubicación**: `ionic/`
- **Estado**: Estructura creada, pendiente adaptación
- **Tecnologías**: Angular 20, Ionic 8, Firebase, Capacitor
- **Features planificadas**:
  - Login médico con roles
  - Ver lista de pacientes
  - Crear consultas
  - Prescribir recetas
  - Solicitar exámenes

### 3. **Laravel** - Panel de Administración 🔜 PENDIENTE
- **Usuarios**: Administradores, Super Admins
- **Ubicación**: `laravel/`
- **Estado**: Estructura base creada
- **Features planificadas**:
  - Gestión de usuarios
  - Catálogos (medicamentos, exámenes)
  - Reportes y estadísticas
  - Configuración del sistema

## 🚀 Quick Start

### 1. Setup Inicial

```bash
# Clonar repositorio
git clone <repo-url>
cd nexus
```


## 🗄️ Base de Datos (Firestore)

### Colecciones Implementadas

#### `pacientes` ✅
Información de pacientes registrados.
```javascript
{
  email: "juan.perez@email.com",
  nombre: "Juan",
  apellido: "Pérez",
  rut: "18.234.567-8",
  telefono: "+56912345678",
  fechaNacimiento: "1990-05-15",
  sexo: "M",
  direccion: "Av. Los Héroes 1234, Santiago",
  prevision: "Fonasa",
  contactoEmergencia: "María Pérez",
  telefonoEmergencia: "+56987654321",
  activo: true,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### `fichas-medicas` ✅
Ficha médica de cada paciente.
```javascript
{
  idPaciente: "uid-del-paciente",
  grupoSanguineo: null,
  alergias: [],
  antecedentes: {
    familiares: null,
    personales: null,
    quirurgicos: null,
    hospitalizaciones: null
  },
  ultimaConsulta: null,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### Colecciones Planificadas 🔜
- `consultas` - Consultas médicas
- `documentos-paciente` - Documentos subidos por pacientes
- `citas` - Citas agendadas
- `recetas` - Recetas médicas
- `ordenes-examen` - Órdenes de exámenes

## 🔐 Seguridad

### Reglas de Firestore

Las reglas están en `firestore.rules`:

```javascript
// Los pacientes solo pueden ver sus propios datos
match /pacientes/{pacienteId} {
  allow read: if request.auth.uid == pacienteId;
}

// Los pacientes pueden subir sus documentos
match /documentos-paciente/{documentoId} {
  allow create: if request.auth.uid == request.resource.data.idPaciente;
}
```

### Deployment de Reglas

```bash
# Opción 1: Script bash
bash scripts/deploy-firestore-rules.sh

# Opción 2: Firebase CLI
firebase deploy --only firestore:rules
```

## 🧪 Testing

### Datos de Prueba

5 pacientes de prueba creados:

| Email | Password | Nombre |
|-------|----------|--------|
| juan.perez@email.com | password123 | Juan Pérez |
| ana.martinez@email.com | password123 | Ana Martínez |
| carlos.lopez@email.com | password123 | Carlos López |
| maria.silva@email.com | password123 | María Silva |
| pedro.rodriguez@email.com | password123 | Pedro Rodríguez |

### Guía Completa

Ver `flutter/TESTING.md` para casos de prueba detallados con 8 escenarios de testing.

## 📚 Documentación

- **Flutter App**: `flutter/README.md`
- **Testing Flutter**: `flutter/TESTING.md`
- **Scripts BD**: `scripts/README.md`
- **Modelo BD**: `Modelo_BDD.md`
- **Autenticación**: `AUTENTICACION_SISTEMA.md`

## 🛠️ Tecnologías

### Frontend
- **Flutter**: 3.9.2+ (Pacientes - Mobile/Web/Desktop)
- **Ionic + Angular**: 8.3.0 + 20.0.0 (Médicos - Mobile)
- **Laravel + Inertia + React**: (Admin - Web)

### Backend
- **Firebase Auth**: Autenticación unificada
- **Cloud Firestore**: Base de datos NoSQL en tiempo real
- **Firebase Storage**: Almacenamiento de archivos

### DevOps
- **Firebase Hosting**: Deploy de web apps
- **Node.js**: Scripts de administración y seed

## 📦 Scripts Útiles

```bash
# Crear pacientes de prueba
node scripts/seed-pacientes.js

# Limpiar pacientes
node scripts/clean-pacientes.js

# Poblar BD completa (legacy - sistema antiguo)
node scripts/seed-firestore.js

# Limpiar BD completa
node scripts/clean-firestore.js

# Deploy reglas Firestore
bash scripts/deploy-firestore-rules.sh
```

## 🎯 Roadmap

### ✅ Completado
- ✅ Autenticación de pacientes (Flutter)
- ✅ Registro de nuevos pacientes
- ✅ Dashboard básico para pacientes
- ✅ Scripts de seed de BD
- ✅ Reglas de seguridad Firestore
- ✅ Documentación completa

### 🚧 En Progreso
- Features de paciente (ficha médica, documentos, citas, recetas)

### 🔜 Próximamente
- App Ionic para médicos
- Panel Laravel para admins
- Notificaciones push
- Modo offline
- Chat en tiempo real

## 🔄 Workflow de Desarrollo

### Para App Flutter (Pacientes)

1. **Crear feature branch**
   ```bash
   git checkout -b feature/mi-ficha-medica
   ```

2. **Desarrollar**
   ```bash
   cd flutter
   flutter run
   ```

3. **Testing**
   - Ver `flutter/TESTING.md`
   - Probar con usuarios de prueba
   - Validar 8 casos de prueba principales

4. **Commit y Push**
   ```bash
   git add .
   git commit -m "feat: implementar mi ficha médica"
   git push origin feature/mi-ficha-medica
   ```

### Para Scripts de BD

1. **Modificar script**
   ```bash
   vim scripts/seed-pacientes.js
   ```

2. **Probar en ambiente local**
   ```bash
   node scripts/seed-pacientes.js
   ```

3. **Verificar en Firebase Console**

4. **Commit**
   ```bash
   git add scripts/
   git commit -m "chore: actualizar seed de pacientes"
   ```

## 🐛 Troubleshooting

### Error: serviceAccountKey.json no encontrado
```bash
# Solución: Descarga las credenciales de Firebase Console
Firebase Console > Project Settings > Service Accounts > Generate New Private Key
# Guarda como serviceAccountKey.json en la raíz
```

### Error: Firebase CLI no instalado
```bash
npm install -g firebase-tools
firebase login
```

### Error: Flutter no encuentra Firebase
```bash
cd flutter
flutter pub get
# Verifica que exista firebase_options.dart
```

### Error: Script seed falla
```bash
# Verifica que serviceAccountKey.json exista y sea válido
# Verifica conexión a internet
# Verifica que el proyecto Firebase esté activo
# Crear pacientes de prueba
node scripts/seed-pacientes.js

# Resultado:
# ✅ 5 usuarios en Firebase Auth
# ✅ 5 pacientes en Firestore  
# ✅ 5 fichas médicas vacías
```

### 4. Ejecutar App Flutter (Pacientes)

```bash
cd flutter
flutter pub get
flutter run
```

**Credenciales de prueba:**
- Email: `juan.perez@email.com`
- Password: `password123`

## 📁 Estructura del Proyecto

```
nexus/
├── flutter/                    # ✅ App para Pacientes
│   ├── lib/
│   │   ├── features/
│   │   │   └── auth/          # ✅ Login y Registro
│   │   ├── models/            # ✅ Usuario (paciente)
│   │   ├── services/          # ✅ AuthService
│   │   ├── providers/         # ✅ AuthProvider
│   │   └── main.dart          # ✅ Entry point + Dashboard
│   ├── README.md              # Documentación Flutter
│   └── TESTING.md             # Guía de testing completa
│
├── ionic/                     # 🔜 App para Médicos
│   └── src/
│
├── laravel/                   # 🔜 Panel Admin
│   └── app/
│
├── scripts/                   # ✅ Scripts de BD
│   ├── seed-pacientes.js      # ✅ Crear pacientes de prueba
│   ├── clean-pacientes.js     # ✅ Limpiar pacientes
│   ├── seed-firestore.js      # Sistema completo (legacy)
│   ├── clean-firestore.js     # Limpiar todo
│   └── README.md              # Documentación de scripts
│
├── firestore.rules            # ✅ Reglas de seguridad
├── firestore.indexes.json     # ✅ Índices de Firestore
├── firebase.json              # ✅ Config de Firebase
├── serviceAccountKey.json     # 🔒 Credenciales (no en git)
├── Modelo_BDD.md              # Modelo de base de datos
├── AUTENTICACION_SISTEMA.md   # Arquitectura de autenticación
└── README.md                  # Este archivo
```

## 📄 Licencia

Proyecto académico - Universidad del Desarrollo (UDD) 2025

## 👥 Autor

- Matías Márquez Reyes

---

**¿Necesitas ayuda?** 
- Revisa la documentación en `flutter/TESTING.md` para guía de testing
- Revisa `scripts/README.md` para uso de scripts de BD
- Contacta al equipo de desarrollo para soporte
