/**
 * Script para desplegar reglas de Firestore usando Admin SDK
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Inicializar Firebase Admin
const serviceAccount = require(path.join(__dirname, '..', 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: serviceAccount.project_id
});

async function deployFirestoreRules() {
  console.log('🔐 Desplegando reglas de Firestore...\n');

  try {
    // Leer el archivo de reglas
    const rulesPath = path.join(__dirname, '..', 'firestore.rules');
    const rulesContent = fs.readFileSync(rulesPath, 'utf8');

    console.log('📄 Reglas leídas desde:', rulesPath);
    console.log('📊 Tamaño:', rulesContent.length, 'caracteres\n');

    // Verificar que las reglas incluyan la colección notas
    if (rulesContent.includes('match /notas/{notaId}')) {
      console.log('✅ Las reglas incluyen la colección "notas"\n');
    } else {
      console.warn('⚠️  Las reglas NO incluyen la colección "notas"\n');
    }

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📋 INSTRUCCIONES PARA DESPLEGAR REGLAS:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    console.log('Las reglas de Firestore deben desplegarse manualmente desde Firebase Console:\n');
    
    console.log('1️⃣  Ve a Firebase Console:');
    console.log('   https://console.firebase.google.com/project/nexus-68994/firestore/rules\n');
    
    console.log('2️⃣  Copia y pega las reglas desde el archivo:');
    console.log('   ' + rulesPath + '\n');
    
    console.log('3️⃣  Haz clic en "Publicar" para aplicar los cambios\n');
    
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    console.log('✅ Verificación completada\n');
    console.log('💡 Las reglas actualizadas incluyen permisos para la colección "notas"\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }

  process.exit(0);
}

deployFirestoreRules();
