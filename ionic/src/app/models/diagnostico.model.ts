import { Timestamp } from '@angular/fire/firestore';

export interface Diagnostico {
  id?: string;
  idConsulta?: string;
  idHospitalizacion?: string;
  codigo: string; // Código CIE-10 u otro sistema
  descripcion: string;
  tipo?: 'principal' | 'secundario';
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}
