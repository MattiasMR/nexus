import { Timestamp } from '@angular/fire/firestore';

// Catálogo de medicamentos
export interface Medicamento {
  id?: string;
  nombre: string;
  nombreGenerico?: string;
  presentacion?: string;
  concentracion?: string;
  viaAdministracion?: string[];
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}
