import { Timestamp } from '@angular/fire/firestore';

export interface Receta {
  id?: string;
  idPaciente: string;
  idProfesional: string;
  idConsulta?: string;
  fecha: Date | Timestamp;
  medicamentos: MedicamentoRecetado[];
  observaciones?: string;
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}

export interface MedicamentoRecetado {
  idMedicamento: string;
  nombreMedicamento: string;
  dosis: string;
  frecuencia: string;
  duracion: string;
  indicaciones?: string;
}
