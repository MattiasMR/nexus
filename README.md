# Nexus - Sistema de Gestión Médica

Este repositorio contiene el sistema completo de gestión médica Nexus con múltiples tecnologías.

## Estructura del Proyecto

```
nexus/
├── ionic/          # Aplicación web/móvil con Ionic + Angular
├── flutter/        # Aplicación móvil nativa con Flutter  
└── laravel/        # API backend con Laravel (próximamente)
```

## Proyectos

### Ionic 
- **Ubicación**: `/ionic`
- **Estado**: ✅ Implementado y funcional
- **Tecnologías**: Angular 20, Ionic 8, Firebase, Capacitor
- **Descripción**: Aplicación para gestión de pacientes, fichas médicas, exámenes y consultas
- **Características**: Dashboard, CRUD completo, integración Firebase en tiempo real

### Flutter 
- **Ubicación**: `/flutter`
- **Estado**: ✅ Implementado y funcional
- **Tecnologías**: Flutter 3.9+, Dart, Firebase, Material Design 3
- **Descripción**: Aplicación nativa multiplataforma
- **Características**: Gestión de pacientes, fichas médicas, integración Firebase, widget de clima
- **Plataformas**: Android, iOS, Web, Windows, Linux, macOS

### Laravel 
- **Ubicación**: `/laravel`

## Modelo de Base de Datos

Ver [Modelo_BDD.md](./Modelo_BDD.md) para el esquema completo de la base de datos.

## Inicio Rápido

### Ionic
```bash
cd ionic
npm install
npm start
```

### Flutter
```bash
cd flutter
flutter pub get
flutter run
```

### Laravel
```bash
cd laravel
# Por implementar
```

## Configuración

Cada proyecto tiene su propia documentación de configuración en su respectiva carpeta:
- [Ionic README](./ionic/README.md)
- [Flutter README](./flutter/README.md)
- [Laravel README](./laravel/README.md)
