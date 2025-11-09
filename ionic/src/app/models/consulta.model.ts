import { Timestamp } from '@angular/fire/firestore';

export interface Consulta {
  id?: string;
  idPaciente: string;
  idProfesional: string;
  idFichaMedica: string;
  fecha: Date | Timestamp;
  motivo: string;
  tratamiento?: string;
  observaciones?: string;
  
  // Notas rápidas incrustadas (requisito: agregar notas)
  notas?: NotaRapida[];
  
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}

export interface NotaRapida {
  texto: string;
  autor: string; // ID del profesional
  fecha: Date | Timestamp;
}
