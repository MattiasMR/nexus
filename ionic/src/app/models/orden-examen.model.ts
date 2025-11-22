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
  textoExtraido?: string;           // Texto extraído por OCR (versión inicial)
  textoActual?: string;             // Versión actual del texto (la más reciente)
  confianzaOCR?: number;            // Confianza del OCR (0-100)
  historialVersiones?: VersionTexto[];  // Historial de versiones anteriores
}

export interface VersionTexto {
  fecha: Date | Timestamp;
  usuario: string;        // ID del usuario que editó
  texto: string;          // Contenido completo de esta versión
  descripcion?: string;   // Descripción opcional del cambio
}
