import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { 
  IonContent, IonCard, IonCardHeader, IonCardTitle, IonCardContent, 
  IonIcon, IonButton, IonBadge, IonSpinner, IonToast, IonModal,
  IonHeader, IonToolbar, IonTitle, IonButtons, IonInput, IonTextarea,
  IonSelect, IonSelectOption, IonDatetime, IonItem, IonLabel,
  ModalController, ToastController
} from '@ionic/angular/standalone';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subscription } from 'rxjs';
import { addIcons } from 'ionicons';
import { add, create, eye, calendar, medical, clipboard } from 'ionicons/icons';
import { Timestamp } from '@angular/fire/firestore';

// Servicios Firestore
import { ExamenesService } from '../data/examenes.service';
import { PacientesService } from '../../pacientes/data/pacientes.service';

// Components
import { NuevaOrdenExamenModalComponent } from '../components/nueva-orden-examen-modal/nueva-orden-examen-modal.component';

// Modelos
import { OrdenExamen, ExamenSolicitado } from '../../../models/orden-examen.model';
import { Examen } from '../../../models/examen.model';
import { Paciente, PacienteCompleto } from '../../../models/paciente.model';

/**
 * UI interface for exam order display with flattened first exam properties
 */
interface OrdenExamenUI extends OrdenExamen {
  examenesPrincipales?: string; // Comma-separated exam names
  criticidad?: 'normal' | 'atencion' | 'critico';
  
  // Flattened properties from first exam for template compatibility
  nombre?: string; // First exam name
  resultado?: string; // First exam result
  detalle?: string; // Additional details
}

@Component({
  selector: 'app-examenes',
  templateUrl: './examenes.page.html',
  styleUrls: ['./examenes.page.scss'],
  standalone: true,
  imports: [
    IonContent, IonCard, IonCardHeader, IonCardTitle, IonCardContent, 
    IonIcon, IonButton, IonBadge, IonSpinner,
    CommonModule, FormsModule
  ]
})
export class ExamenesPage implements OnInit, OnDestroy {
  
  // Estados del componente
  examenes: OrdenExamenUI[] = [];
  isLoading = false;
  error: string | null = null;
  patientId: string | null = null;
  paciente: PacienteCompleto | null = null;
  
  // Modal para crear orden de examen
  isCreateModalOpen = false;
  newExam: Partial<ExamenSolicitado> = this.blankExamen();
  
  // Catálogo de exámenes disponibles
  examenesCatalogo: Examen[] = [];
  
  private subscriptions: Subscription[] = [];
  private examSubscription: Subscription | null = null;
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private examenesService = inject(ExamenesService);
  private pacientesService = inject(PacientesService);
  private modalCtrl = inject(ModalController);
  private toastCtrl = inject(ToastController);

  constructor() {
    addIcons({ add, create, eye, calendar, medical, clipboard });
  }

  ngOnInit() {
    // Obtener el ID del paciente desde los query params
    this.subscriptions.push(
      this.route.queryParams.subscribe(params => {
        this.patientId = params['patientId'];
        if (this.patientId) {
          // Solo cargar paciente, que a su vez cargará los exámenes con el ID correcto
          this.loadPacienteData(this.patientId);
        } else {
          this.error = 'No se especificó el ID del paciente';
        }
      })
    );

    // Load exam catalog
    this.loadExamenesCatalogo();
  }

  /**
   * Load patient data and store correct idPaciente
   */
  loadPacienteData(pacienteId: string) {
    this.subscriptions.push(
      this.pacientesService.getPacienteById(pacienteId).subscribe({
        next: (paciente) => {
          this.paciente = paciente || null;
          // IMPORTANTE: Actualizar patientId con el idPaciente correcto
          if (paciente && paciente.idPaciente) {
            this.patientId = paciente.idPaciente;
            console.log('📋 Examenes - Using correct idPaciente:', this.patientId);
            // Recargar exámenes con el ID correcto
            this.loadExams(this.patientId);
          }
        },
        error: (error) => {
          console.error('Error loading patient:', error);
        }
      })
    );
  }

  ngOnDestroy() {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  /**
   * Cargar catálogo de exámenes
   * Note: ExamenesService doesn't have getAllExamenes method
   * Catalog loading would need to be implemented in service
   */
  loadExamenesCatalogo() {
    // TODO: Implement getAllExamenes() in ExamenesService
    // For now, use empty catalog
    this.examenesCatalogo = [];
  }

  /**
   * Cargar órdenes de examen del paciente
   */
  loadExams(patientId: string) {
    this.isLoading = true;
    this.error = null;
    
    // Unsubscribe from previous exam subscription if exists
    if (this.examSubscription) {
      this.examSubscription.unsubscribe();
    }
    
    this.examSubscription = this.examenesService.getOrdenesByPaciente(patientId).subscribe({
      next: (ordenes) => {
        this.examenes = ordenes.map(this.enrichOrdenExamen);
        this.isLoading = false;
        console.log('Exam orders loaded:', ordenes.length);
      },
      error: (error) => {
        console.error('Error loading exams:', error);
        this.error = 'Error al cargar los exámenes';
        this.isLoading = false;
      }
    });
    
    // Add to subscriptions array for cleanup
    if (this.examSubscription) {
      this.subscriptions.push(this.examSubscription);
    }
  }

  /**
   * Enrich orden examen with UI fields and flatten first exam
   */
  private enrichOrdenExamen = (orden: OrdenExamen): OrdenExamenUI => {
    const firstExam = orden.examenes[0];
    
    return {
      ...orden,
      examenesPrincipales: orden.examenes
        .map(e => e.nombreExamen)
        .join(', '),
      criticidad: 'normal', // Default, can be calculated based on results
      // Flatten first exam for template compatibility
      nombre: firstExam?.nombreExamen || 'Sin nombre',
      resultado: firstExam?.resultado || 'Pendiente',
      detalle: '' // OrdenExamen doesn't have observaciones field
    };
  };

  // ============== NAVEGACIÓN ==============
  volverFicha() {
    if (this.patientId) {
      this.router.navigate(['/tabs/tab3'], { 
        queryParams: { patientId: this.patientId } 
      });
    } else {
      this.router.navigate(['/tabs/tab3']);
    }
  }

  goBack() {
    this.volverFicha();
  }

  // ============== CREAR ORDEN DE EXAMEN ==============
  async openCreateModal() {
    if (!this.paciente) {
      await this.showToast('Error: No se pudo cargar la información del paciente', 'danger');
      return;
    }

    const modal = await this.modalCtrl.create({
      component: NuevaOrdenExamenModalComponent,
      componentProps: {
        pacienteId: this.paciente.id,
        pacienteNombre: this.paciente.nombre || this.paciente.displayName || `${this.paciente.displayName?.split(' ')[0]} ${this.paciente.displayName?.split(' ').slice(1).join(' ')}`
      }
    });

    modal.present();

    const { data, role } = await modal.onWillDismiss();

    if (role === 'confirm' && data) {
      await this.guardarOrdenExamen(data);
    }
  }

  /**
   * Save exam order to Firestore
   */
  private async guardarOrdenExamen(ordenData: any) {
    try {
      const ordenId = await this.examenesService.createOrdenExamen(ordenData);
      await this.showToast('Orden de examen creada exitosamente', 'success');
      
      // Reload exams
      if (this.patientId) {
        this.loadExams(this.patientId);
      }
    } catch (error) {
      console.error('Error creating exam order:', error);
      await this.showToast('Error al crear la orden de examen', 'danger');
    }
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

  closeCreateModal() {
    this.isCreateModalOpen = false;
  }

  async saveExam() {
    if (!this.patientId || !this.newExam.nombreExamen?.trim()) {
      this.error = 'Nombre del examen es obligatorio';
      return;
    }

    this.isLoading = true;

    // Create examen solicitado
    const examenSolicitado: ExamenSolicitado = {
      idExamen: this.newExam.idExamen || 'manual-entry',
      nombreExamen: this.newExam.nombreExamen,
      resultado: this.newExam.resultado,
      documentos: []
    };

    // Create orden examen
    const ordenData: Omit<OrdenExamen, 'id'> = {
      idPaciente: this.patientId,
      idProfesional: 'medico-general', // TODO: Get from auth
      fecha: Timestamp.now(),
      estado: 'pendiente',
      examenes: [examenSolicitado],
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    };

    try {
      const ordenId = await this.examenesService.createOrdenExamen(ordenData);
      console.log('Orden de examen created with ID:', ordenId);
      
      // Reload exams
      this.loadExams(this.patientId);
      this.closeCreateModal();
      this.error = null;
    } catch (error: any) {
      console.error('Error creating exam order:', error);
      this.error = 'Error al crear la orden de examen: ' + (error.message || 'Desconocido');
      this.isLoading = false;
    }
  }

  // ============== GESTIÓN DE EXÁMENES ==============
  verDetalle(orden: OrdenExamenUI) {
    // TODO: Implementar modal o página de detalle de la orden
    console.log('Ver detalle de orden:', orden);
  }

  editarExamen(orden: OrdenExamenUI) {
    // TODO: Implementar edición de orden
    console.log('Editar orden:', orden);
  }

  async eliminarExamen(orden: OrdenExamenUI) {
    if (!orden.id) return;
    
    if (confirm('¿Está seguro de que desea eliminar esta orden de examen?')) {
      try {
        // Note: Service doesn't have deleteOrdenExamen, would need to be added
        // For now, just remove from UI
        console.warn('Delete orden examen not implemented in service');
        this.examenes = this.examenes.filter(e => e.id !== orden.id);
        // TODO: Implement deleteOrdenExamen() in ExamenesService
      } catch (error) {
        console.error('Error deleting exam order:', error);
        this.error = 'Error al eliminar la orden';
      }
    }
  }

  /**
   * Upload exam file (placeholder - requires Firebase Storage setup)
   */
  async uploadExamFile(ordenId: string, examenIndex: number, file: File) {
    try {
      await this.examenesService.uploadExamenFileToOrden(
        ordenId, 
        examenIndex, 
        file,
        {
          contentType: file.type,
          subidoPor: 'medico-general' // TODO: Get from auth
        }
      );
      console.log('File uploaded successfully (placeholder)');
      this.loadExams(this.patientId!);
    } catch (error) {
      console.error('Error uploading file:', error);
      this.error = 'Error al subir el archivo (requiere configuración de Firebase Storage)';
    }
  }

  /**
   * Mark exam order as critical
   */
  async marcarComoCritico(orden: OrdenExamenUI, razon: string = 'Valores alterados') {
    if (!orden.id) return;
    
    try {
      await this.examenesService.markOrdenExamenAsCritical(
        orden.id,
        razon,
        'alta' // Default severity
      );
      console.log('Orden marcada como crítica');
      this.loadExams(this.patientId!);
    } catch (error) {
      console.error('Error marking as critical:', error);
      this.error = 'Error al marcar como crítico';
    }
  }

  // ============== UTILIDADES UI ==============
  getBadgeColor(estado: string): string {
    switch(estado) {
      case 'realizado': return 'success';
      case 'pendiente': return 'warning';
      case 'cancelado': return 'danger';
      // For compatibility with old template
      case 'normal': return 'success';
      case 'atencion': return 'warning';
      case 'critico': return 'danger';
      case 'solicitado': return 'medium';
      case 'en_proceso': return 'primary';
      case 'completado': return 'success';
      default: return 'medium';
    }
  }

  estadoDisplay(estado: string): string {
    switch(estado) {
      case 'pendiente': return 'Pendiente';
      case 'realizado': return 'Realizado';
      case 'cancelado': return 'Cancelado';
      // Old states for compatibility
      case 'solicitado': return 'Solicitado';
      case 'en_proceso': return 'En Proceso';
      case 'completado': return 'Completado';
      case 'normal': return 'Normal';
      case 'atencion': return 'Atención';
      case 'critico': return 'Crítico';
      default: return estado;
    }
  }

  getBadgeText(estado: string): string {
    return this.estadoDisplay(estado);
  }

  tipoDisplay(tipo: string): string {
    switch(tipo) {
      case 'laboratorio': return 'Laboratorio';
      case 'imagen': return 'Imagen';
      case 'biopsia': return 'Biopsia';
      case 'funcional': return 'Funcional';
      default: return tipo;
    }
  }

  formatDate(date: Date | Timestamp | string | undefined): string {
    if (!date) return '';
    
    const d = date instanceof Timestamp 
      ? date.toDate() 
      : new Date(date);
    
    return d.toLocaleDateString('es-CL');
  }

  // ============== FILTROS Y BÚSQUEDA ==============
  filtrarPorEstado(estado: 'pendiente' | 'realizado' | 'cancelado') {
    if (!this.patientId) return;
    
    this.isLoading = true;
    
    this.subscriptions.push(
      this.examenesService.getOrdenesByPaciente(this.patientId).subscribe({
        next: (ordenes) => {
          this.examenes = ordenes
            .filter(orden => orden.estado === estado)
            .map(this.enrichOrdenExamen);
          this.isLoading = false;
        },
        error: (error) => {
          console.error('Error filtering exams:', error);
          this.error = 'Error al filtrar los exámenes';
          this.isLoading = false;
        }
      })
    );
  }

  mostrarTodos() {
    if (this.patientId) {
      this.loadExams(this.patientId);
    }
  }

  // ============== REFRESCAR DATOS ==============
  refreshExams() {
    if (this.patientId) {
      this.loadExams(this.patientId);
    }
  }

  clearError() {
    this.error = null;
  }

  private blankExamen(): Partial<ExamenSolicitado> {
    return {
      idExamen: '',
      nombreExamen: '',
      resultado: ''
    };
  }
}
