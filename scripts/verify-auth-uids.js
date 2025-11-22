/**
 * Script para verificar UIDs de Firebase Authentication vs Firestore
 * Ejecutar: node scripts/verify-auth-uids.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializar Firebase Admin si no está inicializado
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const auth = admin.auth();
const db = admin.firestore();

const EMAILS = [
  'juan.perez@email.com',
  'maria.torres@email.com',
  'pedro.ramirez@email.com',
  'carmen.munoz@email.com',
  'daniela.soto@email.com'
];

async function verifyUids() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   VERIFICANDO UIDs                             ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  for (const email of EMAILS) {
    console.log(`\n👤 ${email}`);
    
    try {
      // Obtener usuario de Firebase Auth
      const authUser = await auth.getUserByEmail(email);
      console.log(`   🔐 Auth UID: ${authUser.uid}`);
      
      // Buscar en Firestore por email
      const firestoreQuery = await db
        .collection('pacientes')
        .where('email', '==', email)
        .limit(1)
        .get();
      
      if (!firestoreQuery.empty) {
        const firestoreDoc = firestoreQuery.docs[0];
        console.log(`   📁 Firestore Doc ID: ${firestoreDoc.id}`);
        console.log(`   📊 Firestore Data:`, {
          nombre: firestoreDoc.data().nombre,
          apellido: firestoreDoc.data().apellido,
          activo: firestoreDoc.data().activo
        });
        
        if (authUser.uid === firestoreDoc.id) {
          console.log(`   ✅ UIDs COINCIDEN`);
        } else {
          console.log(`   ❌ UIDs NO COINCIDEN`);
        }
      } else {
        console.log(`   ❌ No encontrado en Firestore`);
      }
      
    } catch (error) {
      console.error(`   ❌ Error: ${error.message}`);
    }
  }

  console.log('\n');
  process.exit(0);
}

verifyUids().catch(error => {
  console.error('\n❌ Error fatal:', error);
  process.exit(1);
});
