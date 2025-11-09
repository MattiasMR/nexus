# Nexus Ionic - Aplicación Médica

Aplicación móvil y web para gestión médica desarrollada con Ionic y Angular.

## Tecnologías

- **Angular**: 20.0.0
- **Ionic**: 8.0.0
- **Firebase**: Firestore + Authentication
- **Capacitor**: 7.4.3

## Características

- ✅ Gestión de Pacientes
- ✅ Fichas Médicas
- ✅ Consultas Médicas
- ✅ Exámenes y Órdenes
- ✅ Recetas y Medicamentos
- ✅ Dashboard con estadísticas
- ✅ Sincronización en tiempo real con Firebase

## Instalación

### Requisitos previos
- Node.js (v18 o superior)
- npm o yarn
- Cuenta de Firebase configurada

### Pasos

1. Instalar dependencias:
```bash
npm install
```

2. Configurar Firebase:
   - Crear un proyecto en [Firebase Console](https://console.firebase.google.com/)
   - Descargar el archivo de credenciales `serviceAccountKey.json`
   - Colocar en la raíz del proyecto ionic
   - Actualizar `src/environments/environment.ts` con la configuración

3. Inicializar datos (opcional):
```bash
npm run seed
```

## Desarrollo

### Servidor de desarrollo
```bash
npm start
```

La aplicación estará disponible en `http://localhost:4200/`

### Build para producción
```bash
npm run build
```

### Ejecutar tests
```bash
npm test
```

### Linting
```bash
npm run lint
```

## Scripts Disponibles

- `npm start` - Inicia el servidor de desarrollo
- `npm run build` - Compila para producción
- `npm test` - Ejecuta los tests
- `npm run lint` - Ejecuta el linter
- `npm run seed` - Inicializa Firestore con datos de prueba (ver `/scripts`)

## Estructura del Proyecto

```
src/
├── app/
│   ├── core/           # Servicios core y guards
│   ├── features/       # Módulos de características
│   │   ├── consultas/
│   │   ├── dashboard/
│   │   ├── examenes/
│   │   ├── fichas-medicas/
│   │   ├── medicamentos/
│   │   └── pacientes/
│   ├── models/         # Interfaces y modelos
│   ├── shared/         # Componentes compartidos
│   └── tabs/           # Navegación por tabs
├── assets/             # Recursos estáticos
├── environments/       # Configuración de entornos
└── theme/             # Estilos globales
```

## Configuración de Firebase

### Firestore
Ver [scripts/README.md](./scripts/README.md) para instrucciones de configuración.

### Índices necesarios
Los índices compuestos se crearán automáticamente cuando uses la aplicación, o puedes crearlos manualmente desde la consola de Firebase.

## Despliegue

### Web (Firebase Hosting)
```bash
npm run build
firebase deploy --only hosting
```

### Aplicación móvil
```bash
# Android
npx cap add android
npx cap sync
npx cap open android

# iOS
npx cap add ios
npx cap sync
npx cap open ios
```

## Contribución

1. Crear una rama para tu feature
2. Hacer commits con mensajes descriptivos
3. Asegurar que todos los tests pasen
4. Crear un Pull Request

## Licencia

Proyecto académico - UDD 2025
