/**
 * Firestore Seeding Script
 * Run with: node seed-firestore.js
 * 
 * Prerequisites:
 * 1. Install Firebase Admin SDK: npm install firebase-admin --save-dev
 * 2. Download service account key from Firebase Console:
 *    - Go to Project Settings > Service Accounts
 *    - Click "Generate new private key"
 *    - Save as serviceAccountKey.json in project root
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Helper to create Firestore Timestamp
const timestamp = (daysAgo = 0) => {
  const date = new Date();
  date.setDate(date.getDate() - daysAgo);
  return admin.firestore.Timestamp.fromDate(date);
};

// ==================== SEED DATA ====================

const profesionales = [
  {
    id: 'prof-001',
    rut: '12345678-9',
    nombre: 'Juan',
    apellido: 'Pérez',
    especialidad: 'Medicina General',
    email: 'juan.perez@nexus.cl',
    telefono: '+56912345678',
    registro: 'REG-2024-001',
    createdAt: timestamp(365),
    updatedAt: timestamp(1)
  },
  {
    id: 'prof-002',
    rut: '23456789-0',
    nombre: 'María',
    apellido: 'González',
    especialidad: 'Cardiología',
    email: 'maria.gonzalez@nexus.cl',
    telefono: '+56923456789',
    registro: 'REG-2024-002',
    createdAt: timestamp(300),
    updatedAt: timestamp(1)
  },
  {
    id: 'prof-003',
    rut: '34567890-1',
    nombre: 'Carlos',
    apellido: 'Rodríguez',
    especialidad: 'Pediatría',
    email: 'carlos.rodriguez@nexus.cl',
    telefono: '+56934567890',
    registro: 'REG-2024-003',
    createdAt: timestamp(250),
    updatedAt: timestamp(1)
  }
];

const pacientes = [
  {
    id: 'pac-001',
    rut: '11111111-1',
    nombre: 'Ana',
    apellido: 'Martínez',
    fechaNacimiento: timestamp(10950), // ~30 años
    genero: 'femenino',
    grupoSanguineo: 'O+',
    direccion: 'Av. Libertador Bernardo O\'Higgins 1234, Santiago',
    telefono: '+56911111111',
    email: 'ana.martinez@example.com',
    contactoEmergencia: 'Pedro Martínez (+56922222222)',
    alergias: ['Penicilina', 'Ibuprofeno'],
    enfermedadesCronicas: ['Hipertensión'],
    alertasMedicas: [
      {
        tipo: 'alergia',
        descripcion: 'Alergia severa a Penicilina - usar alternativas',
        severidad: 'alta',
        fechaRegistro: timestamp(100)
      }
    ],
    createdAt: timestamp(200),
    updatedAt: timestamp(5)
  },
  {
    id: 'pac-002',
    rut: '22222222-2',
    nombre: 'Pedro',
    apellido: 'Silva',
    fechaNacimiento: timestamp(18250), // ~50 años
    genero: 'masculino',
    grupoSanguineo: 'A+',
    direccion: 'Los Aromos 567, Providencia',
    telefono: '+56922222222',
    email: 'pedro.silva@example.com',
    contactoEmergencia: 'Laura Silva (+56933333333)',
    alergias: [],
    enfermedadesCronicas: ['Diabetes Tipo 2', 'Colesterol alto'],
    alertasMedicas: [
      {
        tipo: 'medicamento',
        descripcion: 'Control mensual de glicemia requerido',
        severidad: 'media',
        fechaRegistro: timestamp(50)
      }
    ],
    createdAt: timestamp(180),
    updatedAt: timestamp(2)
  },
  {
    id: 'pac-003',
    rut: '33333333-3',
    nombre: 'Sofía',
    apellido: 'López',
    fechaNacimiento: timestamp(2555), // ~7 años
    genero: 'femenino',
    grupoSanguineo: 'B+',
    direccion: 'Santa Rosa 890, La Florida',
    telefono: '+56933333333',
    email: 'contacto.lopez@example.com',
    contactoEmergencia: 'Carolina López (+56944444444)',
    alergias: ['Polen'],
    enfermedadesCronicas: ['Asma leve'],
    alertasMedicas: [],
    createdAt: timestamp(150),
    updatedAt: timestamp(3)
  },
  {
    id: 'pac-004',
    rut: '44444444-4',
    nombre: 'Roberto',
    apellido: 'Fernández',
    fechaNacimiento: timestamp(25550), // ~70 años
    genero: 'masculino',
    grupoSanguineo: 'AB-',
    direccion: 'Av. Vicuña Mackenna 2345, Ñuñoa',
    telefono: '+56944444444',
    email: 'roberto.fernandez@example.com',
    contactoEmergencia: 'Daniela Fernández (+56955555555)',
    alergias: ['Mariscos'],
    enfermedadesCronicas: ['Hipertensión', 'Artritis'],
    alertasMedicas: [
      {
        tipo: 'antecedente',
        descripcion: 'Cirugía cardíaca previa (2020) - considerar en tratamientos',
        severidad: 'alta',
        fechaRegistro: timestamp(1500)
      }
    ],
    createdAt: timestamp(300),
    updatedAt: timestamp(1)
  }
];

const fichasMedicas = [
  {
    id: 'ficha-001',
    idPaciente: 'pac-001',
    antecedentesPersonales: 'Hipertensión arterial diagnosticada hace 5 años. Tratamiento con Enalapril. Sin hospitalizaciones previas.',
    antecedentesFamiliares: 'Madre con diabetes tipo 2. Padre hipertenso. Abuela materna falleció por ACV.',
    alergias: 'Penicilina (reacción anafiláctica en 2015). Ibuprofeno (erupciones cutáneas).',
    medicamentosActuales: 'Enalapril 10mg (1 vez al día). Atorvastatina 20mg (1 vez al día).',
    observaciones: 'Paciente adherente al tratamiento. Controles regulares cada 3 meses.',
    createdAt: timestamp(200),
    updatedAt: timestamp(5)
  },
  {
    id: 'ficha-002',
    idPaciente: 'pac-002',
    antecedentesPersonales: 'Diabetes tipo 2 desde hace 8 años. Colesterol alto. Sedentarismo. Fumador (10 cigarros/día).',
    antecedentesFamiliares: 'Padre diabético. Hermano con infarto al miocardio a los 55 años.',
    alergias: 'No refiere alergias conocidas.',
    medicamentosActuales: 'Metformina 850mg (2 veces al día). Atorvastatina 40mg (1 vez al día). Aspirina 100mg (1 vez al día).',
    observaciones: 'Se recomienda control de glicemia mensual y reducir consumo de tabaco.',
    createdAt: timestamp(180),
    updatedAt: timestamp(2)
  },
  {
    id: 'ficha-003',
    idPaciente: 'pac-003',
    antecedentesPersonales: 'Asma leve desde los 4 años. Alergia al polen. Desarrollo psicomotor normal.',
    antecedentesFamiliares: 'Madre asmática. Padre con rinitis alérgica.',
    alergias: 'Polen (rinoconjuntivitis estacional).',
    medicamentosActuales: 'Salbutamol (inhalador de rescate - según necesidad). Montelukast 5mg (1 vez al día).',
    observaciones: 'Control semestral con pediatra. Evitar exposición a alérgenos en primavera.',
    createdAt: timestamp(150),
    updatedAt: timestamp(3)
  },
  {
    id: 'ficha-004',
    idPaciente: 'pac-004',
    antecedentesPersonales: 'Hipertensión arterial crónica. Artritis reumatoide. Cirugía bypass coronario (2020). Hipotiroidismo.',
    antecedentesFamiliares: 'Madre con Alzheimer. Padre falleció por cáncer de pulmón.',
    alergias: 'Mariscos (urticaria).',
    medicamentosActuales: 'Losartán 50mg (1 vez al día). Metotrexato 15mg (semanal). Levotiroxina 100mcg (1 vez al día). Ácido fólico 5mg (diario).',
    observaciones: 'Paciente polimedicado. Requiere seguimiento estrecho por múltiples comorbilidades.',
    createdAt: timestamp(300),
    updatedAt: timestamp(1)
  }
];

const consultas = [
  // Consultas para Ana Martínez (pac-001)
  {
    id: 'cons-001',
    idPaciente: 'pac-001',
    idProfesional: 'prof-001',
    idFichaMedica: 'ficha-001',
    fecha: timestamp(7),
    motivo: 'Control de presión arterial',
    tratamiento: 'Mantener tratamiento con Enalapril 10mg. Control en 3 meses.',
    observaciones: 'PA: 130/85 mmHg. Paciente refiere buena adherencia al tratamiento. Sin sintomatología asociada.',
    notas: [
      {
        texto: 'Paciente solicita cambio de horario de toma de medicamento',
        autor: 'prof-001',
        fecha: timestamp(7)
      }
    ],
    createdAt: timestamp(7),
    updatedAt: timestamp(7)
  },
  {
    id: 'cons-002',
    idPaciente: 'pac-001',
    idProfesional: 'prof-002',
    idFichaMedica: 'ficha-001',
    fecha: timestamp(95),
    motivo: 'Evaluación cardiológica preventiva',
    tratamiento: 'Iniciar Atorvastatina 20mg. Ecografía cardíaca solicitada.',
    observaciones: 'Evaluación cardiovascular dentro de parámetros normales. Se sugiere control anual.',
    createdAt: timestamp(95),
    updatedAt: timestamp(95)
  },
  
  // Consultas para Pedro Silva (pac-002)
  {
    id: 'cons-003',
    idPaciente: 'pac-002',
    idProfesional: 'prof-001',
    idFichaMedica: 'ficha-002',
    fecha: timestamp(15),
    motivo: 'Control de diabetes y colesterol',
    tratamiento: 'Ajuste de dosis de Metformina a 850mg cada 12 horas. Mantener Atorvastatina.',
    observaciones: 'Glicemia: 145 mg/dL. HbA1c: 7.2%. Colesterol total: 210 mg/dL. Se recomienda dieta y ejercicio.',
    notas: [
      {
        texto: 'Derivar a nutricionista para plan alimentario',
        autor: 'prof-001',
        fecha: timestamp(15)
      }
    ],
    createdAt: timestamp(15),
    updatedAt: timestamp(15)
  },
  {
    id: 'cons-004',
    idPaciente: 'pac-002',
    idProfesional: 'prof-001',
    idFichaMedica: 'ficha-002',
    fecha: timestamp(45),
    motivo: 'Control mensual de glicemia',
    tratamiento: 'Mantener tratamiento actual. Reforzar importancia de dieta.',
    observaciones: 'Glicemia en ayunas: 152 mg/dL. Paciente refiere dificultad para adherir a dieta.',
    createdAt: timestamp(45),
    updatedAt: timestamp(45)
  },

  // Consultas para Sofía López (pac-003)
  {
    id: 'cons-005',
    idPaciente: 'pac-003',
    idProfesional: 'prof-003',
    idFichaMedica: 'ficha-003',
    fecha: timestamp(20),
    motivo: 'Control pediátrico de asma',
    tratamiento: 'Continuar con Montelukast 5mg. Inhalador de rescate según necesidad.',
    observaciones: 'Sin crisis asmáticas en últimos 3 meses. Desarrollo adecuado para la edad. Peso: 25kg, Talla: 120cm.',
    createdAt: timestamp(20),
    updatedAt: timestamp(20)
  },

  // Consultas para Roberto Fernández (pac-004)
  {
    id: 'cons-006',
    idPaciente: 'pac-004',
    idProfesional: 'prof-001',
    idFichaMedica: 'ficha-004',
    fecha: timestamp(10),
    motivo: 'Control post-cirugía cardíaca y manejo de polifarmacia',
    tratamiento: 'Mantener todos los medicamentos actuales. Solicitar ecocardiograma de control.',
    observaciones: 'PA: 135/90 mmHg. Paciente estable hemodinámicamente. Artritis controlada con Metotrexato. TSH: 2.5 mU/L.',
    notas: [
      {
        texto: 'Recordar tomar ácido fólico por Metotrexato',
        autor: 'prof-001',
        fecha: timestamp(10)
      },
      {
        texto: 'Coordinar con cardiología para control semestral',
        autor: 'prof-001',
        fecha: timestamp(10)
      }
    ],
    createdAt: timestamp(10),
    updatedAt: timestamp(10)
  }
];

const recetas = [
  // Recetas para Ana Martínez
  {
    id: 'rec-001',
    idPaciente: 'pac-001',
    idProfesional: 'prof-001',
    idConsulta: 'cons-001',
    fecha: timestamp(7),
    medicamentos: [
      {
        idMedicamento: 'med-enalapril',
        nombreMedicamento: 'Enalapril',
        dosis: '10mg',
        frecuencia: '1 vez al día',
        duracion: '90 días',
        indicaciones: 'Tomar en ayunas por la mañana'
      },
      {
        idMedicamento: 'med-atorvastatina',
        nombreMedicamento: 'Atorvastatina',
        dosis: '20mg',
        frecuencia: '1 vez al día',
        duracion: '90 días',
        indicaciones: 'Tomar en la noche antes de dormir'
      }
    ],
    observaciones: 'Renovación de receta habitual. Control en 3 meses.',
    createdAt: timestamp(7),
    updatedAt: timestamp(7)
  },

  // Recetas para Pedro Silva
  {
    id: 'rec-002',
    idPaciente: 'pac-002',
    idProfesional: 'prof-001',
    idConsulta: 'cons-003',
    fecha: timestamp(15),
    medicamentos: [
      {
        idMedicamento: 'med-metformina',
        nombreMedicamento: 'Metformina',
        dosis: '850mg',
        frecuencia: '2 veces al día',
        duracion: '30 días',
        indicaciones: 'Tomar con desayuno y cena'
      },
      {
        idMedicamento: 'med-atorvastatina',
        nombreMedicamento: 'Atorvastatina',
        dosis: '40mg',
        frecuencia: '1 vez al día',
        duracion: '30 días',
        indicaciones: 'Tomar en la noche'
      },
      {
        idMedicamento: 'med-aspirina',
        nombreMedicamento: 'Aspirina',
        dosis: '100mg',
        frecuencia: '1 vez al día',
        duracion: '30 días',
        indicaciones: 'Tomar después del desayuno'
      }
    ],
    observaciones: 'Ajuste de dosis de Metformina. Control mensual obligatorio.',
    createdAt: timestamp(15),
    updatedAt: timestamp(15)
  },

  // Recetas para Sofía López
  {
    id: 'rec-003',
    idPaciente: 'pac-003',
    idProfesional: 'prof-003',
    idConsulta: 'cons-005',
    fecha: timestamp(20),
    medicamentos: [
      {
        idMedicamento: 'med-montelukast',
        nombreMedicamento: 'Montelukast',
        dosis: '5mg',
        frecuencia: '1 vez al día',
        duracion: '90 días',
        indicaciones: 'Tomar en la noche'
      },
      {
        idMedicamento: 'med-salbutamol',
        nombreMedicamento: 'Salbutamol (inhalador)',
        dosis: '100mcg',
        frecuencia: 'Según necesidad (máximo 4 veces al día)',
        duracion: 'Hasta terminarlo',
        indicaciones: 'Usar 2 puffs en caso de dificultad respiratoria. Si usa más de 2 veces por semana, consultar.'
      }
    ],
    observaciones: 'Mantener inhalador de rescate siempre disponible.',
    createdAt: timestamp(20),
    updatedAt: timestamp(20)
  },

  // Recetas para Roberto Fernández
  {
    id: 'rec-004',
    idPaciente: 'pac-004',
    idProfesional: 'prof-001',
    idConsulta: 'cons-006',
    fecha: timestamp(10),
    medicamentos: [
      {
        idMedicamento: 'med-losartan',
        nombreMedicamento: 'Losartán',
        dosis: '50mg',
        frecuencia: '1 vez al día',
        duracion: '30 días',
        indicaciones: 'Tomar en la mañana'
      },
      {
        idMedicamento: 'med-metotrexato',
        nombreMedicamento: 'Metotrexato',
        dosis: '15mg',
        frecuencia: '1 vez por semana',
        duracion: '12 semanas',
        indicaciones: 'Tomar el mismo día cada semana (ej: todos los lunes)'
      },
      {
        idMedicamento: 'med-levotiroxina',
        nombreMedicamento: 'Levotiroxina',
        dosis: '100mcg',
        frecuencia: '1 vez al día',
        duracion: '30 días',
        indicaciones: 'Tomar en ayunas, 30 minutos antes del desayuno'
      },
      {
        idMedicamento: 'med-acido-folico',
        nombreMedicamento: 'Ácido Fólico',
        dosis: '5mg',
        frecuencia: '1 vez al día',
        duracion: '30 días',
        indicaciones: 'Complemento obligatorio con Metotrexato'
      }
    ],
    observaciones: 'Paciente polimedicado. IMPORTANTE: No tomar Metotrexato diariamente, solo semanal.',
    createdAt: timestamp(10),
    updatedAt: timestamp(10)
  }
];

const ordenesExamen = [
  // Órdenes para Ana Martínez
  {
    id: 'orden-001',
    idPaciente: 'pac-001',
    idProfesional: 'prof-002',
    idConsulta: 'cons-002',
    fecha: timestamp(95),
    estado: 'realizado',
    examenes: [
      {
        idExamen: 'ex-eco-cardiaca',
        nombreExamen: 'Ecocardiografía Doppler',
        resultado: 'Función ventricular conservada. Fracción de eyección: 60%. Sin alteraciones valvulares.',
        fechaResultado: timestamp(88)
      },
      {
        idExamen: 'ex-perfil-lipidico',
        nombreExamen: 'Perfil Lipídico',
        resultado: 'Colesterol total: 195 mg/dL, LDL: 120 mg/dL, HDL: 55 mg/dL, Triglicéridos: 100 mg/dL',
        fechaResultado: timestamp(90)
      }
    ],
    createdAt: timestamp(95),
    updatedAt: timestamp(88)
  },

  // Órdenes para Pedro Silva
  {
    id: 'orden-002',
    idPaciente: 'pac-002',
    idProfesional: 'prof-001',
    idConsulta: 'cons-003',
    fecha: timestamp(15),
    estado: 'realizado',
    examenes: [
      {
        idExamen: 'ex-glicemia',
        nombreExamen: 'Glicemia en ayunas',
        resultado: '145 mg/dL',
        fechaResultado: timestamp(14)
      },
      {
        idExamen: 'ex-hba1c',
        nombreExamen: 'Hemoglobina Glicosilada (HbA1c)',
        resultado: '7.2%',
        fechaResultado: timestamp(14)
      },
      {
        idExamen: 'ex-perfil-lipidico',
        nombreExamen: 'Perfil Lipídico',
        resultado: 'Colesterol total: 210 mg/dL, LDL: 140 mg/dL, HDL: 42 mg/dL, Triglicéridos: 180 mg/dL',
        fechaResultado: timestamp(14)
      }
    ],
    createdAt: timestamp(15),
    updatedAt: timestamp(14)
  },
  {
    id: 'orden-003',
    idPaciente: 'pac-002',
    idProfesional: 'prof-001',
    idConsulta: 'cons-004',
    fecha: timestamp(45),
    estado: 'realizado',
    examenes: [
      {
        idExamen: 'ex-glicemia',
        nombreExamen: 'Glicemia en ayunas',
        resultado: '152 mg/dL',
        fechaResultado: timestamp(44)
      }
    ],
    createdAt: timestamp(45),
    updatedAt: timestamp(44)
  },

  // Órdenes para Sofía López
  {
    id: 'orden-004',
    idPaciente: 'pac-003',
    idProfesional: 'prof-003',
    fecha: timestamp(20),
    estado: 'pendiente',
    examenes: [
      {
        idExamen: 'ex-espirometria',
        nombreExamen: 'Espirometría',
        resultado: null,
        fechaResultado: null
      }
    ],
    createdAt: timestamp(20),
    updatedAt: timestamp(20)
  },

  // Órdenes para Roberto Fernández
  {
    id: 'orden-005',
    idPaciente: 'pac-004',
    idProfesional: 'prof-001',
    idConsulta: 'cons-006',
    fecha: timestamp(10),
    estado: 'pendiente',
    examenes: [
      {
        idExamen: 'ex-eco-cardiaca',
        nombreExamen: 'Ecocardiograma de control post-cirugía',
        resultado: null,
        fechaResultado: null
      },
      {
        idExamen: 'ex-tsh',
        nombreExamen: 'TSH (Hormona Estimulante de Tiroides)',
        resultado: null,
        fechaResultado: null
      }
    ],
    createdAt: timestamp(10),
    updatedAt: timestamp(10)
  },
  {
    id: 'orden-006',
    idPaciente: 'pac-004',
    idProfesional: 'prof-001',
    fecha: timestamp(60),
    estado: 'realizado',
    examenes: [
      {
        idExamen: 'ex-tsh',
        nombreExamen: 'TSH',
        resultado: '2.5 mU/L (rango normal: 0.4-4.0)',
        fechaResultado: timestamp(58)
      },
      {
        idExamen: 'ex-hemograma',
        nombreExamen: 'Hemograma completo',
        resultado: 'Leucocitos: 7,500/μL, Eritrocitos: 4.8 M/μL, Hemoglobina: 14.2 g/dL, Plaquetas: 250,000/μL',
        fechaResultado: timestamp(58)
      }
    ],
    createdAt: timestamp(60),
    updatedAt: timestamp(58)
  }
];

const medicamentos = [
  { id: 'med-enalapril', nombre: 'Enalapril', categoria: 'Antihipertensivo', presentacion: 'Comprimido 10mg', laboratorio: 'Genfar' },
  { id: 'med-atorvastatina', nombre: 'Atorvastatina', categoria: 'Estatina', presentacion: 'Comprimido 20mg/40mg', laboratorio: 'Pfizer' },
  { id: 'med-metformina', nombre: 'Metformina', categoria: 'Antidiabético', presentacion: 'Comprimido 850mg', laboratorio: 'Merck' },
  { id: 'med-aspirina', nombre: 'Aspirina', categoria: 'Antiagregante plaquetario', presentacion: 'Comprimido 100mg', laboratorio: 'Bayer' },
  { id: 'med-montelukast', nombre: 'Montelukast', categoria: 'Antiasmático', presentacion: 'Comprimido masticable 5mg', laboratorio: 'Merck' },
  { id: 'med-salbutamol', nombre: 'Salbutamol', categoria: 'Broncodilatador', presentacion: 'Inhalador 100mcg/dosis', laboratorio: 'GSK' },
  { id: 'med-losartan', nombre: 'Losartán', categoria: 'Antihipertensivo', presentacion: 'Comprimido 50mg', laboratorio: 'Sandoz' },
  { id: 'med-metotrexato', nombre: 'Metotrexato', categoria: 'Inmunosupresor', presentacion: 'Comprimido 2.5mg', laboratorio: 'Accord' },
  { id: 'med-levotiroxina', nombre: 'Levotiroxina', categoria: 'Hormona tiroidea', presentacion: 'Comprimido 100mcg', laboratorio: 'Saval' },
  { id: 'med-acido-folico', nombre: 'Ácido Fólico', categoria: 'Vitamina', presentacion: 'Comprimido 5mg', laboratorio: 'Generic' }
];

const examenes = [
  { id: 'ex-eco-cardiaca', nombre: 'Ecocardiografía Doppler', tipo: 'Imagen', area: 'Cardiología' },
  { id: 'ex-perfil-lipidico', nombre: 'Perfil Lipídico', tipo: 'Laboratorio', area: 'Química Clínica' },
  { id: 'ex-glicemia', nombre: 'Glicemia en ayunas', tipo: 'Laboratorio', area: 'Química Clínica' },
  { id: 'ex-hba1c', nombre: 'Hemoglobina Glicosilada', tipo: 'Laboratorio', area: 'Química Clínica' },
  { id: 'ex-espirometria', nombre: 'Espirometría', tipo: 'Funcional', area: 'Neumología' },
  { id: 'ex-tsh', nombre: 'TSH', tipo: 'Laboratorio', area: 'Endocrinología' },
  { id: 'ex-hemograma', nombre: 'Hemograma completo', tipo: 'Laboratorio', area: 'Hematología' }
];

// ==================== SEEDING FUNCTIONS ====================

async function seedCollection(collectionName, data) {
  console.log(`\n📝 Seeding ${collectionName}...`);
  const batch = db.batch();
  
  data.forEach(doc => {
    const { id, ...docData } = doc;
    const docRef = db.collection(collectionName).doc(id);
    batch.set(docRef, docData);
  });
  
  await batch.commit();
  console.log(`✅ Successfully seeded ${data.length} documents to ${collectionName}`);
}

async function seedDatabase() {
  try {
    console.log('🚀 Starting Firestore seeding...\n');
    console.log('========================================');
    
    await seedCollection('profesionales', profesionales);
    await seedCollection('pacientes', pacientes);
    await seedCollection('fichas-medicas', fichasMedicas);
    await seedCollection('consultas', consultas);
    await seedCollection('recetas', recetas);
    await seedCollection('ordenes-examen', ordenesExamen);
    await seedCollection('medicamentos', medicamentos);
    await seedCollection('examenes', examenes);
    
    console.log('\n========================================');
    console.log('🎉 Firestore seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   - ${profesionales.length} Profesionales`);
    console.log(`   - ${pacientes.length} Pacientes`);
    console.log(`   - ${fichasMedicas.length} Fichas Médicas`);
    console.log(`   - ${consultas.length} Consultas`);
    console.log(`   - ${recetas.length} Recetas`);
    console.log(`   - ${ordenesExamen.length} Órdenes de Examen`);
    console.log(`   - ${medicamentos.length} Medicamentos (Catálogo)`);
    console.log(`   - ${examenes.length} Exámenes (Catálogo)`);
    console.log('\n✨ You can now test your app with real data!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Run seeding
seedDatabase();
