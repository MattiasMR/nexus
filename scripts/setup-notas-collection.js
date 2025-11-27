/**
 * Script para configurar la colección 'notas' en Firestore
 * 
 * Este script:
 * 1. Verifica que la colección 'notas' exista
 * 2. Crea un documento de ejemplo si no hay datos
 * 3. Muestra instrucciones para crear los índices necesarios
 */

const admin = require('firebase-admin');
const path = require('path');

// Inicializar Firebase Admin
const serviceAccount = require(path.join(__dirname, '..', 'serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function setupNotasCollection() {
  console.log('🚀 Configurando colección de notas...\n');

  try {
    // 1. Verificar si ya existen notas
    const notasSnapshot = await db.collection('notas').limit(1).get();
    
    if (notasSnapshot.empty) {
      console.log('📝 No hay notas en la colección. Creando documento de ejemplo...\n');
      
      // Crear una nota de ejemplo
      const notaEjemplo = {
        idPaciente: 'Fh2byylkEBfJCxd2vD1P', // Juan Pérez
        idProfesional: 'system',
        contenido: 'Nota de ejemplo del sistema. Puede ser eliminada.',
        fecha: admin.firestore.Timestamp.now(),
        tipoAsociacion: 'general',
        createdAt: admin.firestore.Timestamp.now(),
        updatedAt: admin.firestore.Timestamp.now()
      };

      const docRef = await db.collection('notas').add(notaEjemplo);
      console.log(`✅ Nota de ejemplo creada con ID: ${docRef.id}\n`);
    } else {
      console.log(`✅ La colección 'notas' ya tiene ${notasSnapshot.size} documento(s)\n`);
    }

    // 2. Instrucciones para crear índices
    console.log('📋 ÍNDICES REQUERIDOS:');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    console.log('Para que las queries funcionen correctamente, debes crear estos índices compuestos:\n');
    
    console.log('1️⃣  ÍNDICE PRINCIPAL (idPaciente + fecha):');
    console.log('   Colección: notas');
    console.log('   Campos: idPaciente (Ascending), fecha (Descending)');
    console.log('   Query scope: Collection\n');
    
    console.log('2️⃣  ÍNDICE SECUNDARIO (idProfesional + fecha):');
    console.log('   Colección: notas');
    console.log('   Campos: idProfesional (Ascending), fecha (Descending)');
    console.log('   Query scope: Collection\n');

    console.log('📍 CÓMO CREAR LOS ÍNDICES:\n');
    console.log('Opción A - Desde el error en la consola:');
    console.log('  1. Ejecuta tu aplicación Ionic');
    console.log('  2. Intenta cargar las notas de un paciente');
    console.log('  3. Aparecerá un error con un enlace directo');
    console.log('  4. Haz clic en el enlace para crear el índice automáticamente\n');
    
    console.log('Opción B - Manualmente:');
    console.log('  1. Ve a Firebase Console: https://console.firebase.google.com');
    console.log('  2. Selecciona tu proyecto: nexus-68994');
    console.log('  3. Ve a Firestore Database > Indexes');
    console.log('  4. Haz clic en "Create Index"');
    console.log('  5. Configura cada índice según lo indicado arriba\n');

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    // 3. Verificar estructura de una nota
    const primeraNotaSnapshot = await db.collection('notas').limit(1).get();
    if (!primeraNotaSnapshot.empty) {
      const notaData = primeraNotaSnapshot.docs[0].data();
      console.log('📄 Estructura de nota en Firestore:');
      console.log(JSON.stringify(notaData, null, 2));
      console.log();
    }

    console.log('✅ Configuración completada!\n');
    console.log('💡 Recuerda: Los índices pueden tardar 1-2 minutos en construirse después de crearlos.\n');

  } catch (error) {
    console.error('❌ Error al configurar la colección de notas:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Ejecutar
setupNotasCollection();
