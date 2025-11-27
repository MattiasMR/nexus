# Manual de Uso - Nexus Flutter

## 1. Requisitos Previos

Antes de comenzar, asegúrese de contar con lo siguiente:

*   **Flutter SDK:** Instalado y configurado en el `PATH` del sistema (versión compatible con SDK 3.9.2 o superior).
*   **Editor de Código:** Visual Studio Code (recomendado) con las extensiones de *Flutter* y *Dart* instaladas, o Android Studio.
*   **Emulador o Dispositivo:**
    *   **Android:** Android Studio instalado con un AVD (Android Virtual Device) configurado.
    *   **iOS:** Xcode instalado (solo macOS).
    *   **Web/Windows:** Navegador Chrome o entorno de desarrollo Windows configurado (opcional, si desea probar en estas plataformas).
*   **Conexión a Internet:** El dispositivo o emulador debe tener acceso a internet para conectarse a los servicios de Firebase (Autenticación y Base de Datos).

## 2. Configuración del Entorno

1.  **Abrir el Proyecto:**
    Abra la carpeta `nexus/flutter` en su editor de código preferido.

2.  **Instalar Dependencias:**
    Abra una terminal en la raíz del proyecto (`nexus/flutter`) y ejecute el siguiente comando para descargar las librerías necesarias:
    ```bash
    flutter pub get
    ```

3.  **Verificar Archivos de Configuración:**
    El proyecto incluye el archivo `lib/firebase_options.dart`, el cual contiene las credenciales necesarias para conectar con el proyecto de Firebase. **No elimine ni modifique este archivo**, ya que es esencial para el funcionamiento de la app.

## 3. Ejecución de la Aplicación

1.  **Seleccionar Dispositivo:**
    *   En **VS Code**: Haga clic en el selector de dispositivos en la esquina inferior derecha de la ventana y seleccione su emulador o dispositivo conectado.
    *   En **Terminal**: Puede ver los dispositivos disponibles con `flutter devices`.

2.  **Iniciar la Aplicación:**
    Ejecute el siguiente comando en la terminal:
    ```bash
    flutter run
    ```


## 4. Credenciales de Prueba

Para evaluar las funcionalidades de la aplicación (diseñada para el rol de **Paciente**), utilice las siguientes credenciales de usuarios pre-registrados en el sistema:

### Paciente de Prueba 
*   **Email:** `moralesmattias@gmail.com`
*   **Contraseña:** `contraseña123`