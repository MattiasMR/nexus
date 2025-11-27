# 🔐 Plan de Implementación: Firebase Authentication + JWT Tokens

## 📊 Información del Proyecto

**Firebase Project ID:** `nexus-68994`  
**Base de datos:** Firestore  
**Aplicaciones:**
- 🌐 **Laravel (Web)** - Perfil Admin
- 📱 **Ionic (Angular)** - Perfil Profesional  
- 📲 **Flutter** - Perfil Paciente

---

## 🗂️ Estructura de Base de Datos Firestore (Actualizada - Noviembre 2025)

> ⚠️ **IMPORTANTE:** Esta es la arquitectura normalizada sin duplicación de datos.
> Usuario es la tabla central, Paciente y Profesional solo contienen datos específicos.

### Colección: `usuarios` (CENTRAL - Autenticación + Datos Personales)
```javascript
{
  id: "auto-generated-firebase-uid",  // UID de Firebase Authentication (PK)
  
  // Datos de autenticación
  email: "usuario@example.com",       // ÚNICO - Requerido
  emailVerified: true,
  
  // Datos personales (NO duplicar en pacientes/profesionales)
  displayName: "Nombre Completo",     // REQUERIDO
  rut: "12.345.678-9",                // ÚNICO - Requerido (validación módulo 11)
  telefono: "+56912345678",           // Opcional
  photoURL: "https://...",            // Opcional
  
  // Control de acceso
  rol: "admin" | "profesional" | "paciente",  // REQUERIDO
  activo: true,                       // REQUERIDO
  
  // Referencias (nullable - vincular con datos específicos)
  idPaciente: "id-documento-paciente" | null,      // Solo si rol='paciente'
  idProfesional: "id-documento-profesional" | null, // Solo si rol='profesional'
  
  // Timestamps
  createdAt: Timestamp,
  updatedAt: Timestamp,
  ultimoAcceso: Timestamp
}
```

### Colección: `pacientes` (Solo datos médicos - NO duplicar email, rut, nombre, telefono)
```javascript
{
  id: "auto-generated",
  
  // Referencia a usuario (OBLIGATORIO - todo paciente debe tener usuario)
  idUsuario: "firebase-uid",  // FK a usuarios.id - REQUERIDO
  
  // ⚠️ NO incluir: email, rut, nombre, apellido, telefono
  // Estos datos están en la colección 'usuarios'
  
  // Solo datos médicos específicos
  fechaNacimiento: Timestamp,
  grupoSanguineo: "A+" | "A-" | "B+" | "B-" | "AB+" | "AB-" | "O+" | "O-",
  alergias: ["Polen", "Penicilina"],
  enfermedadesCronicas: ["Diabetes", "Hipertensión"],
  medicamentosActuales: [
    {
      nombre: "Metformina",
      dosis: "850mg",
      frecuencia: "Cada 12 horas"
    }
  ],
  contactoEmergencia: {
    nombre: "María Pérez",
    telefono: "+56987654321",
    relacion: "Esposa"
  },
  prevision: "FONASA" | "ISAPRE" | "Particular",
  numeroFicha: "FP-2024-001",
  observaciones: "Paciente alérgico a...",
  
  // Timestamps
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Colección: `profesionales` (Solo datos profesionales - NO duplicar email, rut, nombre, telefono)
```javascript
{
  id: "auto-generated",
  
  // Referencia a usuario (OBLIGATORIO - todo profesional debe tener usuario)
  idUsuario: "firebase-uid",  // FK a usuarios.id - REQUERIDO
  
  // ⚠️ NO incluir: email, rut, nombre, apellido, telefono
  // Estos datos están en la colección 'usuarios'
  
  // Solo datos profesionales específicos
  especialidad: "Cardiología",
  subespecialidad: "Electrofisiología",  // Opcional
  licenciaMedica: "12345",
  experienciaAnios: 15,
  curriculum: "Especialista en...",
  
  // Configuración de atención
  horarioAtencion: {
    lunes: { inicio: "09:00", fin: "18:00" },
    martes: { inicio: "09:00", fin: "18:00" },
    // ...
  },
  valorConsulta: 50000,
  tiempoConsulta: 30,  // minutos
  
  // Timestamps
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Colección: `permisos-usuario`
```javascript
{
  id: "auto-generated",
  idUsuario: "firebase-uid",  // FK a usuarios
  idHospital: "RSAlN3zsmWzeoY3z9GzN",
  permisos: [
    "gestionar_usuarios",
    "ver_pacientes",
    "comprar_bonos"
    // ... según el rol
  ],
  createdAt: Timestamp,
  updatedAt: Timestamp,
  fechaInicio: Timestamp
}
```

### Colección: `hospitales`
```javascript
{
  id: "RSAlN3zsmWzeoY3z9GzN",
  nombre: "Hospital Regional",
  direccion: "Av. Principal 123",
  telefono: "+56212345678",
  // ... otros campos
}
```

---

## 📐 Diagrama de Relaciones

```
┌─────────────────────────────────────────┐
│            USUARIOS (Central)           │
│─────────────────────────────────────────│
│ id (Firebase UID) ◄─────────────────┐   │
│ email * (único)                     │   │
│ displayName *                       │   │
│ rut * (único, validación módulo 11) │   │
│ telefono                            │   │
│ photoURL                            │   │
│ rol * (admin|profesional|paciente)  │   │
│ activo *                            │   │
│ idPaciente (nullable) ──────┐       │   │
│ idProfesional (nullable) ───┼───┐   │   │
└─────────────────────────────┼───┼───┼───┘
                              │   │   │
        ┌─────────────────────┘   │   │
        │                         │   │
        ▼                         │   │
┌─────────────────────┐           │   │
│     PACIENTES       │           │   │
│─────────────────────│           │   │
│ id (PK)             │           │   │
│ idUsuario (FK) *────┼───────────┘   │
│ fechaNacimiento     │               │
│ grupoSanguineo      │               │
│ alergias []         │               │
│ contactoEmergencia  │               │
│ prevision           │               │
└─────────────────────┘               │
                                      │
        ┌─────────────────────────────┘
        │
        ▼
┌─────────────────────┐
│   PROFESIONALES     │
│─────────────────────│
│ id (PK)             │
│ idUsuario (FK) *────┼───────────┐
│ especialidad        │           │
│ licenciaMedica      │           │
│ horarioAtencion     │           │
│ valorConsulta       │           │
└─────────────────────┘           │
                                  │
                                  └──► usuarios.id
```

**Relaciones:**
- 1 Usuario puede tener 0 o 1 Paciente (si rol='paciente')
- 1 Usuario puede tener 0 o 1 Profesional (si rol='profesional')
- 1 Paciente DEBE tener 1 Usuario (idUsuario obligatorio)
- 1 Profesional DEBE tener 1 Usuario (idUsuario obligatorio)

**Para obtener datos completos:**
```javascript
// Ejemplo: Obtener paciente con datos de usuario
const paciente = await getPaciente(pacienteId);
const usuario = await getUsuario(paciente.idUsuario);

// Datos completos del paciente:
{
  // Datos médicos (de pacientes)
  ...paciente,
  
  // Datos personales (de usuarios)
  displayName: usuario.displayName,
  email: usuario.email,
  rut: usuario.rut,
  telefono: usuario.telefono,
  photoURL: usuario.photoURL
}
```

---

## 🎯 Arquitectura de Autenticación

```
┌─────────────────────────────────────────────────────────────┐
│              FIREBASE AUTHENTICATION (Centro)               │
│              - Email/Password                               │
│              - Google OAuth                                 │
│              - Facebook OAuth                               │
│              - Genera JWT Tokens                            │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   LARAVEL    │    │    IONIC     │    │   FLUTTER    │
│   (Admin)    │    │(Profesional) │    │  (Paciente)  │
│              │    │              │    │              │
│ 1. SignIn    │    │ 1. SignIn    │    │ 1. SignIn    │
│ 2. Get Token │    │ 2. Get Token │    │ 2. Get Token │
│ 3. Verify    │    │ 3. Verify    │    │ 3. Verify    │
│    rol=admin │    │    rol=prof  │    │    rol=pac   │
└──────────────┘    └──────────────┘    └──────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                            ▼
        ┌─────────────────────────────────────┐
        │      FIRESTORE DATABASE             │
        │  - usuarios                         │
        │  - permisos-usuario                 │
        │  - pacientes                        │
        │  - hospitales                       │
        └─────────────────────────────────────┘
```

---

## 📋 FASE 1: Configuración de Firebase Authentication

### ✅ Tareas Previas

1. **Habilitar Firebase Authentication en Firebase Console**
   - Ir a: https://console.firebase.google.com/project/nexus-68994/authentication
   - Habilitar proveedores:
     - ✅ Email/Password
     - ✅ Google (opcional)
     - ✅ Facebook (opcional)

2. **Verificar credenciales Firebase**
   - ✅ Archivo existe: `laravel/storage/app/firebase-credentials.json`
   - ✅ Variables de entorno configuradas en `.env`

3. **Crear usuarios en Firebase Authentication**
   - Opción A: Manualmente en Firebase Console
   - Opción B: Script automático (recomendado)

---

## 🚀 FASE 2: Implementación Laravel (Admin)

### 📝 Paso 1: Actualizar Modelo Usuario

**Archivo:** `app/Models/Usuario.php`

**✅ Cambios ya implementados:**
- Modelo usa Firestore como backend
- Implementa interfaz `Authenticatable` de Laravel
- Validación de RUT único con `rutExists()`
- Validación de email único con `emailExists()`
- Métodos de relación: `findByPacienteId()`, `findByProfesionalId()`

**Campos del modelo:**
```php
// Campos REQUERIDOS al crear usuario
[
    'email' => 'string|email|unique',      // Validación en Firestore
    'displayName' => 'string|required',    
    'rut' => 'string|unique',              // Validación módulo 11
    'rol' => 'admin|profesional|paciente',
]

// Campos OPCIONALES
[
    'telefono' => 'string|nullable',
    'photoURL' => 'url|nullable',
    'activo' => 'boolean|default:true',
    'idPaciente' => 'string|nullable',     // Solo si rol='paciente'
    'idProfesional' => 'string|nullable',  // Solo si rol='profesional'
]
```

**Métodos importantes:**
```php
// Autenticación
Usuario::findByFirebaseUid(string $firebaseUid): ?array
Usuario::createFromFirebaseUser(array $firebaseUser): array
Usuario::updateFirebaseUid(string $id, string $firebaseUid): array

// Validaciones
Usuario::emailExists(string $email): bool
Usuario::rutExists(string $rut): bool

// Relaciones
Usuario::findByPacienteId(string $idPaciente): ?array
Usuario::findByProfesionalId(string $idProfesional): ?array
Usuario::pacienteHasUser(string $idPaciente): bool
Usuario::profesionalHasUser(string $idProfesional): bool

// Consultas por rol
Usuario::getByRole(string $rol): array  // 'admin', 'profesional', 'paciente'
Usuario::getActive(): array
```

---

### 📝 Paso 1.5: Actualizar Modelos Paciente y Profesional

**Archivo:** `app/Models/Paciente.php`

**✅ Cambios ya implementados:**
- Requiere `idUsuario` obligatorio en `create()`
- NO incluye campos duplicados (email, rut, nombre, telefono)
- Métodos para obtener datos completos con join a usuarios

**Campos del modelo Paciente:**
```php
// Campo OBLIGATORIO
[
    'idUsuario' => 'string|required|exists:usuarios,id',
]

// Campos médicos específicos (NO duplicar datos de usuario)
[
    'fechaNacimiento' => 'date|nullable',
    'grupoSanguineo' => 'string|nullable',
    'alergias' => 'array|nullable',
    'enfermedadesCronicas' => 'array|nullable',
    'medicamentosActuales' => 'array|nullable',
    'contactoEmergencia' => 'array|nullable',
    'prevision' => 'string|nullable',
    'numeroFicha' => 'string|nullable',
    'observaciones' => 'text|nullable',
]
```

**Métodos importantes:**
```php
// Consultas con JOIN
Paciente::findWithUser(string $id): ?array          // Paciente + datos de usuario
Paciente::allWithUsers(): array                     // Todos con datos de usuario
Paciente::findByUsuarioId(string $idUsuario): ?array

// CRUD
Paciente::create(array $data): string               // Valida que exista idUsuario
Paciente::update(string $id, array $data): bool     // Previene cambio de idUsuario
Paciente::delete(string $id): bool                  // Limpia referencia en usuario

// Búsqueda (deprecated - usar búsqueda en usuarios)
Paciente::search(string $query): array              // Busca en usuarios primero
```

**Archivo:** `app/Models/Profesional.php`

**Estructura similar a Paciente:**
```php
// Campo OBLIGATORIO
[
    'idUsuario' => 'string|required|exists:usuarios,id',
]

// Campos profesionales específicos
[
    'especialidad' => 'string|nullable',
    'subespecialidad' => 'string|nullable',
    'licenciaMedica' => 'string|nullable',
    'experienciaAnios' => 'integer|nullable',
    'curriculum' => 'text|nullable',
    'horarioAtencion' => 'array|nullable',
    'valorConsulta' => 'numeric|nullable',
    'tiempoConsulta' => 'integer|nullable',
]
```

---

### 📝 Paso 1.6: Controladores para Crear Pacientes y Profesionales

**⚠️ IMPORTANTE: Proceso de Creación en 2 Pasos**

Al crear un paciente o profesional, **SIEMPRE** se debe crear primero el usuario. No se puede crear un paciente/profesional sin usuario asociado.

**Archivo:** `app/Http/Controllers/UsuarioController.php`

**Método `store()` - Crear usuario (CON creación automática de paciente/profesional):**

```php
public function store(Request $request)
{
    // 1. Validar datos del usuario
    $validated = $request->validate([
        'displayName' => 'required|string|max:255',
        'email' => 'required|email|max:255',
        'rut' => 'required|string|max:12',
        'telefono' => 'nullable|string|max:20',
        'rol' => 'required|in:admin,profesional,paciente',
        'password' => 'required|string|min:6|confirmed',
    ]);

    // 2. Crear usuario en Firebase Auth
    $auth = app(FirebaseAuth::class);
    $firebaseUser = $auth->createUser([
        'email' => $validated['email'],
        'password' => $validated['password'],
        'displayName' => $validated['displayName'],
    ]);
    $uid = $firebaseUser->uid;

    // 3. Crear documento en Firestore (usuarios)
    $usuarioData = [
        'id' => $uid,
        'displayName' => $validated['displayName'],
        'email' => $validated['email'],
        'rut' => $validated['rut'],
        'telefono' => $validated['telefono'] ?? null,
        'rol' => $validated['rol'],
        'activo' => true,
        'createdAt' => now()->toISOString(),
        'updatedAt' => now()->toISOString(),
    ];

    $firestore = app(Firestore::class);
    $firestore->database()
        ->collection('usuarios')
        ->document($uid)
        ->set($usuarioData);

    // 4. Si es paciente o profesional, crear registro vinculado
    if ($validated['rol'] === 'paciente') {
        $pacienteRef = $firestore->database()->collection('pacientes')->newDocument();
        $pacienteId = $pacienteRef->id();
        
        $pacienteRef->set([
            'id' => $pacienteId,
            'idUsuario' => $uid,  // ← Vinculación obligatoria
            'createdAt' => now()->toISOString(),
            'updatedAt' => now()->toISOString(),
        ]);

        // Actualizar usuario con referencia bidireccional
        $firestore->database()
            ->collection('usuarios')
            ->document($uid)
            ->update([
                ['path' => 'idPaciente', 'value' => $pacienteId],
            ]);
            
    } elseif ($validated['rol'] === 'profesional') {
        $profesionalRef = $firestore->database()->collection('profesionales')->newDocument();
        $profesionalId = $profesionalRef->id();
        
        $profesionalRef->set([
            'id' => $profesionalId,
            'idUsuario' => $uid,  // ← Vinculación obligatoria
            'createdAt' => now()->toISOString(),
            'updatedAt' => now()->toISOString(),
        ]);

        // Actualizar usuario con referencia bidireccional
        $firestore->database()
            ->collection('usuarios')
            ->document($uid)
            ->update([
                ['path' => 'idProfesional', 'value' => $profesionalId],
            ]);
    }

    return redirect()
        ->route('usuarios.show', $uid)
        ->with('success', "Usuario creado exitosamente");
}
```

**Flujo de creación:**
```
1. Crear usuario en Firebase Auth (obtener UID)
   ↓
2. Crear documento en usuarios con UID
   ↓
3. SI rol='paciente' → Crear paciente con idUsuario=UID
   SI rol='profesional' → Crear profesional con idUsuario=UID
   ↓
4. Actualizar usuario con idPaciente o idProfesional (referencia bidireccional)
```

**❌ NO PERMITIDO:**
```php
// ❌ Crear paciente sin usuario
Paciente::create([
    'grupoSanguineo' => 'O+',
    // Falta idUsuario - ERROR
]);

// ❌ Crear profesional sin usuario
Profesional::create([
    'especialidad' => 'Cardiología',
    // Falta idUsuario - ERROR
]);
```

**✅ CORRECTO:**
```php
// ✅ Primero crear usuario, luego paciente/profesional
$usuario = Usuario::create([...]);  // Firebase Auth + Firestore
$paciente = Paciente::create([
    'idUsuario' => $usuario['id'],  // ← Obligatorio
    'grupoSanguineo' => 'O+',
]);
```

---

### 📝 Paso 2: Crear Guard Personalizado Firebase

**Archivo:** `app/Auth/FirebaseGuard.php`

**Responsabilidades:**
- Verificar JWT token de Firebase
- Validar que el token no haya expirado
- Obtener usuario de Firestore usando el UID del token
- Verificar que el rol sea 'admin'
- Crear sesión Laravel

**Métodos principales:**
```php
public function check(): bool
public function user(): ?Authenticatable
public function validate(array $credentials = []): bool
public function attempt(array $credentials = []): bool
```

---

### 📝 Paso 3: Crear User Provider Firestore

**Archivo:** `app/Auth/FirestoreUserProvider.php`

**Responsabilidades:**
- Recuperar usuarios de Firestore
- Validar credenciales contra Firebase Authentication
- Implementar interfaz `UserProvider`

**Métodos principales:**
```php
public function retrieveById($identifier)
public function retrieveByCredentials(array $credentials)
public function validateCredentials(Authenticatable $user, array $credentials)
```

---

### 📝 Paso 4: Registrar Guard y Provider

**Archivo:** `app/Providers/AuthServiceProvider.php`

**Código:**
```php
public function boot(): void
{
    Auth::provider('firestore', function ($app, array $config) {
        return new FirestoreUserProvider($app['hash'], $config['model']);
    });

    Auth::extend('firebase', function ($app, $name, array $config) {
        return new FirebaseGuard(
            Auth::createUserProvider($config['provider']),
            $app['request']
        );
    });
}
```

---

### 📝 Paso 5: Configurar Auth

**Archivo:** `config/auth.php`

**Cambios:**
```php
'guards' => [
    'web' => [
        'driver' => 'firebase',  // Cambiar de 'session' a 'firebase'
        'provider' => 'usuarios',
    ],
],

'providers' => [
    'usuarios' => [
        'driver' => 'firestore',  // Cambiar de 'eloquent' a 'firestore'
        'model' => App\Models\Usuario::class,
    ],
],
```

---

### 📝 Paso 6: Crear Controlador de Autenticación

**Archivo:** `app/Http/Controllers/Auth/LoginController.php`

**Métodos:**
```php
public function showLoginForm()  // Retorna Inertia::render('Auth/Login')
public function login(Request $request)
public function logout(Request $request)
```

**Flujo de login:**
1. Validar email + password
2. Llamar a Firebase Authentication con `signInWithEmailAndPassword()`
3. Recibir JWT token y UID
4. Buscar usuario en Firestore usando UID
5. Verificar rol = 'admin'
6. Crear sesión Laravel con `Auth::login()`
7. Redirigir a dashboard

---

### 📝 Paso 7: Crear Middleware de Verificación de Rol

**Archivo:** `app/Http/Middleware/CheckRole.php`

**Código:**
```php
public function handle(Request $request, Closure $next, ...$roles)
{
    if (!Auth::check()) {
        return redirect()->route('login');
    }

    $user = Auth::user();
    
    if (!in_array($user['rol'], $roles)) {
        abort(403, 'No tienes permisos para acceder a esta sección');
    }

    return $next($request);
}
```

**Uso en rutas:**
```php
Route::middleware(['auth', 'role:admin'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index']);
});
```

---

### 📝 Paso 8: Crear Páginas de Login (Inertia.js)

**Archivo:** `resources/js/pages/Auth/Login.vue`

**Campos del formulario:**
- Email (input type="email")
- Password (input type="password")
- Remember me (checkbox)
- Submit button

**Funcionalidad:**
```typescript
const form = useForm({
  email: '',
  password: '',
  remember: false
});

const submit = () => {
  form.post(route('login'), {
    onSuccess: () => {
      // Redirigir a dashboard
    },
    onError: (errors) => {
      // Mostrar errores
    }
  });
};
```

---

### 📝 Paso 9: Actualizar Seeder para Firebase Auth

**Archivo:** `database/seeders/UsuariosPermisosSeeder.php`

**Cambios necesarios:**
- Crear usuarios en Firebase Authentication primero
- Usar el UID devuelto como ID del documento en Firestore
- Validar RUT único antes de crear
- Crear pacientes/profesionales con vinculación a usuarios

**Nuevo flujo de creación:**

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Usuario;
use App\Models\Paciente;
use App\Models\Profesional;
use Kreait\Firebase\Contract\Auth;

class UsuariosPermisosSeeder extends Seeder
{
    protected Auth $auth;
    
    public function __construct(Auth $auth)
    {
        $this->auth = $auth;
    }

    public function run(): void
    {
        echo "🔥 Iniciando seeder de usuarios con Firebase Auth\n";
        
        // 1. CREAR ADMINISTRADORES
        $this->crearAdministradores();
        
        // 2. CREAR PROFESIONALES (usuario + profesional)
        $this->crearProfesionales();
        
        // 3. CREAR PACIENTES (usuario + paciente)
        $this->crearPacientes();
        
        echo "✅ Seeder completado exitosamente\n";
    }
    
    /**
     * Crear usuarios administradores
     */
    protected function crearAdministradores(): void
    {
        echo "\n👨‍💼 Creando administradores...\n";
        
        $admins = [
            [
                'email' => 'admin1@nexus.cl',
                'password' => 'Admin123!',
                'displayName' => 'Administrador Principal',
                'rut' => '11.111.111-1',
                'telefono' => '+56911111111',
            ],
            [
                'email' => 'admin2@nexus.cl',
                'password' => 'Admin123!',
                'displayName' => 'Administrador Secundario',
                'rut' => '22.222.222-2',
                'telefono' => '+56922222222',
            ],
        ];
        
        foreach ($admins as $adminData) {
            try {
                // 1. Crear en Firebase Authentication
                $firebaseUser = $this->auth->createUser([
                    'email' => $adminData['email'],
                    'password' => $adminData['password'],
                    'displayName' => $adminData['displayName'],
                    'emailVerified' => true,
                ]);
                
                // 2. Crear en Firestore usando el UID de Firebase
                $usuarioModel = new Usuario();
                $usuarioModel->firestore
                    ->database()
                    ->collection('usuarios')
                    ->document($firebaseUser->uid)  // Usar UID como ID del documento
                    ->set([
                        'email' => $adminData['email'],
                        'displayName' => $adminData['displayName'],
                        'rut' => $adminData['rut'],
                        'telefono' => $adminData['telefono'],
                        'rol' => 'admin',
                        'activo' => true,
                        'emailVerified' => true,
                        'createdAt' => new \DateTime(),
                        'updatedAt' => new \DateTime(),
                        'ultimoAcceso' => new \DateTime(),
                    ]);
                
                echo "  ✓ Admin creado: {$adminData['email']} (UID: {$firebaseUser->uid})\n";
                
            } catch (\Exception $e) {
                echo "  ✗ Error creando admin {$adminData['email']}: {$e->getMessage()}\n";
            }
        }
    }
    
    /**
     * Crear profesionales (usuario + datos profesionales)
     */
    protected function crearProfesionales(): void
    {
        echo "\n👨‍⚕️ Creando profesionales...\n";
        
        $profesionales = [
            [
                'email' => 'dr.gonzalez@nexus.cl',
                'password' => 'Prof123!',
                'displayName' => 'Dr. Juan González',
                'rut' => '15.555.555-5',
                'telefono' => '+56955555555',
                'especialidad' => 'Cardiología',
                'licenciaMedica' => 'MED-12345',
                'experienciaAnios' => 15,
            ],
            [
                'email' => 'dra.martinez@nexus.cl',
                'password' => 'Prof123!',
                'displayName' => 'Dra. María Martínez',
                'rut' => '16.666.666-6',
                'telefono' => '+56966666666',
                'especialidad' => 'Pediatría',
                'licenciaMedica' => 'MED-67890',
                'experienciaAnios' => 10,
            ],
        ];
        
        foreach ($profesionales as $profData) {
            try {
                // 1. Crear usuario en Firebase Auth
                $firebaseUser = $this->auth->createUser([
                    'email' => $profData['email'],
                    'password' => $profData['password'],
                    'displayName' => $profData['displayName'],
                    'emailVerified' => true,
                ]);
                
                // 2. Crear usuario en Firestore
                $usuarioModel = new Usuario();
                $usuarioModel->firestore
                    ->database()
                    ->collection('usuarios')
                    ->document($firebaseUser->uid)
                    ->set([
                        'email' => $profData['email'],
                        'displayName' => $profData['displayName'],
                        'rut' => $profData['rut'],
                        'telefono' => $profData['telefono'],
                        'rol' => 'profesional',
                        'activo' => true,
                        'emailVerified' => true,
                        'createdAt' => new \DateTime(),
                        'updatedAt' => new \DateTime(),
                    ]);
                
                // 3. Crear datos profesionales vinculados
                $profesionalModel = new Profesional(app('firebase.firestore'));
                $profesionalId = $profesionalModel->create([
                    'idUsuario' => $firebaseUser->uid,
                    'especialidad' => $profData['especialidad'],
                    'licenciaMedica' => $profData['licenciaMedica'],
                    'experienciaAnios' => $profData['experienciaAnios'],
                ]);
                
                // 4. Actualizar usuario con idProfesional
                $usuarioModel->update($firebaseUser->uid, [
                    'idProfesional' => $profesionalId
                ]);
                
                echo "  ✓ Profesional creado: {$profData['displayName']} (UID: {$firebaseUser->uid})\n";
                
            } catch (\Exception $e) {
                echo "  ✗ Error creando profesional {$profData['email']}: {$e->getMessage()}\n";
            }
        }
    }
    
    /**
     * Crear pacientes (usuario + datos médicos)
     */
    protected function crearPacientes(): void
    {
        echo "\n🏥 Creando pacientes...\n";
        
        $pacientes = [
            [
                'email' => 'juan.perez@email.com',
                'password' => 'Pac123!',
                'displayName' => 'Juan Pérez',
                'rut' => '17.777.777-7',
                'telefono' => '+56977777777',
                'fechaNacimiento' => '1985-05-15',
                'grupoSanguineo' => 'O+',
                'alergias' => ['Polen', 'Penicilina'],
            ],
            [
                'email' => 'maria.lopez@email.com',
                'password' => 'Pac123!',
                'displayName' => 'María López',
                'rut' => '18.888.888-8',
                'telefono' => '+56988888888',
                'fechaNacimiento' => '1990-08-20',
                'grupoSanguineo' => 'A+',
                'alergias' => ['Aspirina'],
            ],
        ];
        
        foreach ($pacientes as $pacData) {
            try {
                // 1. Crear usuario en Firebase Auth
                $firebaseUser = $this->auth->createUser([
                    'email' => $pacData['email'],
                    'password' => $pacData['password'],
                    'displayName' => $pacData['displayName'],
                    'emailVerified' => true,
                ]);
                
                // 2. Crear usuario en Firestore
                $usuarioModel = new Usuario();
                $usuarioModel->firestore
                    ->database()
                    ->collection('usuarios')
                    ->document($firebaseUser->uid)
                    ->set([
                        'email' => $pacData['email'],
                        'displayName' => $pacData['displayName'],
                        'rut' => $pacData['rut'],
                        'telefono' => $pacData['telefono'],
                        'rol' => 'paciente',
                        'activo' => true,
                        'emailVerified' => true,
                        'createdAt' => new \DateTime(),
                        'updatedAt' => new \DateTime(),
                    ]);
                
                // 3. Crear datos médicos del paciente
                $pacienteModel = new Paciente();
                $pacienteId = $pacienteModel->create([
                    'idUsuario' => $firebaseUser->uid,
                    'fechaNacimiento' => new \DateTime($pacData['fechaNacimiento']),
                    'grupoSanguineo' => $pacData['grupoSanguineo'],
                    'alergias' => $pacData['alergias'],
                ]);
                
                // 4. Actualizar usuario con idPaciente
                $usuarioModel->update($firebaseUser->uid, [
                    'idPaciente' => $pacienteId
                ]);
                
                echo "  ✓ Paciente creado: {$pacData['displayName']} (UID: {$firebaseUser->uid})\n";
                
            } catch (\Exception $e) {
                echo "  ✗ Error creando paciente {$pacData['email']}: {$e->getMessage()}\n";
            }
        }
    }
}
```

**Ejecutar seeder:**
```bash
php artisan db:seed --class=UsuariosPermisosSeeder
```

**Salida esperada:**
```
🔥 Iniciando seeder de usuarios con Firebase Auth

👨‍💼 Creando administradores...
  ✓ Admin creado: admin1@nexus.cl (UID: abc123...)
  ✓ Admin creado: admin2@nexus.cl (UID: def456...)

👨‍⚕️ Creando profesionales...
  ✓ Profesional creado: Dr. Juan González (UID: ghi789...)
  ✓ Profesional creado: Dra. María Martínez (UID: jkl012...)

🏥 Creando pacientes...
  ✓ Paciente creado: Juan Pérez (UID: mno345...)
  ✓ Paciente creado: María López (UID: pqr678...)

✅ Seeder completado exitosamente
```

---

### 📝 Paso 10: Rutas de Autenticación

**Archivo:** `routes/web.php`

```php
// Rutas públicas
Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [LoginController::class, 'login']);
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

// Rutas protegidas (solo admin)
Route::middleware(['auth', 'role:admin'])->group(function () {
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::resource('usuarios', UsuarioController::class);
    Route::resource('permisos', PermisoController::class);
});
```

---

## 📱 FASE 3: Implementación Ionic (Profesional)

### ⚠️ CAMBIOS CRÍTICOS PARA LA NUEVA ARQUITECTURA

**Estado actual del proyecto Ionic:** ⚠️ REQUIERE ACTUALIZACIÓN

La aplicación Ionic **debe actualizarse** para trabajar con la arquitectura normalizada. Los cambios principales son:

1. **Separar datos de usuario y profesional** en dos colecciones
2. **Eliminar duplicación** de email, rut, nombre, telefono
3. **Obtener datos completos** haciendo JOIN entre usuarios y profesionales
4. **Crear usuarios antes de profesionales** (proceso en 2 pasos)

---

### 📝 Paso 1: Instalar Dependencias

**Comandos:**
```bash
cd nexus/ionic
npm install @angular/fire firebase
npm install @ionic/storage-angular
```

---

### 📝 Paso 2: Configurar Firebase

**Archivo:** `src/environments/environment.ts`

```typescript
export const environment = {
  production: false,
  firebaseConfig: {
    apiKey: "YOUR_API_KEY",
    authDomain: "nexus-68994.firebaseapp.com",
    projectId: "nexus-68994",
    storageBucket: "nexus-68994.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  }
};
```

**Obtener configuración:**
- Firebase Console → Project Settings → Your apps → Web app

---

### 📝 Paso 3: Actualizar Modelos TypeScript

**⚠️ CAMBIO IMPORTANTE:** Los modelos deben reflejar la nueva arquitectura

**Archivo:** `src/app/models/usuario.model.ts`

```typescript
/**
 * Modelo de Usuario (Colección central con datos personales y autenticación)
 * 
 * ⚠️ IMPORTANTE: 
 * - Este modelo contiene TODOS los datos personales (email, rut, displayName, telefono)
 * - Los datos profesionales están en un documento separado en la colección 'profesionales'
 * - NO duplicar campos entre Usuario y Profesional
 */
export interface Usuario {
  id: string;                    // UID de Firebase Authentication
  
  // Datos de autenticación
  email: string;                 // ÚNICO - usado para login
  emailVerified: boolean;
  
  // Datos personales (NO duplicar en profesionales)
  displayName: string;           // Nombre completo
  rut: string;                   // ÚNICO - identificación nacional
  telefono?: string;             // Teléfono de contacto
  photoURL?: string;             // URL de foto de perfil
  
  // Control de acceso
  rol: 'admin' | 'profesional' | 'paciente';
  activo: boolean;
  
  // Referencias a otras colecciones
  idProfesional?: string;        // ID del documento en 'profesionales' (solo si rol='profesional')
  idPaciente?: string;           // ID del documento en 'pacientes' (solo si rol='paciente')
  
  // Timestamps
  createdAt?: Date;
  updatedAt?: Date;
  ultimoAcceso?: Date;
}

/**
 * Modelo de Profesional (Solo datos profesionales - NO datos personales)
 * 
 * ⚠️ IMPORTANTE:
 * - NO incluir: email, rut, displayName, telefono (están en Usuario)
 * - Siempre debe tener idUsuario (obligatorio)
 * - Para obtener datos completos, hacer JOIN con usuarios
 */
export interface Profesional {
  id: string;                    // ID del documento en Firestore
  idUsuario: string;             // FK a usuarios.id (OBLIGATORIO)
  
  // Datos profesionales específicos
  especialidad?: string;
  subespecialidad?: string;
  licenciaMedica?: string;
  experienciaAnios?: number;
  curriculum?: string;
  
  // Configuración de atención
  horarioAtencion?: {
    [dia: string]: {
      inicio: string;
      fin: string;
    };
  };
  valorConsulta?: number;
  tiempoConsulta?: number;       // en minutos
  
  // Timestamps
  createdAt?: Date;
  updatedAt?: Date;
}

/**
 * Modelo combinado para vistas que necesitan datos completos
 * 
 * Uso: Mostrar perfil del profesional con nombre, email, especialidad, etc.
 */
export interface ProfesionalCompleto {
  // Datos del usuario
  id: string;
  email: string;
  displayName: string;
  rut: string;
  telefono?: string;
  photoURL?: string;
  rol: string;
  activo: boolean;
  
  // Datos del profesional
  idProfesional: string;
  especialidad?: string;
  subespecialidad?: string;
  licenciaMedica?: string;
  experienciaAnios?: number;
  curriculum?: string;
  horarioAtencion?: any;
  valorConsulta?: number;
  tiempoConsulta?: number;
}
```

**Archivo:** `src/app/models/paciente.model.ts`

```typescript
/**
 * Modelo de Paciente (Solo datos médicos - NO datos personales)
 */
export interface Paciente {
  id: string;
  idUsuario: string;             // FK a usuarios.id (OBLIGATORIO)
  
  // Datos médicos específicos (NO incluir email, rut, nombre, telefono)
  fechaNacimiento?: Date;
  grupoSanguineo?: 'A+' | 'A-' | 'B+' | 'B-' | 'AB+' | 'AB-' | 'O+' | 'O-';
  alergias?: string[];
  enfermedadesCronicas?: string[];
  medicamentosActuales?: Array<{
    nombre: string;
    dosis: string;
    frecuencia: string;
  }>;
  contactoEmergencia?: {
    nombre: string;
    telefono: string;
    relacion: string;
  };
  prevision?: 'FONASA' | 'ISAPRE' | 'Particular';
  numeroFicha?: string;
  observaciones?: string;
  
  createdAt?: Date;
  updatedAt?: Date;
}

/**
 * Modelo combinado Usuario + Paciente
 */
export interface PacienteCompleto {
  // Datos del usuario
  id: string;
  email: string;
  displayName: string;
  rut: string;
  telefono?: string;
  photoURL?: string;
  
  // Datos del paciente
  idPaciente: string;
  fechaNacimiento?: Date;
  grupoSanguineo?: string;
  alergias?: string[];
  enfermedadesCronicas?: string[];
  prevision?: string;
}
```

---

### 📝 Paso 4: Actualizar Servicio de Autenticación

**⚠️ CAMBIO CRÍTICO:** El servicio debe obtener datos de dos colecciones

**Archivo:** `src/app/services/auth.service.ts`

**Implementación actualizada con arquitectura normalizada:**
```typescript
import { Injectable } from '@angular/core';
import { 
  Auth, 
  signInWithEmailAndPassword, 
  signOut, 
  User as FirebaseUser 
} from '@angular/fire/auth';
import { 
  Firestore, 
  doc, 
  getDoc, 
  collection,
  query,
  where,
  getDocs 
} from '@angular/fire/firestore';
import { Storage } from '@ionic/storage-angular';
import { Usuario, Profesional, ProfesionalCompleto } from '../models/usuario.model';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  constructor(
    private auth: Auth,
    private firestore: Firestore,
    private storage: Storage
  ) {
    this.storage.create();
  }

  /**
   * Login para profesionales
   * 
   * ⚠️ CAMBIOS EN ARQUITECTURA:
   * 1. Obtener usuario de la colección 'usuarios'
   * 2. Verificar que rol='profesional'
   * 3. Obtener datos profesionales de la colección 'profesionales' usando usuario.idProfesional
   * 4. Guardar ambos objetos en storage
   */
  async login(email: string, password: string): Promise<void> {
    try {
      console.log('🔵 Iniciando login para profesional:', email);
      
      // 1. Autenticar con Firebase
      const credential = await signInWithEmailAndPassword(
        this.auth, 
        email, 
        password
      );
      
      console.log('✅ Autenticación exitosa, UID:', credential.user.uid);
      
      // 2. Obtener datos del usuario desde Firestore (colección 'usuarios')
      const userDocRef = doc(this.firestore, 'usuarios', credential.user.uid);
      const userDoc = await getDoc(userDocRef);
      
      if (!userDoc.exists()) {
        await signOut(this.auth);
        throw new Error('Usuario no encontrado en la base de datos');
      }
      
      const usuario: Usuario = {
        id: userDoc.id,
        ...userDoc.data()
      } as Usuario;
      
      console.log('📋 Datos de usuario obtenidos:', {
        displayName: usuario.displayName,
        email: usuario.email,
        rol: usuario.rol,
        idProfesional: usuario.idProfesional
      });
      
      // 3. Verificar que sea profesional
      if (usuario.rol !== 'profesional') {
        await signOut(this.auth);
        throw new Error(
          `Esta aplicación es solo para profesionales. Tu rol es: ${usuario.rol}. ` +
          'Usa la aplicación correspondiente a tu rol.'
        );
      }
      
      // 4. Verificar que esté activo
      if (!usuario.activo) {
        await signOut(this.auth);
        throw new Error('Tu cuenta está desactivada. Contacta al administrador.');
      }
      
      // 5. Obtener datos profesionales (colección 'profesionales')
      if (!usuario.idProfesional) {
        await signOut(this.auth);
        throw new Error(
          'No se encontró el perfil profesional asociado a tu cuenta. ' +
          'Contacta al administrador.'
        );
      }
      
      const profesionalDocRef = doc(
        this.firestore, 
        'profesionales', 
        usuario.idProfesional
      );
      const profesionalDoc = await getDoc(profesionalDocRef);
      
      if (!profesionalDoc.exists()) {
        await signOut(this.auth);
        throw new Error('Datos profesionales no encontrados');
      }
      
      const profesional: Profesional = {
        id: profesionalDoc.id,
        ...profesionalDoc.data()
      } as Profesional;
      
      console.log('📋 Datos profesionales obtenidos:', {
        especialidad: profesional.especialidad,
        licenciaMedica: profesional.licenciaMedica
      });
      
      // 6. Guardar token y datos en storage
      const token = await credential.user.getIdToken();
      await this.storage.set('authToken', token);
      await this.storage.set('currentUser', usuario);
      await this.storage.set('profesionalData', profesional);
      
      console.log('✅ Login exitoso:', usuario.displayName);
      
    } catch (error: any) {
      console.error('❌ Error en login:', error);
      throw error;
    }
  }

  /**
   * Obtener usuario actual
   * 
   * Retorna datos personales desde la colección 'usuarios'
   */
  async getCurrentUser(): Promise<Usuario | null> {
    const usuario = await this.storage.get('currentUser');
    return usuario;
  }

  /**
   * Obtener datos profesionales del usuario actual
   * 
   * Retorna datos específicos desde la colección 'profesionales'
   */
  async getCurrentProfesional(): Promise<Profesional | null> {
    const profesional = await this.storage.get('profesionalData');
    return profesional;
  }

  /**
   * Obtener datos completos (Usuario + Profesional combinados)
   * 
   * ⚠️ NUEVO: Combina ambas colecciones en un solo objeto
   */
  async getProfesionalCompleto(): Promise<ProfesionalCompleto | null> {
    const usuario = await this.getCurrentUser();
    const profesional = await this.getCurrentProfesional();
    
    if (!usuario || !profesional) {
      return null;
    }
    
    return {
      // Datos del usuario
      id: usuario.id,
      email: usuario.email,
      displayName: usuario.displayName,
      rut: usuario.rut,
      telefono: usuario.telefono,
      photoURL: usuario.photoURL,
      rol: usuario.rol,
      activo: usuario.activo,
      
      // Datos del profesional
      idProfesional: profesional.id,
      especialidad: profesional.especialidad,
      subespecialidad: profesional.subespecialidad,
      licenciaMedica: profesional.licenciaMedica,
      experienciaAnios: profesional.experienciaAnios,
      curriculum: profesional.curriculum,
      horarioAtencion: profesional.horarioAtencion,
      valorConsulta: profesional.valorConsulta,
      tiempoConsulta: profesional.tiempoConsulta,
    };
  }

  /**
   * Verificar si está autenticado
   */
  async isAuthenticated(): Promise<boolean> {
    const token = await this.storage.get('authToken');
    const user = await this.storage.get('currentUser');
    return !!token && !!user;
  }

  /**
   * Obtener token JWT
   */
  async getToken(): Promise<string | null> {
    return await this.storage.get('authToken');
  }

  /**
   * Cerrar sesión
   */
  async logout(): Promise<void> {
    await signOut(this.auth);
    await this.storage.remove('authToken');
    await this.storage.remove('currentUser');
    await this.storage.remove('profesionalData');
    console.log('✅ Sesión cerrada');
  }

  /**
   * Actualizar datos del profesional en cache
   * 
   * ⚠️ NUEVO: Refresca datos desde Firestore
   */
  async refreshProfesionalData(): Promise<void> {
    const usuario = await this.getCurrentUser();
    if (!usuario || !usuario.idProfesional) return;
    
    const profesionalDocRef = doc(
      this.firestore, 
      'profesionales', 
      usuario.idProfesional
    );
    const profesionalDoc = await getDoc(profesionalDocRef);
    
    if (profesionalDoc.exists()) {
      const profesional = {
        id: profesionalDoc.id,
        ...profesionalDoc.data()
      };
      await this.storage.set('profesionalData', profesional);
    }
  }

  /**
   * Actualizar perfil del usuario (datos personales)
   * 
   * ⚠️ IMPORTANTE: Solo actualiza la colección 'usuarios'
   * Para actualizar datos profesionales, usar updateProfesionalData()
   */
  async updateUserProfile(data: Partial<Usuario>): Promise<void> {
    const usuario = await this.getCurrentUser();
    if (!usuario) throw new Error('Usuario no autenticado');
    
    const userDocRef = doc(this.firestore, 'usuarios', usuario.id);
    await updateDoc(userDocRef, {
      ...data,
      updatedAt: serverTimestamp()
    });
    
    // Actualizar cache
    const updatedUser = { ...usuario, ...data };
    await this.storage.set('currentUser', updatedUser);
  }

  /**
   * Actualizar datos profesionales
   * 
   * ⚠️ IMPORTANTE: Solo actualiza la colección 'profesionales'
   * Para actualizar datos personales, usar updateUserProfile()
   */
  async updateProfesionalData(data: Partial<Profesional>): Promise<void> {
    const usuario = await this.getCurrentUser();
    if (!usuario || !usuario.idProfesional) {
      throw new Error('Perfil profesional no encontrado');
    }
    
    const profesionalDocRef = doc(
      this.firestore, 
      'profesionales', 
      usuario.idProfesional
    );
    await updateDoc(profesionalDocRef, {
      ...data,
      updatedAt: serverTimestamp()
    });
    
    // Actualizar cache
    await this.refreshProfesionalData();
  }
}
```

**Ejemplo de uso en componentes:**

```typescript
// Login
await this.authService.login(email, password);

// Obtener solo datos de usuario (email, rut, nombre, telefono)
const usuario = await this.authService.getCurrentUser();
console.log(usuario.displayName, usuario.rut, usuario.email);

// Obtener solo datos profesionales (especialidad, licencia, etc.)
const profesional = await this.authService.getCurrentProfesional();
console.log(profesional.especialidad, profesional.licenciaMedica);

// Obtener datos completos combinados
const completo = await this.authService.getProfesionalCompleto();
console.log(completo.displayName, completo.especialidad);

// Actualizar datos personales (nombre, telefono, etc.)
await this.authService.updateUserProfile({
  displayName: 'Dr. Juan Pérez',
  telefono: '+56912345678'
});

// Actualizar datos profesionales (especialidad, horario, etc.)
await this.authService.updateProfesionalData({
  especialidad: 'Cardiología',
  valorConsulta: 50000
});
```

---

### 📝 Paso 5: Actualizar Servicios de Datos

**⚠️ NUEVO SERVICIO:** Para obtener datos de pacientes con información completa

**Archivo:** `src/app/services/paciente.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { 
  Firestore, 
  collection, 
  doc, 
  getDoc, 
  getDocs,
  query,
  where 
} from '@angular/fire/firestore';
import { Paciente, PacienteCompleto, Usuario } from '../models/usuario.model';

@Injectable({
  providedIn: 'root'
})
export class PacienteService {
  constructor(private firestore: Firestore) {}

  /**
   * Obtener paciente con datos completos (JOIN con usuarios)
   * 
   * ⚠️ IMPORTANTE: Los profesionales necesitan ver nombre, rut, email del paciente
   * Estos datos están en la colección 'usuarios', no en 'pacientes'
   */
  async getPacienteCompleto(pacienteId: string): Promise<PacienteCompleto | null> {
    try {
      // 1. Obtener datos del paciente
      const pacienteDocRef = doc(this.firestore, 'pacientes', pacienteId);
      const pacienteDoc = await getDoc(pacienteDocRef);
      
      if (!pacienteDoc.exists()) {
        return null;
      }
      
      const paciente = pacienteDoc.data() as Paciente;
      
      // 2. Obtener datos del usuario vinculado
      if (!paciente.idUsuario) {
        console.error('Paciente sin idUsuario:', pacienteId);
        return null;
      }
      
      const usuarioDocRef = doc(this.firestore, 'usuarios', paciente.idUsuario);
      const usuarioDoc = await getDoc(usuarioDocRef);
      
      if (!usuarioDoc.exists()) {
        console.error('Usuario no encontrado:', paciente.idUsuario);
        return null;
      }
      
      const usuario = usuarioDoc.data() as Usuario;
      
      // 3. Combinar datos
      return {
        // Datos del usuario
        id: usuario.id,
        email: usuario.email,
        displayName: usuario.displayName,
        rut: usuario.rut,
        telefono: usuario.telefono,
        photoURL: usuario.photoURL,
        
        // Datos del paciente
        idPaciente: paciente.id,
        fechaNacimiento: paciente.fechaNacimiento,
        grupoSanguineo: paciente.grupoSanguineo,
        alergias: paciente.alergias,
        enfermedadesCronicas: paciente.enfermedadesCronicas,
        prevision: paciente.prevision,
      };
      
    } catch (error) {
      console.error('Error obteniendo paciente completo:', error);
      return null;
    }
  }

  /**
   * Obtener todos los pacientes con datos completos
   */
  async getAllPacientesCompletos(): Promise<PacienteCompleto[]> {
    const pacientesCompletos: PacienteCompleto[] = [];
    
    // 1. Obtener todos los pacientes
    const pacientesSnapshot = await getDocs(collection(this.firestore, 'pacientes'));
    
    // 2. Para cada paciente, obtener sus datos de usuario
    for (const pacienteDoc of pacientesSnapshot.docs) {
      const paciente = pacienteDoc.data() as Paciente;
      
      if (paciente.idUsuario) {
        const usuarioDoc = await getDoc(
          doc(this.firestore, 'usuarios', paciente.idUsuario)
        );
        
        if (usuarioDoc.exists()) {
          const usuario = usuarioDoc.data() as Usuario;
          
          pacientesCompletos.push({
            id: usuario.id,
            email: usuario.email,
            displayName: usuario.displayName,
            rut: usuario.rut,
            telefono: usuario.telefono,
            photoURL: usuario.photoURL,
            idPaciente: paciente.id,
            fechaNacimiento: paciente.fechaNacimiento,
            grupoSanguineo: paciente.grupoSanguineo,
            alergias: paciente.alergias,
            enfermedadesCronicas: paciente.enfermedadesCronicas,
            prevision: paciente.prevision,
          });
        }
      }
    }
    
    return pacientesCompletos;
  }

  /**
   * Buscar pacientes por nombre, RUT o email
   * 
   * ⚠️ IMPORTANTE: La búsqueda se hace en la colección 'usuarios'
   */
  async buscarPacientes(termino: string): Promise<PacienteCompleto[]> {
    const terminoLower = termino.toLowerCase();
    const pacientesCompletos: PacienteCompleto[] = [];
    
    // 1. Buscar en usuarios con rol='paciente'
    const usuariosQuery = query(
      collection(this.firestore, 'usuarios'),
      where('rol', '==', 'paciente')
    );
    
    const usuariosSnapshot = await getDocs(usuariosQuery);
    
    // 2. Filtrar por término de búsqueda
    for (const usuarioDoc of usuariosSnapshot.docs) {
      const usuario = usuarioDoc.data() as Usuario;
      
      const matchNombre = usuario.displayName?.toLowerCase().includes(terminoLower);
      const matchEmail = usuario.email?.toLowerCase().includes(terminoLower);
      const matchRut = usuario.rut?.toLowerCase().includes(terminoLower);
      
      if (matchNombre || matchEmail || matchRut) {
        // Obtener datos del paciente
        if (usuario.idPaciente) {
          const pacienteDoc = await getDoc(
            doc(this.firestore, 'pacientes', usuario.idPaciente)
          );
          
          if (pacienteDoc.exists()) {
            const paciente = pacienteDoc.data() as Paciente;
            
            pacientesCompletos.push({
              id: usuario.id,
              email: usuario.email,
              displayName: usuario.displayName,
              rut: usuario.rut,
              telefono: usuario.telefono,
              photoURL: usuario.photoURL,
              idPaciente: paciente.id,
              fechaNacimiento: paciente.fechaNacimiento,
              grupoSanguineo: paciente.grupoSanguineo,
              alergias: paciente.alergias,
              enfermedadesCronicas: paciente.enfermedadesCronicas,
              prevision: paciente.prevision,
            });
          }
        }
      }
    }
    
    return pacientesCompletos;
  }
}
```

---

### 📝 Paso 5: Crear Guard de Autenticación

**Archivo:** `src/app/guards/auth.guard.ts`

```typescript
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  async canActivate(): Promise<boolean> {
    const isAuth = await this.authService.isAuthenticated();
    
    if (!isAuth) {
      this.router.navigate(['/login']);
      return false;
    }
    
    return true;
  }
}
```

---

### 📝 Paso 6: Crear Página de Login

**Archivo:** `src/app/pages/login/login.page.ts`

**Template:**
```html
<ion-content>
  <form [formGroup]="loginForm" (ngSubmit)="login()">
    <ion-item>
      <ion-label position="floating">Email</ion-label>
      <ion-input type="email" formControlName="email"></ion-input>
    </ion-item>
    
    <ion-item>
      <ion-label position="floating">Contraseña</ion-label>
      <ion-input type="password" formControlName="password"></ion-input>
    </ion-item>
    
    <ion-button expand="block" type="submit">
      Iniciar Sesión
    </ion-button>
  </form>
</ion-content>
```

**Component:**
```typescript
async login() {
  const { email, password } = this.loginForm.value;
  
  try {
    await this.authService.login(email, password);
    this.router.navigate(['/home']);
  } catch (error) {
    this.showError(error.message);
  }
}
```

---

### 📝 Paso 7: Configurar Rutas con Guard

**Archivo:** `src/app/app-routing.module.ts`

```typescript
const routes: Routes = [
  {
    path: 'login',
    loadChildren: () => import('./pages/login/login.module')
  },
  {
    path: 'home',
    loadChildren: () => import('./pages/home/home.module'),
    canActivate: [AuthGuard]
  },
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full'
  }
];
```

---

### 📝 Paso 8: Crear Servicio de Permisos

**Archivo:** `src/app/services/permisos.service.ts`

**Métodos:**
```typescript
async getPermisos(idUsuario: string, idHospital: string): Promise<string[]>
async hasPermiso(permiso: string): Promise<boolean>
async hasAnyPermiso(permisos: string[]): Promise<boolean>
```

---

## 📲 FASE 4: Implementación Flutter (Paciente)

### ⚠️ CAMBIOS CRÍTICOS PARA LA NUEVA ARQUITECTURA

**Estado actual del proyecto Flutter:** ⚠️ REQUIERE ACTUALIZACIÓN

La aplicación Flutter **debe actualizarse** para trabajar con la arquitectura normalizada. Los cambios principales son:

1. **Separar datos de usuario y paciente** en dos colecciones
2. **Eliminar duplicación** de email, rut, nombre, telefono
3. **Obtener datos completos** haciendo JOIN entre usuarios y pacientes
4. **Crear usuarios antes de pacientes** (proceso en 2 pasos)

---

### 📝 Paso 1: Instalar Dependencias

**Archivo:** `pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  provider: ^6.1.1
  shared_preferences: ^2.2.2
```

**Comando:**
```bash
cd nexus/flutter
flutter pub get
```

---

### 📝 Paso 2: Configurar Firebase

**Android:** `android/app/google-services.json`  
**iOS:** `ios/Runner/GoogleService-Info.plist`

**Descargar archivos:**
- Firebase Console → Project Settings → Your apps → Add Android/iOS app

---

### 📝 Paso 3: Inicializar Firebase

**Archivo:** `lib/main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

---

### 📝 Paso 4: Actualizar Modelos Dart

**⚠️ CAMBIO IMPORTANTE:** Los modelos deben reflejar la nueva arquitectura

**Archivo:** `lib/models/usuario.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String email;
  final String displayName;
  final String rut;
  final String? telefono;
  final String? photoURL;
  final String rol;  // 'admin', 'profesional', 'paciente'
  final bool activo;
  final String? idPaciente;  // Solo si rol='paciente'
  final String? idProfesional;  // Solo si rol='profesional'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Usuario({
    required this.id,
    required this.email,
    required this.displayName,
    required this.rut,
    this.telefono,
    this.photoURL,
    required this.rol,
    required this.activo,
    this.idPaciente,
    this.idProfesional,
    this.createdAt,
    this.updatedAt,
  });

  /// Crear Usuario desde documento de Firestore
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Usuario(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      rut: data['rut'] ?? '',
      telefono: data['telefono'],
      photoURL: data['photoURL'],
      rol: data['rol'] ?? '',
      activo: data['activo'] ?? true,
      idPaciente: data['idPaciente'],
      idProfesional: data['idProfesional'],
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'rut': rut,
      'telefono': telefono,
      'photoURL': photoURL,
      'rol': rol,
      'activo': activo,
      'idPaciente': idPaciente,
      'idProfesional': idProfesional,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copiar con modificaciones
  Usuario copyWith({
    String? email,
    String? displayName,
    String? rut,
    String? telefono,
    String? photoURL,
    String? rol,
    bool? activo,
    String? idPaciente,
    String? idProfesional,
  }) {
    return Usuario(
      id: this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      rut: rut ?? this.rut,
      telefono: telefono ?? this.telefono,
      photoURL: photoURL ?? this.photoURL,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      idPaciente: idPaciente ?? this.idPaciente,
      idProfesional: idProfesional ?? this.idProfesional,
      createdAt: this.createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
```

**Archivo:** `lib/models/paciente.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Paciente {
  final String id;
  final String idUsuario;  // Referencia a usuarios.id (OBLIGATORIO)
  
  // Datos médicos (NO duplicar email, rut, nombre, telefono)
  final DateTime? fechaNacimiento;
  final String? grupoSanguineo;  // 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  final List<String>? alergias;
  final List<String>? enfermedadesCronicas;
  final List<Map<String, dynamic>>? medicamentosActuales;
  final Map<String, dynamic>? contactoEmergencia;
  final String? prevision;  // 'FONASA', 'ISAPRE', 'Particular'
  final String? numeroFicha;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Paciente({
    required this.id,
    required this.idUsuario,
    this.fechaNacimiento,
    this.grupoSanguineo,
    this.alergias,
    this.enfermedadesCronicas,
    this.medicamentosActuales,
    this.contactoEmergencia,
    this.prevision,
    this.numeroFicha,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  factory Paciente.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Paciente(
      id: doc.id,
      idUsuario: data['idUsuario'] ?? '',
      fechaNacimiento: data['fechaNacimiento'] != null
          ? (data['fechaNacimiento'] as Timestamp).toDate()
          : null,
      grupoSanguineo: data['grupoSanguineo'],
      alergias: data['alergias'] != null 
          ? List<String>.from(data['alergias']) 
          : null,
      enfermedadesCronicas: data['enfermedadesCronicas'] != null
          ? List<String>.from(data['enfermedadesCronicas'])
          : null,
      medicamentosActuales: data['medicamentosActuales'] != null
          ? List<Map<String, dynamic>>.from(data['medicamentosActuales'])
          : null,
      contactoEmergencia: data['contactoEmergencia'],
      prevision: data['prevision'],
      numeroFicha: data['numeroFicha'],
      observaciones: data['observaciones'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'fechaNacimiento': fechaNacimiento != null 
          ? Timestamp.fromDate(fechaNacimiento!) 
          : null,
      'grupoSanguineo': grupoSanguineo,
      'alergias': alergias,
      'enfermedadesCronicas': enfermedadesCronicas,
      'medicamentosActuales': medicamentosActuales,
      'contactoEmergencia': contactoEmergencia,
      'prevision': prevision,
      'numeroFicha': numeroFicha,
      'observaciones': observaciones,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Modelo combinado Usuario + Paciente para vistas
class PacienteCompleto {
  final Usuario usuario;
  final Paciente paciente;

  PacienteCompleto({
    required this.usuario,
    required this.paciente,
  });

  // Acceso rápido a datos comunes
  String get displayName => usuario.displayName;
  String get email => usuario.email;
  String get rut => usuario.rut;
  String? get telefono => usuario.telefono;
  String? get photoURL => usuario.photoURL;
  
  // Acceso a datos médicos
  DateTime? get fechaNacimiento => paciente.fechaNacimiento;
  String? get grupoSanguineo => paciente.grupoSanguineo;
  List<String>? get alergias => paciente.alergias;
}
```

---

### 📝 Paso 5: Crear Servicio de Autenticación

**Archivo:** `lib/services/auth_service.dart`

**Métodos actualizados con arquitectura normalizada:**
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../models/paciente.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login para pacientes
  /// Valida que el usuario tenga rol='paciente' y datos de paciente
  Future<void> login(String email, String password) async {
    try {
      // 1. Autenticar con Firebase
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Obtener datos del usuario desde Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('Usuario no encontrado en la base de datos');
      }

      Usuario usuario = Usuario.fromFirestore(userDoc);

      // 3. Verificar que sea paciente
      if (usuario.rol != 'paciente') {
        await _auth.signOut();
        throw Exception(
          'Esta aplicación es solo para pacientes. Usa la app correspondiente a tu rol.'
        );
      }

      // 4. Verificar que esté activo
      if (!usuario.activo) {
        await _auth.signOut();
        throw Exception(
          'Tu cuenta está desactivada. Contacta al administrador.'
        );
      }

      // 5. Obtener datos del paciente
      if (usuario.idPaciente == null) {
        await _auth.signOut();
        throw Exception(
          'No se encontraron datos de paciente asociados a tu cuenta.'
        );
      }

      DocumentSnapshot pacienteDoc = await _firestore
          .collection('pacientes')
          .doc(usuario.idPaciente)
          .get();

      if (!pacienteDoc.exists) {
        await _auth.signOut();
        throw Exception('Datos de paciente no encontrados');
      }

      Paciente paciente = Paciente.fromFirestore(pacienteDoc);

      // 6. Guardar datos en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', usuario.id);
      await prefs.setString('userRole', usuario.rol);
      await prefs.setString('displayName', usuario.displayName);
      await prefs.setString('email', usuario.email);
      await prefs.setString('rut', usuario.rut);
      
      // Guardar IDs de referencia
      await prefs.setString('pacienteId', paciente.id);
      
      // Guardar token
      String? token = await credential.user?.getIdToken();
      if (token != null) {
        await prefs.setString('authToken', token);
      }

      print('✅ Login exitoso: ${usuario.displayName}');

    } on FirebaseAuthException catch (e) {
      print('❌ Error de autenticación: ${e.code}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No existe un usuario con este email');
        case 'wrong-password':
          throw Exception('Contraseña incorrecta');
        case 'invalid-email':
          throw Exception('Email inválido');
        case 'user-disabled':
          throw Exception('Usuario deshabilitado');
        default:
          throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      print('❌ Error en login: $e');
      throw Exception(e.toString());
    }
  }

  /// Obtener usuario actual completo
  Future<Usuario?> getCurrentUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      
      if (userId == null) return null;

      DocumentSnapshot userDoc = await _firestore
          .collection('usuarios')
          .doc(userId)
          .get();

      if (!userDoc.exists) return null;

      return Usuario.fromFirestore(userDoc);
    } catch (e) {
      print('Error obteniendo usuario: $e');
      return null;
    }
  }

  /// Obtener datos del paciente actual
  Future<Paciente?> getCurrentPaciente() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? pacienteId = prefs.getString('pacienteId');
      
      if (pacienteId == null) return null;

      DocumentSnapshot pacienteDoc = await _firestore
          .collection('pacientes')
          .doc(pacienteId)
          .get();

      if (!pacienteDoc.exists) return null;

      return Paciente.fromFirestore(pacienteDoc);
    } catch (e) {
      print('Error obteniendo paciente: $e');
      return null;
    }
  }

  /// Obtener datos completos (Usuario + Paciente)
  Future<PacienteCompleto?> getPacienteCompleto() async {
    try {
      Usuario? usuario = await getCurrentUser();
      if (usuario == null) return null;

      Paciente? paciente = await getCurrentPaciente();
      if (paciente == null) return null;

      return PacienteCompleto(
        usuario: usuario,
        paciente: paciente,
      );
    } catch (e) {
      print('Error obteniendo paciente completo: $e');
      return null;
    }
  }

  /// Verificar si está autenticado
  Future<bool> isAuthenticated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    String? userId = prefs.getString('userId');
    
    return token != null && userId != null;
  }

  /// Obtener token JWT
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userRole');
    await prefs.remove('displayName');
    await prefs.remove('email');
    await prefs.remove('rut');
    await prefs.remove('pacienteId');
    await prefs.remove('authToken');
    
    print('✅ Sesión cerrada');
  }

  /// Actualizar datos del paciente en cache
  Future<void> refreshPacienteData() async {
    try {
      Usuario? usuario = await getCurrentUser();
      if (usuario == null || usuario.idPaciente == null) return;

      DocumentSnapshot pacienteDoc = await _firestore
          .collection('pacientes')
          .doc(usuario.idPaciente)
          .get();

      if (pacienteDoc.exists) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('pacienteId', pacienteDoc.id);
      }
    } catch (e) {
      print('Error actualizando datos del paciente: $e');
    }
  }

  /// Actualizar perfil del usuario
  Future<void> updateUserProfile({
    String? displayName,
    String? telefono,
    String? photoURL,
  }) async {
    try {
      Usuario? usuario = await getCurrentUser();
      if (usuario == null) return;

      Map<String, dynamic> updates = {};
      
      if (displayName != null) updates['displayName'] = displayName;
      if (telefono != null) updates['telefono'] = telefono;
      if (photoURL != null) updates['photoURL'] = photoURL;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('usuarios')
          .doc(usuario.id)
          .update(updates);

      // Actualizar SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (displayName != null) {
        await prefs.setString('displayName', displayName);
      }

      print('✅ Perfil actualizado');
    } catch (e) {
      print('Error actualizando perfil: $e');
      throw Exception('Error al actualizar el perfil');
    }
  }

  /// Actualizar datos médicos del paciente
  Future<void> updatePacienteData(Map<String, dynamic> data) async {
    try {
      Paciente? paciente = await getCurrentPaciente();
      if (paciente == null) return;

      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('pacientes')
          .doc(paciente.id)
          .update(data);

      print('✅ Datos médicos actualizados');
    } catch (e) {
      print('Error actualizando datos médicos: $e');
      throw Exception('Error al actualizar los datos médicos');
    }
  }
}
```

**Uso en la aplicación:**
```dart
// Login
final authService = AuthService();
await authService.login('juan.perez@email.com', 'Pac123!');

// Obtener datos completos
PacienteCompleto? pacienteCompleto = await authService.getPacienteCompleto();
if (pacienteCompleto != null) {
  print('Nombre: ${pacienteCompleto.displayName}');
  print('RUT: ${pacienteCompleto.rut}');
  print('Email: ${pacienteCompleto.email}');
  print('Grupo sanguíneo: ${pacienteCompleto.grupoSanguineo}');
  print('Alergias: ${pacienteCompleto.alergias}');
}

// Actualizar perfil (datos en usuarios)
await authService.updateUserProfile(
  displayName: 'Juan Pérez García',
  telefono: '+56911111111',
);

// Actualizar datos médicos (datos en pacientes)
await authService.updatePacienteData({
  'grupoSanguineo': 'O+',
  'alergias': ['Polen', 'Penicilina'],
});
```

---

### 📝 Paso 6: Crear Provider de Estado

**Archivo:** `lib/providers/auth_provider.dart`

```dart
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Usuario? _currentUser;
  
  Usuario? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  
  Future<void> login(String email, String password) async {
    await _authService.login(email, password);
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
```

---

### 📝 Paso 7: Crear Página de Login

**Archivo:** `lib/screens/login_screen.dart`

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  void _login() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text,
        _passwordController.text,
      );
      
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 📝 Paso 8: Configurar Rutas con Guard

**Archivo:** `lib/main.dart`

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
        },
        onGenerateRoute: (settings) {
          // Check authentication
          final authProvider = Provider.of<AuthProvider>(context);
          
          if (!authProvider.isAuthenticated && settings.name != '/login') {
            return MaterialPageRoute(builder: (_) => LoginScreen());
          }
          
          return null;
        },
      ),
    );
  }
}
```

---

## 🔧 FASE 5: Crear Script de Seeder Automático

### 📝 Crear Script PHP para Registrar Usuarios en Firebase Auth

**Archivo:** `database/seeders/FirebaseAuthSeeder.php`

**Responsabilidades:**
- Crear usuarios en Firebase Authentication
- Sincronizar UIDs con Firestore
- Asignar contraseñas temporales

**Usuarios a crear:**
```php
$usuarios = [
    ['email' => 'admin1@nexus.cl', 'password' => 'Admin123!', 'rol' => 'admin'],
    ['email' => 'admin2@nexus.cl', 'password' => 'Admin123!', 'rol' => 'admin'],
    ['email' => 'dr.gonzalez@nexus.cl', 'password' => 'Prof123!', 'rol' => 'profesional'],
    ['email' => 'dra.martinez@nexus.cl', 'password' => 'Prof123!', 'rol' => 'profesional'],
    ['email' => 'juan.perez@email.com', 'password' => 'Pac123!', 'rol' => 'paciente'],
    ['email' => 'maria.lopez@email.com', 'password' => 'Pac123!', 'rol' => 'paciente'],
];
```

---

## ✅ FASE 6: Testing y Validación

### Laravel
- [ ] Login exitoso con admin
- [ ] Rechazo de login con rol profesional/paciente
- [ ] Token JWT válido en sesión
- [ ] Logout correcto
- [ ] Middleware bloquea acceso sin autenticación
- [ ] Middleware verifica rol correctamente

### Ionic
- [ ] Login exitoso con profesional
- [ ] Rechazo de login con rol admin/paciente
- [ ] Token guardado en storage
- [ ] Guard protege rutas
- [ ] Permisos cargados correctamente
- [ ] Logout limpia datos

### Flutter
- [ ] Login exitoso con paciente
- [ ] Rechazo de login con rol admin/profesional
- [ ] Token válido guardado
- [ ] Provider actualiza estado
- [ ] Navegación protegida
- [ ] Datos de usuario disponibles

---

## 📚 FASE 7: Documentación Adicional

### Crear documentos de ayuda:

1. **`USUARIOS_PRUEBA.md`** - Credenciales de testing
2. **`API_TOKENS.md`** - Documentación de JWT tokens
3. **`TROUBLESHOOTING.md`** - Solución de problemas comunes
4. **`DEPLOYMENT.md`** - Guía de despliegue

---

## 🎯 Orden de Implementación Recomendado

### Semana 1: Laravel (Base)
1. ✅ Configurar Firebase Auth en Console
2. ✅ Crear Guard y Provider
3. ✅ Implementar login/logout
4. ✅ Crear seeder automático
5. ✅ Testing completo

### Semana 2: Ionic (Profesionales)
1. ✅ Configurar Firebase SDK
2. ✅ Crear servicio de auth
3. ✅ Implementar login
4. ✅ Configurar guards
5. ✅ Testing

### Semana 3: Flutter (Pacientes)
1. ✅ Configurar Firebase
2. ✅ Crear modelos y servicios
3. ✅ Implementar login
4. ✅ Provider de estado
5. ✅ Testing

### Semana 4: Integración y Testing
1. ✅ Pruebas cruzadas entre plataformas
2. ✅ Verificar sincronización
3. ✅ Optimización de rendimiento
4. ✅ Documentación final

---

## 🔒 Consideraciones de Seguridad

### Firebase Rules (Firestore) - Actualizado para arquitectura normalizada

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ============================================
    // USUARIOS (Tabla central)
    // ============================================
    match /usuarios/{userId} {
      // Permitir lectura solo si es el mismo usuario o es admin
      allow read: if request.auth != null && (
        request.auth.uid == userId ||
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin'
      );
      
      // Solo admins pueden crear/eliminar usuarios
      allow create, delete: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin';
      
      // Usuarios pueden actualizar sus propios datos (excepto rol y activo)
      // Admins pueden actualizar todo
      allow update: if request.auth != null && (
        (request.auth.uid == userId && 
         !request.resource.data.diff(resource.data).affectedKeys().hasAny(['rol', 'activo', 'idPaciente', 'idProfesional'])) ||
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin'
      );
    }
    
    // ============================================
    // PACIENTES (Solo datos médicos)
    // ============================================
    match /pacientes/{pacienteId} {
      // Función helper para verificar si el usuario es dueño del paciente
      function isOwner() {
        let usuario = get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data;
        return usuario.idPaciente == pacienteId;
      }
      
      // Función helper para verificar si es profesional o admin
      function canAccessMedicalData() {
        let usuario = get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data;
        return usuario.rol in ['admin', 'profesional'];
      }
      
      // Lectura: El paciente dueño, profesionales o admins
      allow read: if request.auth != null && (
        isOwner() || 
        canAccessMedicalData()
      );
      
      // Crear: Solo admins y profesionales
      allow create: if request.auth != null && canAccessMedicalData() &&
        request.resource.data.keys().hasAll(['idUsuario']) &&
        // Validar que el usuario exista y no tenga ya un paciente
        exists(/databases/$(database)/documents/usuarios/$(request.resource.data.idUsuario));
      
      // Actualizar: El paciente dueño (solo ciertos campos), profesionales o admins
      allow update: if request.auth != null && (
        // Paciente puede actualizar solo campos específicos
        (isOwner() && 
         !request.resource.data.diff(resource.data).affectedKeys().hasAny(['idUsuario'])) ||
        // Profesionales y admins pueden actualizar todo excepto idUsuario
        (canAccessMedicalData() && 
         !request.resource.data.diff(resource.data).affectedKeys().hasAny(['idUsuario']))
      );
      
      // Eliminar: Solo admins
      allow delete: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin';
    }
    
    // ============================================
    // PROFESIONALES (Solo datos profesionales)
    // ============================================
    match /profesionales/{profesionalId} {
      // Función helper para verificar si el usuario es dueño del perfil profesional
      function isOwner() {
        let usuario = get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data;
        return usuario.idProfesional == profesionalId;
      }
      
      // Lectura: Todos los usuarios autenticados (para ver profesionales disponibles)
      allow read: if request.auth != null;
      
      // Crear: Solo admins
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin' &&
        request.resource.data.keys().hasAll(['idUsuario']) &&
        exists(/databases/$(database)/documents/usuarios/$(request.resource.data.idUsuario));
      
      // Actualizar: El profesional dueño o admins (no puede cambiar idUsuario)
      allow update: if request.auth != null && (
        isOwner() || 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin'
      ) && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['idUsuario']);
      
      // Eliminar: Solo admins
      allow delete: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin';
    }
    
    // ============================================
    // PERMISOS-USUARIO
    // ============================================
    match /permisos-usuario/{permisoId} {
      // Lectura: Solo el usuario dueño o admins
      allow read: if request.auth != null && (
        resource.data.idUsuario == request.auth.uid ||
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin'
      );
      
      // Escritura: Solo admins
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin';
    }
    
    // ============================================
    // FICHAS MÉDICAS
    // ============================================
    match /fichasMedicas/{fichaId} {
      // Función para obtener el paciente de la ficha
      function getPaciente() {
        return get(/databases/$(database)/documents/pacientes/$(resource.data.idPaciente)).data;
      }
      
      // Función para verificar si el usuario es el dueño de la ficha
      function isOwner() {
        let paciente = getPaciente();
        let usuario = get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data;
        return usuario.idPaciente == resource.data.idPaciente;
      }
      
      // Lectura: El paciente dueño, profesionales o admins
      allow read: if request.auth != null && (
        isOwner() ||
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol in ['admin', 'profesional']
      );
      
      // Escritura: Solo profesionales y admins
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol in ['admin', 'profesional'];
    }
    
    // ============================================
    // CONSULTAS, HOSPITALIZACIONES, EXÁMENES
    // ============================================
    match /consultas/{consultaId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol in ['admin', 'profesional'];
    }
    
    match /hospitalizaciones/{hospitalizacionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol in ['admin', 'profesional'];
    }
    
    match /ordenesExamen/{ordenId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol in ['admin', 'profesional'];
    }
    
    // ============================================
    // HOSPITALES (Solo lectura para todos)
    // ============================================
    match /hospitales/{hospitalId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin';
    }
  }
}
```

### Explicación de las reglas de seguridad:

**1. Usuarios:**
- ✅ Los usuarios pueden ver su propia información
- ✅ Los admins pueden ver y modificar cualquier usuario
- ✅ Los usuarios NO pueden cambiar su propio rol o estado activo
- ✅ Solo admins pueden crear/eliminar usuarios

**2. Pacientes:**
- ✅ El paciente puede ver y actualizar sus propios datos médicos
- ✅ Profesionales y admins pueden ver y modificar datos de cualquier paciente
- ✅ NADIE puede cambiar el campo `idUsuario` (inmutable)
- ✅ Se valida que el usuario exista antes de crear el paciente

**3. Profesionales:**
- ✅ Todos pueden ver perfiles profesionales (para buscar especialistas)
- ✅ El profesional puede actualizar su propio perfil
- ✅ Solo admins pueden crear/eliminar profesionales
- ✅ NADIE puede cambiar el campo `idUsuario` (inmutable)

**4. Fichas Médicas:**
- ✅ El paciente puede ver su propia ficha
- ✅ Profesionales pueden crear y modificar fichas
- ✅ Se vincula correctamente con el paciente vía `idPaciente`

### Testing de las reglas:

```javascript
// En Firebase Console → Firestore → Rules → Rules Playground

// Test 1: Usuario paciente intenta leer su propio registro
match /usuarios/abc123
authenticated: yes
auth.uid: abc123
data.rol: paciente
// ✅ Debe permitir

// Test 2: Usuario paciente intenta cambiar su rol
match /usuarios/abc123
authenticated: yes
auth.uid: abc123
request.resource.data.rol: admin  // Intenta cambiar a admin
// ❌ Debe denegar

// Test 3: Profesional intenta leer datos de un paciente
match /pacientes/xyz789
authenticated: yes
auth.uid: def456
usuarios/def456.data.rol: profesional
// ✅ Debe permitir

// Test 4: Paciente intenta cambiar su idUsuario
match /pacientes/xyz789
authenticated: yes
auth.uid: abc123
request.resource.data.idUsuario: otro_id  // Intenta cambiar
// ❌ Debe denegar
```

---

## 📊 Métricas de Éxito

- ✅ Usuarios pueden autenticarse desde las 3 plataformas
- ✅ Roles restringen acceso correctamente
- ✅ Tokens JWT válidos y sincronizados
- ✅ Sesiones persistentes
- ✅ Logout limpia datos correctamente
- ✅ Sin duplicación de usuarios
- ✅ Permisos funcionan según rol

---

## 🆘 Soporte y Recursos

### Documentación Oficial
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Laravel Auth](https://laravel.com/docs/authentication)
- [Angular Fire](https://github.com/angular/angularfire)
- [FlutterFire](https://firebase.flutter.dev/)

### IDs Importantes del Proyecto
- **Hospital ID:** `RSAlN3zsmWzeoY3z9GzN`
- **Paciente 1 ID:** `Fh2byylkEBfJCxd2vD1P`
- **Paciente 2 ID:** `SUso7Nyhb18whZ21Z2Ux`
- **Firebase Project:** `nexus-68994`

---

**Última actualización:** 26 de noviembre de 2025  
**Estado:** ✅ Arquitectura normalizada implementada en Laravel  
**Prioridad:** Alta - Sistema crítico para todas las plataformas

---

## 🔄 CHECKLIST DE MIGRACIÓN POR PLATAFORMA

### ✅ Laravel (COMPLETADO)
- [x] Modelos actualizados (Usuario, Paciente, Profesional)
- [x] UsuarioController con creación en 2 pasos
- [x] Validación de RUT único
- [x] Validación de email único
- [x] Creación automática de paciente/profesional según rol
- [x] Referencias bidireccionales (usuario ↔ paciente/profesional)
- [x] DatabaseSeeder actualizado
- [x] Vistas Vue actualizadas (Index, Show, Create)
- [x] Búsqueda por nombre/email/rut en usuarios

### ⏳ Ionic Angular (PENDIENTE)
- [ ] Actualizar modelos TypeScript (Usuario, Profesional, ProfesionalCompleto)
- [ ] Actualizar AuthService para obtener datos de dos colecciones
- [ ] Crear PacienteService con métodos JOIN
- [ ] Actualizar componentes de perfil para usar datos combinados
- [ ] Actualizar formularios de creación (usuario primero, luego profesional)
- [ ] Actualizar búsquedas para consultar colección usuarios
- [ ] Separar actualizaciones: updateUserProfile() vs updateProfesionalData()
- [ ] Testing completo del login y flujos de datos

### ⏳ Flutter (PENDIENTE)
- [ ] Actualizar modelos Dart (Usuario, Paciente, PacienteCompleto)
- [ ] Actualizar AuthService para obtener datos de dos colecciones
- [ ] Crear métodos de actualización separados (perfil vs datos médicos)
- [ ] Actualizar screens de perfil para usar datos combinados
- [ ] Actualizar formularios de registro (usuario primero, luego paciente)
- [ ] Actualizar búsquedas para consultar colección usuarios
- [ ] Implementar cache local con SharedPreferences
- [ ] Testing completo del login y flujos de datos

---

## 📋 REGLAS DE NEGOCIO CRÍTICAS

### 🔴 Regla 1: Usuario SIEMPRE primero
```
❌ NO SE PUEDE crear un paciente o profesional sin usuario
✅ FLUJO CORRECTO:
   1. Crear usuario en Firebase Auth
   2. Crear usuario en Firestore (usuarios)
   3. SI rol='paciente' → Crear en pacientes con idUsuario
   4. SI rol='profesional' → Crear en profesionales con idUsuario
   5. Actualizar usuario con idPaciente o idProfesional
```

### 🔴 Regla 2: Datos personales SOLO en usuarios
```
❌ NO DUPLICAR en pacientes/profesionales:
   - email
   - rut
   - displayName (nombre completo)
   - telefono
   - photoURL

✅ Estos campos SOLO existen en la colección 'usuarios'
```

### 🔴 Regla 3: JOIN obligatorio para datos completos
```
// ❌ INCORRECTO - Datos incompletos
const paciente = await getPaciente(id);
// Solo tiene: grupoSanguineo, alergias, etc. (no tiene nombre ni email)

// ✅ CORRECTO - Datos completos con JOIN
const paciente = await getPaciente(id);
const usuario = await getUsuario(paciente.idUsuario);
// Ahora tenemos: nombre, email, rut Y datos médicos
```

### 🔴 Regla 4: Búsquedas en usuarios, NO en pacientes
```
// ❌ INCORRECTO
buscarPacientes(nombre) → colección pacientes
// No tiene campo 'nombre'

// ✅ CORRECTO
buscarUsuarios(nombre, rol='paciente') → colección usuarios
// Luego obtener datos de paciente usando usuario.idPaciente
```

### 🔴 Regla 5: Actualizaciones separadas
```
// Datos personales → Actualizar en 'usuarios'
updateDoc('usuarios/abc123', {
  displayName: 'Nuevo Nombre',
  telefono: '+56912345678'
});

// Datos médicos → Actualizar en 'pacientes'
updateDoc('pacientes/xyz789', {
  grupoSanguineo: 'O+',
  alergias: ['Polen']
});

// Datos profesionales → Actualizar en 'profesionales'
updateDoc('profesionales/def456', {
  especialidad: 'Cardiología',
  valorConsulta: 50000
});
```

---

## 🚨 ERRORES COMUNES A EVITAR

### Error 1: Intentar acceder a campos que no existen
```dart
// ❌ INCORRECTO
final paciente = await firestore.collection('pacientes').doc(id).get();
print(paciente.data()['nombre']);  // ❌ Campo 'nombre' no existe en pacientes

// ✅ CORRECTO
final paciente = await firestore.collection('pacientes').doc(id).get();
final usuario = await firestore.collection('usuarios').doc(paciente.data()['idUsuario']).get();
print(usuario.data()['displayName']);  // ✅ Campo existe en usuarios
```

### Error 2: Crear paciente sin usuario
```php
// ❌ INCORRECTO
$paciente = Paciente::create([
    'grupoSanguineo' => 'O+',
    // Falta idUsuario
]);

// ✅ CORRECTO
$usuario = Usuario::create([...]);  // Primero crear usuario
$paciente = Paciente::create([
    'idUsuario' => $usuario['id'],  // Obligatorio
    'grupoSanguineo' => 'O+',
]);
```

### Error 3: Duplicar datos en múltiples colecciones
```typescript
// ❌ INCORRECTO
const profesional = {
  email: 'dr@email.com',      // ❌ Duplicado
  rut: '12345678-9',          // ❌ Duplicado
  nombre: 'Dr. Juan',         // ❌ Duplicado
  especialidad: 'Cardiología' // ✅ OK
};

// ✅ CORRECTO
const usuario = {
  email: 'dr@email.com',      // ✅ En usuarios
  rut: '12345678-9',          // ✅ En usuarios
  displayName: 'Dr. Juan',    // ✅ En usuarios
  rol: 'profesional'
};

const profesional = {
  idUsuario: usuario.id,      // ✅ Vinculación
  especialidad: 'Cardiología' // ✅ Solo datos profesionales
};
```

### Error 4: Buscar en la colección incorrecta
```typescript
// ❌ INCORRECTO - Buscar pacientes por nombre
const pacientes = await firestore.collection('pacientes')
  .where('nombre', '==', 'Juan')  // ❌ Campo no existe
  .get();

// ✅ CORRECTO - Buscar usuarios con rol paciente
const usuarios = await firestore.collection('usuarios')
  .where('rol', '==', 'paciente')
  .where('displayName', '>=', 'Juan')
  .get();

// Luego obtener datos médicos de cada paciente
for (const usuarioDoc of usuarios.docs) {
  if (usuarioDoc.data().idPaciente) {
    const paciente = await firestore.collection('pacientes')
      .doc(usuarioDoc.data().idPaciente)
      .get();
  }
}
```

---

## 📞 SOPORTE Y CONTACTO

### Para desarrolladores del equipo:

**Dudas sobre la arquitectura:**
- Revisar este documento (PLAN_IMPLEMENTACION_FIREBASE_AUTH.md)
- Consultar ejemplos de código en Laravel (ya implementado)
- Ver diagramas de relaciones en sección "Diagrama de Relaciones"

**Problemas durante la migración:**
1. Verificar que los campos existen en la colección correcta
2. Revisar los logs de Firestore para errores de permisos
3. Validar que las referencias (idUsuario, idPaciente, idProfesional) son correctas
4. Comprobar que Firebase Rules permiten las operaciones

**Testing:**
- Usar datos de prueba del DatabaseSeeder
- Verificar en Firebase Console que los datos están correctamente vinculados
- Probar flujos completos: crear usuario → crear paciente → obtener datos completos

---

## 📚 RECURSOS ADICIONALES

### Documentación implementada:
- ✅ Modelos Laravel: `app/Models/Usuario.php`, `Paciente.php`, `Profesional.php`
- ✅ Controlador: `app/Http/Controllers/UsuarioController.php`
- ✅ Vistas Vue: `resources/js/pages/Usuarios/Create.vue`, `Show.vue`, `Index.vue`
- ✅ Seeder: `database/seeders/DatabaseSeeder.php`

### Por implementar:
- ⏳ Modelos Ionic: Ver sección "FASE 3: Implementación Ionic"
- ⏳ Modelos Flutter: Ver sección "FASE 4: Implementación Flutter"
- ⏳ Servicios de datos con JOIN para ambas plataformas
- ⏳ Componentes de UI actualizados

---

## 🆕 Resumen de Cambios en Arquitectura de Base de Datos (Nov 2025)

### ❌ Arquitectura Anterior (Datos Duplicados)
```
usuarios { email, displayName, rol, idPaciente }
pacientes { nombre, apellido, rut, email, telefono, ... datos médicos }
profesionales { nombre, apellido, rut, email, telefono, ... datos profesionales }
```

**Problemas:**
- ❌ Datos duplicados (email, rut, telefono en múltiples colecciones)
- ❌ Inconsistencia de datos al actualizar
- ❌ Complejidad en búsquedas
- ❌ RUT no único en el sistema

### ✅ Arquitectura Nueva (Normalizada)
```
usuarios { 
  id (Firebase UID), 
  email*, displayName*, rut*, telefono, photoURL,
  rol*, activo*,
  idPaciente, idProfesional 
}

pacientes { 
  id, 
  idUsuario* (FK → usuarios.id),
  ...solo datos médicos (NO email, rut, nombre, telefono)
}

profesionales { 
  id, 
  idUsuario* (FK → usuarios.id),
  ...solo datos profesionales (NO email, rut, nombre, telefono)
}
```

**Beneficios:**
- ✅ Sin duplicación de datos
- ✅ RUT único en todo el sistema
- ✅ Email único con validación
- ✅ Un solo punto de autenticación
- ✅ Relaciones claras y mantenibles
- ✅ Fácil actualización de datos personales

### 🔄 Cambios en las 3 Plataformas

#### Laravel (Admin)
**Modelos actualizados:**
- `Usuario`: Validación de RUT único, métodos de relación
- `Paciente`: Requiere `idUsuario`, métodos con JOIN
- `Profesional`: Requiere `idUsuario`, métodos con JOIN

**Controladores:**
- `UsuarioController`: CRUD centralizado para todos los usuarios
- `PacienteController`: Creación en 2 pasos (usuario + paciente)
- `ProfesionalController`: Creación en 2 pasos (usuario + profesional)

**Seeder:**
- Crea usuarios en Firebase Auth primero
- Usa UID de Firebase como ID en Firestore
- Vincula pacientes/profesionales con usuarios

#### Ionic (Profesionales)
**Modelos:**
```typescript
interface Usuario {
  id, email, displayName, rut, telefono, photoURL, rol, idProfesional
}
interface Profesional {
  id, idUsuario, especialidad, licenciaMedica, ...
}
```

**AuthService:**
- Login valida `rol='profesional'`
- Obtiene datos de usuario + profesional
- Cache en Storage con ambas estructuras

#### Flutter (Pacientes)
**Modelos:**
```dart
class Usuario { id, email, displayName, rut, telefono, rol, idPaciente }
class Paciente { id, idUsuario, ...datos médicos }
class PacienteCompleto { Usuario usuario, Paciente paciente }
```

**AuthService:**
- Login valida `rol='paciente'`
- Obtiene datos de usuario + paciente
- Métodos separados: `updateUserProfile()` vs `updatePacienteData()`

### 📝 Reglas de Firestore Actualizadas
- ✅ Usuarios solo pueden modificar sus datos personales (no rol ni estado)
- ✅ Campo `idUsuario` es inmutable en pacientes/profesionales
- ✅ Profesionales pueden acceder a datos médicos de pacientes
- ✅ Pacientes solo ven sus propios datos médicos
- ✅ Validación de existencia de usuario al crear paciente/profesional

### ⚠️ Puntos Críticos de la Migración
1. **Migrar datos existentes** sin perder información
2. **Actualizar todas las vistas** para obtener datos del usuario cuando sea necesario
3. **Modificar búsquedas** para buscar en usuarios en lugar de pacientes/profesionales
4. **Ajustar formularios** de creación para manejar la estructura en 2 pasos

### 🎯 Próximos Pasos
1. ✅ Modelos actualizados (Completado)
2. ⏳ Crear comando de migración de datos
3. ⏳ Actualizar UsuarioController
4. ⏳ Crear PacienteController y ProfesionalController
5. ⏳ Actualizar vistas Vue/Ionic/Flutter
6. ⏳ Ejecutar migración en desarrollo
7. ⏳ Testing completo
8. ⏳ Deployment a producción
