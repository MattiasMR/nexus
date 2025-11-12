# Sistema de Autenticación Unificado - Nexus

## 🎯 Visión General

Sistema de autenticación transversal para 3 aplicaciones diferentes compartiendo la misma base de datos Firestore con control de acceso basado en roles y hospitales.

### Aplicaciones

| Aplicación | Usuarios | Propósito | Acceso |
|------------|----------|-----------|--------|
| **Ionic** | Pacientes | Ver historial médico | Solo lectura de datos propios |
| **Flutter** | Médicos | Gestionar atenciones | Crear/editar en hospitales asignados |
| **Laravel** | Admins/Super Admins | Administración | Gestión completa del hospital |

---

## 👥 Roles del Sistema

### 1. 🔵 Paciente (Ionic)

**Permisos**:
- ✅ Ver todas sus consultas (cualquier hospital)
- ✅ Ver todas sus recetas
- ✅ Ver todos sus exámenes y resultados
- ✅ Ver todas sus hospitalizaciones
- ✅ Ver su ficha médica completa
- ❌ NO puede editar nada
- ❌ NO puede ver datos de otros pacientes

**Acceso**:
```typescript
// Solo puede acceder a documentos donde:
idPaciente == currentUser.idPaciente
```

**Caso de Uso**:
> Juan se atiende en Hospital A, luego en Hospital B. Desde la app Ionic puede ver su historial completo de ambos hospitales sin restricciones.

---

### 2. 📱 Médico (Flutter)

**Permisos**:
- ✅ Ver pacientes que se han atendido en sus hospitales asignados
- ✅ Crear consultas en hospitales asignados
- ✅ Crear recetas para sus pacientes
- ✅ Solicitar exámenes
- ✅ Ver resultados de exámenes
- ✅ Registrar hospitalizaciones
- ❌ NO puede gestionar usuarios
- ❌ NO puede modificar catálogos
- ❌ NO puede ver/editar datos de otros hospitales

**Acceso**:
```typescript
// Solo puede acceder a documentos donde:
idHospital IN currentUser.hospitalesAsignados

// Ejemplo: Médico trabaja en Hospital A y Hospital C
hospitalesAsignados: ['hospital_A', 'hospital_C']
```

**Permisos Granulares**:
- `ver_consultas`
- `crear_consultas`
- `editar_consultas`
- `ver_fichas_medicas`
- `editar_fichas_medicas`
- `crear_recetas`
- `solicitar_examenes`
- `ver_examenes`

**Caso de Uso**:
> Dra. María trabaja en Hospital A y Hospital B. En Flutter puede ver pacientes que se han atendido en ambos hospitales y crear registros médicos. NO puede ver pacientes que solo se han atendido en Hospital C.

---

### 3. 💻 Admin (Laravel)

**Permisos**:
- ✅ Gestionar usuarios de su hospital
- ✅ Gestionar profesionales de su hospital
- ✅ Ver todas las consultas del hospital
- ✅ Gestionar catálogos (exámenes/medicamentos) del hospital
- ✅ Ver reportes y estadísticas del hospital
- ✅ Configurar permisos de médicos en su hospital
- ❌ NO puede gestionar otros hospitales
- ❌ NO puede crear hospitales

**Acceso**:
```typescript
// Solo puede acceder a documentos donde:
idHospital IN currentUser.hospitalesAsignados

// Ejemplo: Admin del Hospital A
hospitalesAsignados: ['hospital_A']
```

**Permisos Granulares**:
- `gestionar_usuarios`
- `gestionar_profesionales`
- `gestionar_pacientes`
- `ver_reportes`
- `configurar_hospital`
- `gestionar_examenes_catalogo`
- `gestionar_medicamentos_catalogo`

---

### 4. 🔐 Super Admin (Laravel)

**Permisos**:
- ✅ TODO lo de Admin en TODOS los hospitales
- ✅ Crear y gestionar hospitales
- ✅ Asignar administradores a hospitales
- ✅ Ver reportes globales del sistema
- ✅ Acceso total sin restricciones

**Acceso**:
```typescript
// Acceso ilimitado a todos los documentos
// hospitalesAsignados: [] (vacío = acceso total)
```

**Permisos Especiales**:
- `gestionar_hospitales`
- `gestionar_todos_usuarios`
- `acceso_total`

---

## 🗄️ Estructura de Datos

### Colección: `usuarios`

```typescript
{
  id: string,                    // Firebase Auth UID
  email: string,
  rol: 'paciente' | 'medico' | 'admin' | 'super_admin',
  
  // Campos condicionales según rol
  idPaciente?: string,           // Si rol = 'paciente'
  idProfesional?: string,        // Si rol = 'medico'
  
  // Hospitales asignados (para medicos/admins)
  hospitalesAsignados: string[], // IDs de hospitales
  
  // Estado
  activo: boolean,
  emailVerificado: boolean,
  
  // Metadata
  createdAt: Timestamp,
  updatedAt: Timestamp,
  ultimoAcceso: Timestamp
}
```

### Colección: `hospitales`

```typescript
{
  id: string,
  nombre: string,
  direccion: string,
  codigoHospital: string,        // Código único identificador
  tipo: 'hospital' | 'clinica' | 'centro_salud',
  
  // Contacto
  telefono?: string,
  email?: string,
  
  // Configuración
  configuracion: {
    permitirRegistroPacientes: boolean,
    requiereAprobacionConsultas: boolean,
    horariosAtencion: string
  },
  
  // Estado
  activo: boolean,
  
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Colección: `permisos-usuario`

```typescript
{
  id: string,                    // formato: {idUsuario}_{idHospital}
  idUsuario: string,
  idHospital: string,
  
  // Array de permisos granulares
  permisos: [
    'ver_consultas',
    'crear_consultas',
    'editar_consultas',
    'solicitar_examenes',
    // ... más permisos
  ],
  
  // Vigencia
  fechaInicio: Timestamp,
  fechaFin?: Timestamp,          // null = indefinido
  activo: boolean,
  
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

---

## 🔄 Flujo de Autenticación

### 1. Login (Todas las Apps)

```typescript
// Firebase Authentication
const userCredential = await signInWithEmailAndPassword(auth, email, password);
const user = userCredential.user;

// Obtener datos del usuario desde Firestore
const userDoc = await getDoc(doc(db, 'usuarios', user.uid));
const userData = userDoc.data();

// Obtener custom claims de Firebase Auth
const idTokenResult = await user.getIdTokenResult();
const rol = idTokenResult.claims.rol;
const hospitalesAsignados = idTokenResult.claims.hospitalesAsignados || [];

// Guardar en estado de la app
setCurrentUser({
  uid: user.uid,
  email: user.email,
  rol: rol,
  idPaciente: userData.idPaciente,
  idProfesional: userData.idProfesional,
  hospitalesAsignados: hospitalesAsignados
});
```

### 2. Verificación de Permisos (Flutter/Laravel)

```typescript
// Antes de realizar una acción sensible
async function verificarPermiso(hospitalId: string, permiso: string): Promise<boolean> {
  const permisoDoc = await getDoc(
    doc(db, 'permisos-usuario', `${currentUser.uid}_${hospitalId}`)
  );
  
  if (!permisoDoc.exists()) {
    return false;
  }
  
  const permisos = permisoDoc.data().permisos;
  return permisos.includes(permiso) && permisoDoc.data().activo;
}

// Ejemplo: Crear consulta
if (await verificarPermiso(selectedHospital, 'crear_consultas')) {
  await addDoc(collection(db, 'consultas'), {
    idHospital: selectedHospital,
    idPaciente: patientId,
    idProfesional: currentUser.idProfesional,
    fecha: Timestamp.now(),
    // ... resto de datos
  });
} else {
  showError('No tienes permiso para crear consultas en este hospital');
}
```

### 3. Filtrado de Datos (Queries)

#### Ionic (Pacientes):
```typescript
// Ver todas mis consultas (sin filtro de hospital)
const consultasRef = collection(db, 'consultas');
const q = query(
  consultasRef,
  where('idPaciente', '==', currentUser.idPaciente),
  orderBy('fecha', 'desc')
);
```

#### Flutter (Médicos):
```typescript
// Ver pacientes de mis hospitales
const pacientesRef = collection(db, 'pacientes');
const q = query(
  pacientesRef,
  where('hospitalesAtendido', 'array-contains-any', currentUser.hospitalesAsignados)
);

// Ver consultas de un hospital específico
const consultasRef = collection(db, 'consultas');
const q2 = query(
  consultasRef,
  where('idHospital', '==', selectedHospital),
  orderBy('fecha', 'desc'),
  limit(50)
);
```

#### Laravel (Admins):
```php
// Ver todas las consultas de mi hospital
$consultasRef = $this->firestore->collection('consultas');
$query = $consultasRef
    ->where('idHospital', '=', $currentUser->hospitalesAsignados[0])
    ->orderBy('fecha', 'DESC')
    ->limit(100);

$consultas = $query->documents();
```

---

## 🛡️ Seguridad (Firestore Rules)

### Principios de Seguridad

1. **Autenticación Obligatoria**: Todas las operaciones requieren usuario autenticado
2. **Roles Verificados**: Los roles vienen de custom claims de Firebase Auth
3. **Permisos Granulares**: Se verifican en colección `permisos-usuario`
4. **Aislamiento por Hospital**: Queries filtradas automáticamente por Firestore Rules
5. **Auditoría**: Todos los cambios registran `updatedAt` y usuario que modificó

### Reglas de Seguridad Clave

```javascript
// Función auxiliar para obtener datos del usuario
function getUserData() {
  return get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data;
}

// Verificar si usuario tiene permiso en hospital específico
function hasPermissionInHospital(hospitalId, permission) {
  let permisoDoc = get(/databases/$(database)/documents/permisos-usuario/$(request.auth.uid + '_' + hospitalId));
  return permisoDoc != null 
    && permission in permisoDoc.data.permisos 
    && permisoDoc.data.activo == true;
}

// Verificar si es el mismo paciente
function isOwnPatientData(pacienteId) {
  let user = getUserData();
  return user.rol == 'paciente' && user.idPaciente == pacienteId;
}
```

---

## 🚀 Plan de Implementación

### Fase 1: Preparación (Semana 1) ✅

- [x] Diseñar modelo de datos multi-tenant
- [x] Actualizar `Modelo_BDD.md`
- [ ] Crear colecciones en Firestore:
  - `usuarios`
  - `hospitales`
  - `permisos-usuario`

### Fase 2: Firebase Auth Setup (Semana 2)

**Tareas**:
1. Configurar Firebase Authentication en los 3 proyectos
2. Crear Cloud Function para asignar custom claims al crear usuario
3. Implementar sincronización Laravel Auth ↔ Firebase Auth

**Código Cloud Function**:
```typescript
// functions/src/index.ts
export const onUserCreate = functions.firestore
  .document('usuarios/{userId}')
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    const userId = context.params.userId;
    
    // Asignar custom claims basados en el rol
    const customClaims = {
      rol: userData.rol,
      idPaciente: userData.idPaciente || null,
      idProfesional: userData.idProfesional || null,
      hospitalesAsignados: userData.hospitalesAsignados || []
    };
    
    await admin.auth().setCustomUserClaims(userId, customClaims);
    
    console.log(`Custom claims set for user ${userId}:`, customClaims);
  });
```

### Fase 3: Laravel Backend (Semana 3)

**Tareas**:
1. Crear modelo `User` con sincronización a Firestore
2. Implementar middleware de autenticación con Firebase
3. Crear interfaces CRUD para:
   - Gestión de usuarios
   - Gestión de hospitales
   - Asignación de permisos
4. Dashboard de administración

**Endpoints API**:
```php
// routes/api.php
Route::middleware(['auth:firebase'])->group(function () {
    // Usuarios
    Route::get('/usuarios', [UsuarioController::class, 'index']);
    Route::post('/usuarios', [UsuarioController::class, 'store']);
    Route::put('/usuarios/{id}', [UsuarioController::class, 'update']);
    
    // Hospitales (solo super_admin)
    Route::middleware(['role:super_admin'])->group(function () {
        Route::get('/hospitales', [HospitalController::class, 'index']);
        Route::post('/hospitales', [HospitalController::class, 'store']);
    });
    
    // Permisos
    Route::post('/permisos', [PermisoController::class, 'asignar']);
    Route::delete('/permisos/{id}', [PermisoController::class, 'revocar']);
});
```

### Fase 4: Flutter App (Semana 4)

**Tareas**:
1. Implementar login con Firebase Auth
2. Agregar selector de hospital (si médico tiene múltiples asignados)
3. Modificar todas las queries para filtrar por hospital
4. Agregar verificación de permisos antes de acciones sensibles
5. Mostrar hospital en cada registro médico

**Pantallas a Modificar**:
- Login/Registro
- Selector de hospital (nueva)
- Lista de pacientes (filtrar por hospital)
- Crear consulta (agregar campo hospital)
- Crear receta (agregar campo hospital)
- Solicitar examen (agregar campo hospital)

### Fase 5: Ionic App (Semana 5)

**Tareas**:
1. Implementar login con Firebase Auth
2. Modificar vistas para mostrar hospital de cada registro
3. Agregar badge/tag con nombre del hospital
4. Implementar filtros por hospital en historial
5. Modo completamente read-only

**Pantallas a Modificar**:
- Login
- Historial de consultas (mostrar hospital)
- Ver recetas (mostrar hospital)
- Ver exámenes (mostrar hospital)

### Fase 6: Migración de Datos (Semana 6)

**Script de Migración**:
```typescript
// scripts/migrate-to-multitenant.ts
async function migrarDatos() {
  // 1. Crear hospital "default" para datos existentes
  const defaultHospital = await addDoc(collection(db, 'hospitales'), {
    nombre: 'Hospital Principal',
    codigoHospital: 'HOSP_DEFAULT',
    tipo: 'hospital',
    activo: true,
    createdAt: Timestamp.now()
  });
  
  // 2. Agregar idHospital a todas las consultas existentes
  const consultasSnapshot = await getDocs(collection(db, 'consultas'));
  const batch = writeBatch(db);
  
  consultasSnapshot.docs.forEach(doc => {
    batch.update(doc.ref, {
      idHospital: defaultHospital.id,
      updatedAt: Timestamp.now()
    });
  });
  
  await batch.commit();
  
  // 3. Actualizar pacientes con hospitalesAtendido
  const pacientesSnapshot = await getDocs(collection(db, 'pacientes'));
  const batch2 = writeBatch(db);
  
  pacientesSnapshot.docs.forEach(doc => {
    batch2.update(doc.ref, {
      hospitalesAtendido: [defaultHospital.id],
      updatedAt: Timestamp.now()
    });
  });
  
  await batch2.commit();
  
  // 4. Similar para recetas, exámenes, hospitalizaciones, diagnósticos
  // ...
}
```

### Fase 7: Testing y Deployment (Semana 7)

**Tests de Seguridad**:
1. ✅ Paciente NO puede ver datos de otro paciente
2. ✅ Médico NO puede ver datos de hospital no asignado
3. ✅ Admin NO puede gestionar otro hospital
4. ✅ Verificar que custom claims se asignan correctamente
5. ✅ Verificar que permisos granulares funcionan

**Tests de Performance**:
1. ✅ Queries con filtro de hospital son rápidas
2. ✅ Indices compuestos creados correctamente
3. ✅ Carga de datos no excede límites de Firestore

**Deployment**:
1. Deploy Firestore Security Rules en producción
2. Deploy Cloud Functions
3. Deploy Laravel backend
4. Deploy Flutter app (Android/iOS)
5. Deploy Ionic app (Android/iOS)

---

## 📊 Monitoreo y Auditoría

### Logs a Implementar

```typescript
// Crear log de auditoría en cada operación sensible
await addDoc(collection(db, 'audit_logs'), {
  accion: 'crear_consulta',
  idUsuario: currentUser.uid,
  rol: currentUser.rol,
  idHospital: selectedHospital,
  documentoAfectado: 'consultas/' + consultaId,
  timestamp: Timestamp.now(),
  detalles: {
    idPaciente: patientId,
    idProfesional: currentUser.idProfesional
  }
});
```

### Métricas a Monitorear

- Número de usuarios activos por hospital
- Consultas creadas por día/hospital
- Intentos de acceso denegados (violaciones de seguridad)
- Tiempo de respuesta de queries
- Errores de autenticación

---

## 🔗 Recursos Adicionales

- [Modelo de Base de Datos Completo](./Modelo_BDD.md)
- [Firestore Security Rules](./firebase/firestore.rules)
- [Custom Claims Documentation](https://firebase.google.com/docs/auth/admin/custom-claims)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

---

**Versión**: 1.0  
**Última Actualización**: Enero 2025  
**Autores**: Equipo Nexus
