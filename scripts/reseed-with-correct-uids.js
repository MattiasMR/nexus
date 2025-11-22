/**
 * Script para RE-SEMBRAR datos usando los UIDs correctos de Firebase Auth
 * Ejecutar: node scripts/reseed-with-correct-uids.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializar Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();
const auth = admin.auth();
const Timestamp = admin.firestore.Timestamp;

// Obtener UIDs de los usuarios de Auth
const USUARIOS = [
  'juan.perez@email.com',
  'maria.torres@email.com',
  'pedro.ramirez@email.com',
  'carmen.munoz@email.com',
  'daniela.soto@email.com'
];

async function getAuthUids() {
  const uids = {};
  for (const email of USUARIOS) {
    try {
      const user = await auth.getUserByEmail(email);
      uids[email] = user.uid;
    } catch (error) {
      console.error(`Error obteniendo UID para ${email}:`, error.message);
    }
  }
  return uids;
}

async function reseedData() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   RE-SEMBRANDO DATOS CON UIDs CORRECTOS        ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  // 1. Obtener UIDs
  console.log('🔑 Obteniendo UIDs de Firebase Auth...');
  const uids = await getAuthUids();
  console.log('   ✓ UIDs obtenidos:', Object.keys(uids).length);

  // 2. Limpiar datos existentes de pacientes
  console.log('\n🧹 Limpiando datos existentes...');
  
  // Eliminar documentos
  const documentosSnap = await db.collection('documentos').get();
  for (const doc of documentosSnap.docs) {
    await doc.ref.delete();
  }
  console.log(`   ✓ ${documentosSnap.size} documentos eliminados`);

  // Eliminar recetas
  const recetasSnap = await db.collection('recetas').get();
  for (const doc of recetasSnap.docs) {
    await doc.ref.delete();
  }
  console.log(`   ✓ ${recetasSnap.size} recetas eliminadas`);

  // Eliminar consultas
  const consultasSnap = await db.collection('consultas').get();
  for (const doc of consultasSnap.docs) {
    await doc.ref.delete();
  }
  console.log(`   ✓ ${consultasSnap.size} consultas eliminadas`);

  // Eliminar citas
  const citasSnap = await db.collection('citas').get();
  for (const doc of citasSnap.docs) {
    await doc.ref.delete();
  }
  console.log(`   ✓ ${citasSnap.size} citas eliminadas`);

  // 3. Crear documentos para cada paciente
  console.log('\n📄 Creando documentos...');
  const now = Timestamp.now();
  let docsCreated = 0;

  const pdfUrls = [
    'https://pdfobject.com/pdf/sample.pdf',
    'https://www.orimi.com/pdf-test.pdf',
    'https://file-examples.com/storage/fe783a26a44778d83097a32/2017/10/file-sample_150kB.pdf',
    'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf'
  ];

  for (const [email, uid] of Object.entries(uids)) {
    const pacienteSnap = await db.collection('pacientes').doc(uid).get();
    
    if (!pacienteSnap.exists) {
      console.log(`   ⚠️  Paciente ${email} no existe en Firestore`);
      continue;
    }

    const paciente = pacienteSnap.data();
    
    // Crear 3-4 documentos por paciente
    const numDocs = 3 + Math.floor(Math.random() * 2);
    for (let i = 0; i < numDocs; i++) {
      await db.collection('documentos').add({
        idPaciente: uid,
        titulo: `Documento ${i + 1} - ${paciente.nombre}`,
        tipo: ['resultado_examen', 'informe_medico', 'certificado', 'otro'][Math.floor(Math.random() * 4)],
        descripcion: `Documento de prueba ${i + 1} para ${paciente.nombreCompleto || paciente.nombre + ' ' + paciente.apellido}`,
        url: pdfUrls[i % pdfUrls.length],
        nombreArchivo: `documento_${i + 1}.pdf`,
        fecha: Timestamp.fromDate(new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000)),
        createdAt: now,
        updatedAt: now
      });
      docsCreated++;
    }
    
    console.log(`   ✓ ${numDocs} documentos para ${email}`);
  }
  
  console.log(`\n✅ Total documentos creados: ${docsCreated}`);

  // 4. Crear recetas para cada paciente
  console.log('\n💊 Creando recetas...');
  let recetasCreated = 0;

  const medicamentos = [
    { nombre: 'Paracetamol', concentracion: '500mg', dosis: '1 comprimido cada 8 horas' },
    { nombre: 'Ibuprofeno', concentracion: '400mg', dosis: '1 comprimido cada 12 horas' },
    { nombre: 'Amoxicilina', concentracion: '500mg', dosis: '1 cápsula cada 8 horas' },
    { nombre: 'Omeprazol', concentracion: '20mg', dosis: '1 cápsula en ayunas' }
  ];

  for (const [email, uid] of Object.entries(uids)) {
    const pacienteSnap = await db.collection('pacientes').doc(uid).get();
    
    if (!pacienteSnap.exists) continue;

    const paciente = pacienteSnap.data();
    
    // Crear 2-3 recetas por paciente
    const numRecetas = 2 + Math.floor(Math.random() * 2);
    for (let i = 0; i < numRecetas; i++) {
      const med = medicamentos[i % medicamentos.length];
      const fechaEmision = new Date(Date.now() - Math.random() * 60 * 24 * 60 * 60 * 1000);
      
      await db.collection('recetas').add({
        idPaciente: uid,
        nombrePaciente: paciente.nombreCompleto || `${paciente.nombre} ${paciente.apellido}`,
        rutPaciente: paciente.rut,
        nombreMedico: 'Dr. Carlos Rodríguez',
        especialidadMedico: 'Medicina General',
        fechaEmision: Timestamp.fromDate(fechaEmision),
        validoHasta: Timestamp.fromDate(new Date(fechaEmision.getTime() + 30 * 24 * 60 * 60 * 1000)),
        medicamentos: [
          {
            nombreComercial: med.nombre,
            nombreGenerico: med.nombre,
            concentracion: med.concentracion,
            cantidad: '10',
            dosis: med.dosis,
            duracion: '10 días'
          }
        ],
        diagnostico: 'Control médico rutinario',
        indicaciones: 'Tomar según indicaciones. No suspender tratamiento.',
        estado: Math.random() > 0.3 ? 'activa' : 'vencida',
        createdAt: now,
        updatedAt: now
      });
      recetasCreated++;
    }
    
    console.log(`   ✓ ${numRecetas} recetas para ${email}`);
  }
  
  console.log(`\n✅ Total recetas creadas: ${recetasCreated}`);

  // 5. Crear consultas para cada paciente
  console.log('\n🏥 Creando consultas...');
  let consultasCreated = 0;

  for (const [email, uid] of Object.entries(uids)) {
    const pacienteSnap = await db.collection('pacientes').doc(uid).get();
    
    if (!pacienteSnap.exists) continue;

    const paciente = pacienteSnap.data();
    
    // Crear 3-5 consultas por paciente
    const numConsultas = 3 + Math.floor(Math.random() * 3);
    for (let i = 0; i < numConsultas; i++) {
      const fechaConsulta = new Date(Date.now() - Math.random() * 180 * 24 * 60 * 60 * 1000);
      
      await db.collection('consultas').add({
        idPaciente: uid,
        nombrePaciente: paciente.nombreCompleto || `${paciente.nombre} ${paciente.apellido}`,
        idProfesional: 'prof_001',
        nombreProfesional: 'Dr. Carlos Rodríguez',
        especialidad: 'Medicina General',
        fecha: Timestamp.fromDate(fechaConsulta),
        motivo: ['Control rutinario', 'Dolor abdominal', 'Consulta de urgencia', 'Seguimiento tratamiento'][i % 4],
        diagnostico: ['Paciente estable', 'Gastritis leve', 'Cuadro viral', 'Evolución favorable'][i % 4],
        tratamiento: 'Medicación según receta',
        observaciones: 'Controlar en 30 días',
        estado: 'completada',
        createdAt: now,
        updatedAt: now
      });
      consultasCreated++;
    }
    
    console.log(`   ✓ ${numConsultas} consultas para ${email}`);
  }
  
  console.log(`\n✅ Total consultas creadas: ${consultasCreated}`);

  // 6. Crear citas para cada paciente
  console.log('\n📅 Creando citas...');
  let citasCreated = 0;

  const especialidades = ['Medicina General', 'Cardiología', 'Traumatología', 'Dermatología'];
  const medicos = ['Dr. Carlos Rodríguez', 'Dra. Ana Martínez', 'Dr. Roberto Silva', 'Dra. Patricia Fernández'];

  for (const [email, uid] of Object.entries(uids)) {
    const pacienteSnap = await db.collection('pacientes').doc(uid).get();
    
    if (!pacienteSnap.exists) continue;

    const paciente = pacienteSnap.data();
    
    // Crear 2-3 citas por paciente
    const numCitas = 2 + Math.floor(Math.random() * 2);
    for (let i = 0; i < numCitas; i++) {
      const medicoIdx = i % medicos.length;
      const diasFuturos = 7 + Math.floor(Math.random() * 60); // Entre 7 y 67 días en el futuro
      const fechaCita = new Date(Date.now() + diasFuturos * 24 * 60 * 60 * 1000);
      
      // Establecer hora de la cita (entre 9:00 y 17:00)
      const hora = 9 + Math.floor(Math.random() * 9);
      const minutos = [0, 30][Math.floor(Math.random() * 2)];
      fechaCita.setHours(hora, minutos, 0, 0);
      
      await db.collection('citas').add({
        idPaciente: uid,
        nombrePaciente: paciente.nombreCompleto || `${paciente.nombre} ${paciente.apellido}`,
        rutPaciente: paciente.rut,
        emailPaciente: paciente.email,
        telefonoPaciente: paciente.telefono,
        idProfesional: `prof_${medicoIdx + 1}`,
        nombreProfesional: medicos[medicoIdx],
        especialidad: especialidades[medicoIdx],
        fechaHora: Timestamp.fromDate(fechaCita),
        fecha: Timestamp.fromDate(fechaCita), // Para compatibilidad con índices
        motivo: ['Control rutinario', 'Consulta de seguimiento', 'Primera consulta', 'Chequeo preventivo'][i % 4],
        estado: i === 0 ? 'confirmada' : 'pendiente', // Primera cita confirmada, resto pendientes
        duracionMinutos: 30,
        observaciones: 'Traer exámenes previos si los tiene',
        createdAt: now,
        updatedAt: now
      });
      citasCreated++;
    }
    
    console.log(`   ✓ ${numCitas} citas para ${email}`);
  }
  
  console.log(`\n✅ Total citas creadas: ${citasCreated}`);

  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   RESUMEN                                      ║');
  console.log('╚════════════════════════════════════════════════╝');
  console.log(`   📄 Documentos: ${docsCreated}`);
  console.log(`   💊 Recetas: ${recetasCreated}`);
  console.log(`   🏥 Consultas: ${consultasCreated}`);
  console.log(`   📅 Citas: ${citasCreated}`);
  console.log(`   👤 Pacientes: ${Object.keys(uids).length}`);
  console.log('\n✅ Re-sembrado completado exitosamente!\n');

  process.exit(0);
}

reseedData().catch(error => {
  console.error('\n❌ Error:', error);
  process.exit(1);
});
