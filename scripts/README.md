# Scripts de Administración

Colección de utilidades para poblar, depurar y verificar el estado del proyecto Firebase utilizado por Nexus Medical.

## Requisitos

- Node.js 18 o superior.
- Dependencias instaladas en la raíz del repo (`npm install`).
- Archivo `serviceAccountKey.json` en la raíz (no subir a git) con permisos de **Editor** o superiores.

## Uso básico

```bash
# Instalar dependencias compartidas
npm install

# Ejecutar un script puntual
node scripts/seed-pacientes.js
```

## Resumen de scripts

| Script | Descripción | Ejemplo de uso |
| --- | --- | --- |
| `seed-pacientes.js` | Crea pacientes de prueba, usuarios Auth y sus fichas médicas. | `node scripts/seed-pacientes.js` |
| `seed-juan-perez.js` | Vuelve a crear solamente al paciente Juan Pérez. | `node scripts/seed-juan-perez.js` |
| `seed-firestore.js` | Seed completo heredado del sistema antiguo (usar solo si necesitas todos los demos). | `node scripts/seed-firestore.js` |
| `clean-pacientes.js` | Elimina pacientes y usuarios Auth creados por los seeds actuales. | `node scripts/clean-pacientes.js` |
| `clean-firestore.js` | Limpia colecciones completas (uso extremo). | `node scripts/clean-firestore.js` |
| `crear-indices-firebase.js` / `create-indexes.js` | Registra índices requeridos en Firestore. | `node scripts/create-indexes.js` |
| `deploy-firestore-rules.sh` | Publica las reglas desde `firestore.rules`. | `bash scripts/deploy-firestore-rules.sh` |
| `enable-storage.js` | Configura Storage y sus reglas iniciales. | `node scripts/enable-storage.js` |
| `create-auth-users.js` | Solo crea usuarios en Firebase Auth (sin documentos). | `node scripts/create-auth-users.js` |
| `verify-auth-uids.js` | Verifica que los UID utilizados en Firestore existan en Auth. | `node scripts/verify-auth-uids.js` |
| `fix-juan-uid.js` | Corrige el UID de Juan Pérez en Auth/Firestore. | `node scripts/fix-juan-uid.js` |
| `reseed-with-correct-uids.js` | Seed alternativo que preserva UIDs existentes. | `node scripts/reseed-with-correct-uids.js` |
| `get-user-id.js` | Busca el UID para un email puntual. | `node scripts/get-user-id.js` |

## Buenas prácticas

- Ejecuta los scripts en entornos de prueba; no apuntes a producción sin revisar los datos que modifican.
- Antes de poblar datos, corre `node scripts/clean-pacientes.js` para evitar duplicados.
- Después de cambios en reglas o índices, usa `bash scripts/deploy-firestore-rules.sh` y `firebase deploy --only firestore:indexes` si necesitas desplegar desde CLI.
- Revisa la consola para confirmar cada operación; la mayoría de los scripts imprimen un resumen con lo que modificaron.
