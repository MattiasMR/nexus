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
import { Observable, map, from } from 'rxjs';
import { Paciente } from '../../../models/paciente.model';

/**
 * Service for managing patient data in Firestore
 * Handles CRUD operations, search, pagination, and medical alerts
 */
@Injectable({
  providedIn: 'root'
})
export class PacientesService {
  private firestore = inject(Firestore);
  private collectionName = 'pacientes';

  /**
   * Get all patients with real-time updates
   */
  getAllPacientes(): Observable<Paciente[]> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(ref, orderBy('apellido', 'asc'));
    return collectionData(q, { idField: 'id' }) as Observable<Paciente[]>;
  }

  /**
   * Get a single patient by ID
   */
  getPacienteById(id: string): Observable<Paciente | undefined> {
    return from(this.getPacienteByIdAsync(id));
  }

  private async getPacienteByIdAsync(id: string): Promise<Paciente | undefined> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() } as Paciente;
    }
    return undefined;
  }

  /**
   * Search patients by RUT, name, or medical record number
   * Note: For full-text search, consider using Algolia or similar service
   * This implementation does basic filtering
   */
  searchPacientes(searchTerm: string): Observable<Paciente[]> {
    const ref = collection(this.firestore, this.collectionName);
    return collectionData(ref, { idField: 'id' }).pipe(
      map((pacientes: any[]) => {
        const term = searchTerm.toLowerCase().trim();
        if (!term) return pacientes as Paciente[];
        
        return pacientes.filter((p: Paciente) => {
          const nombreCompleto = `${p.nombre} ${p.apellido}`.toLowerCase();
          const rut = p.rut?.toLowerCase() || '';
          const id = p.id?.toLowerCase() || '';
          
          return nombreCompleto.includes(term) || 
                 rut.includes(term) || 
                 id.includes(term);
        }) as Paciente[];
      })
    );
  }

  /**
   * Get patients with pagination
   * @param pageSize Number of patients per page
   * @param lastVisible Last document from previous page (for cursor-based pagination)
   */
  getPacientesPaginated(pageSize: number = 20): Observable<Paciente[]> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(
      ref,
      orderBy('apellido', 'asc'),
      limit(pageSize)
    );
    return collectionData(q, { idField: 'id' }) as Observable<Paciente[]>;
  }

  /**
   * Get patients with medical alerts (allergies, chronic diseases, critical conditions)
   */
  getPacientesWithAlerts(): Observable<Paciente[]> {
    const ref = collection(this.firestore, this.collectionName);
    return collectionData(ref, { idField: 'id' }).pipe(
      map((pacientes: any[]) => {
        return pacientes.filter((p: Paciente) => {
          const hasAlergias = p.alergias && p.alergias.length > 0;
          const hasEnfermedades = p.enfermedadesCronicas && p.enfermedadesCronicas.length > 0;
          const hasAlertas = p.alertasMedicas && p.alertasMedicas.length > 0;
          
          return hasAlergias || hasEnfermedades || hasAlertas;
        }) as Paciente[];
      })
    );
  }

  /**
   * Create a new patient
   */
  async createPaciente(paciente: Omit<Paciente, 'id'>): Promise<string> {
    const ref = collection(this.firestore, this.collectionName);
    
    // Compute nombreCompleto for better search
    const nombreCompleto = `${paciente.nombre} ${paciente.apellido}`;
    
    const docRef = await addDoc(ref, {
      ...paciente,
      nombreCompleto,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    
    return docRef.id;
  }

  /**
   * Update an existing patient
   */
  async updatePaciente(id: string, paciente: Partial<Paciente>): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    
    // Update nombreCompleto if name fields changed
    const updates: any = {
      ...paciente,
      updatedAt: Timestamp.now()
    };
    
    if (paciente.nombre || paciente.apellido) {
      // Get current data to build complete name
      const currentDoc = await getDoc(docRef);
      if (currentDoc.exists()) {
        const currentData = currentDoc.data() as Paciente;
        const nombre = paciente.nombre || currentData.nombre;
        const apellido = paciente.apellido || currentData.apellido;
        updates.nombreCompleto = `${nombre} ${apellido}`;
      }
    }
    
    await updateDoc(docRef, updates);
  }

  /**
   * Delete a patient (soft delete recommended in production)
   */
  async deletePaciente(id: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${id}`);
    await deleteDoc(docRef);
  }

  /**
   * Add a medical alert to a patient
   */
  async addAlertaMedica(
    pacienteId: string, 
    alerta: {
      tipo: 'alergia' | 'enfermedad_cronica' | 'medicamento_critico' | 'otro';
      descripcion: string;
      severidad: 'baja' | 'media' | 'alta' | 'critica';
    }
  ): Promise<void> {
    const docRef = doc(this.firestore, `${this.collectionName}/${pacienteId}`);
    const currentDoc = await getDoc(docRef);
    
    if (currentDoc.exists()) {
      const currentData = currentDoc.data() as Paciente;
      const alertas = currentData.alertasMedicas || [];
      
      alertas.push({
        ...alerta,
        fechaRegistro: Timestamp.now()
      });
      
      await updateDoc(docRef, {
        alertasMedicas: alertas,
        updatedAt: Timestamp.now()
      });
    }
  }

  /**
   * Get active patients (patients with recent activity)
   * For dashboard KPIs
   */
  async getActivePatientsCount(): Promise<number> {
    const ref = collection(this.firestore, this.collectionName);
    const snapshot = await getDocs(ref);
    return snapshot.size;
  }

  /**
   * Get patients by gender for statistics
   */
  getPacientesByGender(gender: 'M' | 'F' | 'Otro'): Observable<Paciente[]> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(ref, where('sexo', '==', gender));
    return collectionData(q, { idField: 'id' }) as Observable<Paciente[]>;
  }

  /**
   * Get patients by blood type
   */
  getPacientesByBloodType(bloodType: string): Observable<Paciente[]> {
    const ref = collection(this.firestore, this.collectionName);
    const q = query(ref, where('grupoSanguineo', '==', bloodType));
    return collectionData(q, { idField: 'id' }) as Observable<Paciente[]>;
  }
}
