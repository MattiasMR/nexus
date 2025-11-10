import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { 
  IonHeader, IonToolbar, IonTitle, IonContent, IonBadge, IonButton, 
  IonIcon, IonGrid, IonRow, IonCol, IonItem, IonLabel, IonModal, 
  IonInput, IonTextarea, IonSelect, IonSelectOption, IonDatetime,
  IonSpinner, IonToast, IonSegment, IonSegmentButton, 
  ModalController, ToastController, AlertController
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { add, create, ban, calendar, time, medical, person, warning, checkmarkCircle } from 'ionicons/icons';
import { Subscription } from 'rxjs';
import { Timestamp } from '@angular/fire/firestore';

// Servicios Firestore
import { MedicamentosService } from '../data/medicamentos.service';
import { PacientesService } from '../../pacientes/data/pacientes.service';

// Components
import { EditarMedicamentoModalComponent } from '../components/editar-medicamento-modal/editar-medicamento-modal.component';

// Modelos
import { Receta, MedicamentoRecetado } from '../../../models/receta.model';
import { Medicamento } from '../../../models/medicamento.model';

/**
 * UI interface for medication display with compatibility fields
 * Flattens first medication properties for template compatibility
 */
interface RecetaUI extends Receta {
  estado?: 'activo' | 'suspendido' | 'completado';
  medicamentosPrincipales?: string; // Comma-separated names for display
  
  // Flattened properties from first medication for template compatibility
  nombre?: string; // First medication name
  dosis?: string; // First medication dose
  frecuencia?: string; // First medication frequency
  via?: string; // Administration route
  fechaInicio?: string; // Start date
  duracion?: string; // Duration
  indicaciones?: string; // Instructions
  medicoPrescriptor?: string; // Prescribing doctor name
}

@Component({
  selector: 'app-medicamentos',
  templateUrl: './medicamentos.page.html',
  styleUrls: ['./medicamentos.page.scss'],
  standalone: true,
  imports: [
    IonHeader, IonToolbar, IonTitle, IonContent, IonBadge, IonButton, 
    IonIcon, IonGrid, IonRow, IonCol, IonItem, IonLabel, IonModal, 
    IonInput, IonTextarea, IonSelect, IonSelectOption, IonDatetime,
    IonSpinner, IonSegment, IonSegmentButton,
    CommonModule, FormsModule
  ]
})
export class MedicamentosPage implements OnInit, OnDestroy {
  
  // Estados del componente
  medicamentosActuales: RecetaUI[] = [];
  medicamentosOriginales: RecetaUI[] = []; // Store all medications
  selectedTab: 'activos' | 'completados' = 'activos'; // Tab selection
  isLoading = false;
  error: string | null = null;
  patientId: string | null = null;
  
  // Modal para crear receta/medicamento
  isCreateModalOpen = false;
  newMedication: Partial<MedicamentoRecetado> = this.blankMedicamento();
  
  // Extended form model for template compatibility (includes extra fields)
  nuevoMedicamento: Partial<MedicamentoRecetado> & {
    nombre?: string;
    via?: string;
    medicoPrescriptor?: string;
    fechaInicio?: string;
  } = this.blankMedicamento();
  
  // Modal para indicaciones
  isModalIndicacionOpen = false;
  nuevaIndicacion = {
    titulo: '',
    tipo: '',
    descripcion: '',
    estado: '',
    fecha: new Date()
  };

  // Propiedades adicionales para el HTML
  alertasInteracciones: any[] = [];
  indicacionesMedicas: any[] = [];
  historialMedicacion: RecetaUI[] = [];
  isModalOpen = false;
  
  // Catalog search
  medicamentosCatalogo: Medicamento[] = [];
  searchTerm = '';
  
  private subscriptions: Subscription[] = [];
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private medicamentosService = inject(MedicamentosService);
  private pacientesService = inject(PacientesService);
  private modalCtrl = inject(ModalController);
  private toastCtrl = inject(ToastController);
  private alertCtrl = inject(AlertController);

  constructor() {
    addIcons({ add, create, ban, calendar, time, medical, person, warning, checkmarkCircle });
  }

  ngOnInit() {
    // Obtener el ID del paciente desde los query params
    this.subscriptions.push(
      this.route.queryParams.subscribe(params => {
        this.patientId = params['patientId'];
        if (this.patientId) {
          this.loadMedications(this.patientId);
        } else {
          this.error = 'No se especificó el ID del paciente';
        }
      })
    );

    // Load medication catalog for search
    this.loadMedicamentosCatalogo();
  }

  ngOnDestroy() {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  /**
   * Cargar catálogo de medicamentos
   */
  async loadMedicamentosCatalogo() {
    try {
      const stats = await this.medicamentosService.getMostPrescribedMedicamentos(20);
      // getMostPrescribedMedicamentos returns stats, not full Medicamento objects
      // For now, we'll keep catalog empty and load on search
      this.medicamentosCatalogo = [];
    } catch (error) {
      console.error('Error loading medications catalog:', error);
    }
  }

  /**
   * Buscar medicamento en catálogo
   */
  searchMedicamento() {
    if (!this.searchTerm.trim()) {
      this.loadMedicamentosCatalogo();
      return;
    }

    this.subscriptions.push(
      this.medicamentosService.searchMedicamentos(this.searchTerm).subscribe({
        next: (medicamentos) => {
          this.medicamentosCatalogo = medicamentos;
        },
        error: (error) => {
          console.error('Error searching medications:', error);
        }
      })
    );
  }

  /**
   * Cargar recetas/medicamentos del paciente
   */
  loadMedications(patientId: string) {
    this.isLoading = true;
    this.error = null;
    
    // Get all prescriptions (not just active ones)
    this.subscriptions.push(
      this.medicamentosService.getRecetasByPaciente(patientId).subscribe({
        next: (recetas) => {
          this.medicamentosOriginales = recetas.map(this.enrichReceta);
          this.historialMedicacion = [...this.medicamentosOriginales];
          this.filterMedications(); // Apply current tab filter
          this.isLoading = false;
          console.log('Prescriptions loaded:', recetas.length);
        },
        error: (error) => {
          console.error('Error loading medications:', error);
          this.error = 'Error al cargar los medicamentos';
          this.isLoading = false;
        }
      })
    );
  }

  /**
   * Filter medications based on selected tab
   */
  filterMedications() {
    const now = new Date();
    const ninetyDaysAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
    
    if (this.selectedTab === 'activos') {
      // Active: prescribed in last 90 days
      this.medicamentosActuales = this.medicamentosOriginales.filter(med => {
        const fechaReceta = med.fecha instanceof Timestamp 
          ? med.fecha.toDate() 
          : new Date(med.fecha);
        return fechaReceta >= ninetyDaysAgo;
      });
    } else {
      // Completed: older than 90 days
      this.medicamentosActuales = this.medicamentosOriginales.filter(med => {
        const fechaReceta = med.fecha instanceof Timestamp 
          ? med.fecha.toDate() 
          : new Date(med.fecha);
        return fechaReceta < ninetyDaysAgo;
      });
    }
  }

  /**
   * Handle tab segment change
   */
  onTabChange(event: any) {
    this.selectedTab = event.detail.value;
    this.filterMedications();
  }

  /**
   * Get count of active medications (last 90 days)
   */
  get activeMedicationsCount(): number {
    const now = new Date();
    const ninetyDaysAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
    
    return this.medicamentosOriginales.filter(med => {
      const fechaReceta = med.fecha instanceof Timestamp 
        ? med.fecha.toDate() 
        : new Date(med.fecha);
      return fechaReceta >= ninetyDaysAgo;
    }).length;
  }

  /**
   * Get count of completed medications (older than 90 days)
   */
  get completedMedicationsCount(): number {
    const now = new Date();
    const ninetyDaysAgo = new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
    
    return this.medicamentosOriginales.filter(med => {
      const fechaReceta = med.fecha instanceof Timestamp 
        ? med.fecha.toDate() 
        : new Date(med.fecha);
      return fechaReceta < ninetyDaysAgo;
    }).length;
  }

  /**
   * Enrich receta with UI fields and flatten first medication for template
   */
  private enrichReceta = (receta: Receta): RecetaUI => {
    const firstMed = receta.medicamentos[0];
    const fechaReceta = receta.fecha instanceof Timestamp 
      ? receta.fecha.toDate() 
      : new Date(receta.fecha);
    
    return {
      ...receta,
      estado: 'activo', // Default, can be extended with more logic
      medicamentosPrincipales: receta.medicamentos
        .map(m => m.nombreMedicamento)
        .join(', '),
      // Flatten first medication for template compatibility
      nombre: firstMed?.nombreMedicamento || 'Sin nombre',
      dosis: firstMed?.dosis || 'No especificada',
      frecuencia: firstMed?.frecuencia || 'No especificada',
      via: 'Oral', // Default, not in model yet
      fechaInicio: fechaReceta.toLocaleDateString('es-CL'),
      duracion: firstMed?.duracion || 'No especificada',
      indicaciones: firstMed?.indicaciones || receta.observaciones || '',
      medicoPrescriptor: 'Dr. Sistema' // TODO: Lookup from idProfesional
    };
  };

  // ============== NAVEGACIÓN ==============
  goBack() {
    this.router.navigateByUrl('/tabs/tab3');
  }

  verFicha() {
    if (this.patientId) {
      this.router.navigate(['/tabs/tab3'], { 
        queryParams: { patientId: this.patientId } 
      });
    }
  }

  volverAFicha() {
    this.goBack();
  }

  // ============== CREAR MEDICAMENTO/RECETA ==============
  openCreateModal() {
    this.newMedication = this.blankMedicamento();
    this.nuevoMedicamento = this.blankMedicamento();
    this.isCreateModalOpen = true;
  }

  closeCreateModal() {
    this.isCreateModalOpen = false;
  }

  // Métodos para compatibilidad con HTML
  abrirModalNuevoMedicamento() {
    this.openCreateModal();
  }

  cerrarModal() {
    this.isModalOpen = false;
    this.isCreateModalOpen = false;
  }

  async agregarMedicamento() {
    await this.saveMedication();
  }

  async saveMedication() {
    if (!this.patientId || !this.nuevoMedicamento.nombreMedicamento?.trim()) {
      this.error = 'Nombre del medicamento es obligatorio';
      return;
    }

    this.isLoading = true;

    // Create medicamento recetado
    const medicamentoRecetado: MedicamentoRecetado = {
      idMedicamento: this.nuevoMedicamento.idMedicamento || 'manual-entry',
      nombreMedicamento: this.nuevoMedicamento.nombreMedicamento,
      dosis: this.nuevoMedicamento.dosis || 'Sin especificar',
      frecuencia: this.nuevoMedicamento.frecuencia || 'Sin especificar',
      duracion: this.nuevoMedicamento.duracion || 'Sin especificar',
      indicaciones: this.nuevoMedicamento.indicaciones
    };

    // Create receta with this medicamento
    const recetaData: Omit<Receta, 'id'> = {
      idPaciente: this.patientId,
      idProfesional: 'medico-general', // TODO: Get from auth
      fecha: Timestamp.now(),
      medicamentos: [medicamentoRecetado],
      observaciones: this.nuevoMedicamento.indicaciones || '',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    };

    try {
      const recetaId = await this.medicamentosService.createReceta(recetaData);
      console.log('Receta created with ID:', recetaId);
      
      // Reload medications
      this.loadMedications(this.patientId);
      this.closeCreateModal();
      this.error = null;
    } catch (error: any) {
      console.error('Error creating prescription:', error);
      this.error = 'Error al crear la receta: ' + (error.message || 'Desconocido');
      this.isLoading = false;
    }
  }

  // ============== GESTIÓN DE MEDICAMENTOS ==============
  
  /**
   * Open modal to modify medication prescription
   */
  async modificarMedicamento(receta: RecetaUI) {
    if (!receta.id) return;

    const modal = await this.modalCtrl.create({
      component: EditarMedicamentoModalComponent,
      componentProps: {
        receta: receta
      }
    });

    modal.present();

    const { data, role } = await modal.onWillDismiss();

    if (role === 'confirm' && data) {
      await this.actualizarReceta(receta.id, data);
    }
  }

  /**
   * Update prescription in Firestore
   */
  private async actualizarReceta(recetaId: string, updatedData: Partial<Receta>) {
    try {
      await this.medicamentosService.updateReceta(recetaId, updatedData);
      await this.showToast('Medicamento actualizado exitosamente', 'success');
      
      // Reload medications
      if (this.patientId) {
        this.loadMedications(this.patientId);
      }
    } catch (error) {
      console.error('Error updating prescription:', error);
      await this.showToast('Error al actualizar el medicamento', 'danger');
    }
  }

  /**
   * Suspend medication (mark in observaciones since model doesn't have estado field)
   * Shows confirmation dialog before suspending
   */
  async suspenderMedicamento(receta: RecetaUI) {
    if (!receta.id) return;

    // Check if already suspended
    if (receta.observaciones?.includes('[SUSPENDIDO]')) {
      await this.showToast('Este medicamento ya está suspendido', 'warning');
      return;
    }

    const alert = await this.alertCtrl.create({
      header: 'Suspender Medicamento',
      message: `¿Está seguro de que desea suspender "${receta.nombre || receta.medicamentos?.[0]?.nombreMedicamento}"?`,
      buttons: [
        {
          text: 'Cancelar',
          role: 'cancel'
        },
        {
          text: 'Suspender',
          role: 'confirm',
          handler: async () => {
            await this.marcarComoSuspendido(receta.id!);
          }
        }
      ]
    });

    await alert.present();
  }

  /**
   * Mark medication as suspended by updating observaciones
   */
  private async marcarComoSuspendido(recetaId: string) {
    try {
      const receta = this.medicamentosActuales.find(r => r.id === recetaId);
      if (!receta) return;

      const observaciones = receta.observaciones || '';
      const nuevasObservaciones = `[SUSPENDIDO - ${new Date().toLocaleDateString()}] ${observaciones}`.trim();

      await this.medicamentosService.updateReceta(recetaId, {
        observaciones: nuevasObservaciones
      });

      await this.showToast('Medicamento suspendido', 'success');
      
      // Reload medications
      if (this.patientId) {
        this.loadMedications(this.patientId);
      }
    } catch (error) {
      console.error('Error suspending medication:', error);
      await this.showToast('Error al suspender el medicamento', 'danger');
    }
  }

  /**
   * Reactivate suspended medication
   */
  async reactivarMedicamento(receta: RecetaUI) {
    if (!receta.id) return;

    try {
      // Remove [SUSPENDIDO] tag from observaciones
      const observaciones = receta.observaciones || '';
      const nuevasObservaciones = observaciones
        .replace(/\[SUSPENDIDO - \d{1,2}\/\d{1,2}\/\d{4}\]/g, '')
        .trim();

      await this.medicamentosService.updateReceta(receta.id, {
        observaciones: nuevasObservaciones || undefined
      });

      await this.showToast('Medicamento reactivado', 'success');
      
      // Reload medications
      if (this.patientId) {
        this.loadMedications(this.patientId);
      }
    } catch (error) {
      console.error('Error reactivating medication:', error);
      await this.showToast('Error al reactivar el medicamento', 'danger');
    }
  }

  async completarMedicamento(receta: RecetaUI) {
    console.log('Completar medicamento feature not implemented - requires Receta model extension');
    // TODO: Add 'estado' field to Receta model
  }

  async eliminarMedicamento(receta: RecetaUI) {
    if (!receta.id) return;
    
    const alert = await this.alertCtrl.create({
      header: 'Eliminar Medicamento',
      message: '¿Está seguro de que desea eliminar esta receta? Esta acción no se puede deshacer.',
      buttons: [
        {
          text: 'Cancelar',
          role: 'cancel'
        },
        {
          text: 'Eliminar',
          role: 'confirm',
          handler: async () => {
            try {
              await this.medicamentosService.deleteReceta(receta.id!);
              this.medicamentosActuales = this.medicamentosActuales.filter(m => m.id !== receta.id);
              await this.showToast('Receta eliminada exitosamente', 'success');
            } catch (error) {
              console.error('Error deleting prescription:', error);
              await this.showToast('Error al eliminar la receta', 'danger');
            }
          }
        }
      ]
    });

    await alert.present();
  }

  /**
   * Show toast notification
   */
  private async showToast(message: string, color: 'success' | 'danger' | 'warning' = 'success') {
    const toast = await this.toastCtrl.create({
      message,
      duration: 3000,
      position: 'top',
      color
    });
    await toast.present();
  }

  // ============== INDICACIONES MÉDICAS ==============
  abrirModalNuevaIndicacion() {
    this.nuevaIndicacion = {
      titulo: '',
      tipo: '',
      descripcion: '',
      estado: '',
      fecha: new Date()
    };
    this.isModalIndicacionOpen = true;
  }

  cerrarModalIndicacion() {
    this.isModalIndicacionOpen = false;
  }

  agregarIndicacion() {
    // TODO: Implement medical indications feature
    // This could be part of Consulta notes or a separate collection
    console.log('Agregando indicación:', this.nuevaIndicacion);
    this.cerrarModalIndicacion();
  }

  getTipoIndicacionColor(tipo: string): string {
    switch(tipo) {
      case 'critica': return 'danger';
      case 'importante': return 'warning';
      case 'informativa': return 'primary';
      default: return 'medium';
    }
  }

  completarIndicacion(indicacion: any) {
    console.log('Completar indicación:', indicacion);
    // TODO: Implement indication completion
  }

  // ============== UTILIDADES UI ==============
  estadoClass(estado: string) {
    return {
      'badge-activo': estado === 'activo',
      'badge-suspendido': estado === 'suspendido',
      'badge-completado': estado === 'completado'
    };
  }

  estadoColor(estado: string): string {
    switch (estado) {
      case 'activo': return 'success';
      case 'suspendido': return 'warning';
      case 'completado': return 'secondary';
      default: return 'medium';
    }
  }

  getEstadoColor(estado?: string): string {
    return this.estadoColor(estado || 'activo');
  }

  formatDate(date: Date | Timestamp | string | undefined): string {
    if (!date) return '';
    
    const d = date instanceof Timestamp 
      ? date.toDate() 
      : new Date(date);
    
    return d.toLocaleDateString('es-CL');
  }

  // ============== REFRESCAR DATOS ==============
  refreshMedications() {
    if (this.patientId) {
      this.loadMedications(this.patientId);
    }
  }

  clearError() {
    this.error = null;
  }

  private blankMedicamento(): Partial<MedicamentoRecetado> & {
    nombre?: string;
    via?: string;
    medicoPrescriptor?: string;
    fechaInicio?: string;
  } {
    return {
      idMedicamento: '',
      nombreMedicamento: '',
      dosis: '',
      frecuencia: '',
      duracion: '',
      indicaciones: '',
      nombre: '', // Extra field for template
      via: 'Oral', // Extra field for template
      medicoPrescriptor: '', // Extra field for template
      fechaInicio: '' // Extra field for template
    };
  }
}
