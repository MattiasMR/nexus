import { Timestamp } from '@angular/fire/firestore';

export interface OrdenExamen {
  id?: string;
  idPaciente: string;
  idProfesional: string;
  idConsulta?: string;
  idHospitalizacion?: string;
  fecha: Date | Timestamp;
  estado: 'pendiente' | 'realizado' | 'cancelado';
  examenes: ExamenSolicitado[];
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}

export interface ExamenSolicitado {
  idExamen: string;
  nombreExamen: string;
  resultado?: string;
  fechaResultado?: Date | Timestamp;
  
  // Documentos/imágenes (requisito: subir exámenes)
  documentos?: DocumentoExamen[];
}

export interface DocumentoExamen {
  url: string;          // URL en Firebase Storage
  nombre: string;       // Nombre del archivo
  tipo: string;         // image/jpeg, application/pdf, etc.
  tamanio: number;      // En bytes
  fechaSubida: Date | Timestamp;
  subidoPor: string;    // ID del profesional
}
