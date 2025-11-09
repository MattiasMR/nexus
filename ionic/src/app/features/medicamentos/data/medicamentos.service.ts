import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  collectionData,
  doc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  Timestamp,
  getDoc,
  getDocs,
} from '@angular/fire/firestore';
import { Observable, from } from 'rxjs';
import { Receta, Medicamento } from '../../../models';

/**
 * Service for managing medications and prescriptions in Firestore
 * Handles prescription CRUD, medication tracking, and notes
 */
@Injectable({
  providedIn: 'root'
})
export class MedicamentosService {
  private firestore = inject(Firestore);
  private recetasCollection = 'recetas';
  private medicamentosCollection = 'medicamentos';

  // ==================== RECETAS (Prescriptions) ====================

  /**
   * Get all prescriptions for a patient
   */
  getRecetasByPaciente(pacienteId: string): Observable<Receta[]> {
    const ref = collection(this.firestore, this.recetasCollection);
    const q = query(
      ref,
      where('idPaciente', '==', pacienteId),
      orderBy('fecha', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Receta[]>;
  }

  /**
   * Get active prescriptions for a patient
   * Note: Since Receta model doesn't have fechaFin, we consider all recent prescriptions as active
   * In production, you might want to add fechaFin to the Receta model
   */
  getRecetasActivas(pacienteId: string): Observable<Receta[]> {
    const ref = collection(this.firestore, this.recetasCollection);
    
    // Get prescriptions from the last 90 days
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);
    
    const q = query(
      ref,
      where('idPaciente', '==', pacienteId),
      where('fecha', '>=', Timestamp.fromDate(ninetyDaysAgo)),
      orderBy('fecha', 'desc')
    );
    
    return collectionData(q, { idField: 'id' }) as Observable<Receta[]>;
  }

  /**
   * Get a single prescription by ID
   */
  getRecetaById(id: string): Observable<Receta | undefined> {
    return from(this.getRecetaByIdAsync(id));
  }

  private async getRecetaByIdAsync(id: string): Promise<Receta | undefined> {
    const docRef = doc(this.firestore, `${this.recetasCollection}/${id}`);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() } as Receta;
    }
    return undefined;
  }

  /**
   * Create a new prescription
   */
  async createReceta(receta: Omit<Receta, 'id'>): Promise<string> {
    const ref = collection(this.firestore, this.recetasCollection);
    
    const docRef = await addDoc(ref, {
      ...receta,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    
    return docRef.id;
  }

  /**
   * Update an existing prescription
   */
  async updateReceta(id: string, receta: Partial<Receta>): Promise<void> {
    const docRef = doc(this.firestore, `${this.recetasCollection}/${id}`);
    
    await updateDoc(docRef, {
      ...receta,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Delete a prescription
   */
  async deleteReceta(id: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.recetasCollection}/${id}`);
    await deleteDoc(docRef);
  }

  /**
   * Add a note to a prescription
   */
  async addNotaToReceta(recetaId: string, nota: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.recetasCollection}/${recetaId}`);
    const recetaSnap = await getDoc(docRef);
    
    if (recetaSnap.exists()) {
      const currentData = recetaSnap.data() as any;
      const notas = currentData.notas || [];
      
      notas.push({
        texto: nota,
        fecha: Timestamp.now()
      });
      
      await updateDoc(docRef, {
        notas,
        updatedAt: Timestamp.now()
      });
    }
  }

  // ==================== MEDICAMENTOS (Medications) ====================

  /**
   * Get all medications (medication catalog)
   */
  getAllMedicamentos(): Observable<Medicamento[]> {
    const ref = collection(this.firestore, this.medicamentosCollection);
    const q = query(ref, orderBy('nombre', 'asc'));
    return collectionData(q, { idField: 'id' }) as Observable<Medicamento[]>;
  }

  /**
   * Search medications by name
   */
  searchMedicamentos(searchTerm: string): Observable<Medicamento[]> {
    const ref = collection(this.firestore, this.medicamentosCollection);
    return new Observable(observer => {
      collectionData(ref, { idField: 'id' }).subscribe({
        next: (medicamentos: any[]) => {
          const term = searchTerm.toLowerCase().trim();
          if (!term) {
            observer.next(medicamentos as Medicamento[]);
            return;
          }
          
          const filtered = medicamentos.filter((m: Medicamento) => {
            return m.nombre.toLowerCase().includes(term) ||
                   m.nombreGenerico?.toLowerCase().includes(term);
          });
          
          observer.next(filtered as Medicamento[]);
        },
        error: (err) => observer.error(err),
        complete: () => observer.complete()
      });
    });
  }

  /**
   * Get medication by ID
   */
  getMedicamentoById(id: string): Observable<Medicamento | undefined> {
    return from(this.getMedicamentoByIdAsync(id));
  }

  private async getMedicamentoByIdAsync(id: string): Promise<Medicamento | undefined> {
    const docRef = doc(this.firestore, `${this.medicamentosCollection}/${id}`);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() } as Medicamento;
    }
    return undefined;
  }

  /**
   * Create a new medication in catalog
   */
  async createMedicamento(medicamento: Omit<Medicamento, 'id'>): Promise<string> {
    const ref = collection(this.firestore, this.medicamentosCollection);
    
    const docRef = await addDoc(ref, {
      ...medicamento,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    
    return docRef.id;
  }

  /**
   * Update medication in catalog
   */
  async updateMedicamento(id: string, medicamento: Partial<Medicamento>): Promise<void> {
    const docRef = doc(this.firestore, `${this.medicamentosCollection}/${id}`);
    
    await updateDoc(docRef, {
      ...medicamento,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Delete medication from catalog
   */
  async deleteMedicamento(id: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.medicamentosCollection}/${id}`);
    await deleteDoc(docRef);
  }

  // ==================== STATISTICS & TRACKING ====================

  /**
   * Get active prescriptions count for dashboard
   * (Prescriptions from last 90 days)
   */
  async getActivePrescriptionsCount(): Promise<number> {
    const ref = collection(this.firestore, this.recetasCollection);
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);
    
    const q = query(
      ref,
      where('fecha', '>=', Timestamp.fromDate(ninetyDaysAgo))
    );
    
    const snapshot = await getDocs(q);
    return snapshot.size;
  }

  /**
   * Get prescriptions by professional
   */
  getRecetasByProfesional(profesionalId: string): Observable<Receta[]> {
    const ref = collection(this.firestore, this.recetasCollection);
    const q = query(
      ref,
      where('idProfesional', '==', profesionalId),
      orderBy('fecha', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Receta[]>;
  }

  /**
   * Get most prescribed medications (for statistics)
   */
  async getMostPrescribedMedicamentos(limitCount: number = 10): Promise<{ nombre: string; count: number }[]> {
    const ref = collection(this.firestore, this.recetasCollection);
    const snapshot = await getDocs(ref);
    
    const medicationCounts: { [key: string]: number } = {};
    
    snapshot.forEach(doc => {
      const data = doc.data() as Receta;
      if (data.medicamentos && data.medicamentos.length > 0) {
        data.medicamentos.forEach(med => {
          const nombre = med.nombreMedicamento;
          medicationCounts[nombre] = (medicationCounts[nombre] || 0) + 1;
        });
      }
    });
    
    return Object.entries(medicationCounts)
      .map(([nombre, count]) => ({ nombre, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, limitCount);
  }

  /**
   * Get recent prescriptions (last 30 days)
   * Since Receta model doesn't have fechaFin, we return recent prescriptions
   */
  getRecetasRecientes(days: number = 30): Observable<Receta[]> {
    return from(this.getRecetasRecientesAsync(days));
  }

  private async getRecetasRecientesAsync(days: number): Promise<Receta[]> {
    const ref = collection(this.firestore, this.recetasCollection);
    const pastDate = new Date();
    pastDate.setDate(pastDate.getDate() - days);
    
    const q = query(
      ref,
      where('fecha', '>=', Timestamp.fromDate(pastDate)),
      orderBy('fecha', 'desc')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Receta));
  }
}
