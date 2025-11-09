import { Timestamp } from '@angular/fire/firestore';

// Catálogo de exámenes disponibles
export interface Examen {
  id?: string;
  nombre: string;
  descripcion?: string;
  tipo: 'laboratorio' | 'imagenologia' | 'otro';
  codigo?: string;
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}
