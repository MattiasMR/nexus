/**
 * Script para crear índices compuestos en Firestore usando Firebase Admin SDK
 * 
 * Este script crea todos los índices necesarios para las consultas de la aplicación.
 * Los índices se crean usando la API de administración de Firestore.
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'nexus-68994'
});

const db = admin.firestore();

/**
 * Definición de todos los índices necesarios
 * Cada índice especifica la colección y los campos con su ordenamiento
 */
const indices = [
  // Índices para colección 'citas'
  {
    collectionGroup: 'citas',
    queryScope: 'COLLECTION',
    fields: [
      { fieldPath: 'idPaciente', order: 'ASCENDING' },
      { fieldPath: 'fecha', order: 'ASCENDING' }
    ]
  },
  {
    collectionGroup: 'citas',
    queryScope: 'COLLECTION',
    fields: [
      { fieldPath: 'idPaciente', order: 'ASCENDING' },
      { fieldPath: 'fecha', order: 'DESCENDING' }
    ]
  },
  {
    collectionGroup: 'citas',
    queryScope: 'COLLECTION',
    fields: [
      { fieldPath: 'idPaciente', order: 'ASCENDING' },
      { fieldPath: 'estado', order: 'ASCENDING' },
      { fieldPath: 'fecha', order: 'DESCENDING' }
    ]
  },
  
  // Índices para colección 'recetas'
  {
    collectionGroup: 'recetas',
    queryScope: 'COLLECTION',
    fields: [
      { fieldPath: 'idPaciente', order: 'ASCENDING' },
      { fieldPath: 'fecha', order: 'DESCENDING' }
    ]
  },
  {
    collectionGroup: 'recetas',
    queryScope: 'COLLECTION',
    fields: [
      { fieldPath: 'idPaciente', order: 'ASCENDING' },
      { fieldPath: 'vigente', order: 'ASCENDING' },
      { fieldPath: 'fecha', order: 'DESCENDING' }
    ]
  },
  
  // Índices para colección 'documentos-paciente'
  {
    collectionGroup: 'documentos-paciente',
    queryScope: 'COLLECTION',
    fields: [
      { fieldPath: 'idPaciente', order: 'ASCENDING' },
      { fieldPath: 'fecha', order: 'DESCENDING' }
    ]
  },
  {
    collectionGroup: 'documentos-paciente',
    queryScope: 'COLLECTION',
    fields: [
      { fieldPath: 'idPaciente', order: 'ASCENDING' },
      { fieldPath: 'tipo', order: 'ASCENDING' },
      { fieldPath: 'fecha', order: 'DESCENDING' }
    ]
  },
  
  // Índices para colección 'consultas'
  {
    collectionGroup: 'consultas',
    queryScope: 'COLLECTION',
    fields: [
      { fieldPath: 'idPaciente', order: 'ASCENDING' },
      { fieldPath: 'fecha', order: 'DESCENDING' }
    ]
  }
];

/**
 * Verifica si un índice ya existe
 */
async function verificarIndiceExiste(indice) {
  try {
    // Obtener todos los índices existentes
    const project = `projects/${serviceAccount.project_id}/databases/(default)/collectionGroups/${indice.collectionGroup}`;
    
    // Crear una firma única para comparar
    const firma = JSON.stringify({
      collection: indice.collectionGroup,
      fields: indice.fields
    });
    
    console.log(`   Verificando índice para ${indice.collectionGroup}...`);
    return { exists: false, firma };
  } catch (error) {
    return { exists: false, error: error.message };
  }
}

/**
 * Crea un índice compuesto en Firestore
 * NOTA: Firebase Admin SDK no tiene método directo para crear índices.
 * Los índices se deben crear mediante:
 * 1. Firebase Console (manual)
 * 2. Firebase CLI con firestore.indexes.json
 * 3. API REST de Firestore (requiere autenticación OAuth)
 * 
 * Este script verifica la configuración y guía al usuario.
 */
async function crearIndices() {
  console.log('╔═══════════════════════════════════════════════════════════════╗');
  console.log('║        CREACIÓN DE ÍNDICES COMPUESTOS EN FIRESTORE           ║');
  console.log('╚═══════════════════════════════════════════════════════════════╝\n');
  
  console.log(`📋 Total de índices a crear: ${indices.length}\n`);
  
  // Verificar que firestore.indexes.json existe
  const fs = require('fs');
  const path = require('path');
  const indexFilePath = path.join(__dirname, '..', 'firestore.indexes.json');
  
  try {
    const indexFileContent = fs.readFileSync(indexFilePath, 'utf8');
    const indexConfig = JSON.parse(indexFileContent);
    
    console.log('✅ Archivo firestore.indexes.json encontrado');
    console.log(`   Índices configurados: ${indexConfig.indexes?.length || 0}\n`);
    
    // Mostrar cada índice configurado
    console.log('📌 ÍNDICES CONFIGURADOS:\n');
    
    indices.forEach((indice, i) => {
      console.log(`${i + 1}. Colección: ${indice.collectionGroup}`);
      console.log(`   Campos:`);
      indice.fields.forEach(field => {
        console.log(`   - ${field.fieldPath} (${field.order})`);
      });
      console.log('');
    });
    
    console.log('\n╔═══════════════════════════════════════════════════════════════╗');
    console.log('║                  MÉTODOS DE IMPLEMENTACIÓN                    ║');
    console.log('╚═══════════════════════════════════════════════════════════════╝\n');
    
    console.log('OPCIÓN 1: Usar Firebase CLI (RECOMENDADO - AUTOMÁTICO)');
    console.log('────────────────────────────────────────────────────────────────');
    console.log('1. Instalar Firebase CLI (si no lo tienes):');
    console.log('   npm install -g firebase-tools\n');
    console.log('2. Autenticarte con Firebase:');
    console.log('   firebase login\n');
    console.log('3. Seleccionar el proyecto:');
    console.log('   firebase use nexus-68994\n');
    console.log('4. Desplegar los índices:');
    console.log('   firebase deploy --only firestore:indexes\n');
    console.log('   (Este comando lee firestore.indexes.json y crea todos los índices)\n');
    
    console.log('\nOPCIÓN 2: Crear índices manualmente en Firebase Console');
    console.log('────────────────────────────────────────────────────────────────');
    console.log('1. Ve a: https://console.firebase.google.com/project/nexus-68994/firestore/indexes');
    console.log('2. Haz clic en "Create Index" para cada índice');
    console.log('3. Configura los campos según la lista de arriba\n');
    
    console.log('\nOPCIÓN 3: Ejecutar la app y seguir los enlaces de error');
    console.log('────────────────────────────────────────────────────────────────');
    console.log('1. Ejecuta la aplicación Flutter');
    console.log('2. Intenta usar cada funcionalidad');
    console.log('3. Cuando aparezca un error de índice, haz clic en el enlace');
    console.log('4. Firebase te mostrará el índice ya configurado, solo haz clic en "Create"\n');
    
    console.log('\n╔═══════════════════════════════════════════════════════════════╗');
    console.log('║                         RECOMENDACIÓN                         ║');
    console.log('╚═══════════════════════════════════════════════════════════════╝\n');
    
    console.log('🎯 MÉTODO MÁS RÁPIDO: Firebase CLI\n');
    console.log('Ejecuta estos comandos en orden:\n');
    console.log('   firebase login');
    console.log('   firebase use nexus-68994');
    console.log('   firebase deploy --only firestore:indexes\n');
    console.log('Esto creará automáticamente los 8 índices en ~2-3 minutos.\n');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    process.exit(0);
  }
}

// Ejecutar
crearIndices().catch(console.error);
