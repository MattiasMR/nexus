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
import { FichaMedica } from '../../../models/ficha-medica.model';

/**
 * Service for managing medical records (fichas médicas) in Firestore
 * Handles patient medical history, antecedents, and general medical file data
 */
@Injectable({
  providedIn: 'root'
})
export class FichasMedicasService {
  private firestore = inject(Firestore);
  private collectionName = 'fichas-medicas';

  /**
   * Get medical record by patient ID
   * Each patient should have one ficha médica
   * Returns Observable that emits once and completes (for forkJoin compatibility)
   */
  getFichaByPacienteId(pacienteId: string): Observable<FichaMedica | null> {
    return from(this.getFichaByPacienteIdAsync(pacienteId));
  }

  private async getFichaByPacienteIdAsync(pacienteId: string): Promise<FichaMedica | null> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(ref, where('idPaciente', '==', pacienteId), limit(1));
    
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) {
      return null;
    }
    
    const doc = snapshot.docs[0];
    return { id: doc.id, ...doc.data() } as FichaMedica;
  }

  /**
   * Get medical record by ID
   */
  getFichaById(id: string): Observable<FichaMedica | undefined> {
    return from(this.getFichaByIdAsync(id));
  }

  private async getFichaByIdAsync(id: string): Promise<FichaMedica | undefined> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() } as FichaMedica;
    }
    return undefined;
  }

  /**
   * Create a new medical record for a patient
   */
  async createFicha(ficha: Omit<FichaMedica, 'id'>): Promise<string> {
    const ref = collection(this.firestore, this.collectionName);
    
    const docRef = await addDoc(ref, {
      ...ficha,
      totalConsultas: 0,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    
    return docRef.id;
  }

  /**
   * Update medical record
   */
  async updateFicha(id: string, ficha: Partial<FichaMedica>): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    
    await updateDoc(docRef, {
      ...ficha,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Update antecedents (family, personal, surgical, hospitalizations, allergies)
   */
  async updateAntecedentes(
    fichaId: string,
    antecedentes: {
      familiares?: string;
      personales?: string;
      quirurgicos?: string;
      hospitalizaciones?: string;
      alergias?: string[];
    }
  ): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${fichaId}`);
    
    await updateDoc(docRef, {
      antecedentes,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Update observation/notes in medical record
   */
  async updateObservacion(fichaId: string, observacion: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${fichaId}`);
    
    await updateDoc(docRef, {
      observacion,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Increment consultation counter
   * Called when a new consultation is created
   */
  async incrementConsultationCount(fichaId: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${fichaId}`);
    const fichaSnap = await getDoc(docRef);
    
    if (fichaSnap.exists()) {
      const currentData = fichaSnap.data() as FichaMedica;
      const currentCount = currentData.totalConsultas || 0;
      
      await updateDoc(docRef, {
        totalConsultas: currentCount + 1,
        ultimaConsulta: Timestamp.now(),
        updatedAt: Timestamp.now()
      });
    }
  }

  /**
   * Get medical history summary (for dashboard or quick view)
   * Returns key information from the medical record
   */
  async getMedicalHistorySummary(pacienteId: string): Promise<{
    totalConsultas: number;
    ultimaConsulta?: Date;
    alergias?: string[];
    antecedentes?: {
      familiares?: string;
      personales?: string;
      quirurgicos?: string;
    };
  } | null> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(ref, where('idPaciente', '==', pacienteId), limit(1));
    const snapshot = await getDocs(q);
    
    if (snapshot.empty) return null;
    
    const ficha = snapshot.docs[0].data() as FichaMedica;
    
    return {
      totalConsultas: ficha.totalConsultas || 0,
      ultimaConsulta: ficha.ultimaConsulta instanceof Timestamp 
        ? ficha.ultimaConsulta.toDate() 
        : undefined,
      alergias: ficha.antecedentes?.alergias || [],
      antecedentes: {
        familiares: ficha.antecedentes?.familiares,
        personales: ficha.antecedentes?.personales,
        quirurgicos: ficha.antecedentes?.quirurgicos
      }
    };
  }

  /**
   * Delete medical record (use with caution)
   */
  async deleteFicha(id: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    await deleteDoc(docRef);
  }

  /**
   * Get all medical records with recent activity
   * Useful for dashboard statistics
   */
  getFichasWithRecentActivity(days: number = 30): Observable<FichaMedica[]> {
    const ref = collection(this.firestore, this.collectionName);
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);
    const cutoffTimestamp = Timestamp.fromDate(cutoffDate);
    
    const q = query(
      ref,
      where('ultimaConsulta', '>=', cutoffTimestamp),
      orderBy('ultimaConsulta', 'desc')
    );
    
    return collectionData(q, { idField: 'id' }) as Observable<FichaMedica[]>;
  }

  /**
   * Check if patient has a medical record
   */
  async hasExistingFicha(pacienteId: string): Promise<boolean> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(ref, where('idPaciente', '==', pacienteId), limit(1));
    const snapshot = await getDocs(q);
    
    return !snapshot.empty;
  }

  /**
   * Get or create medical record for patient
   * Ensures every patient has a ficha médica
   */
  async getOrCreateFicha(pacienteId: string): Promise<FichaMedica> {
    // Check if ficha exists
    const ref = collection(this.firestore, this.collectionName);
    const q = query(ref, where('idPaciente', '==', pacienteId), limit(1));
    const snapshot = await getDocs(q);
    
    if (!snapshot.empty) {
      const doc = snapshot.docs[0];
      return { id: doc.id, ...doc.data() } as FichaMedica;
    }
    
    // Create new ficha if doesn't exist
    const newFichaId = await this.createFicha({
      idPaciente: pacienteId,
      fechaMedica: Timestamp.now(),
      observacion: '',
      antecedentes: {
        familiares: '',
        personales: '',
        quirurgicos: '',
        hospitalizaciones: '',
        alergias: []
      },
      totalConsultas: 0
    });
    
    const newFichaSnap = await getDoc(doc(this.firestore, `${this.collectionName}/${newFichaId}`));
    return { id: newFichaSnap.id, ...newFichaSnap.data() } as FichaMedica;
  }
}
