import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { Router } from '@angular/router';
import {
  // Base / listas
  IonContent, IonList, IonItem,
  // Inputs
  IonSearchbar, IonInput, IonTextarea, IonSelect, IonSelectOption,
  // UI
  IonIcon, IonBadge,
  IonModal
} from '@ionic/angular/standalone';
import { FormsModule } from '@angular/forms';
import { NgFor, NgClass, NgIf } from '@angular/common';
import { CommonModule } from '@angular/common';
import { PacientesService } from '../data/pacientes.service';
import { FichasMedicasService } from '../../fichas-medicas/data/fichas-medicas.service';
import { Paciente } from '../../../models/paciente.model';
import { Subscription } from 'rxjs';
import { Timestamp } from '@angular/fire/firestore';
import { AvatarUtils } from '../../../shared/utils/avatar.utils';
import { SkeletonLoaderComponent } from '../../../shared/components/skeleton-loader/skeleton-loader.component';

/**
 * UI-friendly patient display interface with calculated fields
 */
interface PacienteUI {
  id: string;
  edad?: number;
  iniciales?: string;
  nombreCompleto?: string;
  nombres?: string;
  apellidos?: string;
  documento?: string;
  rut?: string;
  telefono?: string;
  email?: string;
  direccion?: string;
  estado?: 'activo' | 'inactivo';
  ultimaVisita?: string;
  ubicacion?: string;
  diagnostico?: string;
  // Medical data
  fechaNacimiento?: Date | Timestamp;
  sexo?: 'M' | 'F' | 'Otro';
  grupoSanguineo?: string;
  alergias?: string[];
  enfermedadesCronicas?: string[];
  medicamentosActuales?: any[];
  contactoEmergencia?: any;
  prevision?: string;
  numeroFicha?: string;
  observaciones?: string;
  alertasMedicas?: any[];
  idUsuario?: string;
  idPaciente?: string;
  // Timestamps
  createdAt?: Date | Timestamp;
  updatedAt?: Date | Timestamp;
}

@Component({
  selector: 'app-patient-list',
  standalone: true,
  imports: [
    // Ionic usados en el HTML
    IonContent, IonList, IonItem,
    IonSearchbar, IonInput, IonTextarea, IonSelect, IonSelectOption,
    IonIcon, IonBadge,
    IonModal,
    // Angular
    FormsModule, NgFor, NgClass, NgIf, CommonModule,
    // Shared components
    SkeletonLoaderComponent
  ],
  templateUrl: './patient-list.page.html',
  styleUrls: ['./patient-list.page.scss'],
})
export class PatientListPage implements OnInit, OnDestroy {
  // Estados del componente
  pacientes: PacienteUI[] = [];
  filteredPacientes: PacienteUI[] = [];
  isLoading = false;
  error: string | null = null;
  
  // Búsqueda
  query = '';
  
  // For pagination display (not used by Firestore but kept for template compatibility)
  currentPage = 1;
  totalPages = 1;
  totalPatients = 0;
  
  // Track newly created patient for temporary top sorting
  private lastCreatedPatientId: string | null = null;
  
  private subscriptions: Subscription[] = [];
  private router = inject(Router);
  private pacientesService = inject(PacientesService);
  private fichasMedicasService = inject(FichasMedicasService);

  ngOnInit() {
    this.loadPatients();
  }

  ngOnDestroy() {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  /**
   * Cargar todos los pacientes desde Firestore
   */
  loadPatients() {
    this.isLoading = true;
    this.error = null;

    this.subscriptions.push(
      this.pacientesService.getAllPacientes().subscribe({
        next: (pacientes) => {
          this.pacientes = pacientes.map(this.enrichPatient);
          
          // If we just created a patient, show it at the top temporarily
          if (this.lastCreatedPatientId) {
            this.pacientes.sort((a, b) => {
              if (a.id === this.lastCreatedPatientId) return -1;
              if (b.id === this.lastCreatedPatientId) return 1;
              return 0;
            });
          }
          
          this.filteredPacientes = [...this.pacientes];
          this.totalPatients = this.pacientes.length;
          this.isLoading = false;
        },
        error: (error) => {
          console.error('Error loading patients:', error);
          this.error = 'Error al cargar los pacientes';
          this.isLoading = false;
        }
      })
    );
  }

  /**
   * Enrich patient data with calculated fields and template compatibility
   */
  private enrichPatient = (paciente: any): PacienteUI => {
    const nombre = paciente.nombre || paciente.displayName?.split(' ')[0] || '';
    const apellido = paciente.apellido || paciente.displayName?.split(' ').slice(1).join(' ') || '';
    const nombreCompleto = paciente.nombreCompleto || paciente.displayName || `${nombre} ${apellido}`;
    
    return {
      id: paciente.id || paciente.idPaciente,
      // Calculated fields
      edad: this.calculateAge(paciente.fechaNacimiento),
      iniciales: this.initials(nombreCompleto),
      nombreCompleto,
      // Personal data
      nombres: nombre,
      apellidos: apellido,
      documento: paciente.rut || paciente.documento,
      rut: paciente.rut,
      telefono: paciente.telefono,
      email: paciente.email,
      direccion: paciente.direccion || paciente.ubicacion,
      // Status fields
      estado: (paciente as any).estado || 'activo',
      // diagnostico se guarda en 'observaciones' en Firestore
      diagnostico: paciente.observaciones || 'Sin diagnóstico registrado',
      ubicacion: paciente.direccion || paciente.ubicacion || 'Sin dirección',
      ultimaVisita: this.formatDate(paciente.updatedAt),
      // Medical data
      fechaNacimiento: paciente.fechaNacimiento,
      sexo: paciente.sexo,
      grupoSanguineo: paciente.grupoSanguineo,
      alergias: paciente.alergias,
      enfermedadesCronicas: paciente.enfermedadesCronicas,
      medicamentosActuales: paciente.medicamentosActuales,
      contactoEmergencia: paciente.contactoEmergencia,
      prevision: paciente.prevision,
      numeroFicha: paciente.numeroFicha,
      observaciones: paciente.observaciones,
      alertasMedicas: paciente.alertasMedicas,
      idUsuario: paciente.idUsuario,
      idPaciente: paciente.idPaciente
    };
  };

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

  /**
   * Formatear fecha para visualización
   */
  private formatDate(date: Date | Timestamp | string | undefined): string {
    if (!date) return 'N/A';
    
    const d = date instanceof Timestamp 
      ? date.toDate() 
      : new Date(date);
    
    return d.toLocaleDateString('es-CL');
  }

  // ---------- Navegación ----------
  goBack() { 
    this.router.navigateByUrl('/tabs/tab1'); 
  }
  
  verFicha(paciente: PacienteUI) { 
    // Usar idPaciente (ID del documento en 'pacientes') no id (UID de usuario)
    const patientId = paciente.idPaciente || paciente.id;
    console.log('📋 Ver Ficha - Paciente:', {
      id: paciente.id,
      idPaciente: paciente.idPaciente,
      idUsuario: paciente.idUsuario,
      patientId: patientId,
      nombreCompleto: paciente.nombreCompleto
    });
    this.router.navigate(['/tabs/tab3'], { 
      queryParams: { patientId: patientId } 
    }); 
  }

  // ---------- Búsqueda ----------
  onSearch(ev: any) { 
    this.query = (ev?.detail?.value || '').toLowerCase().trim();
    
    if (!this.query) {
      // Show all patients if search is empty
      this.filteredPacientes = [...this.pacientes];
      return;
    }

    // Use service search for Firestore query
    this.isLoading = true;
    
    this.subscriptions.push(
      this.pacientesService.searchPacientes(this.query).subscribe({
        next: (results) => {
          this.filteredPacientes = results.map(this.enrichPatient);
          this.isLoading = false;
        },
        error: (error) => {
          console.error('Search error:', error);
          // Fallback to client-side filtering
          this.filteredPacientes = this.pacientes.filter(p =>
            p.nombres?.toLowerCase().includes(this.query) ||
            p.apellidos?.toLowerCase().includes(this.query) ||
            p.rut?.toLowerCase().includes(this.query) ||
            p.documento?.toLowerCase().includes(this.query) ||
            p.nombreCompleto?.toLowerCase().includes(this.query)
          );
          this.isLoading = false;
        }
      })
    );
  }

  get filtered(): PacienteUI[] {
    return this.filteredPacientes;
  }

  get total(): number { 
    return this.filteredPacientes.length; 
  }

  // ---------- Utilidades UI ----------
  
  /**
   * Get initials for avatar
   */
  initials(nombre?: string): string {
    if (!nombre) return '--';
    const parts = nombre.trim().split(/\s+/);
    return AvatarUtils.getInitials(parts[0], parts[parts.length - 1]);
  }
  
  /**
   * Get avatar background color (consistent per patient)
   */
  getAvatarStyle(nombre?: string, apellido?: string): any {
    return AvatarUtils.getAvatarStyle(nombre || '', apellido);
  }
  
  /**
   * Get avatar color as string
   */
  getAvatarColor(nombre?: string, apellido?: string): string {
    return AvatarUtils.getAvatarColor(`${nombre || ''} ${apellido || ''}`);
  }

  estadoClass(estado: 'activo' | 'inactivo' | undefined) {
    return {
      'badge-estable': estado === 'activo',
      'badge-activo' : estado === 'activo',
      'badge-critico': estado === 'inactivo',
    };
  }

  // ============== CREAR PACIENTE (Modal) ==============
  isCreateOpen = false;
  newPaciente: any = {}; // Use any for form flexibility
  isEditMode = false; // Track if modal is in edit or create mode
  editingPacienteId: string | null = null; // ID of patient being edited

  openCreate() {
    this.isEditMode = false;
    this.editingPacienteId = null;
    this.newPaciente = this.blankPaciente();
    this.error = null;
    this.isCreateOpen = true;
  }

  /**
   * Open modal in edit mode with existing patient data
   */
  openEdit(paciente: PacienteUI) {
    this.isEditMode = true;
    // IMPORTANTE: Usar idPaciente (ID del documento en 'pacientes') no id (UID de usuario)
    this.editingPacienteId = paciente.idPaciente || paciente.id || null;
    
    // Pre-fill form with existing patient data - MAP ALL FIELDS
    this.newPaciente = {
      // Basic fields
      nombres: paciente.nombres,
      apellidos: paciente.apellidos,
      rut: paciente.rut || paciente.documento,
      telefono: paciente.telefono,
      direccion: paciente.direccion || paciente.ubicacion,
      fechaNacimiento: paciente.fechaNacimiento,
      grupoSanguineo: paciente.grupoSanguineo,
      email: (paciente as any).email || '',
      // Additional fields that were missing
      genero: paciente.sexo || 'Otro',
      sexo: paciente.sexo || 'Otro', // Map both for compatibility
      estadoCivil: (paciente as any).estadoCivil || 'soltero',
      ocupacion: (paciente as any).ocupacion || '',
      estado: (paciente as any).estado || 'activo',
      // diagnostico se guarda en 'observaciones' en Firestore
      diagnostico: paciente.observaciones || paciente.diagnostico || '',
      // Arrays
      alergias: paciente.alergias?.join(', ') || '',
      enfermedadesCronicas: paciente.enfermedadesCronicas?.join(', ') || '',
      contactoEmergencia: (paciente as any).contactoEmergencia || ''
    };
    
    this.error = null;
    this.isCreateOpen = true;
  }
  
  closeCreate() {
    this.isCreateOpen = false;
    this.error = null;
  }

  // Método de prueba simple
  testButton() {
    console.log('¡Botón funciona!');
    alert('¡El botón responde correctamente!');
  }

  /**
   * Format RUT as user types
   */
  formatRut(event: any) {
    let value = event.target.value;
    // Remove all non-numeric characters except K/k
    value = value.replace(/[^0-9kK]/g, '');
    
    if (value.length === 0) {
      this.newPaciente.rut = '';
      return;
    }

    // Format: 12.345.678-9
    let rut = value.slice(0, -1); // All digits except last
    let dv = value.slice(-1).toUpperCase(); // Last digit/letter

    // Add dots
    rut = rut.replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
    
    // Combine with dash
    const formatted = rut.length > 0 ? `${rut}-${dv}` : dv;
    
    this.newPaciente.rut = formatted;
    event.target.value = formatted;
  }

  /**
   * Validate Chilean RUT
   */
  validateRut(rut: string): boolean {
    if (!rut || rut.trim() === '') return false;
    
    // Remove formatting
    const cleanRut = rut.replace(/\./g, '').replace(/-/g, '');
    
    // Must be at least 2 characters (number + verifier)
    if (cleanRut.length < 2) return false;
    
    const body = cleanRut.slice(0, -1);
    const dv = cleanRut.slice(-1).toUpperCase();
    
    // Calculate verifier digit
    let sum = 0;
    let multiplier = 2;
    
    for (let i = body.length - 1; i >= 0; i--) {
      sum += parseInt(body.charAt(i)) * multiplier;
      multiplier = multiplier === 7 ? 2 : multiplier + 1;
    }
    
    const expectedDv = 11 - (sum % 11);
    const dvStr = expectedDv === 11 ? '0' : expectedDv === 10 ? 'K' : expectedDv.toString();
    
    return dv === dvStr;
  }

  /**
   * Validate email format
   */
  validateEmail(email: string): boolean {
    if (!email || email.trim() === '') return false;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  async saveCreate() {
    const p = this.newPaciente;
    
    // Map template fields (plural) to model fields (singular)
    const nombre = p.nombres || p.nombre;
    const apellido = p.apellidos || p.apellido;
    const rut = p.rut || p.documento;
    
    // Validaciones básicas
    if (!nombre?.trim()) {
      this.error = 'El campo nombre es obligatorio';
      return;
    }
    if (!apellido?.trim()) {
      this.error = 'El campo apellido es obligatorio';
      return;
    }
    if (!rut?.trim()) {
      this.error = 'El campo RUT es obligatorio';
      return;
    }
    
    // Validate RUT format
    if (!this.validateRut(rut)) {
      this.error = 'El RUT ingresado no es válido';
      return;
    }
    
    // Validate email
    if (p.email && !this.validateEmail(p.email)) {
      this.error = 'El email ingresado no es válido (debe contener @)';
      return;
    }
    
    // Validate phone (Chilean format: 9 digits)
    if (p.telefono) {
      const cleanPhone = p.telefono.replace(/\D/g, '');
      if (cleanPhone.length !== 9) {
        this.error = 'El teléfono debe tener exactamente 9 dígitos';
        return;
      }
    }
    
    if (!p.fechaNacimiento) {
      this.error = 'El campo fecha de nacimiento es obligatorio';
      return;
    }

    // Limpiar error previo
    this.error = null;
    this.isLoading = true;

    // Preparar datos para Firestore
    // Note: Using 'any' type for compatibility with old data structure
    // TODO: Migrate to new architecture (usuarios + pacientes collections)
    const pacienteData: any = {
      displayName: `${nombre.trim()} ${apellido.trim()}`,
      rut: rut.trim(),
      fechaNacimiento: typeof p.fechaNacimiento === 'string'
        ? Timestamp.fromDate(new Date(p.fechaNacimiento))
        : Timestamp.now(),
      sexo: (p.sexo || p.genero || 'Otro') as 'M' | 'F' | 'Otro',
      direccion: p.direccion?.trim() || 'Sin dirección',
      telefono: p.telefono?.trim() || 'Sin teléfono',
      nombreCompleto: `${nombre.trim()} ${apellido.trim()}`,
      updatedAt: Timestamp.now()
    };

    // Add extended fields (ALWAYS include these, even in edit mode)
    (pacienteData as any).estado = p.estado || 'activo';
    (pacienteData as any).diagnostico = p.diagnostico?.trim() || 'Sin diagnóstico registrado';
    (pacienteData as any).estadoCivil = p.estadoCivil || 'soltero';
    (pacienteData as any).ocupacion = p.ocupacion?.trim() || '';

    // Only add optional fields if they have values
    if (p.email?.trim()) {
      // Email should be in usuarios collection in new architecture
      pacienteData.email = p.email.trim();
    }
    if (p.grupoSanguineo?.trim()) {
      pacienteData.grupoSanguineo = p.grupoSanguineo.trim();
    }

    // Only add arrays and createdAt for new patients
    if (!this.isEditMode) {
      (pacienteData as any).alergias = [];
      (pacienteData as any).enfermedadesCronicas = [];
      (pacienteData as any).alertasMedicas = [];
      pacienteData.createdAt = Timestamp.now();
    }

    try {
      if (this.isEditMode && this.editingPacienteId) {
        // UPDATE existing patient with new architecture
        console.log('✏️ Actualizando paciente existente con nueva arquitectura...');
        
        await this.pacientesService.updatePacienteCompleto(
          this.editingPacienteId,
          // Datos personales (van a 'usuarios')
          {
            displayName: `${nombre.trim()} ${apellido.trim()}`,
            telefono: p.telefono?.trim()
          },
          // Datos médicos (van a 'pacientes')
          {
            fechaNacimiento: typeof p.fechaNacimiento === 'string'
              ? Timestamp.fromDate(new Date(p.fechaNacimiento))
              : p.fechaNacimiento,
            sexo: (p.sexo || p.genero || 'Otro') as 'M' | 'F' | 'Otro',
            grupoSanguineo: p.grupoSanguineo?.trim() as any,
            observaciones: p.diagnostico?.trim() || p.observaciones
          }
        );
        
        this.lastCreatedPatientId = null; // Clear temp sort
        console.log('✅ Paciente actualizado correctamente');
      } else {
        // CREATE new patient with new architecture
        console.log('🆕 Creando nuevo paciente con arquitectura normalizada...');
        
        // Generate temporary password (user should change it later)
        const tempPassword = `${rut.trim().substring(0, 8)}${Math.floor(Math.random() * 1000)}`;
        
        const pacienteCompleto = await this.pacientesService.createPacienteCompleto(
          // Datos personales para usuario
          {
            email: p.email?.trim() || `${rut.trim()}@nexus.temp`,  // Email temporal si no se proporciona
            password: tempPassword,
            displayName: `${nombre.trim()} ${apellido.trim()}`,
            rut: rut.trim(),
            telefono: p.telefono?.trim()
          },
          // Datos médicos para paciente
          {
            fechaNacimiento: typeof p.fechaNacimiento === 'string'
              ? Timestamp.fromDate(new Date(p.fechaNacimiento))
              : Timestamp.now(),
            sexo: (p.sexo || p.genero || 'Otro') as 'M' | 'F' | 'Otro',
            grupoSanguineo: p.grupoSanguineo?.trim() as any,
            alergias: [],
            enfermedadesCronicas: [],
            medicamentosActuales: [],
            prevision: 'FONASA',
            observaciones: p.diagnostico?.trim() || 'Sin observaciones',
            alertasMedicas: []
          }
        );
        
        this.lastCreatedPatientId = pacienteCompleto.idPaciente; // Store for temp sorting
        
        console.log('✅ Paciente creado:', pacienteCompleto);
        
        // Auto-create ficha medica with patient data
        await this.fichasMedicasService.createFicha({
          idPaciente: pacienteCompleto.idPaciente,
          fechaMedica: Timestamp.now(),
          observacion: `Ficha médica de ${nombre.trim()} ${apellido.trim()}`,
          antecedentes: {
            familiares: '',
            personales: '',
            quirurgicos: '',
            hospitalizaciones: '',
            alergias: []
          },
          totalConsultas: 0
        });
        
        console.log('📋 Ficha médica creada automáticamente');
      }

      this.loadPatients(); // Reload patient list
      this.closeCreate();
      this.isLoading = false;
    } catch (error: any) {
      console.error('Error al guardar paciente:', error);
      this.error = error?.message || 'Error al guardar el paciente';
      this.isLoading = false;
    }
  }

  private today(): string {
    const d = new Date();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    return `${d.getFullYear()}-${mm}-${dd}`;
  }

  private blankPaciente(): any {
    return {
      // Template uses plural forms
      nombres: '',
      apellidos: '',
      rut: '',
      telefono: '',
      email: '',
      direccion: '',
      fechaNacimiento: new Date().toISOString().split('T')[0], // YYYY-MM-DD
      genero: 'Otro',
      estadoCivil: 'soltero',
      ocupacion: '',
      // Model uses singular forms
      nombre: '',
      apellido: '',
      sexo: 'Otro',
      estado: 'activo',
      diagnostico: '',
      ultimaVisita: ''
    };
  }

  // ============== EXPORTAR (CSV) ==============
  exportar() {
    const header = ['Nombre','Apellido','RUT','Teléfono','Email','Edad','Última actualización'];
    const rows = this.filtered.map(p => [
      p.nombres,
      p.apellidos,
      p.rut || p.documento || '',
      p.telefono || '',
      p.email || '',
      p.edad || '',
      this.formatDate(p.updatedAt)
    ]);

    const toCsv = (r: any[]) => r.map(v => `"${String(v ?? '').replace(/"/g, '""')}"`).join(',');
    const csv = [toCsv(header), ...rows.map(toCsv)].join('\r\n');

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `pacientes_${this.today()}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }

  // ============== PAGINACIÓN (Placeholders for template compatibility) ==============
  previousPage() {
    // Firestore doesn't use pagination like this
    // Could be implemented with startAfter/endBefore cursors later
    console.log('Pagination not implemented with Firestore yet');
  }

  nextPage() {
    // Firestore doesn't use pagination like this
    console.log('Pagination not implemented with Firestore yet');
  }

  // ============== REFRESCAR ==============
  refreshPatients() {
    this.loadPatients();
  }

  // ============== ELIMINAR ERROR ==============
  clearError() {
    this.error = null;
  }
}
