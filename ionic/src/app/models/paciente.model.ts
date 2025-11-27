import { Timestamp } from '@angular/fire/firestore';

/**
 * Modelo de Paciente (Solo datos médicos - NO datos personales)
 * 
 * ⚠️ IMPORTANTE:
 * - NO incluir: email, rut, nombre, apellido, telefono (están en Usuario)
 * - Siempre debe tener idUsuario (obligatorio)
 * - Para obtener datos completos, hacer JOIN con usuarios
 */
export interface Paciente {
  id?: string;
  idUsuario: string;             // FK a usuarios.id (OBLIGATORIO)
  
  // Datos médicos específicos (NO incluir datos personales)
  fechaNacimiento?: Date | Timestamp;
  sexo?: 'M' | 'F' | 'Otro';
  grupoSanguineo?: 'A+' | 'A-' | 'B+' | 'B-' | 'AB+' | 'AB-' | 'O+' | 'O-';
  alergias?: string[];
  enfermedadesCronicas?: string[];
  medicamentosActuales?: Array<{
    nombre: string;
    dosis: string;
    frecuencia: string;
  }>;
  contactoEmergencia?: {
    nombre: string;
    telefono: string;
    relacion: string;
  };
  prevision?: 'FONASA' | 'ISAPRE' | 'Particular';
  numeroFicha?: string;
  observaciones?: string;
  alertasMedicas?: AlertaMedica[];
  
  // Timestamps
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}

/**
 * Modelo combinado Usuario + Paciente
 * Uso: Mostrar datos completos del paciente con información personal
 */
export interface PacienteCompleto {
  // Datos del usuario (de colección 'usuarios')
  id: string;                    // UID del usuario
  email: string;
  displayName: string;           // Nombre completo
  rut: string;
  telefono?: string;
  photoURL?: string;
  rol: string;
  activo: boolean;
  
  // Datos del paciente (de colección 'pacientes')
  idPaciente: string;            // ID del documento paciente
  idUsuario: string;             // FK a usuarios.id (para compatibilidad con Paciente)
  fechaNacimiento?: Date | Timestamp;
  sexo?: 'M' | 'F' | 'Otro';
  grupoSanguineo?: string;
  alergias?: string[];
  enfermedadesCronicas?: string[];
  medicamentosActuales?: Array<{
    nombre: string;
    dosis: string;
    frecuencia: string;
  }>;
  contactoEmergencia?: any;
  prevision?: string;
  numeroFicha?: string;
  observaciones?: string;
  alertasMedicas?: AlertaMedica[];
  
  // Para compatibilidad con código existente
  nombre?: string;               // Derivado de displayName (split)
  apellido?: string;             // Derivado de displayName (split)
  nombreCompleto?: string;       // Alias de displayName
}

export interface AlertaMedica {
  tipo: 'alergia' | 'enfermedad_cronica' | 'medicamento_critico' | 'otro';
  descripcion: string;
  severidad: 'baja' | 'media' | 'alta' | 'critica';
  fechaRegistro: Date | Timestamp;
}

