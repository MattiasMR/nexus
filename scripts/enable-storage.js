/**
 * Script para habilitar Firebase Storage mediante Admin SDK
 * Ejecutar: node scripts/enable-storage.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializar Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: 'nexus-68994.firebasestorage.app'
  });
}

async function enableStorage() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   HABILITANDO FIREBASE STORAGE                 ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  try {
    const bucket = admin.storage().bucket();
    console.log('✅ Storage bucket conectado:', bucket.name);
    
    // Crear un archivo de prueba para inicializar el bucket
    const testFile = bucket.file('.initialized');
    await testFile.save('Firebase Storage inicializado correctamente', {
      metadata: {
        contentType: 'text/plain',
      }
    });
    
    console.log('✅ Archivo de prueba creado');
    
    // Eliminar el archivo de prueba
    await testFile.delete();
    console.log('✅ Limpieza completada');
    
    console.log('\n✅ Firebase Storage habilitado exitosamente!\n');
    console.log('📝 Ahora ejecuta: firebase deploy --only storage');
    console.log('   para desplegar las reglas de seguridad.\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.log('\n⚠️  Si el error es sobre permisos o bucket no existe,');
    console.log('   necesitas habilitar Storage manualmente en:');
    console.log('   https://console.firebase.google.com/project/nexus-68994/storage\n');
  }
  
  process.exit(0);
}

enableStorage();
