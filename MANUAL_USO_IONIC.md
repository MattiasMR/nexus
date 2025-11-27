# 📱 Manual de Uso - Aplicación Nexus (Ionic)

## 📋 Índice

1. [Descripción General](#descripción-general)
2. [Requisitos del Sistema](#requisitos-del-sistema)
3. [Instalación y Configuración](#instalación-y-configuración)
4. [Tecnologías Utilizadas](#tecnologías-utilizadas)
5. [Estructura del Proyecto](#estructura-del-proyecto)
6. [Inicio de Sesión](#inicio-de-sesión)
7. [Navegación Principal](#navegación-principal)
8. [Gestión de Pacientes](#gestión-de-pacientes)
9. [Consultas Médicas](#consultas-médicas)
10. [Órdenes de Exámenes](#órdenes-de-exámenes)
11. [Notas Médicas](#notas-médicas)
12. [Búsqueda y Filtros](#búsqueda-y-filtros)

---

## 📖 Descripción General

**Nexus** es una aplicación médica desarrollada en **Ionic 7 + Angular 18 Standalone** para la gestión integral de pacientes, consultas médicas, exámenes y notas clínicas. Utiliza **Firebase Firestore** como base de datos en tiempo real y **Firebase Authentication** para la gestión de usuarios.

### Características Principales
✅ Gestión completa de pacientes con fichas médicas digitales  
✅ Registro de consultas médicas con historial temporal  
✅ Sistema de órdenes y resultados de exámenes  
✅ Notas médicas asociadas a consultas o generales  
✅ OCR para extracción automática de datos de exámenes  
✅ Búsqueda y filtrado avanzado de pacientes  
✅ Arquitectura normalizada en Firestore  
✅ Componentes standalone de Angular 18  

### Usuarios de la Aplicación
- **Médicos/Profesionales**: Gestionan pacientes, crean consultas, ordenan exámenes y registran notas
- **Administradores**: Gestión completa del sistema
- **Pacientes**: Acceden a su información médica (funcionalidad futura)

---

## 💻 Requisitos del Sistema

### Software Requerido

| Software | Versión Mínima | Versión Recomendada | Propósito |
|----------|----------------|---------------------|-----------|
| **Node.js** | 18.x | 20.x o superior | Runtime de JavaScript |
| **npm** | 9.x | 10.x o superior | Gestor de paquetes |
| **Ionic CLI** | 7.x | 7.2.0 o superior | Herramienta de desarrollo Ionic |
| **Angular CLI** | 18.x | 18.x | Framework Angular |
| **Git** | 2.x | Última | Control de versiones |

### Navegadores Compatibles
- ✅ Google Chrome (recomendado para desarrollo)
- ✅ Firefox
- ✅ Safari
- ✅ Microsoft Edge

### Sistema Operativo
- ✅ Windows 10/11
- ✅ macOS 10.15+
- ✅ Linux (Ubuntu 20.04+)

---

## 🚀 Instalación y Configuración

### Paso 1: Instalar Node.js y npm

**Windows/macOS:**
1. Descargar desde [nodejs.org](https://nodejs.org/)
2. Ejecutar el instalador
3. Verificar instalación:
```bash
node --version
npm --version
```

**Linux (Ubuntu/Debian):**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Paso 2: Instalar Ionic CLI Global

```bash
npm install -g @ionic/cli
```

Verificar instalación:
```bash
ionic --version
```

### Paso 3: Clonar el Repositorio

```bash
git clone https://github.com/MattiasMR/nexus.git
cd nexus/ionic
```

### Paso 4: Instalar Dependencias del Proyecto

```bash
npm install
```

**Tiempo estimado**: 2-5 minutos dependiendo de la conexión

### Paso 5: Configurar Firebase

#### 5.1 Crear archivo de configuración

Crear el archivo `src/environments/environment.ts`:

```typescript
export const environment = {
  production: false,
  firebase: {
    apiKey: "TU_API_KEY",
    authDomain: "nexus-68994.firebaseapp.com",
    projectId: "nexus-68994",
    storageBucket: "nexus-68994.appspot.com",
    messagingSenderId: "TU_MESSAGING_SENDER_ID",
    appId: "TU_APP_ID"
  }
};
```

#### 5.2 Obtener credenciales de Firebase

1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Seleccionar el proyecto `nexus-68994`
3. Ir a **Configuración del proyecto** ⚙️
4. En la pestaña **General**, buscar **Tus aplicaciones**
5. Copiar la configuración de Firebase
6. Pegar en el archivo `environment.ts`

### Paso 6: Ejecutar la Aplicación

```bash
ionic serve
```

La aplicación se abrirá automáticamente en `http://localhost:8100`

---

## 🛠️ Tecnologías Utilizadas

### Frontend Framework

| Tecnología | Versión | Descripción |
|------------|---------|-------------|
| **Ionic Framework** | 7.6.2 | Framework híbrido para apps móviles |
| **Angular** | 18.2.11 | Framework web de Google |
| **TypeScript** | 5.5.4 | Superset tipado de JavaScript |
| **RxJS** | 7.8.1 | Programación reactiva |

### Backend y Base de Datos

| Servicio | Propósito |
|----------|-----------|
| **Firebase Authentication** | Autenticación de usuarios |
| **Firebase Firestore** | Base de datos NoSQL en tiempo real |
| **Firebase Storage** | Almacenamiento de archivos (imágenes, PDFs) |

### Librerías Principales

```json
{
  "@angular/fire": "^18.0.1",           // Integración Firebase-Angular
  "@capacitor/core": "^6.1.2",          // Acceso a APIs nativas
  "@capacitor/camera": "^6.0.2",        // Captura de imágenes
  "@ionic/angular": "^8.3.2",           // Componentes UI Ionic
  "tesseract.js": "^5.1.1",             // OCR para lectura de texto
  "date-fns": "^4.1.0"                  // Manejo de fechas
}
```

### Dependencias Completas (package.json)

#### Dependencies
```json
{
  "@angular/animations": "^18.2.0",
  "@angular/cdk": "^18.2.13",
  "@angular/common": "^18.2.0",
  "@angular/compiler": "^18.2.0",
  "@angular/core": "^18.2.0",
  "@angular/fire": "^18.0.1",
  "@angular/forms": "^18.2.0",
  "@angular/platform-browser": "^18.2.0",
  "@angular/platform-browser-dynamic": "^18.2.0",
  "@angular/router": "^18.2.0",
  "@capacitor/android": "^6.1.2",
  "@capacitor/app": "^6.0.1",
  "@capacitor/camera": "^6.0.2",
  "@capacitor/core": "^6.1.2",
  "@capacitor/haptics": "^6.0.1",
  "@capacitor/ios": "^6.1.2",
  "@capacitor/keyboard": "^6.0.2",
  "@capacitor/status-bar": "^6.0.1",
  "@ionic/angular": "^8.3.2",
  "date-fns": "^4.1.0",
  "firebase": "^10.14.1",
  "ionicons": "^7.4.0",
  "rxjs": "~7.8.0",
  "tesseract.js": "^5.1.1",
  "tslib": "^2.3.0",
  "zone.js": "~0.14.2"
}
```

#### DevDependencies
```json
{
  "@angular-devkit/build-angular": "^18.2.11",
  "@angular-eslint/builder": "^18.0.1",
  "@angular-eslint/eslint-plugin": "^18.0.1",
  "@angular-eslint/eslint-plugin-template": "^18.0.1",
  "@angular-eslint/schematics": "^18.0.1",
  "@angular-eslint/template-parser": "^18.0.1",
  "@angular/cli": "^18.2.11",
  "@angular/compiler-cli": "^18.2.0",
  "@angular/language-service": "^18.2.0",
  "@capacitor/cli": "^6.1.2",
  "@ionic/angular-toolkit": "^12.1.1",
  "@types/jasmine": "~5.1.0",
  "@typescript-eslint/eslint-plugin": "^6.0.0",
  "@typescript-eslint/parser": "^6.0.0",
  "eslint": "^8.57.0",
  "eslint-plugin-import": "^2.29.1",
  "eslint-plugin-jsdoc": "^48.2.1",
  "eslint-plugin-prefer-arrow": "1.2.3",
  "jasmine-core": "~5.1.0",
  "jasmine-spec-reporter": "~5.0.0",
  "karma": "~6.4.0",
  "karma-chrome-launcher": "~3.2.0",
  "karma-coverage": "~2.2.0",
  "karma-jasmine": "~5.1.0",
  "karma-jasmine-html-reporter": "~2.1.0",
  "typescript": "~5.5.2"
}
```

### Arquitectura del Proyecto

```
ionic/
├── src/
│   ├── app/
│   │   ├── features/              # Módulos funcionales
│   │   │   ├── pacientes/         # Gestión de pacientes
│   │   │   ├── consultas/         # Consultas médicas
│   │   │   ├── examenes/          # Órdenes de exámenes
│   │   │   └── fichas-medicas/    # Fichas médicas
│   │   ├── models/                # Interfaces TypeScript
│   │   ├── services/              # Servicios globales
│   │   ├── shared/                # Componentes compartidos
│   │   └── guards/                # Guards de autenticación
│   ├── environments/              # Configuración por entorno
│   ├── assets/                    # Recursos estáticos
│   └── theme/                     # Estilos globales
├── capacitor.config.ts            # Configuración Capacitor
├── ionic.config.json              # Configuración Ionic
├── angular.json                   # Configuración Angular
├── package.json                   # Dependencias
└── tsconfig.json                  # Configuración TypeScript
```

---

## 🗄️ Estructura de la Base de Datos (Firestore)

### Colecciones Principales

#### 1. **usuarios** (Authentication + Firestore)
```typescript
{
  id: string,                    // UID de Firebase Auth
  email: string,                 // Email del usuario
  displayName: string,           // Nombre completo
  rol: 'paciente' | 'profesional' | 'admin',
  activo: boolean,
  idPaciente?: string,           // Si es paciente
  idProfesional?: string,        // Si es profesional
  telefono?: string,
  photoURL?: string
}
```

#### 2. **pacientes**
```typescript
{
  id: string,
  idUsuario: string,             // Relación con usuarios
  fechaNacimiento: Timestamp,
  sexo: 'M' | 'F' | 'Otro',
  grupoSanguineo?: string,
  alergias?: string[],
  enfermedadesCronicas?: string[],
  medicamentosActuales?: string[],
  contactoEmergencia?: string,
  prevision?: string,
  numeroFicha?: string,
  observaciones?: string,
  alertasMedicas?: AlertaMedica[]
}
```

#### 3. **consultas**
```typescript
{
  id: string,
  idPaciente: string,
  idProfesional: string,
  idFichaMedica: string,
  fecha: Timestamp,
  motivo: string,
  diagnostico?: string,
  tratamiento?: string,
  observaciones?: string,
  notas?: NotaRapida[],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### 4. **notas**
```typescript
{
  id: string,
  idPaciente: string,
  idProfesional: string,
  contenido: string,
  tipoAsociacion?: 'consulta' | 'orden' | null,
  idAsociado?: string,
  nombreAsociado?: string,
  fecha: Timestamp,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

#### 5. **ordenes-examenes**
```typescript
{
  id: string,
  idPaciente: string,
  idProfesional: string,
  fecha: Timestamp,
  estado: 'pendiente' | 'realizado',
  examenes: [{
    tipoExamen: string,
    nombreExamen: string,
    resultado?: string,
    archivoUrl?: string
  }],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Índices de Firestore Necesarios

```
consultas:
- idPaciente (Ascending) + fecha (Descending)

notas:
- idPaciente (Ascending) + fecha (Descending)

ordenes-examenes:
- idPaciente (Ascending) + fecha (Descending)
- idPaciente (Ascending) + estado (Ascending) + fecha (Descending)
```

---

## 🔧 Comandos Útiles para Desarrollo

### Desarrollo

```bash
# Iniciar servidor de desarrollo
ionic serve

# Iniciar con live reload en dispositivo
ionic serve --lab

# Generar componente standalone
ionic generate component features/nombre --standalone

# Generar servicio
ionic generate service features/nombre/data/nombre
```

### Build y Deploy

```bash
# Build de producción
ionic build --prod

# Build para Android
ionic capacitor build android

# Build para iOS
ionic capacitor build ios

# Sincronizar cambios con Capacitor
ionic capacitor sync
```

### Testing

```bash
# Ejecutar tests unitarios
npm run test

# Ejecutar tests con cobertura
npm run test:coverage

# Ejecutar linter
npm run lint
```

---

## 🔐 Descripción General

---

## 🔐 Inicio de Sesión

### Acceso a la Aplicación

1. **Abrir la aplicación** en tu navegador o dispositivo móvil
2. **Ingresar credenciales**:
   - Email: tu correo registrado
   - Contraseña: tu contraseña
3. **Presionar "Iniciar Sesión"**

### Usuarios de Prueba

```
PROFESIONALES:
- dr.gonzalez@nexus.cl / Prof123!
- dra.martinez@nexus.cl / Prof123!

ADMINISTRADORES:
- admin1@nexus.cl / Admin123!
- admin2@nexus.cl / Admin123!
```

### Recuperar Contraseña
- Haz clic en "¿Olvidaste tu contraseña?"
- Ingresa tu correo electrónico
- Recibirás un email con instrucciones

---

## 🧭 Navegación Principal

La aplicación tiene 4 pestañas principales en la parte inferior:

### 1️⃣ Tab 1: Pacientes
- **Ícono**: 👥 Personas
- **Función**: Listado de todos los pacientes
- **Acciones**:
  - Ver lista completa de pacientes
  - Buscar pacientes
  - Crear nuevo paciente
  - Acceder a ficha médica

### 2️⃣ Tab 2: Ficha Médica
- **Ícono**: 📋 Clipboard
- **Función**: Detalles completos del paciente seleccionado
- **Secciones**:
  - Datos personales
  - Alertas médicas
  - Historial de consultas
  - Exámenes realizados
  - Notas médicas

### 3️⃣ Tab 3: Exámenes
- **Ícono**: 🧪 Flask
- **Función**: Gestión de órdenes de exámenes
- **Características**:
  - Ver exámenes pendientes y realizados
  - Subir resultados con OCR
  - Filtrar por tipo y estado

### 4️⃣ Tab 4: Medicación (Próximamente)
- **Ícono**: 💊 Pill
- **Función**: Gestión de recetas y medicamentos

---

## 👥 Gestión de Pacientes

### Ver Lista de Pacientes

1. **Acceder a Tab 1 (Pacientes)**
2. Verás una tarjeta por cada paciente con:
   - Nombre completo
   - Edad y ubicación
   - Diagnóstico principal
   - Teléfono
   - Última visita

### Buscar Pacientes

1. **Usar la barra de búsqueda** en la parte superior
2. Escribe:
   - Nombre
   - RUT
   - Diagnóstico
   - Ubicación
3. Los resultados se filtran automáticamente

### Crear Nuevo Paciente

1. **Presionar el botón "+" flotante** (esquina inferior derecha)
2. **Completar el formulario**:

   **Datos Personales** (obligatorios):
   - Nombre
   - Apellido
   - RUT (formato: 12345678-9)
   - Fecha de Nacimiento
   - Sexo (M/F/Otro)

   **Contacto**:
   - Teléfono
   - Email
   - Dirección

   **Datos Médicos**:
   - Grupo Sanguíneo (A+, A-, B+, B-, AB+, AB-, O+, O-)
   - Alergias (separadas por comas)
   - Enfermedades Crónicas (separadas por comas)
   - Diagnóstico Principal

3. **Presionar "Guardar"**
4. El paciente aparecerá en la lista

### Ver Ficha Médica de un Paciente

1. **Hacer clic en la tarjeta del paciente**
2. Automáticamente se abre la **Tab 2 (Ficha Médica)**
3. Se cargan todos los datos del paciente

---

## 🏥 Consultas Médicas

### Ver Historial de Consultas

1. **Abrir la ficha médica del paciente** (Tab 2)
2. **Desplazarse a la sección "Historial Médico"**
3. Verás un timeline con:
   - Fecha y hora de cada consulta
   - Motivo de consulta
   - Tratamiento aplicado
   - Diagnóstico

### Crear Nueva Consulta

1. **En la ficha médica del paciente**, presionar el botón **"+ Nueva Consulta"**
2. **Completar el formulario**:

   **Fecha y Hora**:
   - Seleccionar fecha de la consulta
   - Por defecto es la fecha/hora actual

   **Motivo de Consulta** (obligatorio):
   - Describir por qué el paciente acudió
   - Ejemplo: "Dolor abdominal", "Control de presión"

   **Diagnóstico**:
   - Describir el diagnóstico médico
   - Ejemplo: "Hipertensión arterial esencial"

   **Tratamiento**:
   - Indicar el tratamiento prescrito
   - Ejemplo: "Enalapril 10mg cada 12hrs"

   **Signos Vitales** (opcional):
   - Presión Arterial (ej: 120/80)
   - Frecuencia Cardíaca (lpm)
   - Temperatura (°C)
   - Peso (kg)
   - Saturación de Oxígeno (%)

   **Observaciones**:
   - Notas adicionales sobre la consulta

3. **Presionar "Guardar Consulta"**
4. La consulta aparece inmediatamente en el historial

### Ver Detalle de una Consulta

1. **En el historial médico**, buscar la consulta en el timeline
2. La descripción muestra información resumida
3. Los signos vitales y diagnóstico se muestran en los metadatos

---

## 🧪 Órdenes de Exámenes

### Ver Órdenes de Exámenes

1. **Acceder a Tab 3 (Exámenes)**
2. **O desde la ficha médica**, presionar **"Ver Exámenes"**
3. Verás las órdenes con:
   - Estado (Pendiente/Realizado)
   - Fecha de solicitud
   - Cantidad de exámenes
   - Lista de exámenes solicitados

### Crear Orden de Examen

1. **En la ficha médica del paciente**, presionar **"+ Nueva Orden"**
2. **Completar los datos**:

   **Fecha**:
   - Fecha de solicitud del examen

   **Exámenes** (agregar uno o más):
   - Tipo de Examen (Sangre, Orina, Imágenes, etc.)
   - Nombre específico (Hemograma, Glucosa, Radiografía, etc.)

3. **Agregar más exámenes** con el botón "+" si es necesario
4. **Presionar "Guardar Orden"**

### Subir Resultados de Exámenes

1. **Acceder a Tab 3 (Exámenes)**
2. **Presionar el botón "Subir Examen"**
3. **Elegir método**:

   **📷 Capturar con Cámara**:
   - Se abre la cámara del dispositivo
   - Tomar foto del resultado
   - El OCR extrae automáticamente el texto

   **📁 Seleccionar Archivo**:
   - Buscar archivo en el dispositivo
   - Subir PDF o imagen

4. **Completar datos**:
   - Nombre del examen
   - Tipo de examen
   - Resultado (extraído por OCR o manual)

5. **Presionar "Guardar"**

### Filtrar Exámenes

1. **En Tab 3**, usar los botones superiores:
   - **Todos**: Muestra todas las órdenes
   - **Pendientes**: Solo exámenes no realizados
   - **Realizados**: Solo exámenes completados

---

## 📝 Notas Médicas

### Ver Notas del Paciente

1. **En la ficha médica del paciente** (Tab 2)
2. **Desplazarse a la sección "Notas"**
3. Verás todas las notas con:
   - Fecha de creación
   - Contenido de la nota
   - Asociación (Consulta/Examen/General)

### Crear Nueva Nota

1. **Presionar el botón "+ Nueva Nota"**
2. **Completar el formulario**:

   **Contenido** (obligatorio):
   - Escribir la nota médica
   - Puede incluir observaciones, recordatorios, etc.

   **Asociar a** (opcional):
   - General (sin asociación)
   - Consulta específica
   - Orden de examen específica

3. **Presionar "Guardar Nota"**
4. La nota aparece en la lista

### Ver Detalle de una Nota

1. **Hacer clic en la tarjeta de la nota**
2. Se abre un popup con:
   - Contenido completo
   - Fecha y hora
   - Asociación (si tiene)
   - Opciones para editar o eliminar

### Editar una Nota

1. **Abrir el detalle de la nota**
2. **Presionar el ícono de edición** (lápiz)
3. **Modificar el contenido o asociación**
4. **Presionar "Guardar Cambios"**

### Eliminar una Nota

1. **Abrir el detalle de la nota**
2. **Presionar el ícono de eliminar** (papelera)
3. **Confirmar la eliminación**

---

## 🔍 Búsqueda y Filtros

### Búsqueda de Pacientes

**Campos de búsqueda**:
- Nombre completo
- RUT
- Diagnóstico
- Ubicación/Dirección

**Cómo usar**:
1. Escribir en la barra de búsqueda
2. Los resultados se filtran en tiempo real
3. Se busca en todos los campos simultáneamente

### Filtros de Exámenes

**Por Estado**:
- Todos
- Pendientes
- Realizados

**Aplicar filtro**:
1. Presionar el botón del estado deseado
2. La lista se actualiza automáticamente

### Expandir/Contraer Historial

En el historial médico:
- Por defecto se muestran **los 3 registros más recientes**
- **"Ver todos los registros"**: Expande el historial completo
- **"Ver menos"**: Contrae de nuevo a 3 registros

---

## 💡 Consejos y Mejores Prácticas

### Para Médicos/Profesionales

✅ **Registrar consultas inmediatamente**:
- Documenta mientras atiendes al paciente
- Los signos vitales son importantes para el seguimiento

✅ **Usar notas para recordatorios**:
- Anota pendientes o seguimientos necesarios
- Asocia notas a consultas específicas

✅ **Mantener diagnósticos actualizados**:
- El diagnóstico en cada consulta ayuda al historial
- Registra cambios en el estado del paciente

✅ **Subir exámenes rápidamente**:
- Usa la cámara para capturar resultados
- El OCR extrae la información automáticamente

### Datos Importantes

⚠️ **RUT debe ser válido**:
- Formato: 12345678-9
- Debe incluir el guión y dígito verificador

⚠️ **Fechas de nacimiento**:
- No pueden ser futuras
- Se calcula automáticamente la edad

⚠️ **Alergias y enfermedades**:
- Separar con comas
- Ejemplo: "Penicilina, Polen, Mariscos"

---

## 🆘 Solución de Problemas

### No se muestran las consultas recién creadas

**Solución**:
1. Actualizar la página (F5)
2. Verificar que se haya guardado correctamente (aparece mensaje de éxito)
3. Revisar la consola del navegador (F12) para errores

### Las notas no aparecen

**Solución**:
1. Verificar que el paciente esté seleccionado
2. Actualizar la ficha médica
3. Revisar permisos de Firestore

### Error al subir exámenes

**Solución**:
1. Verificar conexión a internet
2. Comprobar que el archivo no sea muy pesado (máx 5MB)
3. Intentar con otro formato (PDF o imagen)

### No puedo crear pacientes

**Solución**:
1. Verificar que todos los campos obligatorios estén completos
2. RUT debe ser válido
3. Email debe tener formato correcto

---

## 📞 Contacto y Soporte

Para reportar problemas o solicitar ayuda:
- Email: soporte@nexus.cl
- Teléfono: +56 2 1234 5678

---

## 📊 Resumen de Funcionalidades

| Funcionalidad | Ubicación | Acción Principal |
|--------------|-----------|------------------|
| Lista de Pacientes | Tab 1 | Ver todos los pacientes |
| Crear Paciente | Tab 1 | Botón "+" flotante |
| Ver Ficha Médica | Tab 2 | Click en paciente |
| Crear Consulta | Tab 2 | Botón "+ Nueva Consulta" |
| Ver Historial | Tab 2 | Sección "Historial Médico" |
| Gestionar Exámenes | Tab 3 | Ver/Filtrar órdenes |
| Subir Resultados | Tab 3 | Botón "Subir Examen" |
| Crear Notas | Tab 2 | Botón "+ Nueva Nota" |
| Buscar | Tab 1 | Barra de búsqueda |

---

## 🔄 Actualización: Noviembre 2025

**Últimas mejoras implementadas**:
- ✅ Colección de notas independiente en Firestore
- ✅ Filtrado de pacientes por rol
- ✅ Mejora en la visualización del historial médico
- ✅ OCR mejorado para extracción de resultados
- ✅ Timeline expandible en el historial

---

**Versión del Manual**: 1.0  
**Última actualización**: Noviembre 26, 2025  
**Aplicación**: Nexus - Sistema Médico Ionic
