import { Timestamp } from '@angular/fire/firestore';

export interface FichaMedica {
  id?: string;
  idPaciente: string;
  fechaMedica: Date | Timestamp;
  
  // Datos generales de la ficha
  observacion?: string;
  
  // Antecedentes médicos
  antecedentes?: {
    familiares?: string;
    personales?: string;
    quirurgicos?: string;
    hospitalizaciones?: string;
    alergias?: string[];
  };
  
  // Episodios/Consultas se manejan en colección separada
  // pero podemos tener un contador
  totalConsultas?: number;
  ultimaConsulta?: Date | Timestamp;
  
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}
