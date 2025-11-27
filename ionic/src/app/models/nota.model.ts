import { Timestamp } from '@angular/fire/firestore';

export interface Nota {
  id?: string;
  idPaciente: string;
  idProfesional: string;
  contenido: string;
  fecha: Date | Timestamp;
  
  // Asociación opcional
  tipoAsociacion?: 'consulta' | 'examen' | 'orden' | null;
  idAsociado?: string; // ID de la consulta, examen u orden
  nombreAsociado?: string; // Nombre descriptivo para mostrar
  
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}
