/**
 * Script para poblar Firebase con datos de prueba para Juan Pérez
 * y crear todos los índices necesarios
 * 
 * Ejecutar: node scripts/seed-juan-perez.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'nexus-68994.appspot.com'
});

const db = admin.firestore();
const auth = admin.auth();

// ID de Juan Pérez (debes obtenerlo de Firebase Auth)
const JUAN_PEREZ_UID = 'REEMPLAZAR_CON_UID_REAL'; // Se obtendrá del email

async function main() {
  try {
    console.log('🚀 Iniciando población de datos para Juan Pérez...\n');

    // 1. Obtener UID de Juan Pérez directamente
    const juanPerezUID = '0vOsxL0aqPVetqnr6ZoK5SgiOig2'; // juan.perez@email.com
    console.log(`✅ Juan Pérez UID: ${juanPerezUID}\n`);

    // 2. Crear o actualizar usuario en Firestore
    await crearUsuarioFirestore(juanPerezUID);

    // 3. Crear Ficha Médica
    await crearFichaMedica(juanPerezUID);

    // 4. Crear Citas
    await crearCitas(juanPerezUID);

    // 5. Crear Recetas
    await crearRecetas(juanPerezUID);

    // 6. Crear Documentos
    await crearDocumentos(juanPerezUID);

    // 7. Crear Consultas
    await crearConsultas(juanPerezUID);

    console.log('\n✅ ¡Población de datos completada exitosamente!');
    console.log('\n📋 IMPORTANTE: Verifica los índices en Firebase Console:');
    console.log('https://console.firebase.google.com/project/nexus-68994/firestore/indexes\n');
    
    console.log('📝 Índices necesarios:');
    console.log('1. citas: idPaciente (Ascending) + estado (Ascending) + fecha (Descending)');
    console.log('2. citas: idPaciente (Ascending) + fecha (Ascending)');
    console.log('3. citas: idPaciente (Ascending) + fecha (Descending)');
    console.log('4. recetas: idPaciente (Ascending) + vigente (Ascending) + fecha (Descending)');
    console.log('5. documentos-paciente: idPaciente (Ascending) + fecha (Descending)');
    console.log('6. documentos-paciente: idPaciente (Ascending) + tipo (Ascending) + fecha (Descending)');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

async function getJuanPerezUID() {
  try {
    // Primero intentar obtener de Firebase Auth
    const user = await auth.getUserByEmail('juan.perez@example.com');
    return user.uid;
  } catch (error) {
    console.log('⚠️  Usuario no encontrado en Auth, buscando en Firestore...');
    
    // Buscar en colección usuarios
    const usuarios = await db.collection('usuarios')
      .where('email', '==', 'juan.perez@example.com')
      .limit(1)
      .get();
    
    if (!usuarios.empty) {
      return usuarios.docs[0].id;
    }

    // Si no existe, buscar cualquier usuario con nombre Juan
    console.log('⚠️  Buscando cualquier usuario llamado Juan...');
    const juanes = await db.collection('usuarios')
      .where('nombre', '==', 'Juan')
      .limit(1)
      .get();
    
    if (!juanes.empty) {
      const usuario = juanes.docs[0];
      console.log(`✅ Encontrado: ${usuario.data().nombre} ${usuario.data().apellido} (${usuario.data().email})`);
      return usuario.id;
    }

    // Si aún no existe, obtener el primer usuario
    console.log('⚠️  Obteniendo primer usuario disponible...');
    const primerUsuario = await db.collection('usuarios')
      .limit(1)
      .get();
    
    if (!primerUsuario.empty) {
      const usuario = primerUsuario.docs[0];
      console.log(`✅ Usando: ${usuario.data().nombre} ${usuario.data().apellido} (${usuario.data().email})`);
      return usuario.id;
    }

    throw new Error('No se encontró ningún usuario en la base de datos. Por favor, crea un usuario primero.');
  }
}

async function crearUsuarioFirestore(pacienteId) {
  console.log('👤 Creando/Actualizando usuario en Firestore...');
  
  const usuario = {
    id: pacienteId,
    email: 'juan.perez@email.com',
    nombre: 'Juan',
    apellido: 'Pérez',
    rut: '12.345.678-9',
    telefono: '+56912345678',
    activo: true,
    direccion: 'Av. Libertador 1234, Santiago',
    fechaNacimiento: '1985-03-15',
    sexo: 'M',
    prevision: 'Fonasa',
    contactoEmergencia: 'María Pérez',
    telefonoEmergencia: '+56987654321',
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now()
  };

  await db.collection('usuarios').doc(pacienteId).set(usuario, { merge: true });
  console.log('  ✓ Usuario creado/actualizado en Firestore');
}

async function crearFichaMedica(pacienteId) {
  console.log('📋 Creando Ficha Médica...');
  
  const fichaMedica = {
    idPaciente: pacienteId,
    grupoSanguineo: 'O+',
    alergias: ['Penicilina', 'Polen'],
    enfermedadesCronicas: ['Hipertensión'],
    antecedentesQuirurgicos: [
      {
        procedimiento: 'Apendicectomía',
        fecha: admin.firestore.Timestamp.fromDate(new Date('2015-03-15')),
        hospital: 'Hospital Central'
      }
    ],
    antecedentesFamiliares: [
      {
        familiar: 'Padre',
        enfermedad: 'Diabetes tipo 2',
        edad: 65
      }
    ],
    medicamentosActuales: [
      {
        nombre: 'Losartán 50mg',
        dosis: '1 comprimido al día',
        inicio: admin.firestore.Timestamp.fromDate(new Date('2023-01-01'))
      }
    ],
    vacunas: [
      {
        nombre: 'COVID-19',
        fecha: admin.firestore.Timestamp.fromDate(new Date('2024-06-15')),
        dosis: '3ra dosis'
      }
    ],
    ultimaConsulta: admin.firestore.Timestamp.fromDate(new Date('2024-11-10')),
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now()
  };

  await db.collection('fichas-medicas').doc(pacienteId).set(fichaMedica);
  console.log('  ✓ Ficha médica creada');
}

async function crearCitas(pacienteId) {
  console.log('📅 Creando Citas...');
  
  const citas = [
    {
      idPaciente: pacienteId,
      idProfesional: 'dr-maria-gonzalez',
      nombreProfesional: 'Dra. María González',
      especialidad: 'Cardiología',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-11-25T10:00:00')),
      duracion: 30,
      estado: 'confirmada',
      motivo: 'Control de presión arterial',
      modalidad: 'presencial',
      ubicacion: 'Consultorio 302, Piso 3',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      idPaciente: pacienteId,
      idProfesional: 'dr-carlos-rodriguez',
      nombreProfesional: 'Dr. Carlos Rodríguez',
      especialidad: 'Medicina General',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-12-05T15:30:00')),
      duracion: 20,
      estado: 'pendiente',
      motivo: 'Chequeo anual',
      modalidad: 'presencial',
      ubicacion: 'Consultorio 105, Piso 1',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      idPaciente: pacienteId,
      idProfesional: 'dr-maria-gonzalez',
      nombreProfesional: 'Dra. María González',
      especialidad: 'Cardiología',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-10-15T11:00:00')),
      duracion: 30,
      estado: 'completada',
      motivo: 'Control mensual',
      modalidad: 'presencial',
      ubicacion: 'Consultorio 302, Piso 3',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    }
  ];

  for (const cita of citas) {
    await db.collection('citas').add(cita);
  }
  console.log(`  ✓ ${citas.length} citas creadas`);
}

async function crearRecetas(pacienteId) {
  console.log('💊 Creando Recetas...');
  
  const recetas = [
    {
      idPaciente: pacienteId,
      idProfesional: 'dr-maria-gonzalez',
      nombreProfesional: 'Dra. María González',
      especialidadProfesional: 'Cardiología',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-11-10')),
      vigente: true,
      medicamentos: [
        {
          idMedicamento: 'med-losartan',
          nombreMedicamento: 'Losartán 50mg',
          dosis: '1 comprimido',
          frecuencia: 'cada 24 horas',
          duracion: '30 días',
          indicaciones: 'Tomar en ayunas'
        },
        {
          idMedicamento: 'med-aspirina',
          nombreMedicamento: 'Aspirina 100mg',
          dosis: '1 comprimido',
          frecuencia: 'cada 24 horas',
          duracion: '30 días',
          indicaciones: 'Tomar después de la cena'
        }
      ],
      observaciones: 'Controlar presión arterial semanalmente',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      idPaciente: pacienteId,
      idProfesional: 'dr-carlos-rodriguez',
      nombreProfesional: 'Dr. Carlos Rodríguez',
      especialidadProfesional: 'Medicina General',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-09-15')),
      vigente: false,
      medicamentos: [
        {
          idMedicamento: 'med-ibuprofeno',
          nombreMedicamento: 'Ibuprofeno 400mg',
          dosis: '1 comprimido',
          frecuencia: 'cada 8 horas',
          duracion: '5 días',
          indicaciones: 'Tomar con alimentos'
        }
      ],
      observaciones: 'Tratamiento para dolor muscular',
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    }
  ];

  for (const receta of recetas) {
    await db.collection('recetas').add(receta);
  }
  console.log(`  ✓ ${recetas.length} recetas creadas`);
}

async function crearDocumentos(pacienteId) {
  console.log('📄 Creando Documentos...');
  
  const documentos = [
    {
      idPaciente: pacienteId,
      nombre: 'Examen de Sangre - Hemograma Completo',
      tipo: 'examen',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-11-05')),
      url: null,
      storagePath: null,
      tamanio: 245000,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      idPaciente: pacienteId,
      nombre: 'Electrocardiograma',
      tipo: 'examen',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-10-20')),
      url: null,
      storagePath: null,
      tamanio: 180000,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      idPaciente: pacienteId,
      nombre: 'Radiografía de Tórax',
      tipo: 'imagen',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-09-10')),
      url: null,
      storagePath: null,
      tamanio: 2500000,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      idPaciente: pacienteId,
      nombre: 'Informe Cardiológico',
      tipo: 'informe',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-10-15')),
      url: null,
      storagePath: null,
      tamanio: 450000,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    }
  ];

  for (const documento of documentos) {
    await db.collection('documentos-paciente').add(documento);
  }
  console.log(`  ✓ ${documentos.length} documentos creados`);
}

async function crearConsultas(pacienteId) {
  console.log('🏥 Creando Consultas...');
  
  const consultas = [
    {
      idPaciente: pacienteId,
      idProfesional: 'dr-maria-gonzalez',
      nombreProfesional: 'Dra. María González',
      especialidad: 'Cardiología',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-11-10T10:00:00')),
      motivo: 'Control de hipertensión',
      diagnosticoPrincipal: 'Hipertensión arterial esencial',
      diagnosticosSecundarios: [],
      sintomas: ['Dolor de cabeza ocasional', 'Fatiga leve'],
      examenFisico: {
        presionArterial: '140/90 mmHg',
        frecuenciaCardiaca: '78 bpm',
        temperatura: '36.5°C',
        peso: '82 kg',
        altura: '175 cm'
      },
      tratamiento: 'Continuar con Losartán 50mg diario',
      observaciones: 'Paciente estable, presión arterial controlada',
      proximoControl: admin.firestore.Timestamp.fromDate(new Date('2024-12-10')),
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    },
    {
      idPaciente: pacienteId,
      idProfesional: 'dr-carlos-rodriguez',
      nombreProfesional: 'Dr. Carlos Rodríguez',
      especialidad: 'Medicina General',
      fecha: admin.firestore.Timestamp.fromDate(new Date('2024-09-15T15:00:00')),
      motivo: 'Dolor muscular',
      diagnosticoPrincipal: 'Mialgia',
      diagnosticosSecundarios: [],
      sintomas: ['Dolor lumbar', 'Rigidez muscular'],
      examenFisico: {
        presionArterial: '135/85 mmHg',
        frecuenciaCardiaca: '72 bpm',
        temperatura: '36.8°C'
      },
      tratamiento: 'Ibuprofeno 400mg cada 8 horas por 5 días',
      observaciones: 'Dolor muscular por esfuerzo físico',
      proximoControl: null,
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now()
    }
  ];

  for (const consulta of consultas) {
    await db.collection('consultas').add(consulta);
  }
  console.log(`  ✓ ${consultas.length} consultas creadas`);
}

// Ejecutar
main();
