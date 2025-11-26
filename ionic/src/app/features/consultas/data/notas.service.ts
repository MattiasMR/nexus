import { Injectable } from '@angular/core';
import { 
  Firestore, 
  collection, 
  addDoc, 
  updateDoc, 
  deleteDoc, 
  doc, 
  query, 
  where, 
  orderBy, 
  getDocs,
  Timestamp 
} from '@angular/fire/firestore';
import { Nota } from '../../../models/nota.model';

@Injectable({
  providedIn: 'root'
})
export class NotasService {
  private notasCollection = 'notas';

  constructor(private firestore: Firestore) {}

  /**
   * Crear una nueva nota
   */
  async createNota(nota: Omit<Nota, 'id'>): Promise<string> {
    const notaData = {
      ...nota,
      fecha: Timestamp.now(),
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    };

    const docRef = await addDoc(
      collection(this.firestore, this.notasCollection),
      notaData
    );

    return docRef.id;
  }

  /**
   * Obtener todas las notas de un paciente
   */
  async getNotasByPaciente(idPaciente: string): Promise<Nota[]> {
    const q = query(
      collection(this.firestore, this.notasCollection),
      where('idPaciente', '==', idPaciente),
      orderBy('fecha', 'desc')
    );

    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Nota));
  }

  /**
   * Obtener notas asociadas a una consulta específica
   */
  async getNotasByConsulta(idConsulta: string): Promise<Nota[]> {
    const q = query(
      collection(this.firestore, this.notasCollection),
      where('idAsociado', '==', idConsulta),
      where('tipoAsociacion', '==', 'consulta'),
      orderBy('fecha', 'desc')
    );

    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Nota));
  }

  /**
   * Obtener notas asociadas a un examen específico
   */
  async getNotasByExamen(idExamen: string): Promise<Nota[]> {
    const q = query(
      collection(this.firestore, this.notasCollection),
      where('idAsociado', '==', idExamen),
      where('tipoAsociacion', '==', 'examen'),
      orderBy('fecha', 'desc')
    );

    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Nota));
  }

  /**
   * Obtener notas asociadas a una orden específica
   */
  async getNotasByOrden(idOrden: string): Promise<Nota[]> {
    const q = query(
      collection(this.firestore, this.notasCollection),
      where('idAsociado', '==', idOrden),
      where('tipoAsociacion', '==', 'orden'),
      orderBy('fecha', 'desc')
    );

    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Nota));
  }

  /**
   * Actualizar una nota
   */
  async updateNota(id: string, cambios: Partial<Nota>): Promise<void> {
    const docRef = doc(this.firestore, this.notasCollection, id);
    await updateDoc(docRef, {
      ...cambios,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Eliminar una nota
   */
  async deleteNota(id: string): Promise<void> {
    const docRef = doc(this.firestore, this.notasCollection, id);
    await deleteDoc(docRef);
  }
}
