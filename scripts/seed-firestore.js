/**
 * Script para POBLAR Firestore con datos de prueba coherentes
 * Basado en el modelo de base de datos Modelo_BDD.md
 * 
 * Uso:
 *   node scripts/seed-firestore.js
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
// FUNCIONES AUXILIARES
// ===============================================

function randomDate(start, end) {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

function randomElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function daysAgo(days) {
  const date = new Date();
  date.setDate(date.getDate() - days);
  return date;
}

// ===============================================
// DATOS MAESTROS (CATÁLOGOS)
// ===============================================

const PROFESIONALES = [
  {
    rut: '12.345.678-9',
    nombre: 'María',
    apellido: 'González',
    especialidad: 'Medicina General',
    telefono: '912345678',
    email: 'maria.gonzalez@nexus.cl',
    licencia: 'MG-2018-001'
  },
  {
    rut: '23.456.789-0',
    nombre: 'Carlos',
    apellido: 'Rodríguez',
    especialidad: 'Cardiología',
    telefono: '923456789',
    email: 'carlos.rodriguez@nexus.cl',
    licencia: 'CA-2015-042'
  },
  {
    rut: '34.567.890-1',
    nombre: 'Ana',
    apellido: 'Martínez',
    especialidad: 'Pediatría',
    telefono: '934567890',
    email: 'ana.martinez@nexus.cl',
    licencia: 'PE-2019-018'
  },
  {
    rut: '45.678.901-2',
    nombre: 'Roberto',
    apellido: 'Silva',
    especialidad: 'Traumatología',
    telefono: '945678901',
    email: 'roberto.silva@nexus.cl',
    licencia: 'TR-2017-025'
  },
  {
    rut: '56.789.012-3',
    nombre: 'Patricia',
    apellido: 'Fernández',
    especialidad: 'Ginecología',
    telefono: '956789012',
    email: 'patricia.fernandez@nexus.cl',
    licencia: 'GI-2020-009'
  }
];

const EXAMENES = [
  { nombre: 'Hemograma Completo', tipo: 'laboratorio', codigo: 'LAB-001', descripcion: 'Análisis completo de células sanguíneas' },
  { nombre: 'Glicemia', tipo: 'laboratorio', codigo: 'LAB-002', descripcion: 'Medición de glucosa en sangre' },
  { nombre: 'Perfil Lipídico', tipo: 'laboratorio', codigo: 'LAB-003', descripcion: 'Colesterol total, HDL, LDL, triglicéridos' },
  { nombre: 'Creatinina', tipo: 'laboratorio', codigo: 'LAB-004', descripcion: 'Función renal' },
  { nombre: 'TSH', tipo: 'laboratorio', codigo: 'LAB-005', descripcion: 'Función tiroidea' },
  { nombre: 'Examen de Orina Completo', tipo: 'laboratorio', codigo: 'LAB-006', descripcion: 'Análisis de orina' },
  { nombre: 'Electrocardiograma (ECG)', tipo: 'otro', codigo: 'CAR-001', descripcion: 'Registro actividad eléctrica cardíaca' },
  { nombre: 'Radiografía de Tórax', tipo: 'imagenologia', codigo: 'RAD-001', descripcion: 'Imagen rayos X del tórax' },
  { nombre: 'Ecografía Abdominal', tipo: 'imagenologia', codigo: 'ECO-001', descripcion: 'Ultrasonido región abdominal' },
  { nombre: 'Mamografía', tipo: 'imagenologia', codigo: 'MAM-001', descripcion: 'Imagen rayos X de mamas' }
];

const MEDICAMENTOS = [
  { nombre: 'Paracetamol', nombreGenerico: 'Acetaminofén', presentacion: 'Tabletas', concentracion: '500mg', viaAdministracion: ['Oral'] },
  { nombre: 'Ibuprofeno', nombreGenerico: 'Ibuprofeno', presentacion: 'Tabletas', concentracion: '400mg', viaAdministracion: ['Oral'] },
  { nombre: 'Amoxicilina', nombreGenerico: 'Amoxicilina', presentacion: 'Cápsulas', concentracion: '500mg', viaAdministracion: ['Oral'] },
  { nombre: 'Losartán', nombreGenerico: 'Losartán potásico', presentacion: 'Tabletas', concentracion: '50mg', viaAdministracion: ['Oral'] },
  { nombre: 'Metformina', nombreGenerico: 'Metformina', presentacion: 'Tabletas', concentracion: '850mg', viaAdministracion: ['Oral'] },
  { nombre: 'Atorvastatina', nombreGenerico: 'Atorvastatina', presentacion: 'Tabletas', concentracion: '20mg', viaAdministracion: ['Oral'] },
  { nombre: 'Omeprazol', nombreGenerico: 'Omeprazol', presentacion: 'Cápsulas', concentracion: '20mg', viaAdministracion: ['Oral'] },
  { nombre: 'Salbutamol', nombreGenerico: 'Salbutamol', presentacion: 'Inhalador', concentracion: '100mcg/dosis', viaAdministracion: ['Inhalatoria'] },
  { nombre: 'Levotiroxina', nombreGenerico: 'Levotiroxina sódica', presentacion: 'Tabletas', concentracion: '100mcg', viaAdministracion: ['Oral'] },
  { nombre: 'Enalapril', nombreGenerico: 'Enalapril maleato', presentacion: 'Tabletas', concentracion: '10mg', viaAdministracion: ['Oral'] }
];

// ===============================================
// DATOS DE PACIENTES
// ===============================================

const PACIENTES = [
  {
    rut: '18.123.456-7',
    nombre: 'Juan',
    apellido: 'Pérez',
    fechaNacimiento: new Date('1985-03-15'),
    sexo: 'M',
    direccion: 'Av. Providencia 1234, Santiago',
    telefono: '987654321',
    email: 'juan.perez@email.com',
    grupoSanguineo: 'O+',
    alergias: ['Penicilina', 'Polen'],
    enfermedadesCronicas: ['Hipertensión arterial'],
    alertasMedicas: [
      {
        tipo: 'alergia',
        descripcion: 'Alergia severa a penicilina',
        severidad: 'critica',
        fechaRegistro: Timestamp.now()
      }
    ]
  },
  {
    rut: '16.234.567-8',
    nombre: 'María',
    apellido: 'Torres',
    fechaNacimiento: new Date('1978-07-22'),
    sexo: 'F',
    direccion: 'Los Leones 890, Providencia',
    telefono: '976543210',
    email: 'maria.torres@email.com',
    grupoSanguineo: 'A+',
    alergias: ['Aspirina'],
    enfermedadesCronicas: ['Diabetes tipo 2', 'Hipotiroidismo'],
    alertasMedicas: [
      {
        tipo: 'enfermedad_cronica',
        descripcion: 'Diabetes tipo 2 controlada con metformina',
        severidad: 'alta',
        fechaRegistro: Timestamp.now()
      }
    ]
  },
  {
    rut: '20.345.678-9',
    nombre: 'Pedro',
    apellido: 'Ramírez',
    fechaNacimiento: new Date('1992-11-10'),
    sexo: 'M',
    direccion: 'Las Condes 2500, Las Condes',
    telefono: '965432109',
    email: 'pedro.ramirez@email.com',
    grupoSanguineo: 'B+',
    alergias: [],
    enfermedadesCronicas: [],
    alertasMedicas: []
  },
  {
    rut: '19.456.789-0',
    nombre: 'Carmen',
    apellido: 'Muñoz',
    fechaNacimiento: new Date('1965-05-18'),
    sexo: 'F',
    direccion: 'Apoquindo 4500, Las Condes',
    telefono: '954321098',
    email: 'carmen.munoz@email.com',
    grupoSanguineo: 'AB+',
    alergias: ['Yodo'],
    enfermedadesCronicas: ['Artritis reumatoide', 'Hipertensión'],
    alertasMedicas: [
      {
        tipo: 'medicamento_critico',
        descripcion: 'Requiere anticoagulantes - riesgo de sangrado',
        severidad: 'alta',
        fechaRegistro: Timestamp.now()
      }
    ]
  },
  {
    rut: '21.567.890-1',
    nombre: 'Daniela',
    apellido: 'Soto',
    fechaNacimiento: new Date('1995-09-25'),
    sexo: 'F',
    direccion: 'Bilbao 1234, Providencia',
    telefono: '943210987',
    email: 'daniela.soto@email.com',
    grupoSanguineo: 'O-',
    alergias: [],
    enfermedadesCronicas: [],
    alertasMedicas: []
  }
];

// ===============================================
// FUNCIÓN PRINCIPAL DE SEED
// ===============================================

async function seedFirestore() {
  console.log('╔════════════════════════════════════════════════╗');
  console.log('║   INICIALIZANDO BASE DE DATOS                  ║');
  console.log('║   Sistema Médico Nexus                         ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  const now = Timestamp.now();
  const createdIds = {
    profesionales: [],
    examenes: [],
    medicamentos: [],
    pacientes: [],
    fichas: [],
    consultas: [],
    ordenes: [],
    recetas: []
  };

  try {
    // 1. CREAR PROFESIONALES
    console.log('👨‍⚕️  Creando profesionales...');
    for (const prof of PROFESIONALES) {
      const docRef = await db.collection('profesionales').add({
        ...prof,
        createdAt: now,
        updatedAt: now
      });
      createdIds.profesionales.push(docRef.id);
      console.log(`   ✓ ${prof.nombre} ${prof.apellido} - ${prof.especialidad}`);
    }

    // 2. CREAR CATÁLOGO DE EXÁMENES
    console.log('\n🧪 Creando catálogo de exámenes...');
    for (const examen of EXAMENES) {
      const docRef = await db.collection('examenes').add({
        ...examen,
        createdAt: now,
        updatedAt: now
      });
      createdIds.examenes.push(docRef.id);
      console.log(`   ✓ ${examen.nombre} (${examen.tipo})`);
    }

    // 3. CREAR CATÁLOGO DE MEDICAMENTOS
    console.log('\n💊 Creando catálogo de medicamentos...');
    for (const med of MEDICAMENTOS) {
      const docRef = await db.collection('medicamentos').add({
        ...med,
        createdAt: now,
        updatedAt: now
      });
      createdIds.medicamentos.push(docRef.id);
      console.log(`   ✓ ${med.nombre} ${med.concentracion}`);
    }

    // 4. CREAR PACIENTES Y SUS FICHAS
    console.log('\n👤 Creando pacientes y fichas médicas...');
    for (const pac of PACIENTES) {
      // Crear paciente
      const pacienteRef = await db.collection('pacientes').add({
        ...pac,
        nombreCompleto: `${pac.nombre} ${pac.apellido}`,
        fechaNacimiento: Timestamp.fromDate(pac.fechaNacimiento),
        createdAt: now,
        updatedAt: now
      });
      createdIds.pacientes.push(pacienteRef.id);

      // Crear ficha médica asociada
      const fichaRef = await db.collection('fichas-medicas').add({
        idPaciente: pacienteRef.id,
        fechaMedica: now,
        observacion: `Ficha médica de ${pac.nombre} ${pac.apellido}`,
        antecedentes: {
          familiares: 'Sin antecedentes familiares relevantes',
          personales: pac.enfermedadesCronicas.join(', ') || 'Sin antecedentes personales',
          quirurgicos: 'Sin cirugías previas',
          hospitalizaciones: 'Sin hospitalizaciones previas',
          alergias: pac.alergias
        },
        totalConsultas: 0,
        createdAt: now,
        updatedAt: now
      });
      createdIds.fichas.push({ pacienteId: pacienteRef.id, fichaId: fichaRef.id });

      console.log(`   ✓ ${pac.nombre} ${pac.apellido} (RUT: ${pac.rut})`);
    }

    // 5. CREAR CONSULTAS (2-4 por paciente)
    console.log('\n📋 Creando consultas médicas...');
    for (const ficha of createdIds.fichas) {
      const numConsultas = Math.floor(Math.random() * 3) + 2; // 2-4 consultas
      
      for (let i = 0; i < numConsultas; i++) {
        const profesionalId = randomElement(createdIds.profesionales);
        const fechaConsulta = Timestamp.fromDate(daysAgo(Math.floor(Math.random() * 180)));
        
        const motivos = [
          'Control de rutina',
          'Dolor abdominal',
          'Dolor de cabeza recurrente',
          'Control de presión arterial',
          'Fiebre y malestar general',
          'Dolor torácico',
          'Control post-operatorio',
          'Chequeo anual'
        ];

        const consultaRef = await db.collection('consultas').add({
          idPaciente: ficha.pacienteId,
          idProfesional: profesionalId,
          idFichaMedica: ficha.fichaId,
          fecha: fechaConsulta,
          motivo: randomElement(motivos),
          tratamiento: 'Tratamiento según evaluación clínica',
          observaciones: 'Paciente estable. Continuar con controles regulares.',
          notas: [],
          createdAt: now,
          updatedAt: now
        });
        
        createdIds.consultas.push({
          consultaId: consultaRef.id,
          pacienteId: ficha.pacienteId,
          profesionalId: profesionalId
        });

        // Actualizar contador en ficha
        await db.collection('fichas-medicas').doc(ficha.fichaId).update({
          totalConsultas: FieldValue.increment(1),
          ultimaConsulta: fechaConsulta,
          updatedAt: now
        });
      }
      console.log(`   ✓ ${numConsultas} consultas para paciente ${ficha.pacienteId.substring(0, 8)}...`);
    }

    // 6. CREAR ÓRDENES DE EXÁMENES (1-2 por consulta)
    console.log('\n🔬 Creando órdenes de exámenes...');
    let ordenesCreadas = 0;
    for (const consulta of createdIds.consultas) {
      if (Math.random() > 0.3) { // 70% de consultas tienen exámenes
        const numExamenes = Math.floor(Math.random() * 3) + 1; // 1-3 exámenes
        const examenesSeleccionados = [];
        
        for (let i = 0; i < numExamenes; i++) {
          const examenIdx = Math.floor(Math.random() * EXAMENES.length);
          const examenId = createdIds.examenes[examenIdx];
          const examen = EXAMENES[examenIdx];
          
          const estado = Math.random() > 0.5 ? 'realizado' : 'pendiente';
          
          // Solo incluir resultado y fechaResultado si el examen está realizado
          const examenData = {
            idExamen: examenId,
            nombreExamen: examen.nombre
          };
          
          if (estado === 'realizado') {
            examenData.resultado = 'Valores dentro de rangos normales';
            examenData.fechaResultado = Timestamp.fromDate(daysAgo(Math.floor(Math.random() * 7)));
          }
          
          examenesSeleccionados.push(examenData);
        }

        await db.collection('ordenes-examen').add({
          idPaciente: consulta.pacienteId,
          idProfesional: consulta.profesionalId,
          idConsulta: consulta.consultaId,
          fecha: Timestamp.fromDate(daysAgo(Math.floor(Math.random() * 30))),
          estado: examenesSeleccionados.some(e => !e.resultado) ? 'pendiente' : 'realizado',
          examenes: examenesSeleccionados,
          createdAt: now,
          updatedAt: now
        });
        
        ordenesCreadas++;
      }
    }
    console.log(`   ✓ ${ordenesCreadas} órdenes de exámenes creadas`);

    // 7. CREAR RECETAS (1 por consulta aleatoria)
    console.log('\n💊 Creando recetas...');
    let recetasCreadas = 0;
    for (const consulta of createdIds.consultas) {
      if (Math.random() > 0.4) { // 60% de consultas tienen receta
        const numMedicamentos = Math.floor(Math.random() * 3) + 1; // 1-3 medicamentos
        const medicamentosRecetados = [];
        
        for (let i = 0; i < numMedicamentos; i++) {
          const medIdx = Math.floor(Math.random() * MEDICAMENTOS.length);
          const medicamentoId = createdIds.medicamentos[medIdx];
          const medicamento = MEDICAMENTOS[medIdx];
          
          medicamentosRecetados.push({
            idMedicamento: medicamentoId,
            nombreMedicamento: medicamento.nombre,
            dosis: medicamento.concentracion,
            frecuencia: randomElement(['Cada 8 horas', 'Cada 12 horas', 'Cada 24 horas', '2 veces al día']),
            duracion: randomElement(['7 días', '14 días', '30 días', 'Uso continuo']),
            indicaciones: 'Tomar con alimentos'
          });
        }

        await db.collection('recetas').add({
          idPaciente: consulta.pacienteId,
          idProfesional: consulta.profesionalId,
          idConsulta: consulta.consultaId,
          fecha: Timestamp.fromDate(daysAgo(Math.floor(Math.random() * 60))),
          medicamentos: medicamentosRecetados,
          observaciones: 'Seguir indicaciones médicas. Contactar si hay efectos adversos.',
          createdAt: now,
          updatedAt: now
        });
        
        recetasCreadas++;
      }
    }
    console.log(`   ✓ ${recetasCreadas} recetas creadas`);

    // 8. CREAR DOCUMENTOS MÉDICOS (2-4 por paciente)
    console.log('\n📄 Creando documentos médicos...');
    const tiposDocumento = ['examen', 'imagen', 'informe', 'otro'];
    const nombresDocumento = {
      'examen': ['Hemograma Completo', 'Examen de Orina', 'Perfil Lipídico', 'Glicemia'],
      'imagen': ['Radiografía Tórax', 'Ecografía Abdominal', 'TAC Cerebral', 'Resonancia Magnética'],
      'informe': ['Informe Cardiológico', 'Informe Neurológico', 'Informe Oncológico'],
      'otro': ['Certificado Médico', 'Orden de Reposo', 'Epicrisis']
    };
    
    // URLs de documentos PDF públicos confiables para testing
    const urlsEjemplo = [
      'https://pdfobject.com/pdf/sample.pdf',
      'https://www.orimi.com/pdf-test.pdf',
      'https://file-examples.com/storage/fe28a82ba9eb1afe5d15e66/2017/10/file-sample_150kB.pdf',
      'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf'
    ];
    
    let documentosCreados = 0;
    for (const pacienteId of createdIds.pacientes) {
      const numDocumentos = Math.floor(Math.random() * 3) + 2; // 2-4 documentos
      
      for (let i = 0; i < numDocumentos; i++) {
        const tipo = randomElement(tiposDocumento);
        const nombre = randomElement(nombresDocumento[tipo]);
        const url = randomElement(urlsEjemplo);
        const tamanio = Math.floor(Math.random() * 2000000) + 50000; // 50KB - 2MB
        
        await db.collection('documentos').add({
          idPaciente: pacienteId,
          nombre: nombre,
          tipo: tipo,
          url: url,
          tamanio: tamanio,
          fecha: Timestamp.fromDate(daysAgo(Math.floor(Math.random() * 180))),
          createdAt: now,
          updatedAt: now
        });
        
        documentosCreados++;
      }
    }
    console.log(`   ✓ ${documentosCreados} documentos médicos creados`);

    // RESUMEN FINAL
    console.log('\n╔════════════════════════════════════════════════╗');
    console.log('║   ✅ BASE DE DATOS INICIALIZADA               ║');
    console.log('╚════════════════════════════════════════════════╝');
    console.log('\n📊 Resumen de datos creados:');
    console.log(`   • ${createdIds.profesionales.length} profesionales`);
    console.log(`   • ${createdIds.examenes.length} tipos de exámenes (catálogo)`);
    console.log(`   • ${createdIds.medicamentos.length} medicamentos (catálogo)`);
    console.log(`   • ${createdIds.pacientes.length} pacientes`);
    console.log(`   • ${createdIds.fichas.length} fichas médicas`);
    console.log(`   • ${createdIds.consultas.length} consultas`);
    console.log(`   • ${ordenesCreadas} órdenes de exámenes`);
    console.log(`   • ${recetasCreadas} recetas`);
    console.log(`   • ${documentosCreados} documentos médicos`);
    console.log('\n🚀 ¡Tu aplicación está lista para usar!');

  } catch (error) {
    console.error('\n❌ Error durante la inicialización:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Ejecutar
seedFirestore();
