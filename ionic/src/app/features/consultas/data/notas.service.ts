import { Injectable, inject } from '@angular/core';
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
  private firestore = inject(Firestore);

  constructor() {}

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
    console.log('🔍 NotasService.getNotasByPaciente()');
    console.log('   📌 Buscando notas con idPaciente:', idPaciente);
    console.log('   📌 Colección:', this.notasCollection);
    
    try {
      // TEMPORAL: Sin orderBy para verificar si el problema es el índice
      const q = query(
        collection(this.firestore, this.notasCollection),
        where('idPaciente', '==', idPaciente)
        // orderBy('fecha', 'desc')  // Comentado temporalmente
      );

      console.log('   🔍 Query construida (SIN orderBy), ejecutando getDocs...');
      const snapshot = await getDocs(q);
      console.log('   📊 Documentos encontrados:', snapshot.size);
      
      const notas = snapshot.docs.map(doc => {
        const data = doc.data();
        console.log('   📄 Documento:', doc.id, {
          idPaciente: data['idPaciente'],
          contenido: data['contenido']?.substring(0, 30),
          fecha: data['fecha']
        });
        return {
          id: doc.id,
          ...data
        } as Nota;
      });
      
      // Ordenar manualmente por fecha en lugar de usar orderBy de Firestore
      notas.sort((a, b) => {
        const fechaA = a.fecha as any;
        const fechaB = b.fecha as any;
        // Manejar timestamps de Firestore
        const timeA = fechaA?.seconds || fechaA?.toMillis?.() || 0;
        const timeB = fechaB?.seconds || fechaB?.toMillis?.() || 0;
        return timeB - timeA; // Descendente
      });
      
      console.log('   ✅ Notas mapeadas y ordenadas:', notas.length);
      return notas;
    } catch (error) {
      console.error('   ❌ Error en getNotasByPaciente:', error);
      throw error;
    }
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
