/**
 * Script para LIMPIAR todas las colecciones de Firestore
 * ⚠️ CUIDADO: Este script ELIMINA TODOS los datos
 * 
 * Uso:
 *   node scripts/clean-firestore.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Colecciones a limpiar
const COLLECTIONS = [
  'pacientes',
  'fichas-medicas',
  'profesionales',
  'consultas',
  'hospitalizaciones',
  'examenes',
  'ordenes-examen',
  'medicamentos',
  'recetas',
  'diagnosticos'
];

/**
 * Elimina todos los documentos de una colección en lotes
 */
async function deleteCollection(collectionName) {
  const collectionRef = db.collection(collectionName);
  const batchSize = 100;
  let deletedCount = 0;

  console.log(`\n🗑️  Limpiando colección: ${collectionName}`);

  while (true) {
    const snapshot = await collectionRef.limit(batchSize).get();
    
    if (snapshot.empty) {
      break;
    }

    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    deletedCount += snapshot.size;
    console.log(`   ✓ Eliminados ${deletedCount} documentos...`);
  }

  console.log(`   ✅ Total eliminados: ${deletedCount} documentos`);
}

/**
 * Función principal
 */
async function cleanFirestore() {
  console.log('╔════════════════════════════════════════════════╗');
  console.log('║   LIMPIEZA COMPLETA DE FIRESTORE               ║');
  console.log('║   ⚠️  ESTO ELIMINARÁ TODOS LOS DATOS          ║');
  console.log('╚════════════════════════════════════════════════╝');
  
  console.log('\n⏳ Iniciando en 3 segundos...');
  await new Promise(resolve => setTimeout(resolve, 3000));

  try {
    for (const collection of COLLECTIONS) {
      await deleteCollection(collection);
    }

    console.log('\n╔════════════════════════════════════════════════╗');
    console.log('║   ✅ LIMPIEZA COMPLETADA EXITOSAMENTE         ║');
    console.log('╚════════════════════════════════════════════════╝');
    console.log('\n💡 Ahora puedes ejecutar: node scripts/seed-firestore.js');

  } catch (error) {
    console.error('\n❌ Error durante la limpieza:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Ejecutar
cleanFirestore();
