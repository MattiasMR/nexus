# 🔐 Plan de Implementación: Firebase Authentication + JWT Tokens

## 📊 Información del Proyecto

**Firebase Project ID:** `nexus-68994`  
**Base de datos:** Firestore  
**Aplicaciones:**
- 🌐 **Laravel (Web)** - Perfil Admin
- 📱 **Ionic (Angular)** - Perfil Profesional  
- 📲 **Flutter** - Perfil Paciente

---

## 🗂️ Estructura de Base de Datos Firestore

### Colección: `usuarios`
```javascript
{
  id: "auto-generated-firebase-uid",  // UID de Firebase Authentication
  email: "usuario@example.com",
  displayName: "Nombre Completo",
  rol: "admin" | "profesional" | "paciente",
  idPaciente: "id-documento-paciente",  // Solo para rol='paciente'
  activo: true,
  createdAt: Timestamp,
  updatedAt: Timestamp,
  ultimoAcceso: Timestamp
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

### Colección: `pacientes`
```javascript
{
  id: "auto-generated",
  nombre: "Nombre Paciente",
  rut: "12345678-9",
  email: "paciente@email.com",
  // ... otros campos
}
```

### Colección: `hospitales`
```javascript
{
  id: "RSAlN3zsmWzeoY3z9GzN",
  nombre: "Hospital Name",
  // ... otros campos
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

**Cambios:**
- ✅ Ya existe modelo Firestore
- ✅ Agregar método `findByFirebaseUid()`
- ✅ Implementar interfaz `Authenticatable` de Laravel
- ✅ Agregar método `syncWithFirebaseAuth()` para sincronizar UID

**Nuevos métodos:**
```php
public function findByFirebaseUid(string $firebaseUid): ?array
public function createFromFirebaseUser(array $firebaseUser): array
public function updateFirebaseUid(string $id, string $firebaseUid): array
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

**Cambios:**
- Crear usuarios en Firebase Authentication primero
- Usar el UID devuelto como ID del documento en Firestore
- Agregar método `createFirebaseAuthUser(email, password, displayName)`

**Nuevo flujo:**
```php
// 1. Crear en Firebase Auth
$firebaseUser = $this->createFirebaseAuthUser(
    'admin1@nexus.cl',
    'password123',
    'Administrador Principal'
);

// 2. Crear en Firestore con el UID de Firebase
Usuario::create([
    'id' => $firebaseUser->uid,  // Usar UID de Firebase
    'email' => 'admin1@nexus.cl',
    'displayName' => 'Administrador Principal',
    'rol' => 'admin',
    'activo' => true,
]);
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

### 📝 Paso 3: Configurar Módulos

**Archivo:** `src/app/app.module.ts`

```typescript
import { provideFirebaseApp, initializeApp } from '@angular/fire/app';
import { provideAuth, getAuth } from '@angular/fire/auth';
import { provideFirestore, getFirestore } from '@angular/fire/firestore';
import { environment } from '../environments/environment';

@NgModule({
  imports: [
    provideFirebaseApp(() => initializeApp(environment.firebaseConfig)),
    provideAuth(() => getAuth()),
    provideFirestore(() => getFirestore()),
  ],
})
```

---

### 📝 Paso 4: Crear Servicio de Autenticación

**Archivo:** `src/app/services/auth.service.ts`

**Métodos:**
```typescript
async login(email: string, password: string): Promise<void>
async logout(): Promise<void>
async getCurrentUser(): Promise<Usuario | null>
async isAuthenticated(): Promise<boolean>
async getToken(): Promise<string | null>
```

**Validación de rol:**
```typescript
async login(email: string, password: string) {
  const credential = await signInWithEmailAndPassword(
    this.auth, 
    email, 
    password
  );
  
  // Obtener usuario de Firestore
  const userDoc = await getDoc(
    doc(this.firestore, 'usuarios', credential.user.uid)
  );
  
  const usuario = userDoc.data();
  
  // Verificar que sea profesional
  if (usuario.rol !== 'profesional') {
    await signOut(this.auth);
    throw new Error('Debes usar la aplicación de administración o pacientes');
  }
  
  // Guardar token
  const token = await credential.user.getIdToken();
  await this.storage.set('authToken', token);
  await this.storage.set('currentUser', usuario);
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

### 📝 Paso 4: Crear Modelo Usuario

**Archivo:** `lib/models/usuario.dart`

```dart
class Usuario {
  final String id;
  final String email;
  final String displayName;
  final String rol;
  final String? idPaciente;
  final bool activo;

  Usuario({
    required this.id,
    required this.email,
    required this.displayName,
    required this.rol,
    this.idPaciente,
    required this.activo,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Usuario(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      rol: data['rol'] ?? '',
      idPaciente: data['idPaciente'],
      activo: data['activo'] ?? true,
    );
  }
}
```

---

### 📝 Paso 5: Crear Servicio de Autenticación

**Archivo:** `lib/services/auth_service.dart`

**Métodos:**
```dart
Future<void> login(String email, String password)
Future<void> logout()
Future<Usuario?> getCurrentUser()
Stream<User?> get authStateChanges
Future<String?> getToken()
```

**Validación de rol:**
```dart
Future<void> login(String email, String password) async {
  UserCredential credential = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password);
  
  // Obtener usuario de Firestore
  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(credential.user!.uid)
      .get();
  
  Usuario usuario = Usuario.fromFirestore(userDoc);
  
  // Verificar que sea paciente
  if (usuario.rol != 'paciente') {
    await FirebaseAuth.instance.signOut();
    throw Exception('Debes usar la aplicación de profesionales o administración');
  }
  
  // Guardar localmente
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', usuario.id);
  await prefs.setString('userRole', usuario.rol);
}
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

### Firebase Rules (Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Solo usuarios autenticados pueden leer sus propios datos
    match /usuarios/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin';
    }
    
    // Permisos solo lectura para el usuario autenticado
    match /permisos-usuario/{permisoId} {
      allow read: if request.auth != null && 
                     resource.data.idUsuario == request.auth.uid;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol == 'admin';
    }
    
    // Pacientes solo pueden leer sus propios datos
    match /pacientes/{pacienteId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.rol in ['admin', 'profesional'];
    }
  }
}
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

**Última actualización:** 25 de noviembre de 2025  
**Estado:** Plan completo - Listo para implementación  
**Prioridad:** Alta - Sistema crítico para todas las plataformas
