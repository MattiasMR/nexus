/**
 * Script para crear usuarios de Firebase Authentication para pacientes
 * Ejecutar: node scripts/create-auth-users.js
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

// Usuarios de autenticación a crear (pacientes del seed)
const USUARIOS_AUTH = [
  {
    email: 'juan.perez@email.com',
    password: 'password123',
    displayName: 'Juan Pérez'
  },
  {
    email: 'maria.torres@email.com',
    password: 'password123',
    displayName: 'María Torres'
  },
  {
    email: 'pedro.ramirez@email.com',
    password: 'password123',
    displayName: 'Pedro Ramírez'
  },
  {
    email: 'carmen.munoz@email.com',
    password: 'password123',
    displayName: 'Carmen Muñoz'
  },
  {
    email: 'daniela.soto@email.com',
    password: 'password123',
    displayName: 'Daniela Soto'
  }
];

async function createAuthUsers() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   CREANDO USUARIOS DE AUTENTICACIÓN           ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  let created = 0;
  let updated = 0;
  let errors = 0;

  for (const userData of USUARIOS_AUTH) {
    try {
      console.log(`\n👤 Procesando: ${userData.email}`);
      
      // Primero verificar si el paciente existe en Firestore
      const pacientesSnapshot = await db
        .collection('pacientes')
        .where('email', '==', userData.email)
        .limit(1)
        .get();

      if (pacientesSnapshot.empty) {
        console.log(`   ⚠️  Paciente no existe en Firestore, saltando...`);
        continue;
      }

      const pacienteDoc = pacientesSnapshot.docs[0];
      const pacienteId = pacienteDoc.id;
      
      let userRecord;
      
      try {
        // Intentar obtener el usuario existente
        userRecord = await auth.getUserByEmail(userData.email);
        console.log(`   ℹ️  Usuario ya existe en Auth`);
        
        // Actualizar la contraseña
        await auth.updateUser(userRecord.uid, {
          password: userData.password,
          displayName: userData.displayName,
          disabled: false
        });
        
        console.log(`   ✓ Contraseña actualizada`);
        updated++;
        
      } catch (error) {
        if (error.code === 'auth/user-not-found') {
          // Crear nuevo usuario con el UID del documento de Firestore
          userRecord = await auth.createUser({
            uid: pacienteId,
            email: userData.email,
            password: userData.password,
            displayName: userData.displayName,
            disabled: false
          });
          
          console.log(`   ✅ Usuario creado en Authentication`);
          created++;
        } else {
          throw error;
        }
      }

      // Actualizar el documento en Firestore con activo=true
      await db.collection('pacientes').doc(pacienteId).update({
        activo: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log(`   ✓ Paciente activado en Firestore`);
      console.log(`   📧 Email: ${userData.email}`);
      console.log(`   🔑 Password: ${userData.password}`);
      
    } catch (error) {
      console.error(`   ❌ Error: ${error.message}`);
      errors++;
    }
  }

  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   RESUMEN                                      ║');
  console.log('╚════════════════════════════════════════════════╝');
  console.log(`   ✅ Usuarios creados: ${created}`);
  console.log(`   🔄 Usuarios actualizados: ${updated}`);
  console.log(`   ❌ Errores: ${errors}`);
  console.log('\n📝 Credenciales de acceso:');
  console.log('   Email: juan.perez@email.com');
  console.log('   Password: password123\n');

  process.exit(0);
}

// Ejecutar
createAuthUsers().catch(error => {
  console.error('\n❌ Error fatal:', error);
  process.exit(1);
});
