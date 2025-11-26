# Modelo de Base de Datos - Sistema Médico Nexus

## 📋 Descripción General

Sistema médico multi-tenant con autenticación unificada para pacientes (Ionic), administradores hospitalarios (Laravel) y médicos (Flutter). Todos los usuarios comparten la misma base de datos con permisos basados en roles y asignaciones hospitalarias.

---

## 🔐 Sistema de Autenticación y Autorización

### Roles del Sistema
- **Paciente**: Acceso a su propia información médica (app Ionic)
- **Médico**: Gestión de pacientes en hospitales asignados (app Flutter)
- **Administrador**: Gestión completa del hospital asignado (app Laravel)
- **Super Admin**: Acceso total al sistema (app Laravel)

### Aplicaciones
- **Ionic**: Para pacientes
- **Flutter**: Para médicos
- **Laravel**: Para administradores y super admins

---

## 🗂️ Colecciones de Firestore

### ✅ 1. **usuarios** (Colección Raíz - AUTENTICACIÓN) - IMPLEMENTADO
**Descripción**: Usuarios del sistema con autenticación unificada vía Firebase Authentication.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | UID de Firebase Auth (usado como document ID) |
| `email` | string | ✅ | Email único (login) |
| `displayName` | string | ✅ | Nombre completo del usuario |
| `rol` | string | ✅ | 'paciente', 'profesional', 'admin', 'super_admin' |
| `activo` | boolean | ✅ | Usuario activo/inactivo (default: true) |
| `photoURL` | string | ❌ | URL foto de perfil |
| `telefono` | string | ❌ | Teléfono de contacto |
| `idPaciente` | string | ❌ | ID si es paciente (relación 1:1) |
| `idProfesional` | string | ❌ | ID si es profesional médico (relación 1:1) |
| `ultimoAcceso` | Timestamp | Auto | Última vez que inició sesión |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Implementación**:
- ✅ Modelo Laravel: `app/Models/Usuario.php`
- ✅ Seeder: `database/seeders/FirebaseAuthSeeder.php`
- ✅ 6 usuarios de prueba creados (2 admin, 2 profesional, 2 paciente)
- ✅ Sincronización Firebase Auth ↔ Firestore
- ✅ UIDs de Firebase Auth usados como document IDs

**Índices**:
- `email` (único - gestionado por Firebase Auth)
- `rol` + `activo` (compuesto - para queries)
- `idPaciente` (único cuando no es null)
- `idProfesional` (único cuando no es null)

**Reglas de Validación Implementadas**:
- Si `rol === 'paciente'`: `idPaciente` es requerido
- Email debe ser único (validado en Firebase Auth)
- Un paciente solo puede tener un usuario asociado
- Las contraseñas se gestionan en Firebase Auth (no en Firestore)

**Usuarios de Prueba Creados**:
```
ADMIN:
- admin1@nexus.cl / Admin123!
- admin2@nexus.cl / Admin123!

PROFESIONAL:
- dr.gonzalez@nexus.cl / Prof123!
- dra.martinez@nexus.cl / Prof123!

PACIENTE:
- juan.perez@email.com / Pac123! (idPaciente: Fh2byylkEBfJCxd2vD1P)
- maria.lopez@email.com / Pac123! (idPaciente: SUso7Nyhb18whZ21Z2Ux)
```

---

### 🆕 2. **hospitales** (Colección Raíz)
**Descripción**: Hospitales y centros médicos del sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `nombre` | string | ✅ | Nombre del hospital |
| `direccion` | string | ✅ | Dirección física |
| `ciudad` | string | ✅ | Ciudad |
| `region` | string | ✅ | Región/Estado |
| `telefono` | string | ✅ | Teléfono principal |
| `email` | string | ✅ | Email de contacto |
| `codigoHospital` | string | ✅ | Código único interno |
| `tipo` | string | ✅ | 'publico', 'privado', 'clinica' |
| `servicios` | string[] | ❌ | Servicios disponibles |
| `activo` | boolean | ✅ | Hospital activo/inactivo |
| `configuracion` | ConfigHospital | ❌ | Configuraciones específicas |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Sub-objeto ConfigHospital**:
```typescript
{
  permitirAutoRegistroPacientes?: boolean,
  horarioAtencion?: {
    inicio: string,  // "08:00"
    fin: string      // "20:00"
  },
  logoURL?: string,
  colorPrimario?: string,
  colorSecundario?: string
}
```

**Índices**:
- `codigoHospital` (único)
- `activo` (filtrado)
- `ciudad` + `activo` (compuesto)

---

### ✅ 3. **permisos-usuario** (Colección Raíz) - IMPLEMENTADO
**Descripción**: Permisos granulares por usuario y hospital.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idUsuario` | string | ✅ | Referencia a usuarios (Firebase UID) |
| `idHospital` | string | ✅ | Hospital donde aplica el permiso |
| `permisos` | string[] | ✅ | Lista de permisos otorgados |
| `fechaInicio` | Timestamp | ✅ | Desde cuando es válido |
| `fechaFin` | Timestamp | ❌ | Hasta cuando es válido (null = permanente) |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Implementación**:
- ✅ Modelo Laravel: `app/Models/PermisoUsuario.php`
- ✅ Constantes de permisos definidas por rol
- ✅ Seeder automático (crea permisos junto con usuarios)
- ✅ Métodos de validación: `hasPermission()`, `hasAnyPermission()`

**Permisos Implementados**:
```php
// PERMISOS_ADMIN (Laravel - Administradores)
'gestionar_usuarios'
'gestionar_profesionales'
'gestionar_pacientes'
'gestionar_examenes_catalogo'
'gestionar_medicamentos_catalogo'
'configurar_hospital'
'ver_reportes'

// PERMISOS_PROFESIONAL (Ionic/Flutter - Médicos)
'ver_pacientes'
'crear_consultas'
'editar_consultas'
'ver_fichas_medicas'
'editar_fichas_medicas'
'crear_recetas'
'editar_recetas'
'solicitar_examenes'
'ver_examenes'
'hospitalizar_paciente'
'editar_hospitalizacion'

// PERMISOS_PACIENTE (Ionic - Pacientes)
'ver_mi_ficha'
'ver_mis_consultas'
'ver_mis_examenes'
'ver_mis_recetas'
'descargar_documentos'
'comprar_bonos'
```

**Índices**:
- `idUsuario` + `idHospital` (compuesto - query principal)
- `idHospital` (filtrado por hospital)

**Permisos Asignados en Seeder**:
- Todos los usuarios tienen permisos en hospital: `RSAlN3zsmWzeoY3z9GzN`

---

### 4. **pacientes** (Colección Raíz - ACTUALIZADA)
**Descripción**: Información personal y demográfica de los pacientes del sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idUsuario` | string | ❌ | Ref a usuarios (si tiene cuenta) |
| `rut` | string | ✅ | RUT único del paciente |
| `nombre` | string | ✅ | Nombre(s) del paciente |
| `apellido` | string | ✅ | Apellido(s) del paciente |
| `nombreCompleto` | string | Auto | Nombre completo para búsquedas |
| `fechaNacimiento` | Timestamp | ✅ | Fecha de nacimiento |
| `sexo` | string | ✅ | 'M', 'F' o 'Otro' |
| `direccion` | string | ❌ | Dirección de residencia |
| `telefono` | string | ❌ | Teléfono de contacto |
| `email` | string | ❌ | Correo electrónico |
| `grupoSanguineo` | string | ❌ | Ej: A+, O-, AB+ |
| `alergias` | string[] | ❌ | Lista de alergias |
| `enfermedadesCronicas` | string[] | ❌ | Enfermedades crónicas |
| `alertasMedicas` | AlertaMedica[] | ❌ | Alertas importantes |
| `hospitalesAtendido` | string[] | ❌ | IDs de hospitales donde ha sido atendido |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Sub-objeto AlertaMedica**:
```typescript
{
  tipo: 'alergia' | 'enfermedad_cronica' | 'medicamento_critico' | 'otro',
  descripcion: string,
  severidad: 'baja' | 'media' | 'alta' | 'critica',
  fechaRegistro: Timestamp
}
```

**Índices**:
- `rut` (único)
- `nombreCompleto` (búsqueda)
- `createdAt` (listado)

---

### 2. **fichas-medicas** (Colección Raíz)
**Descripción**: Ficha médica única por paciente con antecedentes médicos.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idPaciente` | string | ✅ | Referencia a pacientes |
| `fechaMedica` | Timestamp | ✅ | Fecha de creación de ficha |
| `observacion` | string | ❌ | Observaciones generales |
| `antecedentes` | Antecedentes | ❌ | Historial médico |
| `totalConsultas` | number | Auto | Contador de consultas |
| `ultimaConsulta` | Timestamp | Auto | Fecha última consulta |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Sub-objeto Antecedentes**:
```typescript
{
  familiares?: string,      // Antecedentes familiares
  personales?: string,      // Antecedentes personales
  quirurgicos?: string,     // Cirugías previas
  hospitalizaciones?: string, // Hospitalizaciones previas
  alergias?: string[]       // Alergias documentadas
}
```

**Índices**:
- `idPaciente` (único)
- `ultimaConsulta` (ordenamiento)

**Relación**: 1:1 con pacientes (un paciente, una ficha)

---

### 3. **profesionales** (Colección Raíz - ACTUALIZADA)
**Descripción**: Médicos y profesionales de la salud del sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idUsuario` | string | ❌ | Ref a usuarios (si tiene cuenta) |
| `rut` | string | ✅ | RUT único del profesional |
| `nombre` | string | ✅ | Nombre del profesional |
| `apellido` | string | ✅ | Apellido del profesional |
| `especialidad` | string | ❌ | Especialidad médica |
| `telefono` | string | ❌ | Teléfono de contacto |
| `email` | string | ❌ | Correo electrónico |
| `licencia` | string | ❌ | Número de licencia médica |
| `activo` | boolean | Auto | Estado del profesional |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `rut` (único)
- `especialidad` (filtrado)

**Nota**: Los hospitales asignados se encuentran en la colección `usuarios`, no en `profesionales`.

---

### 5. **consultas** (Colección Raíz - ACTUALIZADA)
**Descripción**: Registro de consultas médicas realizadas a pacientes.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idHospital` | string | ✅ | Hospital donde se realizó |
| `idPaciente` | string | ✅ | Referencia a pacientes |
| `idProfesional` | string | ✅ | Referencia a profesionales |
| `idFichaMedica` | string | ✅ | Referencia a fichas-medicas |
| `fecha` | Timestamp | ✅ | Fecha y hora de consulta |
| `motivo` | string | ✅ | Motivo de la consulta |
| `tratamiento` | string | ❌ | Tratamiento prescrito |
| `observaciones` | string | ❌ | Notas del médico |
| `notas` | NotaRapida[] | ❌ | Notas rápidas agregadas |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Sub-objeto NotaRapida**:
```typescript
{
  texto: string,
  autor: string,        // ID del profesional
  fecha: Timestamp
}
```

**Índices**:
- `idHospital` + `fecha` (compuesto)
- `idPaciente` + `fecha` (compuesto)
- `idProfesional` + `fecha` (compuesto)
- `fecha` (ordenamiento)

**Relaciones**:
- N:1 con hospitales
- N:1 con pacientes
- N:1 con profesionales
- N:1 con fichas-medicas

---

### 6. **hospitalizaciones** (Colección Raíz - ACTUALIZADA)
**Descripción**: Registros de hospitalizaciones de pacientes.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idHospital` | string | ✅ | Hospital donde ocurrió |
| `idPaciente` | string | ✅ | Referencia a pacientes |
| `idProfesional` | string | ✅ | Médico responsable |
| `fechaIngreso` | Timestamp | ✅ | Fecha de ingreso |
| `fechaAlta` | Timestamp | ❌ | Fecha de alta (null si activo) |
| `habitacion` | string | ❌ | Número de habitación |
| `motivoIngreso` | string | ✅ | Razón de hospitalización |
| `observaciones` | string | ❌ | Notas generales |
| `intervencion` | string[] | ❌ | Intervenciones realizadas |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `idHospital` + `fechaIngreso` (compuesto)
- `idPaciente` + `fechaIngreso` (compuesto)
- `fechaAlta` (filtrado - hospitalizaciones activas)

**Relaciones**:
- N:1 con hospitales
- N:1 con pacientes
- N:1 con profesionales

---

### 7. **examenes** (Colección Raíz - CATÁLOGO - ACTUALIZADA)
**Descripción**: Catálogo de tipos de exámenes disponibles en el sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idHospital` | string | ❌ | Hospital específico (null=global) |
| `nombre` | string | ✅ | Nombre del examen |
| `descripcion` | string | ❌ | Descripción detallada |
| `tipo` | string | ✅ | 'laboratorio', 'imagenologia', 'otro' |
| `codigo` | string | ❌ | Código interno/estándar |
| `activo` | boolean | Auto | Disponibilidad del examen |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `nombre` (búsqueda)
- `tipo` (filtrado)
- `idHospital` (filtrado - null para globales)

**Nota**: Esta es una tabla CATÁLOGO. `idHospital` null = examen disponible en todos los hospitales.

---

### 8. **ordenes-examen** (Colección Raíz - ACTUALIZADA)
**Descripción**: Órdenes de exámenes solicitadas a pacientes (examenes pendientes/realizados).

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idHospital` | string | ✅ | Hospital donde se solicitó |
| `idPaciente` | string | ✅ | Referencia a pacientes |
| `idProfesional` | string | ✅ | Médico que ordena |
| `idConsulta` | string | ❌ | Consulta asociada |
| `idHospitalizacion` | string | ❌ | Hospitalización asociada |
| `fecha` | Timestamp | ✅ | Fecha de orden |
| `estado` | string | ✅ | 'pendiente', 'realizado', 'cancelado' |
| `examenes` | ExamenSolicitado[] | ✅ | Lista de exámenes |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Sub-objeto ExamenSolicitado**:
```typescript
{
  idExamen: string,           // Referencia a examenes (catálogo)
  nombreExamen: string,       // Cache del nombre
  resultado?: string,         // Resultado textual
  fechaResultado?: Timestamp, // Cuándo se obtuvo resultado
  documentos?: DocumentoExamen[] // Archivos adjuntos
}
```

**Sub-objeto DocumentoExamen**:
```typescript
{
  url: string,          // URL en Firebase Storage
  nombre: string,       // Nombre del archivo
  tipo: string,         // MIME type (image/jpeg, application/pdf)
  tamanio: number,      // Bytes
  fechaSubida: Timestamp,
  subidoPor: string     // ID del profesional
}
```

**Índices**:
- `idHospital` + `fecha` (compuesto)
- `idPaciente` + `fecha` (compuesto)
- `estado` + `fecha` (compuesto)
- `idConsulta` (opcional)

**Relaciones**:
- N:1 con hospitales
- N:1 con pacientes
- N:1 con profesionales
- N:1 con consultas (opcional)
- N:1 con hospitalizaciones (opcional)
- N:N con examenes (a través de ExamenSolicitado)

---

### 9. **medicamentos** (Colección Raíz - CATÁLOGO - ACTUALIZADA)
**Descripción**: Catálogo de medicamentos disponibles en el sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idHospital` | string | ❌ | Hospital específico (null=global) |
| `nombre` | string | ✅ | Nombre comercial |
| `nombreGenerico` | string | ❌ | Nombre genérico |
| `presentacion` | string | ❌ | Tabletas, jarabe, etc. |
| `concentracion` | string | ❌ | Ej: 500mg, 10ml |
| `viaAdministracion` | string[] | ❌ | Oral, IV, IM, etc. |
| `activo` | boolean | Auto | Disponibilidad del medicamento |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `nombre` (búsqueda)
- `nombreGenerico` (búsqueda)
- `idHospital` (filtrado - null para globales)

**Nota**: Esta es una tabla CATÁLOGO. `idHospital` null = medicamento disponible en todos los hospitales.

---

### 10. **recetas** (Colección Raíz - ACTUALIZADA)
**Descripción**: Prescripciones médicas (medicamentos recetados a pacientes).

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idHospital` | string | ✅ | Hospital donde se prescribió |
| `idPaciente` | string | ✅ | Referencia a pacientes |
| `idProfesional` | string | ✅ | Médico que prescribe |
| `idConsulta` | string | ❌ | Consulta asociada |
| `fecha` | Timestamp | ✅ | Fecha de prescripción |
| `medicamentos` | MedicamentoRecetado[] | ✅ | Lista de medicamentos |
| `observaciones` | string | ❌ | Indicaciones generales |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Sub-objeto MedicamentoRecetado**:
```typescript
{
  idMedicamento: string,      // Referencia a medicamentos
  nombreMedicamento: string,  // Cache del nombre
  dosis: string,              // Ej: 500mg
  frecuencia: string,         // Ej: cada 8 horas
  duracion: string,           // Ej: 7 días
  indicaciones?: string       // Instrucciones específicas
}
```

**Índices**:
- `idHospital` + `fecha` (compuesto)
- `idPaciente` + `fecha` (compuesto)
- `idProfesional` + `fecha` (compuesto)
- `fecha` (ordenamiento)

**Relaciones**:
- N:1 con hospitales
- N:1 con pacientes
- N:1 con profesionales
- N:1 con consultas (opcional)
- N:N con medicamentos (a través de MedicamentoRecetado)

---

### 11. **diagnosticos** (Colección Raíz - ACTUALIZADA)
**Descripción**: Diagnósticos médicos registrados (vinculados a consultas u hospitalizaciones).

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idHospital` | string | ✅ | Hospital donde se diagnosticó |
| `idConsulta` | string | ❌ | Consulta asociada |
| `idHospitalizacion` | string | ❌ | Hospitalización asociada |
| `codigo` | string | ✅ | Código CIE-10 u otro |
| `descripcion` | string | ✅ | Descripción del diagnóstico |
| `tipo` | string | ❌ | 'principal' o 'secundario' |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `idHospital` (filtrado)
- `idConsulta` (filtrado)
- `idHospitalizacion` (filtrado)
- `codigo` (búsqueda)

**Relaciones**:
- N:1 con hospitales
- N:1 con consultas (opcional)
- N:1 con hospitalizaciones (opcional)

**Nota**: Un diagnóstico DEBE tener al menos idConsulta o idHospitalizacion.

---

## 🔗 Diagrama de Relaciones (Multi-Tenant)

```
                    ┌──────────────────┐
                    │   USUARIOS       │ ◄──── Firebase Auth
                    └────────┬─────────┘
                             │ 1:1
                    ┌────────┼─────────┐
                    │        │         │
                    ▼        ▼         ▼
          ┌──────────┐  ┌─────────┐  ┌──────────┐
          │PACIENTES │  │PROFESIO-│  │  ADMINS  │
          │          │  │  NALES  │  │          │
          └──────┬───┘  └────┬────┘  └──────────┘
                 │           │
                 │           │      ┌────────────────┐
                 │           └─────►│  HOSPITALES    │
                 │                  └────────┬───────┘
                 │                           │
                 │                           │ N:1
                 │           ┌───────────────┴───────────┐
                 │           │                           │
                 ▼           ▼                           ▼
    ┌────────────────┐  ┌──────────────┐    ┌─────────────────┐
    │ FICHAS-MEDICAS │  │  CONSULTAS   │◄───│HOSPITALIZACIONES│
    └────────────────┘  └──────┬───────┘    └─────────────────┘
                               │
                    ┌──────────┼──────────┐
                    │          │          │
                    ▼          ▼          ▼
         ┌──────────────┐  ┌────────┐  ┌──────────────┐
         │ORDENES-EXAMEN│  │RECETAS │  │ DIAGNOSTICOS │
         └──────┬───────┘  └───┬────┘  └──────────────┘
                │              │
                │ N:N          │ N:N
                ▼              ▼
         ┌──────────────┐  ┌────────────────┐
         │  EXAMENES    │  │ MEDICAMENTOS   │
         │  (Catálogo)  │  │  (Catálogo)    │
         └──────────────┘  └────────────────┘

LEYENDA:
━━━━ Relación directa
──── Relación multi-tenant (filtrada por hospital)
```

### Relaciones Clave

**Por Usuario**:
- `usuarios` ──1:1──> `pacientes` (si rol=paciente)
- `usuarios` ──1:1──> `profesionales` (si rol=medico)
- `usuarios` ──N:M──> `hospitales` (a través de permisos-usuario)

**Por Hospital** (Multi-Tenant):
- TODAS las colecciones transaccionales tienen campo `idHospital`
- Catálogos pueden ser globales (idHospital=null) o específicos

**Transaccionales**:
- `pacientes` ──1:1──> `fichas-medicas`
- `pacientes` ──1:N──> `consultas` (filtrado por hospital)
- `consultas` ──1:N──> `recetas`
- `consultas` ──1:N──> `ordenes-examen`
- `consultas` ──1:N──> `diagnosticos`

---

## 📊 Reglas de Negocio (Multi-Tenant)

### Integridad Referencial

1. **Usuario → Paciente/Profesional**: 1:1 (según rol)
2. **Paciente → Ficha Médica**: 1:1 (un paciente tiene exactamente una ficha)
3. **Paciente → Consultas**: 1:N (un paciente puede tener consultas en múltiples hospitales)
4. **Profesional → Hospitales**: N:M (un profesional puede trabajar en varios hospitales)
5. **Hospital → Todas las transacciones médicas**: 1:N (cada registro médico pertenece a un hospital)
6. **Consulta → Recetas/Exámenes**: 1:N (una consulta puede generar múltiples recetas/exámenes)

### Multi-Tenancy

**Aislamiento por Hospital**:
- Cada hospital funciona como un "tenant" separado
- Los médicos solo ven pacientes de hospitales asignados
- Los admins solo gestionan su hospital asignado
- Los pacientes ven todos sus registros sin importar el hospital

**Datos Compartidos**:
- Pacientes son globales (pueden atenderse en múltiples hospitales)
- Profesionales pueden trabajar en múltiples hospitales
- Catálogos pueden ser globales o específicos por hospital

### Colecciones Catálogo vs Transaccionales

**CATÁLOGOS** (datos maestros):
- `examenes`: Tipos de exámenes disponibles
- `medicamentos`: Medicamentos disponibles
- `profesionales`: Médicos del sistema

**TRANSACCIONALES** (datos operativos):
- `pacientes`: Registros de pacientes
- `consultas`: Atenciones médicas
- `ordenes-examen`: Exámenes solicitados/realizados
- `recetas`: Prescripciones médicas
- `hospitalizaciones`: Ingresos hospitalarios
- `diagnosticos`: Diagnósticos registrados
- `fichas-medicas`: Historiales médicos

### Validaciones Importantes

1. **Creación de Paciente**: Automáticamente crear su ficha médica
2. **Consulta**: Debe tener paciente, profesional Y ficha médica válidos
3. **Orden de Examen**: Debe tener al menos un examen en el array `examenes`
4. **Receta**: Debe tener al menos un medicamento en el array `medicamentos`
5. **Diagnóstico**: Debe tener `idConsulta` O `idHospitalizacion` (al menos uno)

---

## 🔍 Queries Comunes Optimizadas

### Por Paciente
```typescript
// Obtener ficha médica
WHERE idPaciente == 'paciente123'

// Obtener consultas
WHERE idPaciente == 'paciente123' ORDER BY fecha DESC

// Obtener exámenes pendientes
WHERE idPaciente == 'paciente123' AND estado == 'pendiente'

// Obtener recetas activas
WHERE idPaciente == 'paciente123' ORDER BY fecha DESC LIMIT 10
```

### Por Profesional
```typescript
// Consultas del día
WHERE idProfesional == 'prof123' 
  AND fecha >= today 
  ORDER BY fecha ASC

// Pacientes atendidos
WHERE idProfesional == 'prof123' 
  ORDER BY fecha DESC
```

### Dashboard/Reportes
```typescript
// Exámenes con resultados críticos (últimos 30 días)
WHERE estado == 'realizado' 
  AND fecha >= thirtyDaysAgo 
  ORDER BY fecha DESC

// Consultas por especialidad
WHERE idProfesional IN [profesionales de especialidad X]
  ORDER BY fecha DESC
```

---

## 💾 Estrategia de Datos

### Desnormalización Controlada

**Campos Duplicados Aceptables**:
- `nombreExamen` en `ordenes-examen.examenes[]` (cache del catálogo)
- `nombreMedicamento` en `recetas.medicamentos[]` (cache del catálogo)
- `nombreCompleto` en `pacientes` (optimización de búsqueda)

**Razón**: Evitar joins y mejorar performance de lectura.

### Contadores y Agregaciones

- `totalConsultas` en `fichas-medicas`: Se actualiza en cada consulta
- `ultimaConsulta` en `fichas-medicas`: Se actualiza en cada consulta

### Subcollecciones (No Usadas)

Este diseño usa **colecciones raíz** en lugar de subcollecciones para:
- Facilitar queries complejas
- Permitir consultas cross-paciente
- Simplificar reportes y dashboard

---

## � Firestore Security Rules

### Reglas de Seguridad por Rol

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Función auxiliar para obtener datos del usuario
    function getUserData() {
      return get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data;
    }
    
    // Función para verificar permisos en hospital específico
    function hasPermissionInHospital(hospitalId, permission) {
      let user = getUserData();
      let permiso = get(/databases/$(database)/documents/permisos-usuario/$(request.auth.uid + '_' + hospitalId));
      return permiso != null && permission in permiso.data.permisos;
    }
    
    // Función para verificar si es el mismo usuario paciente
    function isOwnPatientData(pacienteId) {
      let user = getUserData();
      return user.rol == 'paciente' && user.idPaciente == pacienteId;
    }
    
    // ===== COLECCIÓN: usuarios =====
    match /usuarios/{userId} {
      // Solo el propio usuario puede leer sus datos
      allow read: if request.auth.uid == userId;
      // Solo admins pueden crear/modificar usuarios
      allow write: if getUserData().rol in ['admin', 'super_admin'];
    }
    
    // ===== COLECCIÓN: hospitales =====
    match /hospitales/{hospitalId} {
      // Todos los usuarios autenticados pueden leer hospitales
      allow read: if request.auth != null;
      // Solo super_admin puede gestionar hospitales
      allow write: if getUserData().rol == 'super_admin';
    }
    
    // ===== COLECCIÓN: permisos-usuario =====
    match /permisos-usuario/{permisoId} {
      // Usuario puede leer sus propios permisos
      allow read: if request.auth.uid == resource.data.idUsuario;
      // Solo admins pueden gestionar permisos
      allow write: if getUserData().rol in ['admin', 'super_admin'];
    }
    
    // ===== COLECCIÓN: pacientes =====
    match /pacientes/{pacienteId} {
      // Pacientes: solo sus propios datos
      allow read: if isOwnPatientData(pacienteId);
      
      // Médicos: pacientes de hospitales asignados
      allow read: if getUserData().rol == 'medico' 
        && resource.data.hospitalesAtendido.hasAny(getUserData().hospitalesAsignados);
      
      // Admins: pacientes de su hospital
      allow read: if getUserData().rol == 'admin' 
        && resource.data.hospitalesAtendido.hasAny(getUserData().hospitalesAsignados);
      
      // Super Admin: todos los pacientes
      allow read: if getUserData().rol == 'super_admin';
      
      // Solo médicos y admins pueden crear/editar pacientes
      allow write: if getUserData().rol in ['medico', 'admin', 'super_admin'];
    }
    
    // ===== COLECCIÓN: profesionales =====
    match /profesionales/{profesionalId} {
      // Todos los usuarios autenticados pueden ver profesionales
      allow read: if request.auth != null;
      // Solo admins pueden gestionar profesionales
      allow write: if getUserData().rol in ['admin', 'super_admin'];
    }
    
    // ===== COLECCIÓN: consultas =====
    match /consultas/{consultaId} {
      // Pacientes: solo sus propias consultas
      allow read: if isOwnPatientData(resource.data.idPaciente);
      
      // Médicos: consultas de su hospital con permiso 'ver_consultas'
      allow read: if getUserData().rol == 'medico' 
        && hasPermissionInHospital(resource.data.idHospital, 'ver_consultas');
      
      // Crear consulta: solo médicos con permiso 'crear_consultas'
      allow create: if getUserData().rol == 'medico'
        && hasPermissionInHospital(request.resource.data.idHospital, 'crear_consultas');
      
      // Editar: solo el médico que la creó o con permiso 'editar_consultas'
      allow update: if getUserData().idProfesional == resource.data.idProfesional
        || hasPermissionInHospital(resource.data.idHospital, 'editar_consultas');
      
      // Admins: todas las consultas de su hospital
      allow read, write: if getUserData().rol in ['admin', 'super_admin'];
    }
    
    // ===== COLECCIÓN: fichas-medicas =====
    match /fichas-medicas/{fichaId} {
      // Reglas similares a consultas
      allow read: if isOwnPatientData(resource.data.idPaciente)
        || getUserData().rol in ['medico', 'admin', 'super_admin'];
      
      allow write: if getUserData().rol in ['medico', 'admin', 'super_admin'];
    }
    
    // ===== COLECCIÓN: hospitalizaciones =====
    match /hospitalizaciones/{hospitalizacionId} {
      // Pacientes: solo sus propias hospitalizaciones
      allow read: if isOwnPatientData(resource.data.idPaciente);
      
      // Médicos/Admins: hospitalizaciones de su hospital
      allow read: if getUserData().rol in ['medico', 'admin'] 
        && getUserData().hospitalesAsignados.hasAny([resource.data.idHospital]);
      
      allow write: if getUserData().rol in ['medico', 'admin', 'super_admin']
        && hasPermissionInHospital(request.resource.data.idHospital, 'crear_hospitalizaciones');
      
      allow read, write: if getUserData().rol == 'super_admin';
    }
    
    // ===== COLECCIÓN: ordenes-examen =====
    match /ordenes-examen/{ordenId} {
      // Pacientes: solo sus propias órdenes
      allow read: if isOwnPatientData(resource.data.idPaciente);
      
      // Médicos: órdenes de su hospital con permiso 'solicitar_examenes'
      allow read: if getUserData().rol == 'medico'
        && getUserData().hospitalesAsignados.hasAny([resource.data.idHospital]);
      
      allow create: if getUserData().rol == 'medico'
        && hasPermissionInHospital(request.resource.data.idHospital, 'solicitar_examenes');
      
      // Admins: todas las órdenes de su hospital
      allow read, write: if getUserData().rol in ['admin', 'super_admin'];
    }
    
    // ===== COLECCIÓN: recetas =====
    match /recetas/{recetaId} {
      // Pacientes: solo sus propias recetas
      allow read: if isOwnPatientData(resource.data.idPaciente);
      
      // Médicos: recetas de su hospital con permiso 'crear_recetas'
      allow read: if getUserData().rol == 'medico'
        && getUserData().hospitalesAsignados.hasAny([resource.data.idHospital]);
      
      allow create: if getUserData().rol == 'medico'
        && hasPermissionInHospital(request.resource.data.idHospital, 'crear_recetas');
      
      // Admins: todas las recetas de su hospital
      allow read, write: if getUserData().rol in ['admin', 'super_admin'];
    }
    
    // ===== COLECCIÓN: diagnosticos =====
    match /diagnosticos/{diagnosticoId} {
      // Similar a consultas - vinculado a hospital
      allow read: if getUserData().rol in ['medico', 'admin', 'super_admin']
        && getUserData().hospitalesAsignados.hasAny([resource.data.idHospital]);
      
      allow write: if getUserData().rol in ['medico', 'admin', 'super_admin']
        && hasPermissionInHospital(request.resource.data.idHospital, 'crear_consultas');
    }
    
    // ===== CATÁLOGOS: examenes y medicamentos =====
    match /examenes/{examenId} {
      // Todos pueden leer catálogos
      allow read: if request.auth != null;
      // Solo admins pueden modificar catálogos
      allow write: if getUserData().rol in ['admin', 'super_admin']
        && (resource.data.idHospital == null 
          || getUserData().hospitalesAsignados.hasAny([resource.data.idHospital]));
    }
    
    match /medicamentos/{medicamentoId} {
      allow read: if request.auth != null;
      allow write: if getUserData().rol in ['admin', 'super_admin']
        && (resource.data.idHospital == null 
          || getUserData().hospitalesAsignados.hasAny([resource.data.idHospital]));
    }
  }
}
```

---

## 🚀 Implementación por Aplicación

### 🔵 **Ionic (Pacientes)**

**Acceso**:
- ✅ Ver propias consultas (todos los hospitales donde fue atendido)
- ✅ Ver propias recetas
- ✅ Ver propios exámenes
- ✅ Ver propias hospitalizaciones
- ✅ Ver propia ficha médica
- ❌ NO puede editar nada
- ❌ NO puede ver datos de otros pacientes

**Queries Principales**:
```typescript
// Obtener consultas del paciente
const consultasRef = collection(db, 'consultas');
const q = query(
  consultasRef, 
  where('idPaciente', '==', currentUser.idPaciente),
  orderBy('fecha', 'desc')
);

// Obtener recetas activas
const recetasRef = collection(db, 'recetas');
const q2 = query(
  recetasRef,
  where('idPaciente', '==', currentUser.idPaciente),
  orderBy('fecha', 'desc'),
  limit(10)
);
```

**Autenticación**:
- Firebase Authentication con email/password
- Custom claims: `{ rol: 'paciente', idPaciente: 'xxx' }`

---

### 📱 **Flutter (Médicos)**

**Acceso**:
- ✅ Ver pacientes de hospitales asignados
- ✅ Crear/editar consultas en hospitales asignados
- ✅ Crear recetas
- ✅ Solicitar exámenes
- ✅ Ver resultados de exámenes
- ✅ Registrar hospitalizaciones
- ❌ NO puede gestionar usuarios
- ❌ NO puede modificar catálogos
- ❌ NO puede ver datos de hospitales no asignados

**Queries Principales**:
```typescript
// Obtener pacientes del hospital asignado
const pacientesRef = collection(db, 'pacientes');
const q = query(
  pacientesRef,
  where('hospitalesAtendido', 'array-contains-any', currentUser.hospitalesAsignados)
);

// Crear consulta en hospital asignado
await addDoc(collection(db, 'consultas'), {
  idHospital: selectedHospital,
  idPaciente: patientId,
  idProfesional: currentUser.idProfesional,
  fecha: Timestamp.now(),
  motivo: consultData.motivo,
  // ... resto de campos
});

// Verificar permisos antes de crear
const permisoDoc = await getDoc(
  doc(db, 'permisos-usuario', `${currentUser.uid}_${selectedHospital}`)
);
if (permisoDoc.exists() && permisoDoc.data().permisos.includes('crear_consultas')) {
  // Permitir crear consulta
}
```

**Autenticación**:
- Firebase Authentication con email/password
- Custom claims: `{ rol: 'medico', idProfesional: 'xxx', hospitalesAsignados: ['h1', 'h2'] }`

---

### 💻 **Laravel (Administradores)**

**Acceso Admin**:
- ✅ Gestionar usuarios del hospital asignado
- ✅ Gestionar profesionales del hospital
- ✅ Ver todas las consultas del hospital
- ✅ Gestionar catálogos (examenes/medicamentos) del hospital
- ✅ Ver reportes y estadísticas del hospital
- ✅ Configurar permisos de usuarios
- ❌ NO puede gestionar otros hospitales
- ❌ NO puede crear hospitales

**Acceso Super Admin**:
- ✅ TODO lo de Admin en TODOS los hospitales
- ✅ Crear y gestionar hospitales
- ✅ Asignar administradores a hospitales
- ✅ Ver reportes globales del sistema

**Backend Laravel** (servidor a servidor):
```php
// En FirebaseService.php
public function getConsultasByHospital($hospitalId, $startDate, $endDate)
{
    $consultasRef = $this->firestore->collection('consultas');
    $query = $consultasRef
        ->where('idHospital', '=', $hospitalId)
        ->where('fecha', '>=', $startDate)
        ->where('fecha', '<=', $endDate)
        ->orderBy('fecha', 'DESC');
    
    return $query->documents();
}

// Verificar permisos del usuario admin
public function hasPermission($userId, $hospitalId, $permission)
{
    $permisoDoc = $this->firestore
        ->collection('permisos-usuario')
        ->document($userId . '_' . $hospitalId)
        ->snapshot();
    
    if (!$permisoDoc->exists()) {
        return false;
    }
    
    return in_array($permission, $permisoDoc->data()['permisos'] ?? []);
}
```

**Autenticación**:
- Laravel Fortify para login web
- Sincronizar con Firebase Authentication
- Sesión Laravel + Token Firebase para APIs

---

## 📋 Plan de Migración

### ✅ Fase 1: Preparación (Completada - Nov 2025)
1. ✅ Actualizar `Modelo_BDD.md` con campos multi-tenant
2. ✅ Crear colecciones `usuarios`, `permisos-usuario` en Firestore
3. ✅ Configurar Firebase Authentication en proyecto Laravel
4. ✅ Crear 6 usuarios de prueba en Firebase Auth + Firestore

### ✅ Fase 2: Backend Laravel (Completada - Nov 2025)
1. ✅ Crear modelos Laravel para `Usuario` y `PermisoUsuario`
2. ✅ Implementar sincronización Laravel Auth ↔ Firebase Auth
   - FirebaseGuard personalizado (implements StatefulGuard)
   - FirestoreUserProvider para carga de usuarios
   - LoginController con validación de roles
3. ✅ Implementar sistema de permisos granulares
   - Constantes de permisos por rol
   - Middleware CheckRole para protección de rutas
4. ✅ Crear seeder automatizado (FirebaseAuthSeeder)
5. ✅ Configurar rutas protegidas con autenticación + roles
6. ✅ Página de login funcional (Auth/Login.vue)

### ⏳ Fase 3: Ionic App - Profesionales (Pendiente)
1. ⬜ Implementar login con Firebase Auth
2. ⬜ Integrar con colección `usuarios` (rol='profesional')
3. ⬜ Verificar permisos desde `permisos-usuario`
4. ⬜ Modificar queries para filtrar por hospital asignado
5. ⬜ Agregar campo `idHospital` a todas las operaciones de escritura

### ⏳ Fase 4: Flutter App - Pacientes (Pendiente)
1. ⬜ Implementar login con Firebase Auth
2. ⬜ Integrar con colección `usuarios` (rol='paciente')
3. ⬜ Modo solo lectura (sin ediciones - solo permisos de visualización)
4. ⬜ Mostrar historial médico de todos los hospitales
5. ⬜ Funcionalidad de compra de bonos

### ⏳ Fase 5: Colección Hospitales (Pendiente)
1. ⬜ Crear modelo `Hospital` en Laravel
2. ⬜ Crear seeder con hospital por defecto (RSAlN3zsmWzeoY3z9GzN)
3. ⬜ Agregar campo `idHospital` a colecciones transaccionales existentes
4. ⬜ Script para actualizar pacientes con `hospitalesAtendido`
5. ⬜ Interfaz de gestión de hospitales (solo super_admin)

### ⏳ Fase 6: Testing y Deployment (Pendiente)
1. ⬜ Pruebas de autenticación en las 3 plataformas
2. ⬜ Pruebas de permisos (verificar roles y restricciones)
3. ⬜ Validar sincronización Firebase Auth ↔ Firestore
4. ⬜ Deploy de Security Rules en producción
5. ⬜ Documentación de usuario final

---

## 🔑 Custom Claims en Firebase Auth

### Estructura de Custom Claims

```typescript
// Para Pacientes
{
  rol: 'paciente',
  idPaciente: 'pac_12345',
  hospitalesAtendido: ['hosp_1', 'hosp_2']
}

// Para Médicos
{
  rol: 'medico',
  idProfesional: 'prof_67890',
  hospitalesAsignados: ['hosp_1'],
  especialidad: 'Cardiología'
}

// Para Administradores
{
  rol: 'admin',
  hospitalesAsignados: ['hosp_1']
}

// Para Super Admin
{
  rol: 'super_admin',
  hospitalesAsignados: []  // Vacío = acceso a todos
}
```

### Configuración de Custom Claims (Cloud Functions)

```typescript
// functions/src/index.ts
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const setUserClaims = functions.https.onCall(async (data, context) => {
  // Verificar que quien llama es admin
  if (!context.auth || context.auth.token.rol !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can set user claims'
    );
  }
  
  const { uid, rol, idPaciente, idProfesional, hospitalesAsignados } = data;
  
  const customClaims: any = { rol };
  
  if (idPaciente) customClaims.idPaciente = idPaciente;
  if (idProfesional) customClaims.idProfesional = idProfesional;
  if (hospitalesAsignados) customClaims.hospitalesAsignados = hospitalesAsignados;
  
  await admin.auth().setCustomUserClaims(uid, customClaims);
  
  return { success: true };
});
```

---

## �📝 Notas Técnicas

- **Timestamps**: Usar `Timestamp` de Firebase para fechas
- **IDs**: Generados automáticamente por Firestore
- **Búsquedas**: Implementar Algolia o similar para búsqueda full-text
- **Archivos**: Usar Firebase Storage con rutas por hospital: `{hospitalId}/examenes/{pacienteId}/{...}`
- **Seguridad**: Firestore Rules + Custom Claims para protección multi-capa
- **Performance**: Indices compuestos por hospital + fecha en todas las colecciones transaccionales
- **Backup**: Configurar exportaciones automáticas de Firestore por hospital

---

## 🎯 Estado Actual de Implementación

### ✅ Completado (Laravel - Admin)
- **Autenticación Firebase**: Sistema completo con FirebaseGuard + FirestoreUserProvider
- **Colecciones Firestore**:
  - `usuarios`: 6 usuarios de prueba (2 admin, 2 profesional, 2 paciente)
  - `permisos-usuario`: Permisos asignados por rol y hospital
- **Modelos Laravel**:
  - `Usuario`: CRUD completo con validaciones
  - `PermisoUsuario`: Sistema de permisos granulares
- **Autenticación Web**:
  - LoginController con validación de roles
  - Middleware CheckRole para protección de rutas
  - Página Login.vue funcional en español
- **Seeders**: FirebaseAuthSeeder automatizado
- **Seguridad**: Solo admins pueden acceder a Laravel web

### ⏳ Pendiente (Multi-plataforma)
- Implementación Ionic (profesionales)
- Implementación Flutter (pacientes)
- Colección `hospitales` y modelo Hospital
- Integración multi-tenant completa en todas las colecciones
- Firestore Security Rules en producción
- Custom Claims en Firebase Auth

### 📌 Hospital por Defecto
- **ID**: `RSAlN3zsmWzeoY3z9GzN`
- **Uso**: Todos los permisos actuales están asignados a este hospital
- **Migración**: Cuando se cree la colección `hospitales`, este será el primer registro

---

**Versión**: 2.1 - Multi-Tenant (Laravel Implementado)  
**Fecha**: Noviembre 25, 2025  
**Última Actualización**: Sistema de autenticación Laravel completado  