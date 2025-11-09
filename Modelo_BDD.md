# Modelo de Base de Datos - Sistema Médico Nexus

## 📋 Descripción General

Sistema de visualización de exámenes médicos para pacientes, incluyendo fichas médicas, medicamentos, exámenes (anteriores y pendientes), tratamientos, consultas y hospitalizaciones.

---

## 🗂️ Colecciones de Firestore

### 1. **pacientes** (Colección Raíz)
**Descripción**: Información personal y demográfica de los pacientes del sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
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

### 3. **profesionales** (Colección Raíz)
**Descripción**: Médicos y profesionales de la salud del sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `rut` | string | ✅ | RUT único del profesional |
| `nombre` | string | ✅ | Nombre del profesional |
| `apellido` | string | ✅ | Apellido del profesional |
| `especialidad` | string | ❌ | Especialidad médica |
| `telefono` | string | ❌ | Teléfono de contacto |
| `email` | string | ❌ | Correo electrónico |
| `licencia` | string | ❌ | Número de licencia médica |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `rut` (único)
- `especialidad` (filtrado)

---

### 4. **consultas** (Colección Raíz)
**Descripción**: Registro de consultas médicas realizadas a pacientes.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
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
- `idPaciente` + `fecha` (compuesto)
- `idProfesional` + `fecha` (compuesto)
- `fecha` (ordenamiento)

**Relaciones**:
- N:1 con pacientes
- N:1 con profesionales
- N:1 con fichas-medicas

---

### 5. **hospitalizaciones** (Colección Raíz)
**Descripción**: Registros de hospitalizaciones de pacientes.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
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
- `idPaciente` + `fechaIngreso` (compuesto)
- `fechaAlta` (filtrado - hospitalizaciones activas)

**Relaciones**:
- N:1 con pacientes
- N:1 con profesionales

---

### 6. **examenes** (Colección Raíz - CATÁLOGO)
**Descripción**: Catálogo de tipos de exámenes disponibles en el sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `nombre` | string | ✅ | Nombre del examen |
| `descripcion` | string | ❌ | Descripción detallada |
| `tipo` | string | ✅ | 'laboratorio', 'imagenologia', 'otro' |
| `codigo` | string | ❌ | Código interno/estándar |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `nombre` (búsqueda)
- `tipo` (filtrado)

**Nota**: Esta es una tabla CATÁLOGO, no registra exámenes de pacientes.

---

### 7. **ordenes-examen** (Colección Raíz)
**Descripción**: Órdenes de exámenes solicitadas a pacientes (examenes pendientes/realizados).

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
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
- `idPaciente` + `fecha` (compuesto)
- `estado` + `fecha` (compuesto)
- `idConsulta` (opcional)

**Relaciones**:
- N:1 con pacientes
- N:1 con profesionales
- N:1 con consultas (opcional)
- N:1 con hospitalizaciones (opcional)
- N:N con examenes (a través de ExamenSolicitado)

---

### 8. **medicamentos** (Colección Raíz - CATÁLOGO)
**Descripción**: Catálogo de medicamentos disponibles en el sistema.

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `nombre` | string | ✅ | Nombre comercial |
| `nombreGenerico` | string | ❌ | Nombre genérico |
| `presentacion` | string | ❌ | Tabletas, jarabe, etc. |
| `concentracion` | string | ❌ | Ej: 500mg, 10ml |
| `viaAdministracion` | string[] | ❌ | Oral, IV, IM, etc. |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `nombre` (búsqueda)
- `nombreGenerico` (búsqueda)

**Nota**: Esta es una tabla CATÁLOGO, no registra recetas de pacientes.

---

### 9. **recetas** (Colección Raíz)
**Descripción**: Prescripciones médicas (medicamentos recetados a pacientes).

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
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
- `idPaciente` + `fecha` (compuesto)
- `idProfesional` + `fecha` (compuesto)
- `fecha` (ordenamiento)

**Relaciones**:
- N:1 con pacientes
- N:1 con profesionales
- N:1 con consultas (opcional)
- N:N con medicamentos (a través de MedicamentoRecetado)

---

### 10. **diagnosticos** (Colección Raíz)
**Descripción**: Diagnósticos médicos registrados (vinculados a consultas u hospitalizaciones).

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | string | Auto | ID del documento |
| `idConsulta` | string | ❌ | Consulta asociada |
| `idHospitalizacion` | string | ❌ | Hospitalización asociada |
| `codigo` | string | ✅ | Código CIE-10 u otro |
| `descripcion` | string | ✅ | Descripción del diagnóstico |
| `tipo` | string | ❌ | 'principal' o 'secundario' |
| `createdAt` | Timestamp | Auto | Fecha de creación |
| `updatedAt` | Timestamp | Auto | Última actualización |

**Índices**:
- `idConsulta` (filtrado)
- `idHospitalizacion` (filtrado)
- `codigo` (búsqueda)

**Relaciones**:
- N:1 con consultas (opcional)
- N:1 con hospitalizaciones (opcional)

**Nota**: Un diagnóstico DEBE tener al menos idConsulta o idHospitalizacion.

---

## 🔗 Diagrama de Relaciones

```
┌─────────────────┐
│   PACIENTES     │◄─────┐
└────────┬────────┘      │
         │ 1:1           │
         ▼               │
┌─────────────────┐      │
│ FICHAS-MEDICAS  │      │
└─────────────────┘      │
                         │
┌─────────────────┐      │ N:1
│  PROFESIONALES  │      │
└────────┬────────┘      │
         │               │
         │               │
         ▼               │
┌─────────────────┐      │
│    CONSULTAS    │──────┤
└────────┬────────┘      │
         │               │
         ├───────────────┤
         │               │
         ▼               │
┌─────────────────┐      │
│ HOSPITALIZACIO- │──────┤
│      NES        │      │
└────────┬────────┘      │
         │               │
         ├───────────────┤
         │               │
         ▼               │
┌─────────────────┐      │
│ ORDENES-EXAMEN  │──────┘
└────────┬────────┘
         │
         │ N:N (referencia)
         ▼
┌─────────────────┐
│    EXAMENES     │ (CATÁLOGO)
│   (Catálogo)    │
└─────────────────┘

┌─────────────────┐
│    RECETAS      │──────┐
└────────┬────────┘      │
         │               │ N:1
         │ N:N           │
         ▼               │
┌─────────────────┐      │
│  MEDICAMENTOS   │      │
│   (Catálogo)    │      │
└─────────────────┘      │
                         │
                         ▼
                ┌─────────────────┐
                │   PACIENTES     │
                └─────────────────┘

┌─────────────────┐
│  DIAGNOSTICOS   │
└────────┬────────┘
         │
         ├──► CONSULTAS (opcional)
         │
         └──► HOSPITALIZACIONES (opcional)
```

---

## 📊 Reglas de Negocio

### Integridad Referencial

1. **Paciente → Ficha Médica**: 1:1 (un paciente tiene exactamente una ficha)
2. **Paciente → Consultas**: 1:N (un paciente puede tener muchas consultas)
3. **Profesional → Consultas**: 1:N (un profesional atiende muchas consultas)
4. **Consulta → Recetas**: 1:N (una consulta puede generar varias recetas)
5. **Consulta → Órdenes de Examen**: 1:N (una consulta puede ordenar varios exámenes)

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

## 📝 Notas Técnicas

- **Timestamps**: Usar `Timestamp` de Firebase para fechas
- **IDs**: Generados automáticamente por Firestore
- **Búsquedas**: Implementar Algolia o similar para búsqueda full-text
- **Archivos**: Usar Firebase Storage para documentos/imágenes
- **Seguridad**: Implementar Firestore Rules para proteger datos sensibles

---

**Versión**: 1.0  
**Fecha**: Noviembre 2025  