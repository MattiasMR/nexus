# 📋 Sistema de Gestión de Fichas Médicas - ASCLE

Sistema web para la gestión integral de fichas médicas, pacientes, consultas y registros clínicos, desarrollado con Laravel, Vue.js e integrado con Firebase/Firestore.

## 🚀 Tecnologías Utilizadas

### Backend
- **Laravel 11+** - Framework PHP para desarrollo web
- **PHP 8.2.12** - Lenguaje de programación
- **Laravel Fortify** - Autenticación y gestión de usuarios
- **Firebase PHP SDK** (`kreait/firebase-php` v7.23.0) - Integración con Firebase
- **Google Cloud Firestore** - Base de datos NoSQL en la nube
- **Composer** - Gestor de dependencias PHP

### Frontend
- **Vue 3** - Framework JavaScript progresivo
- **TypeScript** - Superset tipado de JavaScript
- **Inertia.js** - Framework para crear SPAs con Laravel
- **Tailwind CSS** - Framework CSS utility-first
- **Lucide Vue** - Biblioteca de iconos
- **Vite** - Build tool y dev server

### Base de Datos
- **Firebase Firestore** - Base de datos principal (NoSQL)
- **SQLite** - Base de datos local para autenticación
- **gRPC 1.62.0** - Protocolo de comunicación con Firestore

### Extensiones PHP Requeridas
- `grpc` v1.62.0 - Comunicación con Google Cloud
- `sodium` - Criptografía y seguridad

## 📁 Estructura del Proyecto

```
ascle/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── DashboardController.php    # Controlador del dashboard
│   │   │   └── PacienteController.php     # CRUD de pacientes
│   │   └── Middleware/
│   ├── Models/
│   │   ├── User.php                       # Modelo de usuario
│   │   ├── Paciente.php                   # Modelo de paciente (Firestore)
│   │   ├── FichaMedica.php                # Modelo de ficha médica (Firestore)
│   │   └── Consulta.php                   # Modelo de consultas (Firestore)
│   └── Providers/
│       ├── AppServiceProvider.php
│       └── FirebaseServiceProvider.php    # Configuración de Firebase
├── config/
│   ├── firebase.php                       # Configuración de Firebase
│   └── fortify.php                        # Configuración de autenticación
├── resources/
│   ├── js/
│   │   ├── app.ts                         # Punto de entrada de Vue
│   │   ├── pages/
│   │   │   └── Dashboard.vue              # Componente del dashboard
│   │   └── layouts/
│   └── views/
│       └── app.blade.php                  # Layout principal Inertia
├── routes/
│   └── web.php                            # Rutas de la aplicación
├── storage/
│   └── app/
│       └── firebase-credentials.json      # Credenciales de Firebase
└── database/
    └── migrations/                        # Migraciones de base de datos
```

## 🗄️ Modelos de Datos (Firestore)

### Paciente
```php
- id: string
- rut: string
- nombre: string
- apellido: string
- fechaNacimiento: timestamp
- genero: string
- telefono: string
- email: string
- direccion: string
- alergias: array
- enfermedadesCronicas: array
- alertasMedicas: array
  - descripcion: string
  - severidad: string (baja|media|alta)
  - fecha: timestamp
- createdAt: timestamp
- updatedAt: timestamp
```

### FichaMedica
```php
- id: string
- pacienteId: string
- numeroFicha: string
- fechaCreacion: timestamp
- ultimaActualizacion: timestamp
- consultasRealizadas: number
- diagnosticoPrincipal: string
- observaciones: string
```

### Consulta
```php
- id: string
- fichaMedicaId: string
- pacienteId: string
- fecha: timestamp
- motivoConsulta: string
- diagnostico: string
- tratamiento: string
- profesionalId: string
- notas: array
```

### Profesional
```php
- id: string
- rut: string
- nombre: string
- apellido: string
- especialidad: string
- telefono: string
- email: string
- licencia: string
- createdAt: timestamp
- updatedAt: timestamp
```

### Examen
```php
- id: string
- nombre: string
- descripcion: string
- tipo: string (laboratorio|imagenologia|otro)
- codigo: string
- createdAt: timestamp
- updatedAt: timestamp
```

### Medicamento
```php
- id: string
- nombre: string
- nombreGenerico: string
- presentacion: string
- concentracion: string
- viaAdministracion: array
- createdAt: timestamp
- updatedAt: timestamp
```

### Diagnostico
```php
- id: string
- idConsulta: string
- idHospitalizacion: string
- codigo: string (CIE-10)
- descripcion: string
- tipo: string (principal|secundario)
- createdAt: timestamp
- updatedAt: timestamp
```

### Receta
```php
- id: string
- idPaciente: string
- idProfesional: string
- idConsulta: string
- fecha: timestamp
- medicamentos: array
  - idMedicamento: string
  - nombreMedicamento: string
  - dosis: string
  - frecuencia: string
  - duracion: string
  - indicaciones: string
- observaciones: string
- createdAt: timestamp
- updatedAt: timestamp
```

### Hospitalizacion
```php
- id: string
- idPaciente: string
- idProfesional: string
- fechaIngreso: timestamp
- fechaAlta: timestamp
- habitacion: string
- motivoIngreso: string
- observaciones: string
- intervencion: array
- createdAt: timestamp
- updatedAt: timestamp
```

### OrdenExamen
```php
- id: string
- idPaciente: string
- idProfesional: string
- idConsulta: string
- idHospitalizacion: string
- fecha: timestamp
- estado: string (pendiente|realizado|cancelado)
- examenes: array
  - idExamen: string
  - nombreExamen: string
  - resultado: string
  - fechaResultado: timestamp
  - documentos: array
    - url: string
    - nombre: string
    - tipo: string
    - tamanio: number
    - fechaSubida: timestamp
    - subidoPor: string
- createdAt: timestamp
- updatedAt: timestamp
```

## ✨ Funcionalidades Implementadas

### ✅ Autenticación
- [x] Sistema de login con Laravel Fortify
- [x] Registro de usuarios
- [x] 2FA deshabilitado para desarrollo
- [x] Credenciales de prueba: `test@example.com` / `password`

### ✅ Integración Firebase/Firestore
- [x] Conexión configurada con Firebase
- [x] Certificados SSL de gRPC configurados
- [x] Service Provider personalizado para Firebase
- [x] Variables de entorno configuradas

### ✅ Gestión de Pacientes
- [x] Modelo Paciente con métodos CRUD
- [x] Búsqueda de pacientes por RUT
- [x] Listado de todos los pacientes
- [x] Formateo de fechas con Carbon
- [x] Gestión de alertas médicas
- [x] API REST para pacientes (PacienteController)

### ✅ Dashboard
- [x] Vista principal con Inertia + Vue
- [x] Estadísticas de pacientes
- [x] Alertas médicas prioritarias
- [x] Diseño responsive con Tailwind CSS

### ✅ Rutas API
- [x] `/test-firebase` - Prueba de conexión con lista de pacientes
- [x] `/test-firebase-simple` - Verificación de extensiones PHP
- [x] `/dashboard` - Dashboard principal (requiere autenticación)

## 🔧 Configuración

### Variables de Entorno (.env)
```env
# Firebase Configuration
FIREBASE_CREDENTIALS=storage/app/firebase-credentials.json
FIREBASE_PROJECT_ID=nexus-68994
FIREBASE_DATABASE_URL=https://nexus-68994.firebaseio.com
FIREBASE_STORAGE_BUCKET=nexus-68994.appspot.com

# gRPC Configuration
GRPC_VERBOSITY=ERROR
GRPC_DEFAULT_SSL_ROOTS_FILE_PATH=C:/grpc/roots.pem
```

### Archivos de Configuración Importantes
- **firebase-credentials.json**: Credenciales del service account de Firebase
- **roots.pem**: Certificados SSL para gRPC (ubicado en `C:/grpc/`)

## 📦 Instalación

### Requisitos Previos
- PHP 8.2+
- Composer
- Node.js y npm
- Extensión gRPC 1.62.0
- Extensión Sodium

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd ascle
   ```

2. **Instalar dependencias de PHP**
   ```bash
   composer install
   ```

3. **Instalar dependencias de Node**
   ```bash
   npm install
   ```

4. **Configurar variables de entorno**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

5. **Descargar certificados SSL para gRPC**
   ```bash
   # Windows PowerShell
   New-Item -ItemType Directory -Force -Path "C:\grpc"
   Invoke-WebRequest -Uri "https://pki.google.com/roots.pem" -OutFile "C:\grpc\roots.pem"
   ```

6. **Colocar credenciales de Firebase**
   - Descargar el archivo de credenciales desde Firebase Console
   - Guardar en `storage/app/firebase-credentials.json`

7. **Ejecutar migraciones**
   ```bash
   php artisan migrate
   ```

8. **Compilar assets**
   ```bash
   npm run build
   # o para desarrollo:
   npm run dev
   ```

9. **Iniciar servidor**
   ```bash
   # Importante: Configurar variable de entorno para gRPC
   $env:GRPC_DEFAULT_SSL_ROOTS_FILE_PATH='C:/grpc/roots.pem'
   php artisan serve
   ```

## 🚀 Uso

### Iniciar el Servidor de Desarrollo

**Windows PowerShell:**
```powershell
cd C:\Users\milan\UDD\Tecnologias\ascle
$env:GRPC_DEFAULT_SSL_ROOTS_FILE_PATH='C:/grpc/roots.pem'
php artisan serve
```

Luego visita: `http://localhost:8000`

### Endpoints Disponibles

- **GET** `/` - Página de bienvenida
- **GET** `/login` - Página de login
- **GET** `/dashboard` - Dashboard principal (requiere auth)
- **GET** `/test-firebase` - Prueba de conexión Firebase con datos
- **GET** `/test-firebase-simple` - Verificación de extensiones

### Credenciales de Prueba
```
Email: test@example.com
Password: password
```

## 🔗 Integración con Proyecto Ionic

Este proyecto Laravel comparte la **misma base de datos Firebase** con la aplicación móvil Ionic (`nexus/`):

- **Proyecto Firebase**: `nexus-68994`
- **Colecciones compartidas**: 
  - `pacientes`
  - `fichasMedicas`
  - `consultas`
  - `examenes`
  - `medicamentos`

Los modelos TypeScript de la app Ionic se replicaron como modelos PHP en Laravel para mantener consistencia de datos.

## 🛠️ Próximas Funcionalidades

### En Desarrollo
- [ ] CRUD completo de pacientes en interfaz web
- [ ] Vista de detalle de paciente
- [ ] Gestión de fichas médicas
- [ ] Registro de consultas
- [ ] Historial clínico del paciente
- [ ] Gestión de exámenes médicos
- [ ] Recetas y medicamentos
- [ ] Dashboard con gráficos y estadísticas
- [ ] Búsqueda avanzada de pacientes
- [ ] Exportación de reportes (PDF)

### Mejoras Planificadas
- [ ] Sistema de roles y permisos
- [ ] Notificaciones en tiempo real
- [ ] Agenda de citas médicas
- [ ] Sincronización offline
- [ ] Respaldo automático de datos
- [ ] Auditoría de cambios
- [ ] API REST completa documentada

## 🐛 Resolución de Problemas

### El servidor se cae al acceder a rutas de Firebase

**Solución**: Asegúrate de que la variable de entorno `GRPC_DEFAULT_SSL_ROOTS_FILE_PATH` esté configurada:

```powershell
$env:GRPC_DEFAULT_SSL_ROOTS_FILE_PATH='C:/grpc/roots.pem'
```

### Error: "No root certs in config"

**Solución**: Descarga los certificados SSL de Google:

```powershell
Invoke-WebRequest -Uri "https://pki.google.com/roots.pem" -OutFile "C:\grpc\roots.pem"
```

### PHP se congela al conectar con Firestore

**Solución**: Verifica la versión de gRPC. Debe ser 1.62.0, no 1.76.0:

```bash
php -r "echo phpversion('grpc');"
```

### Error: "Firebase credentials file not found"

**Solución**: Verifica que el archivo existe en la ruta correcta:

```bash
storage/app/firebase-credentials.json
```

## 📝 Notas Técnicas

### Configuración de gRPC en Windows
- **Versión estable**: gRPC 1.62.0
- **Versión problemática**: gRPC 1.76.0 (causa congelamiento en Windows)
- Certificados SSL requeridos en `C:/grpc/roots.pem`

### Estructura de Firebase
El proyecto usa Firebase/Firestore como base de datos principal, manteniendo SQLite solo para la tabla de usuarios de Laravel (autenticación).

### Conversión de Fechas
Las fechas de Firestore (Timestamp) se convierten automáticamente a Carbon en los modelos para facilitar su manipulación en Laravel.

## 👥 Equipo de Desarrollo

- **Desarrollador Principal**: [Tu nombre]
- **Framework**: Laravel + Vue + Firebase
- **Fecha de Inicio**: Noviembre 2025

## 📄 Licencia

[Especificar licencia]

## 🔗 Enlaces Útiles

- [Documentación de Laravel](https://laravel.com/docs)
- [Documentación de Vue 3](https://vuejs.org/)
- [Firebase PHP SDK](https://github.com/kreait/firebase-php)
- [Inertia.js](https://inertiajs.com/)
- [Tailwind CSS](https://tailwindcss.com/)

---

**Última actualización**: Noviembre 8, 2025
