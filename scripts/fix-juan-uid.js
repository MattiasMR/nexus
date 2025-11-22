/**
 * Script para arreglar el UID de juan.perez@email.com
 * Ejecutar: node scripts/fix-juan-uid.js
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

async function fixJuanUid() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   ARREGLANDO UID DE JUAN PÉREZ                 ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  const email = 'juan.perez@email.com';
  const password = 'password123';
  
  try {
    // 1. Obtener el usuario actual de Auth
    console.log('1️⃣ Buscando usuario en Firebase Auth...');
    const oldAuthUser = await auth.getUserByEmail(email);
    console.log(`   ✓ Usuario encontrado con UID: ${oldAuthUser.uid}`);
    
    // 2. Obtener el documento de Firestore
    console.log('\n2️⃣ Buscando documento en Firestore...');
    const firestoreQuery = await db
      .collection('pacientes')
      .where('email', '==', email)
      .limit(1)
      .get();
    
    if (firestoreQuery.empty) {
      throw new Error('Documento no encontrado en Firestore');
    }
    
    const firestoreDoc = firestoreQuery.docs[0];
    const correctUid = firestoreDoc.id;
    console.log(`   ✓ Documento encontrado con ID: ${correctUid}`);
    
    // 3. Eliminar el usuario actual de Auth
    console.log('\n3️⃣ Eliminando usuario actual de Auth...');
    await auth.deleteUser(oldAuthUser.uid);
    console.log(`   ✓ Usuario eliminado`);
    
    // 4. Crear nuevo usuario con el UID correcto
    console.log('\n4️⃣ Creando nuevo usuario con UID correcto...');
    const newAuthUser = await auth.createUser({
      uid: correctUid,
      email: email,
      password: password,
      displayName: 'Juan Pérez',
      disabled: false
    });
    console.log(`   ✓ Usuario creado con UID: ${newAuthUser.uid}`);
    
    // 5. Verificar que coincidan
    console.log('\n5️⃣ Verificando...');
    if (newAuthUser.uid === correctUid) {
      console.log('   ✅ UIDs COINCIDEN correctamente!');
      console.log(`   📧 Email: ${email}`);
      console.log(`   🔑 Password: ${password}`);
      console.log(`   🆔 UID: ${correctUid}`);
    } else {
      console.log('   ❌ Error: UIDs no coinciden');
    }
    
    console.log('\n✅ Arreglo completado exitosamente\n');
    
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
  
  process.exit(0);
}

fixJuanUid();
