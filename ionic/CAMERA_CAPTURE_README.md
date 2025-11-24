# Funcionalidad de Captura de Cámara

## Resumen
Se ha implementado la opción de tomar fotos directamente con la cámara del dispositivo para los exámenes médicos, además de la funcionalidad existente de subir archivos desde el almacenamiento del dispositivo.

## Cambios Realizados

### 1. HTML (`consultas.page.html`)
- Se modificó la sección de carga de archivos para incluir dos botones:
  - **"Subir archivo"**: Permite seleccionar archivos desde el dispositivo (PDF, JPG, PNG, DOC, etc.)
  - **"Tomar foto"**: Abre la cámara para capturar una foto directamente
- Los botones están en un contenedor flexible (`file-upload-options`) que se adapta a diferentes tamaños de pantalla
- Se agregó un hint informativo sobre los formatos aceptados y el tamaño máximo

### 2. TypeScript (`consultas.page.ts`)
- Se importó el plugin `Camera` de Capacitor:
  ```typescript
  import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';
  ```

- Se implementó el método `tomarFoto()`:
  - Abre la cámara nativa del dispositivo con calidad del 90%
  - Captura la imagen como Data URL
  - Convierte el Data URL a un objeto `File` compatible con el flujo existente
  - Valida el tamaño de la imagen (máximo 10MB)
  - Muestra advertencia si la imagen es mayor a 1MB
  - Guarda el archivo en `nuevoExamen.archivo` y crea la previsualización
  - Maneja errores y cancelaciones de usuario
  - Ejecuta OCR automáticamente al guardar (igual que con archivos subidos)

### 3. Estilos (`consultas.page.scss`)
- Se creó `.file-upload-options` como contenedor flexible para los dos botones
- El botón de cámara (`.camera-btn`) tiene un diseño azul distintivo
- Ambos botones comparten estilos base con hover effects y animaciones
- Diseño responsive que apila los botones en pantallas pequeñas

## Flujo de Funcionamiento

1. **Usuario presiona "Tomar foto"**
2. Se abre la cámara nativa del dispositivo
3. Usuario toma la foto
4. La foto se convierte a formato `File` (JPEG)
5. Se valida tamaño (máximo 10MB, advertencia >1MB)
6. Se guarda en `nuevoExamen.archivo` con previsualización
7. Al presionar "Guardar Examen":
   - Se convierte a Base64
   - Se ejecuta OCR automático (Tesseract.js)
   - Se guarda en Firestore con texto extraído
   - Se muestra en el visor con edición de texto habilitada

## Compatibilidad

- **Web/Browser**: Solicitará permisos de cámara del navegador
- **iOS**: Funciona nativamente (requiere permisos en Info.plist)
- **Android**: Funciona nativamente (requiere permisos en AndroidManifest.xml)

## Permisos Requeridos

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS (`ios/App/App/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Esta app necesita acceso a la cámara para tomar fotos de exámenes médicos</string>
```

## Ventajas de la Implementación

1. ✅ **Integración Perfecta**: Utiliza el mismo flujo que la subida de archivos
2. ✅ **OCR Automático**: La foto capturada se procesa con OCR igual que las imágenes subidas
3. ✅ **Validación Consistente**: Mismas validaciones de tamaño y formato
4. ✅ **UX Mejorada**: Los usuarios pueden tomar fotos directamente sin salir de la app
5. ✅ **Nativo**: Usa la cámara nativa del dispositivo (mejor calidad y rendimiento)
6. ✅ **Manejo de Errores**: Controla cancelaciones y errores de permisos

## Formato de Archivo Generado

- **Nombre**: `foto_examen_[timestamp].jpg`
- **Formato**: JPEG con calidad 90%
- **Tipo MIME**: `image/jpeg`
- **Almacenamiento**: Base64 en Firestore (igual que archivos subidos)

## Próximos Pasos Opcionales

1. **Ajuste de Calidad**: Modificar el parámetro `quality` en `Camera.getPhoto()` si se requiere menor tamaño
2. **Editor de Imagen**: Habilitar `allowEditing: true` para permitir recorte/rotación antes de guardar
3. **Galería de Fotos**: Agregar opción adicional para seleccionar desde la galería usando `CameraSource.Photos`
4. **Compresión**: Implementar compresión adicional para fotos mayores a 1MB antes de guardar

## Uso

1. Navegar a la página de consultas de un paciente
2. Abrir el formulario "Solicitar Nuevo Examen"
3. Presionar el botón **"Tomar foto"**
4. Tomar la foto con la cámara
5. La foto aparecerá en la previsualización
6. Completar el formulario y presionar **"Guardar Examen"**
7. El examen se guardará con OCR automático
