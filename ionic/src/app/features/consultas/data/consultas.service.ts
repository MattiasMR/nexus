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
import { Consulta, NotaRapida } from '../../../models/consulta.model';
import { FichasMedicasService } from '../../fichas-medicas/data/fichas-medicas.service';

/**
 * Service for managing medical consultations in Firestore
 * Handles consultation CRUD, evolution timeline, and quick notes
 */
@Injectable({
  providedIn: 'root'
})
export class ConsultasService {
  private firestore = inject(Firestore);
  private fichasMedicasService = inject(FichasMedicasService);
  private collectionName = 'consultas';

  /**
   * Get all consultations for a specific patient
   * Ordered chronologically (most recent first)
   */
  getConsultasByPaciente(pacienteId: string): Observable<Consulta[]> {
    return from(this.getConsultasByPacienteAsync(pacienteId));
  }

  private async getConsultasByPacienteAsync(pacienteId: string): Promise<Consulta[]> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(
      ref,
      where('idPaciente', '==', pacienteId),
      orderBy('fecha', 'desc')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Consulta));
  }

  /**
   * Get medical evolution timeline (chronological order, oldest first)
   * For displaying patient medical history progression
   */
  getEvolutionTimeline(pacienteId: string): Observable<Consulta[]> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(
      ref,
      where('idPaciente', '==', pacienteId),
      orderBy('fecha', 'asc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Consulta[]>;
  }

  /**
   * Get a single consultation by ID
   */
  getConsultaById(id: string): Observable<Consulta | undefined> {
    return from(this.getConsultaByIdAsync(id));
  }

  private async getConsultaByIdAsync(id: string): Promise<Consulta | undefined> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() } as Consulta;
    }
    return undefined;
  }

  /**
   * Get recent consultations (for dashboard)
   * @param limitCount Number of recent consultations to fetch
   */
  getRecentConsultations(limitCount: number = 10): Observable<Consulta[]> {
    return from(this.getRecentConsultationsAsync(limitCount));
  }

  private async getRecentConsultationsAsync(limitCount: number): Promise<Consulta[]> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(
      ref,
      orderBy('fecha', 'desc'),
      limit(limitCount)
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Consulta));
  }

  /**
   * Get consultations by professional/doctor
   */
  getConsultasByProfesional(profesionalId: string): Observable<Consulta[]> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(
      ref,
      where('idProfesional', '==', profesionalId),
      orderBy('fecha', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<Consulta[]>;
  }

  /**
   * Create a new consultation
   * Automatically updates the ficha médica consultation counter
   */
  async createConsulta(consulta: Omit<Consulta, 'id'>): Promise<string> {
    const ref = collection(this.firestore, this.collectionName);
    
    const docRef = await addDoc(ref, {
      ...consulta,
      notas: consulta.notas || [],
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    
    // Update ficha médica consultation count
    if (consulta.idFichaMedica) {
      await this.fichasMedicasService.incrementConsultationCount(consulta.idFichaMedica);
    }
    
    return docRef.id;
  }

  /**
   * Update an existing consultation
   */
  async updateConsulta(id: string, consulta: Partial<Consulta>): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    
    await updateDoc(docRef, {
      ...consulta,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Delete a consultation
   */
  async deleteConsulta(id: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    await deleteDoc(docRef);
  }

  /**
   * Add a quick note to a consultation
   */
  async addNotaRapida(
    consultaId: string,
    nota: {
      texto: string;
      autor: string; // ID del profesional
    }
  ): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${consultaId}`);
    const consultaSnap = await getDoc(docRef);
    
    if (consultaSnap.exists()) {
      const currentData = consultaSnap.data() as Consulta;
      const notas = currentData.notas || [];
      
      const nuevaNota: NotaRapida = {
        ...nota,
        fecha: Timestamp.now()
      };
      
      notas.push(nuevaNota);
      
      await updateDoc(docRef, {
        notas,
        updatedAt: Timestamp.now()
      });
    }
  }

  /**
   * Update treatment in a consultation
   */
  async updateTratamiento(consultaId: string, tratamiento: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${consultaId}`);
    
    await updateDoc(docRef, {
      tratamiento,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Update observations in a consultation
   */
  async updateObservaciones(consultaId: string, observaciones: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${consultaId}`);
    
    await updateDoc(docRef, {
      observaciones,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Get consultations count for today (for dashboard KPI)
   */
  async getConsultationsCountToday(): Promise<number> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayTimestamp = Timestamp.fromDate(today);
    
    const ref = collection(this.firestore, this.collectionName);
    const q = query(
      ref,
      where('fecha', '>=', todayTimestamp)
    );
    
    const snapshot = await getDocs(q);
    return snapshot.size;
  }

  /**
   * Get consultations count by date range
   */
  async getConsultationsCountByDateRange(
    startDate: Date,
    endDate: Date
  ): Promise<number> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(
      ref,
      where('fecha', '>=', Timestamp.fromDate(startDate)),
      where('fecha', '<=', Timestamp.fromDate(endDate))
    );
    
    const snapshot = await getDocs(q);
    return snapshot.size;
  }

  /**
   * Get consultations grouped by professional
   * Groups consultations by professional ID and counts them
   */
  async getConsultationsBySpecialty(): Promise<{ [specialty: string]: number }> {
    const ref = collection(this.firestore, this.collectionName);
    const snapshot = await getDocs(ref);
    
    const professionals: { [key: string]: number } = {};
    
    snapshot.forEach(doc => {
      const data = doc.data() as Consulta;
      // Group by professional ID
      const professionalId = data.idProfesional || 'Sin asignar';
      professionals[professionalId] = (professionals[professionalId] || 0) + 1;
    });
    
    return professionals;
  }

  /**
   * Get last consultation date for a patient
   */
  async getLastConsultationDate(pacienteId: string): Promise<Date | null> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(
      ref,
      where('idPaciente', '==', pacienteId),
      orderBy('fecha', 'desc'),
      limit(1)
    );
    
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) return null;
    
    const consulta = snapshot.docs[0].data() as Consulta;
    return consulta.fecha instanceof Timestamp 
      ? consulta.fecha.toDate() 
      : null;
  }
}
