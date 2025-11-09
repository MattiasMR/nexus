import { Timestamp } from '@angular/fire/firestore';

export interface Paciente {
  id?: string;
  rut: string;
  nombre: string;
  apellido: string;
  fechaNacimiento: Date | Timestamp;
  direccion: string;
  telefono: string;
  email?: string;
  sexo: 'M' | 'F' | 'Otro';
  grupoSanguineo?: string;
  
  // Problem List (requisito: alertas y enfermedades)
  alergias?: string[];
  enfermedadesCronicas?: string[];
  alertasMedicas?: AlertaMedica[];
  
  // Para búsqueda mejorada
  nombreCompleto?: string; // "Juan Pérez" para búsqueda
  
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}

export interface AlertaMedica {
  tipo: 'alergia' | 'enfermedad_cronica' | 'medicamento_critico' | 'otro';
  descripcion: string;
  severidad: 'baja' | 'media' | 'alta' | 'critica';
  fechaRegistro: Date | Timestamp;
}
