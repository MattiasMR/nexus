/**
 * Script para crear índices de Firestore usando Admin SDK
 * Ejecutar: node scripts/create-indexes.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const projectId = serviceAccount.project_id;

console.log('🔥 Creando índices de Firestore...\n');
console.log('📝 IMPORTANTE: Los índices deben crearse manualmente en Firebase Console');
console.log('   O usando Firebase CLI: firebase deploy --only firestore:indexes\n');

console.log('🔗 Links directos para crear índices:\n');

const indexes = [
  {
    name: 'Citas - Próximas (idPaciente + fecha ASC)',
    collection: 'citas',
    fields: 'idPaciente,fecha',
    url: `https://console.firebase.google.com/v1/r/project/${projectId}/firestore/indexes?create_composite=ClFwcm9qZWN0cy8ke3Byb2plY3RJZH0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2NpdGFzL2luZGV4ZXMvXxABGgwKCGlkUGFjaWVudGUQARoJCgVmZWNoYRABGgwKCF9fbmFtZV9fEAE`
  },
  {
    name: 'Citas - Pasadas (idPaciente + fecha DESC)',
    collection: 'citas', 
    fields: 'idPaciente,fecha DESC',
    url: `https://console.firebase.google.com/v1/r/project/${projectId}/firestore/indexes?create_composite=ClFwcm9qZWN0cy8ke3Byb2plY3RJZH0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2NpdGFzL2luZGV4ZXMvXxABGgwKCGlkUGFjaWVudGUQARoJCgVmZWNoYRAC`
  },
  {
    name: 'Citas - Por Estado (idPaciente + estado + fecha DESC)',
    collection: 'citas',
    fields: 'idPaciente,estado,fecha DESC',
    url: `https://console.firebase.google.com/v1/r/project/${projectId}/firestore/indexes?create_composite=ClVwcm9qZWN0cy8ke3Byb2plY3RJZH0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2NpdGFzL2luZGV4ZXMvXxABGgwKCGlkUGFjaWVudGUQARoKCgZlc3RhZG8QARoJCgVmZWNoYRAC`
  },
  {
    name: 'Recetas - Todas (idPaciente + fecha DESC)',
    collection: 'recetas',
    fields: 'idPaciente,fecha DESC',
    url: `https://console.firebase.google.com/v1/r/project/${projectId}/firestore/indexes?create_composite=ClNwcm9qZWN0cy8ke3Byb2plY3RJZH0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3JlY2V0YXMvaW5kZXhlcy9fEAEaDAoIaWRQYWNpZW50ZRABGgkKBWZlY2hhEAI`
  },
  {
    name: 'Recetas - Vigentes (idPaciente + vigente + fecha DESC)',
    collection: 'recetas',
    fields: 'idPaciente,vigente,fecha DESC',
    url: `https://console.firebase.google.com/v1/r/project/${projectId}/firestore/indexes?create_composite=ClZwcm9qZWN0cy8ke3Byb2plY3RJZH0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3JlY2V0YXMvaW5kZXhlcy9fEAEaDAoIaWRQYWNpZW50ZRABGgsKB3ZpZ2VudGUQARoJCgVmZWNoYRAC`
  },
  {
    name: 'Documentos - Todos (idPaciente + fecha DESC)',
    collection: 'documentos-paciente',
    fields: 'idPaciente,fecha DESC',
    url: `https://console.firebase.google.com/v1/r/project/${projectId}/firestore/indexes?create_composite=Cl5wcm9qZWN0cy8ke3Byb2plY3RJZH0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2RvY3VtZW50b3MtcGFjaWVudGUvaW5kZXhlcy9fEAEaDAoIaWRQYWNpZW50ZRABGgkKBWZlY2hhEAI`
  },
  {
    name: 'Documentos - Por Tipo (idPaciente + tipo + fecha DESC)',
    collection: 'documentos-paciente',
    fields: 'idPaciente,tipo,fecha DESC',
    url: `https://console.firebase.google.com/v1/r/project/${projectId}/firestore/indexes?create_composite=CmFwcm9qZWN0cy8ke3Byb2plY3RJZH0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2RvY3VtZW50b3MtcGFjaWVudGUvaW5kZXhlcy9fEAEaDAoIaWRQYWNpZW50ZRABGgkKBXRpcG8QARoJCgVmZWNoYRAC`
  },
  {
    name: 'Consultas (idPaciente + fecha DESC)',
    collection: 'consultas',
    fields: 'idPaciente,fecha DESC',
    url: `https://console.firebase.google.com/v1/r/project/${projectId}/firestore/indexes?create_composite=ClZwcm9qZWN0cy8ke3Byb2plY3RJZH0vZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2NvbnN1bHRhcy9pbmRleGVzL18QARoMCghpZFBhY2llbnRlEAEaCQoFZmVjaGEQAg`
  }
];

indexes.forEach((index, i) => {
  console.log(`${i + 1}. ${index.name}`);
  console.log(`   Collection: ${index.collection}`);
  console.log(`   Fields: ${index.fields}`);
  console.log(`   ${index.url}\n`);
});

console.log('\n📋 INSTRUCCIONES:');
console.log('1. Copia y pega cada URL en tu navegador');
console.log('2. Haz clic en "CREATE INDEX" en cada página');
console.log('3. Espera 2-3 minutos para que los índices se creen');
console.log('4. Ejecuta: node scripts/seed-juan-perez.js\n');

console.log('💡 TIP: También puedes usar Firebase CLI:');
console.log('   firebase login');
console.log('   firebase use nexus-68994');
console.log('   firebase deploy --only firestore:indexes\n');
