/**
 * Script simple para obtener el UID del usuario actual
 * y usarlo en el script de población
 * 
 * Ejecutar: node scripts/get-user-id.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function main() {
  try {
    console.log('🔍 Buscando usuarios en Firebase...\n');

    // Listar usuarios de Auth
    console.log('📋 Usuarios en Firebase Auth:');
    const listUsers = await auth.listUsers(10);
    
    if (listUsers.users.length === 0) {
      console.log('   ⚠️  No hay usuarios en Firebase Auth\n');
    } else {
      listUsers.users.forEach((user, i) => {
        console.log(`   ${i + 1}. ${user.email || 'Sin email'}`);
        console.log(`      UID: ${user.uid}`);
        console.log(`      Display Name: ${user.displayName || 'N/A'}\n`);
      });
    }

    // Listar usuarios de Firestore
    console.log('📋 Usuarios en Firestore (colección "usuarios"):');
    const usuarios = await db.collection('usuarios').limit(10).get();
    
    if (usuarios.empty) {
      console.log('   ⚠️  No hay usuarios en Firestore\n');
    } else {
      usuarios.docs.forEach((doc, i) => {
        const data = doc.data();
        console.log(`   ${i + 1}. ${data.nombre || 'Sin nombre'} ${data.apellido || ''}`);
        console.log(`      ID: ${doc.id}`);
        console.log(`      Email: ${data.email || 'N/A'}`);
        console.log(`      RUT: ${data.rut || 'N/A'}\n`);
      });
    }

    // Dar instrucciones
    console.log('\n📝 INSTRUCCIONES:');
    console.log('1. Si no ves ningún usuario arriba, inicia sesión en la app Flutter primero');
    console.log('2. Copia el UID o ID del usuario que quieres usar');
    console.log('3. Edita scripts/seed-juan-perez.js y reemplaza la línea 17:');
    console.log('   const JUAN_PEREZ_UID = "REEMPLAZAR_CON_UID_REAL";');
    console.log('4. Luego ejecuta: node scripts/seed-juan-perez.js\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

main();
