/**
 * Script para poblar Firestore con PACIENTES de prueba
 * Compatible con la app Flutter para pacientes
 * 
 * Uso:
 *   node scripts/seed-pacientes.js
 * 
 * IMPORTANTE: 
 * - Primero crea los usuarios en Firebase Authentication Console
 * - Luego ejecuta este script usando los UIDs de Firebase Auth
 */

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Inicializar Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const Timestamp = admin.firestore.Timestamp;

// ===============================================
// DATOS DE PACIENTES DE PRUEBA
// ===============================================

const PACIENTES_PRUEBA = [
  {
    // IMPORTANTE: Reemplaza estos UIDs con los UIDs reales de Firebase Auth
    // Opción 1: Si ya creaste usuarios, usa sus UIDs
    // Opción 2: Deja que este script cree los usuarios automáticamente
    createAuthUser: true, // Si es true, crea el usuario en Firebase Auth
    email: 'juan.perez@email.com',
    password: 'password123', // Contraseña temporal
    
    // Datos del paciente
    nombre: 'Juan',
    apellido: 'Pérez',
    rut: '18.234.567-8',
    telefono: '+56912345678',
    fechaNacimiento: '1990-05-15',
    sexo: 'M',
    direccion: 'Av. Los Héroes 1234, Santiago',
    prevision: 'Fonasa',
    contactoEmergencia: 'María Pérez',
    telefonoEmergencia: '+56987654321',
  },
  {
    createAuthUser: true,
    email: 'ana.martinez@email.com',
    password: 'password123',
    
    nombre: 'Ana',
    apellido: 'Martínez',
    rut: '17.876.543-2',
    telefono: '+56923456789',
    fechaNacimiento: '1985-08-22',
    sexo: 'F',
    direccion: 'Calle Las Rosas 567, Providencia',
    prevision: 'Isapre Banmédica',
    contactoEmergencia: 'Carlos Martínez',
    telefonoEmergencia: '+56945678901',
  },
  {
    createAuthUser: true,
    email: 'carlos.lopez@email.com',
    password: 'password123',
    
    nombre: 'Carlos',
    apellido: 'López',
    rut: '19.123.456-7',
    telefono: '+56934567890',
    fechaNacimiento: '1995-12-03',
    sexo: 'M',
    direccion: 'Pasaje Los Olivos 89, Las Condes',
    prevision: 'Fonasa',
    contactoEmergencia: 'Laura López',
    telefonoEmergencia: '+56956789012',
  },
  {
    createAuthUser: true,
    email: 'maria.silva@email.com',
    password: 'password123',
    
    nombre: 'María',
    apellido: 'Silva',
    rut: '16.789.012-3',
    telefono: '+56945678901',
    fechaNacimiento: '1982-03-28',
    sexo: 'F',
    direccion: 'Av. Apoquindo 3456, Las Condes',
    prevision: 'Isapre Consalud',
    contactoEmergencia: 'Pedro Silva',
    telefonoEmergencia: '+56967890123',
  },
  {
    createAuthUser: true,
    email: 'pedro.rodriguez@email.com',
    password: 'password123',
    
    nombre: 'Pedro',
    apellido: 'Rodríguez',
    rut: '20.345.678-9',
    telefono: '+56956789012',
    fechaNacimiento: '2000-07-10',
    sexo: 'M',
    direccion: 'Calle Primavera 234, Ñuñoa',
    prevision: 'Fonasa',
    contactoEmergencia: 'Carmen Rodríguez',
    telefonoEmergencia: '+56978901234',
  },
];

// ===============================================
// FUNCIONES DE CREACIÓN
// ===============================================

async function crearUsuarioAuth(email, password) {
  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: true,
    });
    console.log(`✅ Usuario Auth creado: ${email} (UID: ${userRecord.uid})`);
    return userRecord.uid;
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      // Si el usuario ya existe, obtener su UID
      const userRecord = await admin.auth().getUserByEmail(email);
      console.log(`ℹ️  Usuario Auth ya existe: ${email} (UID: ${userRecord.uid})`);
      return userRecord.uid;
    }
    throw error;
  }
}

async function crearPacienteFirestore(uid, pacienteData) {
  const now = Timestamp.now();
  
  const pacienteDoc = {
    email: pacienteData.email,
    nombre: pacienteData.nombre,
    apellido: pacienteData.apellido,
    rut: pacienteData.rut,
    telefono: pacienteData.telefono,
    activo: true,
    fechaNacimiento: pacienteData.fechaNacimiento || null,
    sexo: pacienteData.sexo || null,
    direccion: pacienteData.direccion || null,
    prevision: pacienteData.prevision || null,
    contactoEmergencia: pacienteData.contactoEmergencia || null,
    telefonoEmergencia: pacienteData.telefonoEmergencia || null,
    photoURL: null,
    ultimoAcceso: null,
    createdAt: now,
    updatedAt: now,
  };

  await db.collection('pacientes').doc(uid).set(pacienteDoc);
  console.log(`✅ Paciente creado en Firestore: ${pacienteData.nombre} ${pacienteData.apellido}`);
}

async function crearFichaMedicaPaciente(idPaciente, pacienteData) {
  const fichaDoc = {
    idPaciente: idPaciente,
    grupoSanguineo: null,
    alergias: [],
    antecedentes: {
      familiares: null,
      personales: null,
      quirurgicos: null,
      hospitalizaciones: null,
    },
    ultimaConsulta: null,
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
  };

  await db.collection('fichas-medicas').add(fichaDoc);
  console.log(`✅ Ficha médica creada para: ${pacienteData.nombre} ${pacienteData.apellido}`);
}

// ===============================================
// FUNCIÓN PRINCIPAL
// ===============================================

async function seedPacientes() {
  console.log('🚀 Iniciando seed de pacientes...\n');

  try {
    for (const paciente of PACIENTES_PRUEBA) {
      console.log(`\n📝 Procesando: ${paciente.nombre} ${paciente.apellido}`);
      
      let uid;
      
      // Crear usuario en Firebase Auth si es necesario
      if (paciente.createAuthUser) {
        uid = await crearUsuarioAuth(paciente.email, paciente.password);
      } else if (paciente.uid) {
        uid = paciente.uid;
      } else {
        console.error(`❌ Error: No se especificó UID ni createAuthUser para ${paciente.email}`);
        continue;
      }

      // Crear documento en Firestore
      await crearPacienteFirestore(uid, paciente);

      // Crear ficha médica vacía
      await crearFichaMedicaPaciente(uid, paciente);
    }

    console.log('\n✅ ¡Seed completado exitosamente!');
    console.log('\n📋 Resumen:');
    console.log(`   - ${PACIENTES_PRUEBA.length} pacientes creados`);
    console.log(`   - ${PACIENTES_PRUEBA.length} usuarios Auth creados`);
    console.log(`   - ${PACIENTES_PRUEBA.length} fichas médicas creadas`);
    
    console.log('\n🔐 Credenciales de prueba:');
    PACIENTES_PRUEBA.forEach(p => {
      console.log(`   - Email: ${p.email} | Password: ${p.password}`);
    });
    
  } catch (error) {
    console.error('\n❌ Error durante el seed:', error);
    throw error;
  } finally {
    console.log('\n👋 Finalizando...');
    process.exit(0);
  }
}

// Ejecutar
seedPacientes();
