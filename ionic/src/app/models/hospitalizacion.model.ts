import { Timestamp } from '@angular/fire/firestore';

export interface Hospitalizacion {
  id?: string;
  idPaciente: string;
  idProfesional: string;
  fechaIngreso: Date | Timestamp;
  fechaAlta?: Date | Timestamp;
  habitacion?: string;
  motivoIngreso: string;
  observaciones?: string;
  intervencion?: string[];
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}
