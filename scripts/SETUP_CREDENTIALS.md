# 🔑 Configuración de Credenciales de Firebase

## ⚠️ ANTES DE EJECUTAR LOS SCRIPTS

Necesitas generar el archivo `serviceAccountKey.json` desde Firebase Console.

## 📋 Pasos para Obtener las Credenciales

### 1. Abre Firebase Console

Ve a: https://console.firebase.google.com/

### 2. Selecciona tu Proyecto

Haz clic en tu proyecto "Nexus" (o como lo hayas llamado)

### 3. Accede a Project Settings

1. Haz clic en el ícono de **⚙️ engranaje** (parte superior izquierda)
2. Selecciona **"Project settings"**

### 4. Ve a Service Accounts

1. En el menú de configuración, haz clic en la pestaña **"Service accounts"**
2. Deberías ver una sección que dice **"Firebase Admin SDK"**

### 5. Genera la Clave Privada

1. Haz clic en el botón **"Generate new private key"**
2. Confirma en el diálogo que aparece
3. Se descargará automáticamente un archivo JSON

### 6. Renombra y Coloca el Archivo

1. El archivo descargado tendrá un nombre largo como:
   ```
   nombre-proyecto-firebase-adminsdk-xxxxx-xxxxxxxxxx.json
   ```

2. **Renómbralo** a:
   ```
   serviceAccountKey.json
   ```

3. **Muévelo** a la raíz de tu proyecto:
   ```
   nexus/
   ├── serviceAccountKey.json  ← AQUÍ
   ├── package.json
   ├── angular.json
   ├── scripts/
   └── ...
   ```

## ✅ Verificación

El archivo debe tener esta estructura:

```json
{
  "type": "service_account",
  "project_id": "tu-proyecto-id",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@tu-proyecto.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "..."
}
```

## 🛡️ Seguridad IMPORTANTE

### ⚠️ NUNCA subas este archivo a Git

El archivo ya está en `.gitignore`, pero verifica:

```bash
# Verifica que NO aparezca en git status
git status

# Si aparece, agrégalo al .gitignore
echo "serviceAccountKey.json" >> .gitignore
```

### 🔒 Mantén el archivo seguro

- **NO lo compartas** con nadie
- **NO lo subas** a repositorios públicos
- **NO lo incluyas** en capturas de pantalla
- Si lo comprometes, **ELIMÍNALO INMEDIATAMENTE** desde Firebase Console

## 🚀 Ahora Puedes Ejecutar los Scripts

Una vez que tengas el archivo en su lugar:

```bash
# Poblar base de datos
node scripts/seed-firestore.js

# O limpiar primero
node scripts/clean-firestore.js
```

## 🆘 Problemas Comunes

### "Error: Could not load the default credentials"

**Solución**: El archivo no está en la ubicación correcta o tiene un nombre incorrecto.
- Verifica que se llame exactamente `serviceAccountKey.json`
- Verifica que esté en la raíz del proyecto

### "Error: Permission denied"

**Solución**: La cuenta de servicio no tiene permisos suficientes.
- En Firebase Console, ve a IAM & Admin
- Asegúrate de que la cuenta de servicio tenga el rol "Firebase Admin"

### El archivo no se descarga

**Solución**: Problemas de navegador.
- Intenta con otro navegador
- Verifica que las descargas no estén bloqueadas
- Revisa tu carpeta de Descargas

---

**Nota**: Si ya tienes un proyecto de Firebase configurado pero no encuentras la opción de Service Accounts, asegúrate de que el proyecto tenga Firestore habilitado.
