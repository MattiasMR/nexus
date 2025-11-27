# Manual de Instalación y Uso - Sistema de Gestión Médica Nexus

## Requisitos Previos

### Software Necesario

1. **PHP >= 8.2**
   - Extensiones requeridas:
     - BCMath
     - Ctype
     - Fileinfo
     - JSON
     - Mbstring
     - OpenSSL
     - PDO
     - Tokenizer
     - XML
     - gRPC (para Firestore)

2. **Composer** (Gestor de dependencias PHP)
   - Descargar desde: https://getcomposer.org/download/

3. **Node.js >= 18.x** y **npm**
   - Descargar desde: https://nodejs.org/

4. **Cuenta de Firebase/Firestore**
   - Proyecto configurado en Firebase Console
   - Credenciales JSON del proyecto

---

## Instalación Paso a Paso

### 1. Clonar o Descargar el Proyecto

```bash
# Si usa Git
git clone <url-del-repositorio>
cd nexus/laravel

# Si descargó un ZIP, extraiga y navegue a la carpeta
cd nexus/laravel
```

### 2. Instalar Dependencias de PHP

```bash
composer install
```

Esto instalará todas las dependencias necesarias:
- Laravel Framework 12
- Inertia.js
- Firebase PHP SDK
- Google Cloud Firestore
- Laravel Fortify (autenticación)
- Transbank SDK (pagos)
- DomPDF (generación de PDFs)

### 3. Instalar Dependencias de JavaScript

```bash
npm install
```

Esto instalará:
- Vue 3
- Vite
- Tailwind CSS
- shadcn-vue (componentes UI)
- Radix Vue
- Lucide Icons

### 4. Configurar Variables de Entorno

#### 4.1. Crear archivo .env

```bash
# En Windows PowerShell
Copy-Item .env.example .env

# O manualmente copie el archivo .env.example y renómbrelo a .env
```

#### 4.2. Generar clave de aplicación

```bash
php artisan key:generate
```

#### 4.3. Configurar Firebase/Firestore

**Importante:** Necesita las credenciales de Firebase

1. Descargue el archivo de credenciales JSON desde Firebase Console:
   - Vaya a: Configuración del proyecto > Cuentas de servicio
   - Click en "Generar nueva clave privada"
   - Guarde el archivo como `firebase-credentials.json`

2. Coloque el archivo en: `storage/app/firebase-credentials.json`

3. En el archivo `.env`, configure:

```env
APP_NAME="Sistema Nexus"
APP_URL=http://localhost:8000

# Base de datos (SQLite por defecto, no requiere configuración adicional)
DB_CONNECTION=sqlite

# Firebase (reemplazar con sus valores)
FIREBASE_PROJECT_ID=nexus-68994
FIREBASE_CREDENTIALS=storage/app/firebase-credentials.json
```

#### 4.4. Configuración opcional de gRPC (Windows)

Si está en Windows y tiene problemas con Firestore, agregue:

```env
GRPC_VERBOSITY=ERROR
GRPC_TRACE=
```

### 5. Preparar Base de Datos

El proyecto usa SQLite por defecto (no requiere servidor de BD):

```bash
# Crear archivo de base de datos
# En Windows PowerShell
New-Item -Path database/database.sqlite -ItemType File

# Ejecutar migraciones
php artisan migrate
```

### 6. Compilar Assets del Frontend

#### Desarrollo (con hot reload):

```bash
npm run dev
```

#### Producción (compilación optimizada):

```bash
npm run build
```

---

## Ejecutar la Aplicación

### Opción 1: Servidor de Desarrollo de Laravel

En una terminal:

```bash
php artisan serve
```

La aplicación estará disponible en: http://localhost:8000

### Opción 2: Con npm concurrently (Backend + Frontend)

Si quiere ejecutar el servidor PHP y Vite simultáneamente:

Terminal 1:
```bash
php artisan serve
```

Terminal 2:
```bash
npm run dev
```

---

## Estructura de Firestore Requerida

El sistema requiere las siguientes colecciones en Firestore:

### Colección: `usuarios`
```javascript
{
  id: "string",
  email: "string",
  displayName: "string",
  rut: "string",
  telefono: "string",
  photoURL: "string",
  role: "admin" | "paciente",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Colección: `pacientes`
```javascript
{
  id: "string",
  idUsuario: "string",
  nombre: "string",
  apellido: "string",
  fechaNacimiento: "string",
  sexo: "M" | "F" | "Otro",
  direccion: "string",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Colección: `fichasMedicas`
```javascript
{
  id: "string",
  idPaciente: "string",
  antecedentes: {
    alergias: [],
    familiares: "string",
    hospitalizaciones: "string",
    personales: "string",
    quirurgicos: "string"
  },
  observacion: "string",
  fechaMedica: timestamp
}
```

### Colección: `consultas`
```javascript
{
  id: "string",
  idPaciente: "string",
  fecha: timestamp,
  nombreProfesional: "string",
  diagnostico: "string",
  receta: "string",
  sintomas: "string",
  tratamiento: "string"
}
```

### Colección: `ordenes-examen`
```javascript
{
  id: "string",
  idPaciente: "string",
  fecha: timestamp,
  estado: "pendiente" | "completado",
  examenes: [
    {
      idExamen: "string",
      nombreExamen: "string",
      resultado: "string",
      fechaResultado: timestamp,
      documentos: [
        {
          url: "string",
          nombre: "string",
          tipo: "string",
          tamanio: number,
          textoExtraido: "string",
          confianzaOCR: number,
          fechaSubida: timestamp
        }
      ]
    }
  ],
  idProfesional: "string",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

---

## Credenciales de Acceso por Defecto

**Nota:** El sistema usa autenticación de Firebase, por lo que debe crear usuarios manualmente en Firebase Authentication o usar el sistema de registro de la aplicación.

Roles disponibles:
- `admin`: Acceso completo al sistema
- `paciente`: Acceso limitado a su información personal

---

## Funcionalidades Principales

### 1. Dashboard
- Vista general del sistema
- Estadísticas básicas

### 2. Gestión de Usuarios
- Lista de usuarios registrados
- Filtrado y búsqueda
- Visualización de datos de perfil

### 3. Gestión Médica (Módulo Principal)

#### 3.1. Lista de Pacientes
- Visualización de todos los pacientes
- Estadísticas:
  - Total de pacientes
  - Pacientes con ficha médica
  - Pacientes sin ficha médica
  - Pacientes con alergias registradas
- Búsqueda y filtrado
- Acceso rápido a ficha médica

#### 3.2. Ficha Médica del Paciente
Sistema de pestañas con 4 secciones:

**Pestaña 1: Ficha Médica**
- Datos personales del paciente
- Antecedentes médicos:
  - Personales
  - Familiares
  - Quirúrgicos
  - Hospitalizaciones
- Gestión de alergias
- Observaciones generales
- Descargar PDF de ficha médica

**Pestaña 2: Consultas**
- Historial de consultas médicas
- Información por consulta:
  - Fecha
  - Profesional que atendió
  - Diagnóstico
  - Receta
  - Síntomas
  - Tratamiento
- Botones CRUD (en desarrollo):
  - Nueva Consulta
  - Ver detalles
  - Editar
  - Eliminar

**Pestaña 3: Exámenes**
- Órdenes de examen del paciente
- Información por orden:
  - Fecha de la orden
  - Estado (pendiente/completado)
  - Lista de exámenes solicitados
  - Documentos adjuntos
- Botones CRUD (en desarrollo):
  - Nueva Orden
  - Ver detalles
  - Editar
  - Eliminar

**Pestaña 4: Diagnósticos**
- Diagnóstico principal (desde observaciones)
- Lista de diagnósticos por consulta
- Vista consolidada de historial clínico

### 4. Comprar Bono
- Sistema de compra de bonos (módulo básico)

---

## Solución de Problemas Comunes

### Error: "Class 'firebase.firestore' does not exist"

**Solución:**
1. Verifique que el archivo `firebase-credentials.json` esté en `storage/app/`
2. Ejecute: `composer dump-autoload`
3. Limpie caché: `php artisan config:clear`

### Error: Firestore queries failing

**Solución:**
- El sistema usa ordenamiento manual en PHP para evitar índices compuestos
- Verifique logs en `storage/logs/laravel.log`

### Error: "Vite manifest not found"

**Solución:**
```bash
npm run build
```

### Error: "Permission denied" en storage/logs

**Solución en Windows:**
```bash
# Dar permisos a carpetas de storage
icacls "storage" /grant Users:F /T
icacls "bootstrap/cache" /grant Users:F /T
```

### El frontend no se actualiza

**Solución:**
```bash
# Limpiar caché de navegador (Ctrl + Shift + R)
# Reconstruir assets
npm run build
```

---

## Comandos Útiles de Laravel

```bash
# Limpiar todas las cachés
php artisan optimize:clear

# Ver logs en tiempo real
php artisan pail

# Ejecutar migraciones
php artisan migrate

# Revertir migraciones
php artisan migrate:rollback

# Generar nueva clave de app
php artisan key:generate

# Listar rutas disponibles
php artisan route:list
```

---

## Tecnologías Utilizadas

### Backend
- **Laravel 12** - Framework PHP
- **Inertia.js** - SPA sin API
- **Firebase/Firestore** - Base de datos NoSQL
- **Laravel Fortify** - Autenticación
- **DomPDF** - Generación de PDFs

### Frontend
- **Vue 3** - Framework JavaScript
- **TypeScript** - Tipado estático
- **Tailwind CSS 4** - Framework CSS
- **shadcn-vue** - Componentes UI
- **Radix Vue** - Primitivas accesibles
- **Lucide Icons** - Iconografía
- **Vite** - Build tool

---

## Contacto y Soporte

Para dudas o problemas durante la evaluación, revisar:
1. Logs del sistema: `storage/logs/laravel.log`
2. Consola del navegador (F12) para errores de frontend
3. Terminal donde corre `php artisan serve` para errores de backend

---

## Notas para Evaluación

- El sistema está completamente funcional para visualización de datos
- Las operaciones CRUD de Consultas y Exámenes tienen los botones UI pero la lógica está pendiente
- El sistema usa Firestore REST API para evitar problemas de compatibilidad con gRPC en Windows
- Los logs detallados facilitan el debugging (buscar emojis 🔵📋👤📄💊🔬🎨 en los logs)
- El diseño es responsive y sigue las mejores prácticas de UI/UX
