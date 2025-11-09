# 🗄️ Scripts de Base de Datos - Sistema Nexus

## 📝 Descripción

Scripts para administrar la base de datos Firestore del sistema médico Nexus.

## 📋 Pre-requisitos

1. **Archivo de credenciales**: Necesitas el archivo `serviceAccountKey.json` en la raíz del proyecto
2. **Node.js**: Versión 16 o superior
3. **Dependencias instaladas**: Ejecuta `npm install` si no lo has hecho

## 🚀 Scripts Disponibles

### 1. Limpiar Base de Datos

**⚠️ ADVERTENCIA**: Este script ELIMINA TODOS los datos de Firestore.

```bash
node scripts/clean-firestore.js
```

**Qué hace:**
- Elimina todos los documentos de todas las colecciones
- Procesa en lotes de 100 documentos
- Muestra progreso en tiempo real
- Espera 3 segundos antes de comenzar (tiempo para cancelar si fue un error)

**Colecciones que limpia:**
- pacientes
- fichas-medicas
- profesionales
- consultas
- hospitalizaciones
- examenes
- ordenes-examen
- medicamentos
- recetas
- diagnosticos

### 2. Poblar Base de Datos

```bash
node scripts/seed-firestore.js
```

**Qué crea:**

#### Catálogos (Datos Maestros)
- ✅ **5 Profesionales** con diferentes especialidades
- ✅ **10 Tipos de Exámenes** (laboratorio, imagenología, etc.)
- ✅ **10 Medicamentos** comunes

#### Datos Operativos
- ✅ **5 Pacientes** con información completa
- ✅ **5 Fichas Médicas** (1 por paciente)
- ✅ **10-20 Consultas** (2-4 por paciente)
- ✅ **7-14 Órdenes de Exámenes** (70% de las consultas)
- ✅ **6-12 Recetas** (60% de las consultas)

**Características:**
- Datos coherentes y relacionados correctamente
- Fechas realistas (últimos 6 meses)
- Referencias válidas entre colecciones
- Pacientes con y sin condiciones crónicas
- Exámenes pendientes y realizados
- Medicamentos con dosis y frecuencias reales

## 📖 Flujo Recomendado

### Primer Uso

```bash
# 1. Instalar dependencias
npm install

# 2. Poblar base de datos
node scripts/seed-firestore.js
```

### Resetear Base de Datos

```bash
# 1. Limpiar datos existentes
node scripts/clean-firestore.js

# 2. Poblar con datos frescos
node scripts/seed-firestore.js
```

## 🔍 Verificación

Después de ejecutar los scripts, verifica en Firebase Console:

1. **Firestore Database**: Deberías ver 10 colecciones con datos
2. **Pacientes**: 5 documentos con información completa
3. **Consultas**: Múltiples consultas vinculadas a pacientes y profesionales
4. **Órdenes-Examen**: Algunas pendientes, algunas realizadas

## 📊 Datos de Ejemplo Creados

### Profesionales
- María González (Medicina General)
- Carlos Rodríguez (Cardiología)
- Ana Martínez (Pediatría)
- Roberto Silva (Traumatología)
- Patricia Fernández (Ginecología)

### Pacientes
- Juan Pérez (con hipertensión)
- María Torres (con diabetes e hipotiroidismo)
- Pedro Ramírez (sin condiciones crónicas)
- Carmen Muñoz (con artritis e hipertensión)
- Daniela Soto (sin condiciones crónicas)

### Exámenes Disponibles
- Hemograma Completo
- Glicemia
- Perfil Lipídico
- Creatinina
- TSH
- Examen de Orina
- Electrocardiograma
- Radiografía de Tórax
- Ecografía Abdominal
- Mamografía

### Medicamentos Disponibles
- Paracetamol 500mg
- Ibuprofeno 400mg
- Amoxicilina 500mg
- Losartán 50mg
- Metformina 850mg
- Y 5 más...

## 🛡️ Seguridad

- Los scripts requieren credenciales de administrador
- Solo ejecutar en entorno de desarrollo/testing
- **NUNCA** ejecutar `clean-firestore.js` en producción
- Mantener `serviceAccountKey.json` fuera del control de versiones (ya está en `.gitignore`)

## 🐛 Resolución de Problemas

### Error: "Cannot find module 'firebase-admin'"

```bash
npm install firebase-admin
```

### Error: "serviceAccountKey.json not found"

1. Ve a Firebase Console
2. Project Settings > Service Accounts
3. Generate New Private Key
4. Guarda el archivo como `serviceAccountKey.json` en la raíz del proyecto

### Los scripts se quedan "colgados"

- Verifica tu conexión a internet
- Confirma que las credenciales son válidas
- Revisa que el proyecto de Firebase esté activo

## 📚 Documentación Relacionada

- [Modelo_BDD.md](../Modelo_BDD.md) - Diseño completo de la base de datos

## 🔄 Próximas Mejoras

- [ ] Script para agregar pacientes individuales
- [ ] Script para backup de datos
- [ ] Script para migración entre versiones
- [ ] Generación de datos aleatorios más extensos
- [ ] Exportación a CSV/JSON

---

**Versión**: 1.0  
**Última actualización**: Noviembre 2025
