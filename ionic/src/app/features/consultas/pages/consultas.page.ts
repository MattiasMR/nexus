import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { 
  IonHeader, IonToolbar, IonTitle, IonContent, IonIcon, IonButton,
  IonCard, IonCardContent, IonCardHeader, IonCardTitle, IonCardSubtitle,
  IonBadge, IonGrid, IonRow, IonCol, IonList, IonItem, IonLabel,
  IonTextarea, IonTabs, IonTabButton, IonSpinner, IonToast,
  IonInput, IonSelect, IonSelectOption, IonDatetime, IonDatetimeButton, IonModal,
  ModalController, ToastController
} from '@ionic/angular/standalone';
import { CommonModule, DOCUMENT } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Subscription, firstValueFrom } from 'rxjs';
import { Timestamp, doc, updateDoc, deleteDoc, Firestore } from '@angular/fire/firestore';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';

// Servicios Firestore
import { PacientesService } from '../../pacientes/data/pacientes.service';
import { FichasMedicasService } from '../../fichas-medicas/data/fichas-medicas.service';
import { ConsultasService } from '../data/consultas.service';
import { ExamenesService } from '../../examenes/data/examenes.service';
import { OcrService } from '../../../services/ocr.service';

// Components
import { NuevaConsultaModalComponent } from '../components/nueva-consulta-modal/nueva-consulta-modal.component';
import { TimelineComponent, TimelineItem } from '../../../shared/components/timeline/timeline.component';

// Modelos
import { Paciente } from '../../../models/paciente.model';
import { FichaMedica } from '../../../models/ficha-medica.model';
import { Consulta } from '../../../models/consulta.model';
import { OrdenExamen } from '../../../models/orden-examen.model';

// Utilidades
import { AvatarUtils } from '../../../shared/utils/avatar.utils';

/**
 * UI interface for medical record display
 */
interface FichaMedicaUI {
  datosPersonales: {
    nombres: string;
    apellidos: string;
    rut: string;
    edad: number;
    grupoSanguineo: string;
    direccion: string;
    telefono: string;
    contactoEmergencia: string;
  };
  alertasMedicas: Array<{
    tipo: 'alergia' | 'medicamento' | 'antecedente';
    descripcion: string;
    criticidad: 'alta' | 'media' | 'baja';
  }>;
  consultas: ConsultaUI[];
  examenes: OrdenExamenUI[];
  historiaMedica?: {
    antecedentesPersonales: string[];
    antecedentesFamiliares: string[];
    hospitalizacionesPrevias?: number;
  };
}

/**
 * UI interface for consultations with additional display properties
 */
interface ConsultaUI extends Consulta {
  hora?: string;
  especialidad?: string;
  medico?: string;
  signosVitales?: {
    presionArterial?: string;
    frecuenciaCardiaca?: number;
    temperatura?: number;
    peso?: number;
  };
}

/**
 * UI interface for exam orders with additional display properties
 */
interface OrdenExamenUI extends OrdenExamen {
  nombre?: string;
  resultado?: string;
  detalle?: string;
}

@Component({
  selector: 'app-consultas',
  templateUrl: './consultas.page.html',
  styleUrls: ['./consultas.page.scss'],
  standalone: true,
  imports: [
    IonContent, IonIcon, IonButton,
    IonCard, IonCardContent, IonCardHeader, IonCardTitle,
    IonBadge, IonGrid, IonRow, IonCol,
    IonTextarea, IonInput, IonSelect, IonSelectOption,
    IonDatetime, IonDatetimeButton, IonModal,
    CommonModule, FormsModule, TimelineComponent
  ],
})
export class ConsultasPage implements OnInit, OnDestroy {
  
  // Estados del componente
  ficha: FichaMedicaUI | null = null;
  fichaId: string | null = null;
  paciente: Paciente | null = null;
  isLoading = false;
  error: string | null = null;
  patientId: string | null = null;
  
  // Modal state guard - prevents multiple opens
  private isModalOpen = false;
  
  // Variable para las notas rápidas
  nuevaNota: string = '';
  
  // Popup de Subir Examen
  showExamenPopup = false;
  nuevoExamen = {
    nombreExamen: '',
    tipoExamen: '',
    resultado: '',
    archivo: null as File | null,
    archivoNombre: '',
    archivoUrl: ''
  };
  
  // Archivos de exámenes subidos
  archivosExamenes: any[] = [];
  
  // Órdenes de exámenes
  ordenesExamenes: OrdenExamen[] = [];
  
  // Estado de edición de texto OCR
  editandoTexto = false;
  textoEnEdicion = '';
  mostrarHistorial = false;
  
  // Popup de confirmación de eliminación
  mostrarConfirmacionEliminar = false;
  archivoAEliminar: any = null;
  
  // Estado del historial médico expandible
  historialExpandido = false;
  
  // Popup de Nueva Orden de Examen
  showOrdenPopup = false;
  datosNuevaOrden = {
    examenes: [{ nombre: '', instrucciones: '' }],
    observaciones: ''
  };
  
  // Popup de Nueva Consulta
  showConsultaPopup = false;
  formSubmitted = false;
  datosNuevaConsulta = {
    fechaConsulta: new Date().toISOString(),
    motivoConsulta: '',
    diagnostico: '',
    tratamiento: '',
    signosVitales: {
      presionArterial: '',
      frecuenciaCardiaca: null as number | null,
      temperatura: '',
      saturacionOxigeno: null as number | null,
      peso: '',
      talla: ''
    },
    observaciones: ''
  };
  maxDate = new Date().toISOString();
  
  // Edit mode
  isEditMode = false;
  editedData: any = {};
  
  // Timeline items - cached property instead of getter
  timelineItems: TimelineItem[] = [];
  
  private subscriptions: Subscription[] = [];
  private router = inject(Router);
  private route = inject(ActivatedRoute);
  private sanitizer = inject(DomSanitizer);
  private firestore = inject(Firestore);
  private pacientesService = inject(PacientesService);
  private fichasMedicasService = inject(FichasMedicasService);
  private consultasService = inject(ConsultasService);
  private examenesService = inject(ExamenesService);
  private ocrService = inject(OcrService);
  private modalCtrl = inject(ModalController);
  private toastCtrl = inject(ToastController);
  private document = inject(DOCUMENT);

  async ngOnInit() {
    // Subscribe to queryParams changes to detect patient navigation
    // This is necessary because Angular reuses the component when navigating between patients
    this.subscriptions.push(
      this.route.queryParams.subscribe(async (params) => {
        const newPatientId = params['patientId'];
        
        // Only reload if patient ID actually changed
        if (newPatientId && newPatientId !== this.patientId) {
          console.log(`🔄 Patient changed from ${this.patientId} to ${newPatientId}`);
          
          // Clear previous patient data immediately
          this.clearPatientData();
          
          // Load new patient
          this.patientId = newPatientId;
          await this.loadPatientData(newPatientId);
        } else if (newPatientId && !this.patientId) {
          // First load
          this.patientId = newPatientId;
          await this.loadPatientData(newPatientId);
        } else if (!newPatientId) {
          this.error = 'No se especificó el ID del paciente';
        }
      })
    );
  }

  ngOnDestroy() {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  /**
   * Clear all patient data before loading new patient
   * Prevents showing stale data from previous patient
   */
  private clearPatientData() {
    this.paciente = null;
    this.ficha = null;
    this.fichaId = null;
    this.timelineItems = [];
    this.nuevaNota = '';
    this.isEditMode = false;
    this.editedData = {};
    this.error = null;
  }

  /**
   * Cargar todos los datos del paciente desde Firestore
   * REFACTORED: Usa async/await como patient-list.saveCreate()
   * Patrón completamente síncrono que garantiza completion
   */
  async loadPatientData(patientId: string) {
    this.isLoading = true;
    this.error = null;

    try {
      // Load all data using Promise.all with firstValueFrom - ensures completion
      const [paciente, ficha, consultas, examenes] = await Promise.all([
        firstValueFrom(this.pacientesService.getPacienteById(patientId)),
        firstValueFrom(this.fichasMedicasService.getFichaByPacienteId(patientId)),
        firstValueFrom(this.consultasService.getConsultasByPaciente(patientId)),
        firstValueFrom(this.examenesService.getOrdenesByPaciente(patientId))
      ]);

      if (!paciente || !ficha) {
        this.error = 'No se encontró el paciente o su ficha médica';
        this.isLoading = false;
        return;
      }

      this.paciente = paciente;
      this.fichaId = ficha.id || null;
      this.ficha = this.buildFichaMedicaUI(
        paciente,
        ficha,
        consultas || [],
        examenes || []
      );
      
      // Build timeline items once after loading data
      this.buildTimelineItems();

      // Cargar archivos de exámenes
      await this.cargarArchivosExamenes();
      
      // Cargar órdenes de exámenes
      await this.cargarOrdenesExamenes();

      this.isLoading = false;
    } catch (error: any) {
      console.error('❌ Error loading patient data:', error);
      this.error = 'Error al cargar los datos del paciente: ' + (error?.message || 'Desconocido');
      this.isLoading = false;
    }
  }

  /**
   * Construir la ficha médica UI a partir de los datos de Firestore
   */
  private buildFichaMedicaUI(
    paciente: Paciente,
    ficha: FichaMedica,
    consultas: Consulta[],
    examenes: OrdenExamen[]
  ): FichaMedicaUI {
    const datosPersonales = {
      nombres: paciente.nombre || 'Sin nombre',
      apellidos: paciente.apellido || 'Sin apellido',
      rut: paciente.rut || 'Sin RUT',
      edad: this.calculateAge(paciente.fechaNacimiento),
      grupoSanguineo: paciente.grupoSanguineo || 'No registrado',
      direccion: paciente.direccion || 'Sin dirección',
      telefono: paciente.telefono || 'Sin teléfono',
      contactoEmergencia: 'Contacto por definir' // TODO: Add to Paciente model
    };
    
    return {
      datosPersonales,
      alertasMedicas: [
        // Alergias del paciente - LIMIT to prevent performance issues
        ...(paciente.alergias || []).slice(0, 5).map(alergia => ({
          tipo: 'alergia' as const,
          descripcion: alergia,
          criticidad: 'alta' as const
        })),
        // Enfermedades crónicas - LIMIT to prevent performance issues
        ...(paciente.enfermedadesCronicas || []).slice(0, 5).map(enfermedad => ({
          tipo: 'antecedente' as const,
          descripcion: enfermedad,
          criticidad: 'media' as const
        })),
        // Alertas médicas - LIMIT to prevent performance issues
        ...(paciente.alertasMedicas || []).slice(0, 5).map(alerta => ({
          tipo: 'antecedente' as const,
          descripcion: alerta.descripcion,
          criticidad: (alerta.severidad === 'critica' || alerta.severidad === 'alta' 
            ? 'alta' 
            : (alerta.severidad === 'media' ? 'media' : 'baja')) as 'alta' | 'media' | 'baja'
        }))
      ].slice(0, 10), // HARD LIMIT: Maximum 10 alerts total
      consultas: (consultas || []).slice(0, 5), // LIMIT: Only 5 most recent
      examenes: (examenes || []).slice(0, 5), // LIMIT: Only 5 most recent
      historiaMedica: {
        antecedentesPersonales: ficha.antecedentes?.personales ? [ficha.antecedentes.personales] : [],
        antecedentesFamiliares: ficha.antecedentes?.familiares ? [ficha.antecedentes.familiares] : [],
        hospitalizacionesPrevias: ficha.antecedentes?.hospitalizaciones ? 1 : 0
      }
    };
  }

  /**
   * Calcular edad a partir de fecha de nacimiento
   */
  private calculateAge(fechaNacimiento?: Date | Timestamp): number {
    if (!fechaNacimiento) return 0;
    
    const birth = fechaNacimiento instanceof Timestamp 
      ? fechaNacimiento.toDate() 
      : new Date(fechaNacimiento);
    
    const today = new Date();
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
      age--;
    }
    
    return age;
  }

  // ============== NAVEGACIÓN ==============
  goBack() {
    this.router.navigateByUrl('/tabs/tab2');
  }

  /**
   * Toggle edit mode for datos personales
   */
  editarDatosPersonales() {
    this.isEditMode = true;
    // Copy current data to editedData for editing
    if (this.ficha?.datosPersonales) {
      this.editedData = {
        telefono: this.ficha.datosPersonales.telefono,
        direccion: this.ficha.datosPersonales.direccion,
        grupoSanguineo: this.ficha.datosPersonales.grupoSanguineo
      };
    }
  }
  
  /**
   * Cancel editing and restore original data
   */
  cancelarEdicion() {
    this.isEditMode = false;
    this.editedData = {};
  }
  
  /**
   * Save edited patient data to Firestore
   */
  async guardarCambios() {
    if (!this.patientId) return;
    
    this.isLoading = true;
    
    try {
      // Update only the fields that can be edited
      const updateData: any = {};
      if (this.editedData.telefono) updateData.telefono = this.editedData.telefono;
      if (this.editedData.direccion) updateData.direccion = this.editedData.direccion;
      if (this.editedData.grupoSanguineo) updateData.grupoSanguineo = this.editedData.grupoSanguineo;
      
      await this.pacientesService.updatePaciente(this.patientId, updateData);
      
      // Reload patient data to reflect changes
      this.loadPatientData(this.patientId);
      
      this.isEditMode = false;
      this.editedData = {};
      
      // Show success toast
      const toast = await this.toastCtrl.create({
        message: 'Cambios guardados correctamente',
        duration: 2000,
        color: 'success',
        position: 'bottom'
      });
      await toast.present();
    } catch (error: any) {
      console.error('❌ Error saving changes:', error);
      this.error = 'Error al guardar los cambios: ' + (error.message || 'Desconocido');
      
      // Show error toast
      const toast = await this.toastCtrl.create({
        message: 'Error al guardar los cambios',
        duration: 3000,
        color: 'danger',
        position: 'bottom'
      });
      await toast.present();
    } finally {
      this.isLoading = false;
    }
  }

  verMedicamentos() {
    if (this.patientId) {
      this.router.navigate(['/tabs/tab4'], { 
        queryParams: { patientId: this.patientId } 
      });
    }
  }

  verExamenes() {
    if (this.patientId) {
      this.router.navigate(['/tabs/tab5'], { 
        queryParams: { patientId: this.patientId } 
      });
    }
  }

  /**
   * Open modal to create a new consultation
   * Guard prevents multiple simultaneous opens
   */
  nuevaConsulta() {
    if (!this.paciente || !this.fichaId) {
      this.showToast('Error: No se pudo cargar la información del paciente', 'danger');
      return;
    }
    
    // Abrir popup CSS en lugar de ModalController
    this.showConsultaPopup = true;
    this.formSubmitted = false;
    this.datosNuevaConsulta = {
      fechaConsulta: new Date().toISOString(),
      motivoConsulta: '',
      diagnostico: '',
      tratamiento: '',
      signosVitales: {
        presionArterial: '',
        frecuenciaCardiaca: null,
        temperatura: '',
        saturacionOxigeno: null,
        peso: '',
        talla: ''
      },
      observaciones: ''
    };
  }

  /**
   * Save consultation to Firestore
   * Uses async/await pattern like patient-list
   */
  private async guardarConsulta(consultaData: any) {
    try {
      const consultaId = await this.consultasService.createConsulta(consultaData);
      await this.showToast('Consulta guardada exitosamente', 'success');
      
      // Reload consultas using async/await (no subscriptions)
      if (this.patientId && this.ficha && this.paciente) {
        this.isLoading = true;
        
        try {
          const consultas = await firstValueFrom(
            this.consultasService.getConsultasByPaciente(this.patientId)
          );
          
          // Update consultas section of ficha
          if (this.ficha) {
            this.ficha.consultas = consultas
              .sort((a, b) => {
                const dateA = a.fecha instanceof Timestamp ? a.fecha.toDate() : new Date(a.fecha);
                const dateB = b.fecha instanceof Timestamp ? b.fecha.toDate() : new Date(b.fecha);
                return dateB.getTime() - dateA.getTime();
              })
              .slice(0, 5) // Keep limit of 5
              .map(c => {
                const fecha = c.fecha instanceof Timestamp ? c.fecha.toDate() : new Date(c.fecha);
                return {
                  ...c,
                  hora: fecha.toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' }),
                  medico: 'Dr./Dra. Profesional',
                  especialidad: 'Medicina General'
                };
              });
            
            // Rebuild timeline with updated consultas
            this.buildTimelineItems();
          }
        } catch (err) {
          console.error('Error reloading consultas:', err);
        } finally {
          this.isLoading = false;
        }
      }
    } catch (error) {
      console.error('Error saving consultation:', error);
      await this.showToast('Error al guardar la consulta', 'danger');
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

  // ============== UTILIDADES UI ==============
  badgeClass(criticidad: 'alta' | 'media' | 'baja') {
    return {
      'badge-alta': criticidad === 'alta',
      'badge-media': criticidad === 'media',
      'badge-baja': criticidad === 'baja'
    };
  }

  badgeColor(criticidad: 'alta' | 'media' | 'baja'): string {
    switch (criticidad) {
      case 'alta': return 'danger';
      case 'media': return 'warning';
      case 'baja': return 'secondary';
      default: return 'secondary';
    }
  }

  // Alias para compatibilidad con HTML
  getBadgeColor(criticidad: string): string {
    return this.badgeColor(criticidad as 'alta' | 'media' | 'baja');
  }

  verMedicacion() {
    if (this.patientId) {
      this.router.navigate(['/tabs/tab4'], { 
        queryParams: { patientId: this.patientId } 
      });
    }
  }

  /**
   * Abrir popup para crear nueva orden de examen
   */
  nuevaOrdenExamen() {
    if (!this.patientId) {
      this.showToast('Error: No se ha cargado el paciente', 'danger');
      return;
    }
    
    // Reset form
    this.datosNuevaOrden = {
      examenes: [{ nombre: '', instrucciones: '' }],
      observaciones: ''
    };
    
    this.showOrdenPopup = true;
  }

  /**
   * Agregar otro examen al formulario
   */
  agregarExamen() {
    this.datosNuevaOrden.examenes.push({ nombre: '', instrucciones: '' });
  }

  /**
   * Eliminar un examen del formulario
   */
  eliminarExamen(index: number) {
    if (this.datosNuevaOrden.examenes.length > 1) {
      this.datosNuevaOrden.examenes.splice(index, 1);
    }
  }

  /**
   * Guardar nueva orden de examen
   */
  async guardarNuevaOrden() {
    // Validar que al menos un examen tenga nombre
    const hayExamenValido = this.datosNuevaOrden.examenes.some(e => e.nombre.trim());
    
    if (!hayExamenValido) {
      const toast = await this.toastCtrl.create({
        message: 'Debe agregar al menos un examen',
        duration: 2000,
        color: 'warning'
      });
      await toast.present();
      return;
    }

    try {
      this.isLoading = true;

      // Filtrar exámenes válidos
      const examenesValidos = this.datosNuevaOrden.examenes
        .filter(e => e.nombre.trim())
        .map(e => ({
          idExamen: 'examen-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9),
          nombreExamen: e.nombre,
          resultado: e.instrucciones || 'Pendiente'
        }));

      const ordenExamen = {
        idPaciente: this.patientId!,
        idProfesional: 'system', // Aquí deberías poner el ID del usuario actual
        fecha: Timestamp.now(),
        estado: 'pendiente' as const,
        examenes: examenesValidos,
        createdAt: Timestamp.now()
      };

      await this.examenesService.createOrdenExamen(ordenExamen);

      const toast = await this.toastCtrl.create({
        message: 'Orden de examen creada exitosamente',
        duration: 2000,
        color: 'success'
      });
      await toast.present();

      this.cerrarPopupOrden();
      
      // Recargar archivos de exámenes
      await this.cargarArchivosExamenes();
      
      // Recargar órdenes
      await this.cargarOrdenesExamenes();
      
    } catch (error) {
      console.error('Error al guardar orden de examen:', error);
      const toast = await this.toastCtrl.create({
        message: 'Error al crear la orden de examen',
        duration: 3000,
        color: 'danger'
      });
      await toast.present();
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Cerrar popup de nueva orden
   */
  cerrarPopupOrden() {
    this.showOrdenPopup = false;
  }
  
  /**
   * Cargar órdenes de exámenes del paciente
   */
  async cargarOrdenesExamenes() {
    try {
      if (!this.patientId) return;
      
      const ordenes$ = this.examenesService.getOrdenesByPaciente(this.patientId);
      const ordenes = await firstValueFrom(ordenes$);
      
      this.ordenesExamenes = ordenes.sort((a: OrdenExamen, b: OrdenExamen) => {
        const fechaA = a.fecha instanceof Timestamp ? a.fecha.toDate() : new Date(a.fecha);
        const fechaB = b.fecha instanceof Timestamp ? b.fecha.toDate() : new Date(b.fecha);
        return fechaB.getTime() - fechaA.getTime(); // Más reciente primero
      });
      
      console.log('Órdenes de exámenes cargadas:', this.ordenesExamenes);
    } catch (error) {
      console.error('Error al cargar órdenes de exámenes:', error);
    }
  }
  
  /**
   * Calcular el estado real de una orden basado en fecha y completitud
   */
  getEstadoOrden(orden: OrdenExamen): 'pendiente' | 'completo' | 'atrasado' {
    // Si la orden está marcada como realizado, está completa
    if (orden.estado === 'realizado') {
      return 'completo';
    }
    
    // Si está cancelada, considerarla como pendiente
    if (orden.estado === 'cancelado') {
      return 'pendiente';
    }
    
    // Verificar si todos los exámenes tienen documentos subidos
    const todosCompletos = orden.examenes.every(examen => 
      examen.documentos && examen.documentos.length > 0
    );
    
    if (todosCompletos) {
      return 'completo';
    }
    
    // Si está pendiente, verificar si está atrasado (más de 30 días)
    const fechaOrden = orden.fecha instanceof Timestamp ? orden.fecha.toDate() : new Date(orden.fecha);
    const hoy = new Date();
    const diasTranscurridos = Math.floor((hoy.getTime() - fechaOrden.getTime()) / (1000 * 60 * 60 * 24));
    
    if (diasTranscurridos > 30) {
      return 'atrasado';
    }
    
    return 'pendiente';
  }
  
  /**
   * Obtener el color del badge según el estado
   */
  getColorEstado(estado: string): string {
    switch (estado) {
      case 'completo':
        return 'success';
      case 'atrasado':
        return 'danger';
      case 'pendiente':
      default:
        return 'warning';
    }
  }
  
  /**
   * Obtener el ícono según el estado
   */
  getIconoEstado(estado: string): string {
    switch (estado) {
      case 'completo':
        return 'checkmark-circle';
      case 'atrasado':
        return 'alert-circle';
      case 'pendiente':
      default:
        return 'time';
    }
  }
  
  /**
   * Convertir Timestamp o Date a Date
   */
  getFechaOrden(fecha: Date | Timestamp): Date {
    return fecha instanceof Timestamp ? fecha.toDate() : fecha;
  }

  estadoExamenColor(estado: string): string {
    switch (estado) {
      case 'normal': 
      case 'completado': return 'success';
      case 'atencion': 
      case 'en_proceso': return 'warning';
      case 'critico': 
      case 'solicitado': return 'danger';
      case 'pendiente': return 'warning';
      default: return 'medium';
    }
  }

  formatDate(date: Date | Timestamp | string | undefined): string {
    if (!date) return '';
    
    const d = date instanceof Timestamp 
      ? date.toDate() 
      : new Date(date);
    
    return d.toLocaleDateString('es-CL');
  }

  formatDateShort(date: Date | Timestamp | string | undefined): string {
    if (!date) return '';
    
    const d = date instanceof Timestamp 
      ? date.toDate() 
      : new Date(date);
    
    return d.toLocaleDateString('es-CL', { day: '2-digit', month: '2-digit' });
  }

  getExamenBadgeColor(estado: string): string {
    return this.estadoExamenColor(estado);
  }

  getExamenBadgeText(estado: string): string {
    switch (estado) {
      case 'normal': return 'Normal';
      case 'atencion': return 'Atención';
      case 'critico': return 'Crítico';
      case 'solicitado': return 'Solicitado';
      case 'pendiente': return 'Pendiente';
      case 'en_proceso': return 'En Proceso';
      case 'completado': return 'Completado';
      default: return estado;
    }
  }

  formatTime(time: string | Date | Timestamp): string {
    if (!time) return '';
    
    let date: Date;
    if (typeof time === 'string') {
      return time; // Already formatted
    } else if (time instanceof Timestamp) {
      date = time.toDate();
    } else {
      date = time;
    }
    
    return date.toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' });
  }

  // ============== REFRESCAR DATOS ==============
  refreshData() {
    if (this.patientId) {
      this.loadPatientData(this.patientId);
    }
  }

  clearError() {
    this.error = null;
  }
  
  // ============== AVATAR UTILITIES ==============
  
  /**
   * Get initials for patient avatar
   */
  getInitials(nombre?: string, apellido?: string): string {
    return AvatarUtils.getInitials(nombre || '', apellido);
  }
  
  /**
   * Get avatar color for patient
   */
  getAvatarColor(nombre?: string, apellido?: string): string {
    return AvatarUtils.getAvatarColor(`${nombre || ''} ${apellido || ''}`);
  }
  
  /**
   * Get avatar style object
   */
  getAvatarStyle(nombre?: string, apellido?: string): any {
    return AvatarUtils.getAvatarStyle(nombre || '', apellido);
  }

  // ============== TIMELINE DATA ==============
  
  /**
   * Build timeline items from consultations and exams
   * Called explicitly instead of getter to avoid change detection overhead
   */
  private buildTimelineItems() {
    if (!this.ficha) {
      this.timelineItems = [];
      return;
    }
    
    const items: TimelineItem[] = [];
    
    // Add consultations to timeline (already limited to 5)
    (this.ficha.consultas || []).forEach(consulta => {
      items.push({
        id: consulta.id,
        title: `Consulta - ${consulta.motivo || 'Revisión general'}`,
        description: consulta.observaciones || consulta.tratamiento || undefined,
        date: consulta.fecha,
        type: 'consultation',
        icon: 'medical-outline',
        color: 'primary',
        metadata: {
          tratamiento: consulta.tratamiento || 'No especificado'
        }
      });
    });
    
    // Add exam orders to timeline (already limited to 5)
    (this.ficha.examenes || []).forEach(examen => {
      const primerExamen = examen.examenes && examen.examenes.length > 0 
        ? examen.examenes[0].nombreExamen 
        : 'Laboratorio';
      
      items.push({
        id: examen.id,
        title: `Examen - ${primerExamen}`,
        description: `${examen.examenes?.length || 0} examen(es) solicitado(s)`,
        date: examen.fecha,
        type: 'exam',
        icon: 'flask-outline',
        color: examen.estado === 'realizado' ? 'success' : 'warning',
        metadata: {
          resultado: examen.estado === 'realizado' ? 'Completado' : 'Pendiente'
        }
      });
    });
    
    // Sort by date (most recent first) and limit to 10 total items
    this.timelineItems = items
      .sort((a, b) => {
        const dateA = a.date instanceof Timestamp ? a.date.toDate() : a.date;
        const dateB = b.date instanceof Timestamp ? b.date.toDate() : b.date;
        return dateB.getTime() - dateA.getTime();
      })
      .slice(0, 10); // HARD LIMIT: Max 10 timeline items
  }

  // ============== NOTAS RÁPIDAS ==============
  async guardarNota() {
    if (!this.nuevaNota.trim() || !this.patientId || !this.fichaId) return;
    
    try {
      // Get the most recent consultation to add note to
      const consultas = await this.consultasService.getConsultasByPaciente(this.patientId).toPromise();
      
      if (consultas && consultas.length > 0) {
        const consultaId = consultas[0].id!;
        await this.consultasService.addNotaRapida(consultaId, {
          texto: this.nuevaNota.trim(),
          autor: 'medico-general' // TODO: Get from auth
        });
        this.nuevaNota = '';
        this.refreshData();
      } else {
        // Si no hay consultas, crear una nueva solo para la nota
        await this.nuevaConsulta();
        // Note will be added after consultation is created
      }
    } catch (error) {
      console.error('Error guardando nota:', error);
      this.error = 'Error al guardar la nota';
    }
  }

  agregarNota() {
    this.guardarNota();
  }
  
  /**
   * Abrir popup para subir examen (CSS overlay, no ModalController)
   */
  subirExamen() {
    console.log('🚀 subirExamen() llamado - Abriendo popup');
    this.showExamenPopup = true;
    this.nuevoExamen = {
      nombreExamen: '',
      tipoExamen: '',
      resultado: '',
      archivo: null,
      archivoNombre: '',
      archivoUrl: ''
    };
    console.log('📋 Formulario reseteado');
  }
  
  /**
   * Cerrar popup de examen
   */
  cerrarPopupExamen() {
    this.showExamenPopup = false;
    this.nuevoExamen = {
      nombreExamen: '',
      tipoExamen: '',
      resultado: '',
      archivo: null,
      archivoNombre: '',
      archivoUrl: ''
    };
  }
  
  /**
   * Manejar selección de archivo
   */
  async onArchivoSeleccionado(event: Event) {
    console.log('📁 onArchivoSeleccionado() llamado');
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      const file = input.files[0];
      console.log('📄 Archivo seleccionado:', file.name, 'Tamaño:', file.size, 'Tipo:', file.type);
      
      // Validar tamaño (máximo 10MB pero advertir sobre limitación de Firestore con Base64)
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (file.size > maxSize) {
        console.log('❌ Archivo demasiado grande');
        this.showToast('El archivo es demasiado grande. Máximo 10MB', 'warning');
        return;
      }
      
      // Advertencia si el archivo es mayor a 1MB (límite de Firestore)
      if (file.size > 1 * 1024 * 1024) {
        console.warn('⚠️ Archivo mayor a 1MB. Podría tener problemas con Firestore (límite Base64)');
        const toast = await this.toastCtrl.create({
          message: 'Advertencia: Archivo grande (>1MB). Se recomienda usar archivos más pequeños.',
          duration: 4000,
          color: 'warning'
        });
        await toast.present();
      }
      
      // Validar tipo de archivo - Aceptar más tipos MIME
      const allowedTypes = [
        'application/pdf',
        'image/jpeg',
        'image/jpg', 
        'image/png',
        'image/gif',
        'image/webp',
        'application/msword', // .doc
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // .docx
        'application/vnd.ms-excel', // .xls
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // .xlsx
        'text/plain', // .txt
      ];
      
      // Validar también por extensión como fallback
      const fileName = file.name.toLowerCase();
      const validExtensions = ['.pdf', '.jpg', '.jpeg', '.png', '.gif', '.webp', '.doc', '.docx', '.xls', '.xlsx', '.txt'];
      const hasValidExtension = validExtensions.some(ext => fileName.endsWith(ext));
      
      if (!allowedTypes.includes(file.type) && !hasValidExtension) {
        console.log('❌ Tipo de archivo no permitido:', file.type);
        console.log('📝 Extensión del archivo:', fileName.substring(fileName.lastIndexOf('.')));
        this.showToast('Formato de archivo no permitido. Use PDF, imágenes (JPG, PNG) o documentos (DOC, DOCX)', 'warning');
        return;
      }
      
      console.log('✅ Archivo validado correctamente');
      this.nuevoExamen.archivo = file;
      this.nuevoExamen.archivoNombre = file.name;
      console.log('✅ Archivo guardado en nuevoExamen.archivo');
      
      // Crear URL de previsualización para imágenes
      if (file.type.startsWith('image/')) {
        const reader = new FileReader();
        reader.onload = (e) => {
          this.nuevoExamen.archivoUrl = e.target?.result as string;
          console.log('🖼️ URL de previsualización creada');
        };
        reader.readAsDataURL(file);
      }
    } else {
      console.log('⚠️ No se detectaron archivos en el input');
    }
  }
  
  /**
   * Eliminar archivo seleccionado
   */
  eliminarArchivo() {
    this.nuevoExamen.archivo = null;
    this.nuevoExamen.archivoNombre = '';
    this.nuevoExamen.archivoUrl = '';
    
    // Limpiar el input file
    const fileInput = this.document.querySelector('#archivoExamen') as HTMLInputElement;
    if (fileInput) {
      fileInput.value = '';
    }
  }

  /**
   * Tomar foto con la cámara del dispositivo usando HTML5 MediaDevices
   */
  async tomarFoto() {
    try {
      console.log('📸 Abriendo cámara...');
      
      // Verificar si el navegador soporta getUserMedia
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        this.showToast('Tu navegador no soporta acceso a la cámara', 'danger');
        return;
      }
      
      // Crear elemento de video temporal para capturar
      const video = document.createElement('video');
      video.setAttribute('autoplay', '');
      video.setAttribute('playsinline', '');
      
      // Crear modal para mostrar la cámara
      const modal = document.createElement('div');
      modal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.95);
        z-index: 10000;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 20px;
      `;
      
      video.style.cssText = `
        max-width: 100%;
        max-height: 70vh;
        border-radius: 8px;
        margin-bottom: 20px;
      `;
      
      const btnContainer = document.createElement('div');
      btnContainer.style.cssText = `
        display: flex;
        gap: 15px;
      `;
      
      const btnCapture = document.createElement('button');
      btnCapture.innerHTML = '📸 Capturar';
      btnCapture.style.cssText = `
        padding: 15px 30px;
        font-size: 16px;
        font-weight: bold;
        background: linear-gradient(135deg, #4CAF50, #45a049);
        color: white;
        border: none;
        border-radius: 8px;
        cursor: pointer;
      `;
      
      const btnCancel = document.createElement('button');
      btnCancel.innerHTML = '❌ Cancelar';
      btnCancel.style.cssText = `
        padding: 15px 30px;
        font-size: 16px;
        font-weight: bold;
        background: linear-gradient(135deg, #f44336, #d32f2f);
        color: white;
        border: none;
        border-radius: 8px;
        cursor: pointer;
      `;
      
      btnContainer.appendChild(btnCapture);
      btnContainer.appendChild(btnCancel);
      modal.appendChild(video);
      modal.appendChild(btnContainer);
      document.body.appendChild(modal);
      
      // Solicitar acceso a la cámara con restricción de resolución
      const stream = await navigator.mediaDevices.getUserMedia({ 
        video: { 
          facingMode: 'environment', // Usar cámara trasera en móviles
          width: { ideal: 1920 },    // Limitar ancho a Full HD
          height: { ideal: 1080 }    // Limitar alto a Full HD
        },
        audio: false 
      });
      
      video.srcObject = stream;
      
      // Función para capturar y redimensionar la foto
      const capturarFoto = async () => {
        const canvas = document.createElement('canvas');
        
        // Dimensiones máximas deseadas (HD ready)
        const maxWidth = 1280;
        const maxHeight = 720;
        
        let width = video.videoWidth;
        let height = video.videoHeight;
        
        // Calcular nuevas dimensiones manteniendo aspect ratio
        if (width > maxWidth || height > maxHeight) {
          const ratio = Math.min(maxWidth / width, maxHeight / height);
          width = width * ratio;
          height = height * ratio;
        }
        
        canvas.width = width;
        canvas.height = height;
        
        const ctx = canvas.getContext('2d');
        ctx?.drawImage(video, 0, 0, width, height);
        
        // Convertir a blob con calidad reducida (60%)
        canvas.toBlob(async (blob) => {
          if (blob) {
            // Detener el stream
            stream.getTracks().forEach(track => track.stop());
            document.body.removeChild(modal);
            
            console.log('📄 Foto capturada - Tamaño original del blob:', blob.size);
            
            // Si aún es muy grande, comprimir más
            let finalBlob = blob;
            if (blob.size > 800 * 1024) { // Si es mayor a 800KB
              console.log('🔄 Foto muy grande, aplicando compresión adicional...');
              finalBlob = await this.comprimirImagen(canvas, 0.4); // Calidad 40%
              console.log('📉 Tamaño después de compresión:', finalBlob.size);
            }
            
            // Crear archivo
            const fileName = `foto_examen_${Date.now()}.jpg`;
            const file = new File([finalBlob], fileName, { type: 'image/jpeg' });
            
            console.log('📄 Archivo creado:', fileName, 'Tamaño final:', file.size, '(' + (file.size / 1024).toFixed(2) + ' KB)');
            
            // Validar tamaño
            const maxSize = 10 * 1024 * 1024; // 10MB
            if (file.size > maxSize) {
              console.log('❌ Foto demasiado grande');
              this.showToast('La foto es demasiado grande. Máximo 10MB', 'warning');
              return;
            }
            
            // Advertencia si es mayor a 1MB
            if (file.size > 1 * 1024 * 1024) {
              console.warn('⚠️ Foto mayor a 1MB');
              const toast = await this.toastCtrl.create({
                message: `Foto: ${(file.size / 1024 / 1024).toFixed(2)}MB. Se recomienda usar archivos más pequeños.`,
                duration: 4000,
                color: 'warning'
              });
              await toast.present();
            }
            
            // Crear URL de previsualización
            const reader = new FileReader();
            reader.onload = (e) => {
              this.nuevoExamen.archivoUrl = e.target?.result as string;
            };
            reader.readAsDataURL(file);
            
            // Guardar archivo
            this.nuevoExamen.archivo = file;
            this.nuevoExamen.archivoNombre = fileName;
            
            console.log('✅ Foto guardada en nuevoExamen.archivo');
            this.showToast('Foto capturada correctamente', 'success');
          }
        }, 'image/jpeg', 0.6); // Calidad inicial 60%
      };
      
      // Evento de captura
      btnCapture.onclick = capturarFoto;
      
      // Evento de cancelar
      btnCancel.onclick = () => {
        stream.getTracks().forEach(track => track.stop());
        document.body.removeChild(modal);
        console.log('📸 Captura cancelada');
      };
      
    } catch (error) {
      console.error('❌ Error al abrir cámara:', error);
      this.showToast('Error al acceder a la cámara. Verifique los permisos.', 'danger');
    }
  }
  
  /**
   * Guardar examen con archivo adjunto
   * NOTA: Actualmente guarda archivos como Base64 en Firestore (modo desarrollo)
   * Para producción, migrar a Firebase Storage cuando esté disponible
   */
  async guardarExamen() {
    console.log('🔵 guardarExamen() llamado');
    console.log('📋 Datos del formulario:', {
      nombreExamen: this.nuevoExamen.nombreExamen,
      archivo: this.nuevoExamen.archivo,
      patientId: this.patientId
    });

    if (!this.nuevoExamen.nombreExamen.trim()) {
      console.log('❌ Validación falló: nombreExamen vacío');
      const toast = await this.toastCtrl.create({
        message: 'Debe ingresar el tipo de examen',
        duration: 2000,
        color: 'warning'
      });
      await toast.present();
      return;
    }
    
    if (!this.nuevoExamen.archivo) {
      console.log('❌ Validación falló: archivo no seleccionado');
      const toast = await this.toastCtrl.create({
        message: 'Debe seleccionar un archivo',
        duration: 2000,
        color: 'warning'
      });
      await toast.present();
      return;
    }

    if (!this.patientId) {
      console.log('❌ Validación falló: patientId no disponible');
      const toast = await this.toastCtrl.create({
        message: 'Error: No se ha cargado el paciente',
        duration: 2000,
        color: 'danger'
      });
      await toast.present();
      return;
    }

    console.log('✅ Todas las validaciones pasadas, iniciando proceso de guardado...');

    try {
      this.isLoading = true;
      console.log('🔄 isLoading = true');

      // MODO DESARROLLO: Convertir archivo a Base64 (sin usar Storage)
      const timestamp = Date.now();
      console.log('📦 Convirtiendo archivo a Base64...');
      
      const fileBase64 = await this.convertirArchivoABase64(this.nuevoExamen.archivo);
      console.log('✅ Archivo convertido a Base64');
      
      // URL simulada para desarrollo (el archivo se guarda como base64 en Firestore)
      const downloadURL = `data:${this.nuevoExamen.archivo.type};base64,${fileBase64}`;
      console.log('📄 URL de datos creada (Base64)');

      // Procesar OCR si es una imagen
      let textoExtraido = '';
      let confianzaOCR = 0;
      
      if (this.nuevoExamen.archivo.type.startsWith('image/')) {
        console.log('🔍 Detectada imagen, iniciando OCR...');
        
        const toastOCR = await this.toastCtrl.create({
          message: 'Extrayendo texto de la imagen...',
          duration: 0,
          color: 'primary'
        });
        await toastOCR.present();
        
        try {
          const ocrResult = await this.ocrService.extractTextFromImage(downloadURL);
          textoExtraido = ocrResult.text;
          confianzaOCR = ocrResult.confidence;
          console.log('✅ OCR completado. Confianza:', confianzaOCR);
          console.log('📝 Texto extraído:', textoExtraido);
          
          await toastOCR.dismiss();
          
          if (textoExtraido) {
            const toastSuccess = await this.toastCtrl.create({
              message: `Texto extraído exitosamente (${Math.round(confianzaOCR)}% confianza)`,
              duration: 3000,
              color: 'success'
            });
            await toastSuccess.present();
          }
        } catch (error) {
          console.error('❌ Error en OCR:', error);
          await toastOCR.dismiss();
        }
      }

      // 3. Crear el documento de examen en Firestore
      const ordenExamen: Omit<OrdenExamen, 'id'> = {
        idPaciente: this.patientId,
        idProfesional: 'system', // Aquí deberías poner el ID del usuario actual
        fecha: Timestamp.now(),
        estado: 'realizado',
        examenes: [
          {
            idExamen: 'examen-manual-' + timestamp,
            nombreExamen: this.nuevoExamen.nombreExamen,
            resultado: this.nuevoExamen.resultado || 'Pendiente de interpretación',
            fechaResultado: Timestamp.now(),
            documentos: [
              {
                url: downloadURL,
                nombre: this.nuevoExamen.archivo.name,
                tipo: this.nuevoExamen.archivo.type,
                tamanio: this.nuevoExamen.archivo.size,
                fechaSubida: Timestamp.now(),
                subidoPor: 'system', // Aquí deberías poner el ID del usuario actual
                textoExtraido: textoExtraido || undefined,
                textoActual: textoExtraido || undefined, // La versión actual es la del OCR inicial
                confianzaOCR: confianzaOCR > 0 ? confianzaOCR : undefined,
                historialVersiones: []
              }
            ]
          }
        ],
        createdAt: Timestamp.now()
      };

      console.log('📦 Guardando orden de examen en Firestore...');
      console.log('📋 Estructura completa:', JSON.stringify(ordenExamen, null, 2));
      console.log('📄 URL del documento (primeros 100 chars):', ordenExamen.examenes[0].documentos![0].url.substring(0, 100) + '...');
      
      const ordenId = await this.examenesService.createOrdenExamen(ordenExamen);
      console.log('✅ Orden de examen guardada exitosamente con ID:', ordenId);
      console.log('🔍 Verifica en Firebase Console → Firestore → ordenes-examen/' + ordenId);

      const toast = await this.toastCtrl.create({
        message: 'Examen guardado exitosamente',
        duration: 2000,
        color: 'success'
      });
      await toast.present();

      // Recargar archivos de exámenes
      await this.cargarArchivosExamenes();

      this.cerrarPopupExamen();
    } catch (error) {
      console.error('Error al guardar examen:', error);
      const toast = await this.toastCtrl.create({
        message: 'Error al guardar el examen: ' + (error as Error).message,
        duration: 3000,
        color: 'danger'
      });
      await toast.present();
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Cargar archivos de exámenes del paciente
   */
  async cargarArchivosExamenes() {
    if (!this.patientId) return;

    try {
      // Obtener todas las órdenes de examen del paciente
      const ordenes = await firstValueFrom(this.examenesService.getOrdenesByPaciente(this.patientId));
      
      // Extraer todos los documentos de todos los exámenes
      this.archivosExamenes = [];
      
      for (const orden of ordenes) {
        for (const examen of orden.examenes) {
          if (examen.documentos && examen.documentos.length > 0) {
            for (const doc of examen.documentos) {
              this.archivosExamenes.push({
                ...doc,
                nombreExamen: examen.nombreExamen,
                fechaOrden: orden.fecha,
                ordenId: orden.id,
                examenId: examen.idExamen
              });
            }
          }
        }
      }

      // Ordenar por fecha de subida (más recientes primero)
      this.archivosExamenes.sort((a, b) => {
        const dateA = a.fechaSubida instanceof Timestamp ? a.fechaSubida.toDate() : new Date(a.fechaSubida);
        const dateB = b.fechaSubida instanceof Timestamp ? b.fechaSubida.toDate() : new Date(b.fechaSubida);
        return dateB.getTime() - dateA.getTime();
      });

      console.log('Archivos de exámenes cargados:', this.archivosExamenes);
    } catch (error) {
      console.error('Error al cargar archivos de exámenes:', error);
    }
  }

  /**
   * Abrir archivo en visor embebido
   */
  archivoViendose: any = null;
  
  abrirArchivo(archivo: any) {
    console.log('📂 Abriendo archivo:', archivo.nombre);
    console.log('📋 Tipo MIME:', archivo.tipo);
    this.archivoViendose = archivo;
    this.editandoTexto = false;
    this.mostrarHistorial = false;
  }
  
  cerrarVisorArchivo() {
    this.archivoViendose = null;
    this.editandoTexto = false;
    this.textoEnEdicion = '';
    this.mostrarHistorial = false;
  }

  /**
   * Iniciar edición de texto OCR
   */
  iniciarEdicionTexto() {
    this.editandoTexto = true;
    this.textoEnEdicion = this.archivoViendose.textoActual || this.archivoViendose.textoExtraido || '';
  }

  /**
   * Cancelar edición de texto
   */
  cancelarEdicionTexto() {
    this.editandoTexto = false;
    this.textoEnEdicion = '';
  }

  /**
   * Guardar texto editado con historial
   */
  async guardarTextoEditado() {
    if (!this.archivoViendose || !this.patientId) return;

    try {
      this.isLoading = true;
      console.log('💾 Guardando texto editado...');

      // Obtener la orden actual
      const ordenes = await firstValueFrom(this.examenesService.getOrdenesByPaciente(this.patientId));
      const ordenActual = ordenes.find(o => o.id === this.archivoViendose.ordenId);

      if (!ordenActual) {
        throw new Error('No se encontró la orden de examen');
      }

      // Encontrar el examen y documento
      const examen = ordenActual.examenes.find(e => e.idExamen === this.archivoViendose.examenId);
      if (!examen || !examen.documentos) {
        throw new Error('No se encontró el documento');
      }

      const docIndex = examen.documentos.findIndex(d => d.url === this.archivoViendose.url);
      if (docIndex === -1) {
        throw new Error('No se encontró el documento');
      }

      // Obtener el texto actual antes de modificar
      const textoAnterior = this.archivoViendose.textoActual || this.archivoViendose.textoExtraido || '';
      
      // Solo guardar en historial si hay texto anterior diferente
      const historialActualizado = [...(examen.documentos[docIndex].historialVersiones || [])];
      
      if (textoAnterior && textoAnterior !== this.textoEnEdicion) {
        // Guardar la versión anterior en el historial
        const versionAnterior = {
          fecha: Timestamp.now(),
          usuario: 'system', // Aquí deberías poner el ID del usuario actual
          texto: textoAnterior,
          descripcion: this.generarDescripcionVersion(textoAnterior, this.textoEnEdicion)
        };
        historialActualizado.push(versionAnterior);
      } else if (!textoAnterior && this.textoEnEdicion) {
        // Primera edición, guardar versión OCR original si existe
        const textoOCR = this.archivoViendose.textoExtraido;
        if (textoOCR) {
          const versionOCR = {
            fecha: this.archivoViendose.fechaSubida || Timestamp.now(),
            usuario: 'OCR',
            texto: textoOCR,
            descripcion: 'Versión original extraída por OCR'
          };
          historialActualizado.push(versionOCR);
        }
      }

      // Actualizar documento con la nueva versión actual
      examen.documentos[docIndex] = {
        ...examen.documentos[docIndex],
        textoActual: this.textoEnEdicion, // Guardar como versión actual
        historialVersiones: historialActualizado
      };

      // Guardar en Firestore
      await this.actualizarOrden(ordenActual);

      // Actualizar vista local
      this.archivoViendose = {
        ...this.archivoViendose,
        textoActual: this.textoEnEdicion,
        historialVersiones: examen.documentos[docIndex].historialVersiones
      };

      // Recargar archivos
      await this.cargarArchivosExamenes();

      const toast = await this.toastCtrl.create({
        message: 'Texto guardado exitosamente',
        duration: 2000,
        color: 'success'
      });
      await toast.present();

      this.editandoTexto = false;
      this.textoEnEdicion = '';

    } catch (error) {
      console.error('❌ Error al guardar texto:', error);
      const toast = await this.toastCtrl.create({
        message: 'Error al guardar el texto: ' + (error as Error).message,
        duration: 3000,
        color: 'danger'
      });
      await toast.present();
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Generar descripción de la versión
   */
  private generarDescripcionVersion(textoAnterior: string, textoNuevo: string): string {
    if (!textoNuevo || textoNuevo.trim() === '') {
      return 'Texto eliminado completamente';
    }
    
    if (!textoAnterior || textoAnterior.trim() === '') {
      return 'Primera versión del texto';
    }
    
    const longitudAnterior = textoAnterior.length;
    const longitudNueva = textoNuevo.length;
    const diferencia = longitudNueva - longitudAnterior;
    
    if (diferencia > 50) {
      return `Contenido ampliado (+${diferencia} caracteres)`;
    } else if (diferencia < -50) {
      return `Contenido reducido (${diferencia} caracteres)`;
    } else if (Math.abs(diferencia) <= 50) {
      return 'Texto modificado';
    }
    
    return 'Versión editada';
  }

  /**
   * Restaurar una versión anterior del texto
   */
  async restaurarVersion(version: any) {
    const confirmar = confirm(
      `¿Estás seguro de restaurar esta versión?\n\n` +
      `Fecha: ${version.fecha?.toDate ? version.fecha.toDate().toLocaleString() : new Date(version.fecha).toLocaleString()}\n` +
      `Descripción: ${version.descripcion}\n\n` +
      `La versión actual se guardará en el historial.`
    );

    if (!confirmar) return;

    try {
      this.isLoading = true;
      console.log('🔄 Restaurando versión:', version);

      // Obtener la orden actual
      const ordenes = await firstValueFrom(this.examenesService.getOrdenesByPaciente(this.patientId!));
      const ordenActual = ordenes.find(o => o.id === this.archivoViendose.ordenId);

      if (!ordenActual) {
        throw new Error('No se encontró la orden de examen');
      }

      // Encontrar el examen y documento
      const examen = ordenActual.examenes.find(e => e.idExamen === this.archivoViendose.examenId);
      if (!examen || !examen.documentos) {
        throw new Error('No se encontró el documento');
      }

      const docIndex = examen.documentos.findIndex(d => d.url === this.archivoViendose.url);
      if (docIndex === -1) {
        throw new Error('No se encontró el documento');
      }

      // Guardar la versión actual en el historial antes de restaurar
      const textoActualAnterior = this.archivoViendose.textoActual || '';
      const historialActualizado = [...(examen.documentos[docIndex].historialVersiones || [])];
      
      if (textoActualAnterior) {
        const versionActualAnterior = {
          fecha: Timestamp.now(),
          usuario: 'system',
          texto: textoActualAnterior,
          descripcion: 'Versión antes de restaurar'
        };
        historialActualizado.push(versionActualAnterior);
      }

      // Restaurar la versión seleccionada como versión actual
      examen.documentos[docIndex] = {
        ...examen.documentos[docIndex],
        textoActual: version.texto,
        historialVersiones: historialActualizado
      };

      // Guardar en Firestore
      await this.actualizarOrden(ordenActual);

      // Actualizar vista local
      this.archivoViendose = {
        ...this.archivoViendose,
        textoActual: version.texto,
        historialVersiones: examen.documentos[docIndex].historialVersiones
      };

      // Recargar archivos
      await this.cargarArchivosExamenes();

      const toast = await this.toastCtrl.create({
        message: 'Versión restaurada exitosamente',
        duration: 2000,
        color: 'success'
      });
      await toast.present();

      console.log('✅ Versión restaurada correctamente');

    } catch (error) {
      console.error('❌ Error al restaurar versión:', error);
      const toast = await this.toastCtrl.create({
        message: 'Error al restaurar la versión: ' + (error as Error).message,
        duration: 3000,
        color: 'danger'
      });
      await toast.present();
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * Descargar archivo desde base64
   */
  descargarArchivo(archivo: any) {
    console.log('💾 Descargando archivo:', archivo.nombre);
    
    try {
      // Crear un enlace temporal para descargar
      const link = document.createElement('a');
      link.href = archivo.url;
      link.download = archivo.nombre;
      link.style.display = 'none';
      
      // Agregar al DOM, hacer click y remover
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      
      console.log('✅ Descarga iniciada');
      
      // Mostrar toast de confirmación
      this.toastCtrl.create({
        message: 'Descarga iniciada',
        duration: 2000,
        color: 'success'
      }).then(toast => toast.present());
      
    } catch (error) {
      console.error('❌ Error al descargar archivo:', error);
      this.toastCtrl.create({
        message: 'Error al descargar el archivo',
        duration: 2000,
        color: 'danger'
      }).then(toast => toast.present());
    }
  }
  
  /**
   * Obtener URL sanitizada para iframe
   */
  getSafeUrl(url: string): SafeResourceUrl {
    console.log('🔒 Sanitizando URL para iframe (primeros 100 chars):', url.substring(0, 100));
    const safeUrl = this.sanitizer.bypassSecurityTrustResourceUrl(url);
    console.log('✅ URL sanitizada');
    return safeUrl;
  }

  /**
   * Ver datos de Firestore en consola (debugging)
   */
  async verDatosFirestore() {
    if (!this.patientId) {
      console.warn('⚠️ No hay paciente seleccionado');
      return;
    }

    console.log('🔍 === DATOS DE FIRESTORE ===');
    console.log('👤 Paciente ID:', this.patientId);
    
    try {
      const ordenes = await firstValueFrom(this.examenesService.getOrdenesByPaciente(this.patientId));
      console.log('📦 Total de órdenes encontradas:', ordenes.length);
      console.log('📋 Órdenes completas:', ordenes);
      
      ordenes.forEach((orden, index) => {
        console.log(`\n📄 Orden ${index + 1}:`, {
          id: orden.id,
          paciente: orden.idPaciente,
          fecha: orden.fecha,
          estado: orden.estado,
          totalExamenes: orden.examenes.length
        });
        
        orden.examenes.forEach((examen, exIndex) => {
          console.log(`  🧪 Examen ${exIndex + 1}: ${examen.nombreExamen}`);
          console.log('     Documentos:', examen.documentos?.length || 0);
          
          if (examen.documentos && examen.documentos.length > 0) {
            examen.documentos.forEach((doc, docIndex) => {
              console.log(`     📎 Documento ${docIndex + 1}:`, {
                nombre: doc.nombre,
                tipo: doc.tipo,
                tamaño: this.formatFileSize(doc.tamanio),
                urlPreview: doc.url.substring(0, 50) + '...',
                urlCompleta: doc.url
              });
            });
          }
        });
      });
      
      console.log('\n🎯 Archivos procesados para UI:', this.archivosExamenes);
      console.log('=== FIN DATOS FIRESTORE ===\n');
      
      const toast = await this.toastCtrl.create({
        message: `${ordenes.length} órdenes encontradas. Ver consola (F12)`,
        duration: 3000,
        color: 'primary'
      });
      await toast.present();
    } catch (error) {
      console.error('❌ Error al obtener datos:', error);
    }
  }

  /**
   * Eliminar archivo de examen
   */
  async eliminarArchivoExamen(archivo: any) {
    // Mostrar popup de confirmación personalizado
    this.archivoAEliminar = archivo;
    this.mostrarConfirmacionEliminar = true;
  }

  /**
   * Confirmar eliminación de archivo
   */
  async confirmarEliminacion() {
    this.mostrarConfirmacionEliminar = false;
    
    if (!this.archivoAEliminar) return;

    try {
      this.isLoading = true;
      console.log('🗑️ Eliminando archivo:', this.archivoAEliminar);

      // 1. Obtener la orden completa desde Firestore
      const ordenes = await firstValueFrom(this.examenesService.getOrdenesByPaciente(this.patientId!));
      const ordenActual = ordenes.find(o => o.id === this.archivoAEliminar.ordenId);

      if (!ordenActual) {
        throw new Error('No se encontró la orden de examen');
      }

      console.log('📦 Orden encontrada:', ordenActual);

      // 2. Encontrar el examen que contiene el documento
      const examenIndex = ordenActual.examenes.findIndex(e => e.idExamen === this.archivoAEliminar.examenId);
      if (examenIndex === -1) {
        throw new Error('No se encontró el examen');
      }

      const examen = ordenActual.examenes[examenIndex];
      console.log('🧪 Examen encontrado:', examen);

      // 3. Filtrar el documento a eliminar
      if (!examen.documentos || examen.documentos.length === 0) {
        throw new Error('No hay documentos para eliminar');
      }

      const nuevosDocumentos = examen.documentos.filter(doc => doc.url !== this.archivoAEliminar.url);
      console.log('📄 Documentos después de filtrar:', nuevosDocumentos.length);

      // 4. Actualizar el examen con los nuevos documentos
      ordenActual.examenes[examenIndex] = {
        ...examen,
        documentos: nuevosDocumentos
      };

      // 5. Si no quedan documentos y solo hay este examen, eliminar toda la orden
      if (nuevosDocumentos.length === 0 && ordenActual.examenes.length === 1) {
        console.log('🗑️ Eliminando orden completa (no quedan documentos)');
        await this.eliminarOrdenCompleta(ordenActual.id!);
      } else if (nuevosDocumentos.length === 0) {
        // Si no quedan documentos pero hay más exámenes, eliminar solo este examen
        console.log('🗑️ Eliminando examen (no quedan documentos)');
        ordenActual.examenes.splice(examenIndex, 1);
        await this.actualizarOrden(ordenActual);
      } else {
        // Actualizar la orden con los documentos filtrados
        console.log('💾 Actualizando orden con documentos filtrados');
        await this.actualizarOrden(ordenActual);
      }

      // 6. Recargar la lista de archivos
      await this.cargarArchivosExamenes();

      const toast = await this.toastCtrl.create({
        message: 'Archivo eliminado exitosamente',
        duration: 2000,
        color: 'success'
      });
      await toast.present();
      
    } catch (error) {
      console.error('❌ Error al eliminar archivo:', error);
      const toast = await this.toastCtrl.create({
        message: 'Error al eliminar el archivo: ' + (error as Error).message,
        duration: 3000,
        color: 'danger'
      });
      await toast.present();
    } finally {
      this.isLoading = false;
      this.archivoAEliminar = null;
    }
  }

  /**
   * Cancelar eliminación de archivo
   */
  cancelarEliminacion() {
    this.mostrarConfirmacionEliminar = false;
    this.archivoAEliminar = null;
  }

  /**
   * Alternar expansión del historial médico
   */
  toggleHistorial() {
    this.historialExpandido = !this.historialExpandido;
  }

  /**
   * Obtener items del historial para mostrar (limitados o completos)
   */
  get timelineItemsVisible() {
    if (this.historialExpandido) {
      return this.timelineItems;
    }
    return this.timelineItems.slice(0, 3);
  }

  /**
   * Verificar si hay más items para mostrar
   */
  get hayMasItems() {
    return this.timelineItems.length > 3;
  }

  /**
   * Actualizar una orden de examen en Firestore
   */
  private async actualizarOrden(orden: OrdenExamen): Promise<void> {
    const docRef = doc(this.firestore, 'ordenes-examen', orden.id!);
    
    await updateDoc(docRef, {
      examenes: orden.examenes,
      updatedAt: Timestamp.now()
    });
    
    console.log('✅ Orden actualizada en Firestore');
  }

  /**
   * Eliminar una orden completa de examen
   */
  private async eliminarOrdenCompleta(ordenId: string): Promise<void> {
    const docRef = doc(this.firestore, 'ordenes-examen', ordenId);
    
    await deleteDoc(docRef);
    
    console.log('✅ Orden eliminada completamente de Firestore');
  }

  /**
   * Obtener icono según tipo de archivo
   */
  getFileIcon(tipo: string): string {
    if (tipo.includes('pdf')) return 'document-text';
    if (tipo.includes('image')) return 'image';
    if (tipo.includes('word') || tipo.includes('document')) return 'document';
    return 'document-attach';
  }

  /**
   * Obtener color según tipo de examen
   */
  getTipoExamenColor(nombreExamen: string): string {
    const nombre = nombreExamen.toLowerCase();
    if (nombre.includes('sangre') || nombre.includes('hemograma')) return 'danger';
    if (nombre.includes('orina')) return 'warning';
    if (nombre.includes('rayos') || nombre.includes('radiograf')) return 'tertiary';
    if (nombre.includes('resonancia') || nombre.includes('tomograf')) return 'secondary';
    return 'primary';
  }

  /**
   * Formatear tamaño de archivo
   */
  formatFileSize(bytes: number): string {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / 1048576).toFixed(1) + ' MB';
  }

  /**
   * Convertir archivo a Base64 (para desarrollo sin Storage)
   */
  private convertirArchivoABase64(file: File): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const base64 = (reader.result as string).split(',')[1];
        resolve(base64);
      };
      reader.onerror = () => reject(reader.error);
      reader.readAsDataURL(file);
    });
  }

  /**
   * Comprimir imagen usando canvas con calidad específica
   */
  private comprimirImagen(canvas: HTMLCanvasElement, quality: number): Promise<Blob> {
    return new Promise((resolve, reject) => {
      canvas.toBlob((blob) => {
        if (blob) {
          resolve(blob);
        } else {
          reject(new Error('Error al comprimir imagen'));
        }
      }, 'image/jpeg', quality);
    });
  }
  
  /**
   * Cerrar popup de nueva consulta
   */
  cerrarPopupConsulta() {
    this.showConsultaPopup = false;
    this.formSubmitted = false;
  }
  
  /**
   * Validar formulario de consulta
   */
  isConsultaFormValid(): boolean {
    return this.datosNuevaConsulta.motivoConsulta.trim().length > 0;
  }
  
  /**
   * Confirmar y guardar nueva consulta
   */
  async confirmarNuevaConsulta() {
    this.formSubmitted = true;
    
    if (!this.isConsultaFormValid()) {
      const toast = await this.toastCtrl.create({
        message: 'El motivo de consulta es obligatorio',
        duration: 2000,
        color: 'warning'
      });
      await toast.present();
      return;
    }
    
    const consultaData = {
      pacienteId: this.paciente?.id,
      fichaMedicaId: this.fichaId,
      fecha: Timestamp.fromDate(new Date(this.datosNuevaConsulta.fechaConsulta)),
      motivoConsulta: this.datosNuevaConsulta.motivoConsulta,
      diagnostico: this.datosNuevaConsulta.diagnostico,
      tratamiento: this.datosNuevaConsulta.tratamiento,
      signosVitales: this.datosNuevaConsulta.signosVitales,
      observaciones: this.datosNuevaConsulta.observaciones
    };
    
    await this.guardarConsulta(consultaData);
    this.cerrarPopupConsulta();
  }
}
