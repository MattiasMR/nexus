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
  
  // OCR y edición de texto
  textoExtraido?: string;           // Texto extraído por OCR
  textoEditado?: string;            // Texto editado por el usuario
  confianzaOCR?: number;            // Confianza del OCR (0-100)
  historialEdiciones?: EdicionTexto[];  // Historial de cambios
}

export interface EdicionTexto {
  fecha: Date | Timestamp;
  usuario: string;        // ID del usuario que editó
  textoAnterior: string;
  textoNuevo: string;
  cambios: string;        // Descripción de los cambios
}
