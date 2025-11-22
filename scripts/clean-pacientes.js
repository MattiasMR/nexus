/**
 * Script para LIMPIAR la colección de pacientes en Firestore
 * Útil para resetear los datos de prueba
 * 
 * Uso:
 *   node scripts/clean-pacientes.js
 * 
 * ADVERTENCIA: Esto eliminará todos los documentos de la colección 'pacientes'
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function deleteCollection(collectionPath, batchSize = 100) {
  const collectionRef = db.collection(collectionPath);
  const query = collectionRef.limit(batchSize);

  return new Promise((resolve, reject) => {
    deleteQueryBatch(query, resolve, reject);
  });
}

async function deleteQueryBatch(query, resolve, reject) {
  try {
    const snapshot = await query.get();

    if (snapshot.size === 0) {
      resolve();
      return;
    }

    const batch = db.batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();

    process.nextTick(() => {
      deleteQueryBatch(query, resolve, reject);
    });
  } catch (error) {
    reject(error);
  }
}

async function cleanPacientes() {
  console.log('🧹 Limpiando datos de pacientes...\n');

  try {
    // Limpiar colección de pacientes
    console.log('🗑️  Eliminando colección: pacientes');
    await deleteCollection('pacientes');
    console.log('✅ Colección "pacientes" eliminada');

    // Limpiar fichas médicas de pacientes
    console.log('🗑️  Eliminando colección: fichas-medicas');
    await deleteCollection('fichas-medicas');
    console.log('✅ Colección "fichas-medicas" eliminada');

    console.log('\n✅ ¡Limpieza completada!');
    console.log('\nNOTA: Los usuarios en Firebase Authentication NO fueron eliminados.');
    console.log('Si necesitas eliminar usuarios de Auth, hazlo manualmente desde Firebase Console.');
    
  } catch (error) {
    console.error('\n❌ Error durante la limpieza:', error);
    throw error;
  } finally {
    console.log('\n👋 Finalizando...');
    process.exit(0);
  }
}

// Ejecutar
cleanPacientes();
