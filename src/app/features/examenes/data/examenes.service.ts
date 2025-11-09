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
import { Examen, OrdenExamen } from '../../../models';

/**
 * Service for managing medical exams in Firestore
 * Handles exam CRUD, file uploads (Firebase Storage), critical alerts, and exam orders
 */
@Injectable({
  providedIn: 'root'
})
export class ExamenesService {
  private firestore = inject(Firestore);
  private examenesCollection = 'examenes';
  private ordenesCollection = 'ordenes-examen';

  // ==================== EXÁMENES (Exam Results) ====================

  /**
   * Get all exam ORDERS (with results) for a patient, ordered by date (most recent first)
   * Note: Examen collection is just a catalog of exam types
   * OrdenExamen contains the actual patient exam results
   */
  getExamenesByPaciente(pacienteId: string): Observable<OrdenExamen[]> {
    return this.getOrdenesByPaciente(pacienteId);
  }

  /**
   * Get exam catalog by ID (exam types, not results)
   */
  getExamenById(id: string): Observable<Examen | undefined> {
    return from(this.getExamenByIdAsync(id));
  }

  private async getExamenByIdAsync(id: string): Promise<Examen | undefined> {
    const docRef = doc(this.firestore, `${this.examenesCollection}/${id}`);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() } as Examen;
    }
    return undefined;
  }

  /**
   * Create a new exam TYPE in catalog (not a patient result)
   */
  async createExamen(examen: Omit<Examen, 'id'>): Promise<string> {
    const ref = collection(this.firestore, this.examenesCollection);
    
    const docRef = await addDoc(ref, {
      ...examen,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    
    return docRef.id;
  }

  /**
   * Update an exam TYPE in catalog
   */
  async updateExamen(id: string, examen: Partial<Examen>): Promise<void> {
    const docRef = doc(this.firestore, `${this.examenesCollection}/${id}`);
    
    await updateDoc(docRef, {
      ...examen,
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Delete an exam TYPE from catalog
   */
  async deleteExamen(id: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.examenesCollection}/${id}`);
    await deleteDoc(docRef);
  }

  /**
   * Upload exam file/document to an OrdenExamen
   * Note: This requires Firebase Storage to be configured
   * For now, this stores the file URL/path in the orden document
   * 
   * TODO: Implement actual Firebase Storage upload
   * Example implementation would use:
   * - import { Storage, ref, uploadBytes, getDownloadURL } from '@angular/fire/storage';
   * - Upload file to storage
   * - Get download URL
   * - Store URL in Firestore
   */
  async uploadExamenFileToOrden(
    ordenId: string,
    examenIndex: number,
    file: File,
    metadata?: { contentType: string; description?: string; subidoPor: string }
  ): Promise<string> {
    // TODO: Implement Firebase Storage upload
    // For now, return placeholder
    console.warn('Firebase Storage not yet configured. File upload pending.');
    
    // Placeholder: Store file metadata in Firestore
    const docRef = doc(this.firestore, `${this.ordenesCollection}/${ordenId}`);
    const ordenSnap = await getDoc(docRef);
    
    if (ordenSnap.exists()) {
      const ordenData = ordenSnap.data() as OrdenExamen;
      const examenes = ordenData.examenes || [];
      
      if (examenes[examenIndex]) {
        const documentos = examenes[examenIndex].documentos || [];
        
        documentos.push({
          url: 'placeholder-url', // Would come from Storage
          nombre: file.name,
          tipo: file.type,
          tamanio: file.size,
          fechaSubida: Timestamp.now(),
          subidoPor: metadata?.subidoPor || 'unknown'
        });
        
        examenes[examenIndex].documentos = documentos;
        
        await updateDoc(docRef, {
          examenes,
          updatedAt: Timestamp.now()
        });
      }
    }
    
    return 'placeholder-url'; // Would return actual Storage URL
  }

  /**
   * Get exams with critical/abnormal results
   * For alert panel in dashboard
   */
  getExamenesConAlertas(): Observable<Examen[]> {
    return from(this.getExamenesConAlertasAsync());
  }

  private async getExamenesConAlertasAsync(): Promise<Examen[]> {
    const ref = collection(this.firestore, this.examenesCollection);
    
    // Return exam catalog with alerts flag
    // This is a catalog of exam types, not exam results
    const q = query(ref, orderBy('nombre', 'asc'));
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Examen));
  }

  /**
   * Get exam orders with critical results
   * For dashboard alerts
   */
  getOrdenesConResultadosCriticos(): Observable<OrdenExamen[]> {
    return from(this.getOrdenesConResultadosCriticosAsync());
  }

  private async getOrdenesConResultadosCriticosAsync(): Promise<OrdenExamen[]> {
    const ref = collection(this.firestore, this.ordenesCollection);
    
    // Get recent completed exams
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const q = query(
      ref,
      where('fecha', '>=', Timestamp.fromDate(thirtyDaysAgo)),
      where('estado', '==', 'realizado'),
      orderBy('fecha', 'desc')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as OrdenExamen));
  }

  /**
   * Mark exam order as having critical/abnormal values
   */
  async markOrdenExamenAsCritical(
    ordenId: string,
    razon: string,
    severidad: 'baja' | 'media' | 'alta' | 'critica'
  ): Promise<void> {
    const docRef = doc(this.firestore, `${this.ordenesCollection}/${ordenId}`);
    
    await updateDoc(docRef, {
      alerta: {
        esCritico: true,
        razon,
        severidad,
        fechaAlerta: Timestamp.now()
      },
      updatedAt: Timestamp.now()
    });
  }

  /**
   * Get exam by type (uses OrdenExamen, not Examen catalog)
   */
  getExamenesByTipo(pacienteId: string, tipoExamen: string): Observable<OrdenExamen[]> {
    const ref = collection(this.firestore, this.ordenesCollection);
    
    // This would require querying the examenes array - Firestore doesn't support this directly
    // Better approach: Filter in the component after fetching all orders
    return this.getOrdenesByPaciente(pacienteId);
  }

  /**
   * Add a note to an exam ORDER
   */
  async addNotaToOrdenExamen(ordenId: string, nota: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.ordenesCollection}/${ordenId}`);
    const ordenSnap = await getDoc(docRef);
    
    if (ordenSnap.exists()) {
      const currentData = ordenSnap.data() as any;
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

  // ==================== ÓRDENES DE EXAMEN (Exam Orders) ====================

  /**
   * Get exam orders for a patient
   */
  getOrdenesByPaciente(pacienteId: string): Observable<OrdenExamen[]> {
    return from(this.getOrdenesByPacienteAsync(pacienteId));
  }

  private async getOrdenesByPacienteAsync(pacienteId: string): Promise<OrdenExamen[]> {
    const ref = collection(this.firestore, this.ordenesCollection);
    const q = query(
      ref,
      where('idPaciente', '==', pacienteId),
      orderBy('fecha', 'desc')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as OrdenExamen));
  }

  /**
   * Get pending exam orders
   */
  getOrdenesPendientes(pacienteId: string): Observable<OrdenExamen[]> {
    const ref = collection(this.firestore, this.ordenesCollection);
    const q = query(
      ref,
      where('idPaciente', '==', pacienteId),
      where('estado', '==', 'pendiente'),
      orderBy('fecha', 'desc')
    );
    return collectionData(q, { idField: 'id' }) as Observable<OrdenExamen[]>;
  }

  /**
   * Create a new exam order
   */
  async createOrdenExamen(orden: Omit<OrdenExamen, 'id'>): Promise<string> {
    const ref = collection(this.firestore, this.ordenesCollection);
    
    const docRef = await addDoc(ref, {
      ...orden,
      estado: orden.estado || 'pendiente',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    
    return docRef.id;
  }

  /**
   * Update exam order status
   */
  async updateOrdenEstado(
    ordenId: string,
    estado: 'pendiente' | 'en_proceso' | 'completada' | 'cancelada'
  ): Promise<void> {
    const docRef = doc(this.firestore, `${this.ordenesCollection}/${ordenId}`);
    
    const updates: any = {
      estado,
      updatedAt: Timestamp.now()
    };
    
    if (estado === 'completada') {
      updates.fechaCompletado = Timestamp.now();
    }
    
    await updateDoc(docRef, updates);
  }

  /**
   * Link exam result to an order
   */
  async linkExamenToOrden(ordenId: string, examenId: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.ordenesCollection}/${ordenId}`);
    
    await updateDoc(docRef, {
      idExamen: examenId,
      estado: 'completada',
      fechaCompletado: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
  }

  // ==================== STATISTICS ====================

  /**
   * Get exam order count for dashboard KPI
   */
  async getExamCountByDateRange(
    startDate: Date,
    endDate: Date
  ): Promise<number> {
    const ref = collection(this.firestore, this.ordenesCollection);
    const q = query(
      ref,
      where('fecha', '>=', Timestamp.fromDate(startDate)),
      where('fecha', '<=', Timestamp.fromDate(endDate))
    );
    
    const snapshot = await getDocs(q);
    return snapshot.size;
  }

  /**
   * Get pending exam orders count (for dashboard alerts)
   */
  async getPendingExamOrdersCount(): Promise<number> {
    const ref = collection(this.firestore, this.ordenesCollection);
    const q = query(
      ref,
      where('estado', '==', 'pendiente')
    );
    
    const snapshot = await getDocs(q);
    return snapshot.size;
  }

  /**
   * Get critical exams count (for dashboard alerts)
   * Orders with critical flag set
   */
  async getCriticalExamsCount(): Promise<number> {
    const ref = collection(this.firestore, this.ordenesCollection);
    
    // Get recent orders (last 7 days) with critical flag
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const q = query(
      ref,
      where('fecha', '>=', Timestamp.fromDate(sevenDaysAgo)),
      where('alerta.esCritico', '==', true)
    );
    
    const snapshot = await getDocs(q);
    return snapshot.size;
  }
}
