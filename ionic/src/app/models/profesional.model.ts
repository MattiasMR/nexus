import { Timestamp } from '@angular/fire/firestore';

export interface Profesional {
  id?: string;
  rut: string;
  nombre: string;
  apellido: string;
  especialidad?: string;
  telefono?: string;
  email?: string;
  licencia?: string;
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}
