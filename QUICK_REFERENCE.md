# Quick Reference - Multi-Tenant Authentication

## 🚀 Inicio Rápido por Aplicación

### Ionic (Pacientes) - Solo Lectura

```typescript
// Login
const { user } = await signInWithEmailAndPassword(auth, email, password);
const userData = await getDoc(doc(db, 'usuarios', user.uid));

// Ver mis consultas (TODOS los hospitales)
const q = query(
  collection(db, 'consultas'),
  where('idPaciente', '==', userData.data().idPaciente),
  orderBy('fecha', 'desc')
);

// Ver mis recetas
const q2 = query(
  collection(db, 'recetas'),
  where('idPaciente', '==', userData.data().idPaciente),
  orderBy('fecha', 'desc')
);
```

**Regla**: SIEMPRE filtrar por `idPaciente` del usuario autenticado.

---

### Flutter (Médicos) - Crear y Editar

```typescript
// Login y obtener hospitales asignados
const { user } = await signInWithEmailAndPassword(auth, email, password);
const idToken = await user.getIdTokenResult();
const hospitalesAsignados = idToken.claims.hospitalesAsignados || [];

// Ver pacientes de MIS hospitales
const q = query(
  collection(db, 'pacientes'),
  where('hospitalesAtendido', 'array-contains-any', hospitalesAsignados)
);

// Crear consulta (verificar permiso primero)
async function crearConsulta(hospitalId, consultaData) {
  // 1. Verificar permiso
  const permisoDoc = await getDoc(
    doc(db, 'permisos-usuario', `${user.uid}_${hospitalId}`)
  );
  
  if (!permisoDoc.exists() || !permisoDoc.data().permisos.includes('crear_consultas')) {
    throw new Error('Sin permiso para crear consultas en este hospital');
  }
  
  // 2. Crear consulta con idHospital
  await addDoc(collection(db, 'consultas'), {
    idHospital: hospitalId,  // ⚠️ CRÍTICO: Siempre incluir
    idPaciente: consultaData.idPaciente,
    idProfesional: user.idProfesional,
    fecha: Timestamp.now(),
    motivo: consultaData.motivo,
    // ... resto de campos
  });
  
  // 3. Actualizar hospitalesAtendido del paciente
  const pacienteRef = doc(db, 'pacientes', consultaData.idPaciente);
  await updateDoc(pacienteRef, {
    hospitalesAtendido: arrayUnion(hospitalId)
  });
}
```

**Regla**: SIEMPRE incluir `idHospital` en TODAS las operaciones de escritura.

---

### Laravel (Admins) - Gestión Completa

```php
// Obtener usuario autenticado con Firebase
$firebaseUser = $request->attributes->get('firebaseUser');
$userData = $this->firestore
    ->collection('usuarios')
    ->document($firebaseUser->uid)
    ->snapshot()
    ->data();

// Ver consultas de MI hospital
$hospitalId = $userData['hospitalesAsignados'][0];
$consultas = $this->firestore
    ->collection('consultas')
    ->where('idHospital', '=', $hospitalId)
    ->orderBy('fecha', 'DESC')
    ->limit(100)
    ->documents();

// Crear usuario y asignar a hospital
public function crearUsuario(Request $request)
{
    // 1. Crear en Firebase Auth
    $firebaseUser = $this->auth->createUser([
        'email' => $request->email,
        'password' => $request->password,
        'emailVerified' => false
    ]);
    
    // 2. Crear en Firestore usuarios
    $this->firestore->collection('usuarios')->document($firebaseUser->uid)->set([
        'email' => $request->email,
        'rol' => $request->rol,
        'idProfesional' => $request->idProfesional ?? null,
        'hospitalesAsignados' => [$request->hospitalId],
        'activo' => true,
        'createdAt' => new Timestamp(new DateTime())
    ]);
    
    // 3. Asignar permisos por defecto
    $permisos = $this->getPermisosDefaultPorRol($request->rol);
    $this->firestore
        ->collection('permisos-usuario')
        ->document($firebaseUser->uid . '_' . $request->hospitalId)
        ->set([
            'idUsuario' => $firebaseUser->uid,
            'idHospital' => $request->hospitalId,
            'permisos' => $permisos,
            'activo' => true,
            'fechaInicio' => new Timestamp(new DateTime()),
            'createdAt' => new Timestamp(new DateTime())
        ]);
    
    // 4. Asignar custom claims (requiere Cloud Function o Admin SDK)
    $this->auth->setCustomUserClaims($firebaseUser->uid, [
        'rol' => $request->rol,
        'hospitalesAsignados' => [$request->hospitalId]
    ]);
    
    return response()->json(['success' => true, 'uid' => $firebaseUser->uid]);
}
```

---

## 🔒 Checklist de Seguridad

### Antes de cada operación de escritura:

- [ ] Usuario está autenticado (`request.auth != null`)
- [ ] Rol del usuario es correcto para la operación
- [ ] Campo `idHospital` está presente en el documento
- [ ] Usuario tiene permiso en ese hospital específico
- [ ] Se verificó en colección `permisos-usuario`
- [ ] Se agregó `updatedAt` con timestamp actual

### Ejemplo de verificación completa:

```typescript
async function verificarYEjecutar(
  accion: string,
  hospitalId: string,
  operacion: () => Promise<void>
) {
  // 1. Usuario autenticado
  if (!auth.currentUser) {
    throw new Error('Usuario no autenticado');
  }
  
  // 2. Obtener datos del usuario
  const userDoc = await getDoc(doc(db, 'usuarios', auth.currentUser.uid));
  if (!userDoc.exists()) {
    throw new Error('Usuario no encontrado en sistema');
  }
  
  const userData = userDoc.data();
  
  // 3. Verificar rol
  if (userData.rol !== 'medico' && userData.rol !== 'admin') {
    throw new Error('Rol no autorizado para esta acción');
  }
  
  // 4. Verificar hospital asignado
  if (!userData.hospitalesAsignados.includes(hospitalId)) {
    throw new Error('Usuario no asignado a este hospital');
  }
  
  // 5. Verificar permiso específico
  const permisoDoc = await getDoc(
    doc(db, 'permisos-usuario', `${auth.currentUser.uid}_${hospitalId}`)
  );
  
  if (!permisoDoc.exists()) {
    throw new Error('Sin permisos en este hospital');
  }
  
  const permisos = permisoDoc.data().permisos;
  if (!permisos.includes(accion)) {
    throw new Error(`Sin permiso para: ${accion}`);
  }
  
  // 6. Ejecutar operación
  await operacion();
}

// Uso:
await verificarYEjecutar('crear_consultas', selectedHospital, async () => {
  await addDoc(collection(db, 'consultas'), {
    idHospital: selectedHospital,
    // ... resto de datos
  });
});
```

---

## 📝 Queries Comunes por Rol

### Paciente (Ionic)

```typescript
// Mis consultas (todos los hospitales)
query(
  collection(db, 'consultas'),
  where('idPaciente', '==', currentUser.idPaciente),
  orderBy('fecha', 'desc')
)

// Mis recetas activas
query(
  collection(db, 'recetas'),
  where('idPaciente', '==', currentUser.idPaciente),
  orderBy('fecha', 'desc'),
  limit(10)
)

// Mis exámenes pendientes
query(
  collection(db, 'ordenes-examen'),
  where('idPaciente', '==', currentUser.idPaciente),
  where('estado', '==', 'pendiente')
)
```

### Médico (Flutter)

```typescript
// Pacientes de mis hospitales
query(
  collection(db, 'pacientes'),
  where('hospitalesAtendido', 'array-contains-any', currentUser.hospitalesAsignados)
)

// Consultas del día en hospital seleccionado
query(
  collection(db, 'consultas'),
  where('idHospital', '==', selectedHospital),
  where('fecha', '>=', startOfDay),
  where('fecha', '<=', endOfDay),
  orderBy('fecha', 'asc')
)

// Mis consultas de la semana
query(
  collection(db, 'consultas'),
  where('idProfesional', '==', currentUser.idProfesional),
  where('fecha', '>=', startOfWeek),
  orderBy('fecha', 'desc')
)
```

### Admin (Laravel)

```php
// Todas las consultas del hospital (últimos 30 días)
$consultasRef->where('idHospital', '=', $hospitalId)
    ->where('fecha', '>=', $thirtyDaysAgo)
    ->orderBy('fecha', 'DESC')
    ->documents();

// Médicos del hospital
$profesionalesRef->where('hospitalesAsignados', 'array-contains', $hospitalId)
    ->orderBy('nombre', 'ASC')
    ->documents();

// Exámenes pendientes del hospital
$ordenesRef->where('idHospital', '=', $hospitalId)
    ->where('estado', '=', 'pendiente')
    ->orderBy('fecha', 'ASC')
    ->documents();
```

---

## ⚠️ Errores Comunes

### 1. Olvidar agregar `idHospital`

❌ **MAL**:
```typescript
await addDoc(collection(db, 'consultas'), {
  idPaciente: patientId,
  idProfesional: currentUser.idProfesional,
  fecha: Timestamp.now()
  // ⚠️ Falta idHospital
});
```

✅ **BIEN**:
```typescript
await addDoc(collection(db, 'consultas'), {
  idHospital: selectedHospital,  // ✅ Incluir siempre
  idPaciente: patientId,
  idProfesional: currentUser.idProfesional,
  fecha: Timestamp.now()
});
```

### 2. No verificar permisos antes de actuar

❌ **MAL**:
```typescript
// Crear directamente sin verificar
await addDoc(collection(db, 'consultas'), consultaData);
```

✅ **BIEN**:
```typescript
// Verificar permiso primero
const permisoDoc = await getDoc(
  doc(db, 'permisos-usuario', `${user.uid}_${hospitalId}`)
);

if (permisoDoc.exists() && permisoDoc.data().permisos.includes('crear_consultas')) {
  await addDoc(collection(db, 'consultas'), consultaData);
} else {
  throw new Error('Sin permiso');
}
```

### 3. Query sin filtro de hospital (médicos/admins)

❌ **MAL**:
```typescript
// Ver TODAS las consultas (violación de seguridad)
const q = query(collection(db, 'consultas'), orderBy('fecha', 'desc'));
```

✅ **BIEN**:
```typescript
// Filtrar por hospital asignado
const q = query(
  collection(db, 'consultas'),
  where('idHospital', '==', selectedHospital),
  orderBy('fecha', 'desc')
);
```

### 4. No actualizar `hospitalesAtendido` del paciente

❌ **MAL**:
```typescript
// Crear consulta pero paciente no queda "registrado" en hospital
await addDoc(collection(db, 'consultas'), {
  idHospital: hospitalId,
  idPaciente: patientId,
  // ...
});
```

✅ **BIEN**:
```typescript
// Crear consulta Y actualizar paciente
await addDoc(collection(db, 'consultas'), consultaData);

await updateDoc(doc(db, 'pacientes', patientId), {
  hospitalesAtendido: arrayUnion(hospitalId)
});
```

---

## 🔑 Permisos Disponibles

### Para Médicos (Flutter)
- `ver_consultas`
- `crear_consultas`
- `editar_consultas`
- `ver_fichas_medicas`
- `editar_fichas_medicas`
- `crear_recetas`
- `solicitar_examenes`
- `ver_examenes`

### Para Admins (Laravel)
- `gestionar_usuarios`
- `gestionar_profesionales`
- `gestionar_pacientes`
- `ver_reportes`
- `configurar_hospital`
- `gestionar_examenes_catalogo`
- `gestionar_medicamentos_catalogo`

### Para Super Admins (Laravel)
- `gestionar_hospitales`
- `gestionar_todos_usuarios`
- `acceso_total`

---

## 📚 Documentos Relacionados

- [Modelo de Base de Datos Completo](./Modelo_BDD.md)
- [Sistema de Autenticación Detallado](./AUTENTICACION_SISTEMA.md)
- [Validaciones Flutter](./flutter/VALIDACIONES.md)

---

**Actualizado**: Enero 2025
