import { Timestamp } from '@angular/fire/firestore';

/**
 * Modelo de Usuario (Colección central con datos personales y autenticación)
 * 
 * ⚠️ IMPORTANTE: 
 * - Este modelo contiene TODOS los datos personales (email, rut, displayName, telefono)
 * - Los datos profesionales/paciente están en documentos separados
 * - NO duplicar campos entre Usuario y Profesional/Paciente
 */
export interface Usuario {
  id: string;                    // UID de Firebase Authentication
  
  // Datos de autenticación
  email: string;                 // ÚNICO - usado para login
  emailVerified?: boolean;
  
  // Datos personales (NO duplicar en profesionales/pacientes)
  displayName: string;           // Nombre completo
  rut: string;                   // ÚNICO - identificación nacional
  telefono?: string;             // Teléfono de contacto
  photoURL?: string;             // URL de foto de perfil
  
  // Control de acceso
  rol: 'admin' | 'profesional' | 'paciente';
  activo: boolean;
  
  // Referencias a otras colecciones
  idProfesional?: string;        // ID del documento en 'profesionales' (solo si rol='profesional')
  idPaciente?: string;           // ID del documento en 'pacientes' (solo si rol='paciente')
  
  // Timestamps
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
  ultimoAcceso?: Date | Timestamp;
}

/**
 * Modelo de Profesional (Solo datos profesionales - NO datos personales)
 * 
 * ⚠️ IMPORTANTE:
 * - NO incluir: email, rut, displayName, telefono (están en Usuario)
 * - Siempre debe tener idUsuario (obligatorio)
 * - Para obtener datos completos, hacer JOIN con usuarios
 */
export interface Profesional {
  id: string;                    // ID del documento en Firestore
  idUsuario: string;             // FK a usuarios.id (OBLIGATORIO)
  
  // Datos profesionales específicos
  especialidad?: string;
  subespecialidad?: string;
  licenciaMedica?: string;
  experienciaAnios?: number;
  curriculum?: string;
  
  // Configuración de atención
  horarioAtencion?: {
    [dia: string]: {
      inicio: string;
      fin: string;
    };
  };
  valorConsulta?: number;
  tiempoConsulta?: number;       // en minutos
  
  // Timestamps
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}

/**
 * Modelo combinado para vistas que necesitan datos completos
 * 
 * Uso: Mostrar perfil del profesional con nombre, email, especialidad, etc.
 */
export interface ProfesionalCompleto {
  // Datos del usuario
  id: string;
  email: string;
  displayName: string;
  rut: string;
  telefono?: string;
  photoURL?: string;
  rol: string;
  activo: boolean;
  
  // Datos del profesional
  idProfesional: string;
  especialidad?: string;
  subespecialidad?: string;
  licenciaMedica?: string;
  experienciaAnios?: number;
  curriculum?: string;
  horarioAtencion?: any;
  valorConsulta?: number;
  tiempoConsulta?: number;
}
