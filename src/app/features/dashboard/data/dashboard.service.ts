import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  collectionData,
  query,
  where,
  orderBy,
  limit,
  Timestamp,
  getDocs,
} from '@angular/fire/firestore';
import { Observable, combineLatest, map, from } from 'rxjs';
import { PacientesService } from '../../pacientes/data/pacientes.service';
import { ConsultasService } from '../../consultas/data/consultas.service';
import { ExamenesService } from '../../examenes/data/examenes.service';
import { MedicamentosService } from '../../medicamentos/data/medicamentos.service';

export interface DashboardStats {
  consultasHoy: number;
  pacientesActivos: number;
  examenPendientes: number;
  alertasCriticas: number;
}

export interface ConsultasPorEspecialidad {
  especialidad: string;
  cantidad: number;
}

export interface AlertaDashboard {
  id: string;
  tipo: 'paciente' | 'examen' | 'medicamento' | 'sistema';
  titulo: string;
  descripcion: string;
  severidad: 'baja' | 'media' | 'alta' | 'critica';
  fecha: Date;
  pacienteId?: string;
  pacienteNombre?: string;
}

export interface AccionRapida {
  id: string;
  titulo: string;
  descripcion: string;
  icono: string;
  ruta: string;
  color: string;
}

export interface ActividadReciente {
  id: string;
  tipo: 'consulta' | 'examen' | 'medicamento' | 'paciente';
  titulo: string;
  descripcion: string;
  fecha: Date;
  icono: string;
}

/**
 * Dashboard Service - Aggregates data from multiple services
 * Provides KPIs, alerts, recent activity, and quick actions for the dashboard
 */
@Injectable({
  providedIn: 'root'
})
export class DashboardService {
  private firestore = inject(Firestore);
  private pacientesService = inject(PacientesService);
  private consultasService = inject(ConsultasService);
  private examenesService = inject(ExamenesService);
  private medicamentosService = inject(MedicamentosService);

  /**
   * Get dashboard statistics (KPIs)
   */
  getDashboardStats(): Observable<DashboardStats> {
    return from(this.getDashboardStatsAsync());
  }

  private async getDashboardStatsAsync(): Promise<DashboardStats> {
    const [consultasHoy, pacientesActivos, examenPendientes, alertasCriticas] = await Promise.all([
      this.consultasService.getConsultationsCountToday(),
      this.pacientesService.getActivePatientsCount(),
      this.examenesService.getPendingExamOrdersCount(),
      this.examenesService.getCriticalExamsCount(),
    ]);

    return {
      consultasHoy,
      pacientesActivos,
      examenPendientes,
      alertasCriticas,
    };
  }

  /**
   * Get consultations by specialty for today
   * Uses real data from consultations grouped by professional specialty
   */
  async getConsultasPorEspecialidad(): Promise<ConsultasPorEspecialidad[]> {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayTimestamp = Timestamp.fromDate(today);
    
    const ref = collection(this.firestore, 'consultas');
    const q = query(
      ref,
      where('fecha', '>=', todayTimestamp)
    );
    
    const snapshot = await getDocs(q);
    
    // Group by professional and count
    // Since we don't have specialty field, we group by professional ID
    const profesionalCounts: { [key: string]: number } = {};
    
    snapshot.forEach(doc => {
      const consulta = doc.data();
      const profId = consulta['idProfesional'] || 'General';
      profesionalCounts[profId] = (profesionalCounts[profId] || 0) + 1;
    });
    
    // Convert to array and return
    return Object.entries(profesionalCounts).map(([especialidad, cantidad]) => ({
      especialidad: `Profesional ${especialidad}`,
      cantidad
    }));
  }

  /**
   * Get critical alerts for dashboard
   * Aggregates alerts from patients, exams, and medications
   */
  getDashboardAlerts(): Observable<AlertaDashboard[]> {
    return combineLatest([
      this.pacientesService.getPacientesWithAlerts(),
      this.examenesService.getOrdenesConResultadosCriticos(),
    ]).pipe(
      map(([pacientesConAlertas, ordenesConAlertas]) => {
        const alertas: AlertaDashboard[] = [];

        // Patient alerts (allergies, chronic diseases)
        pacientesConAlertas.slice(0, 5).forEach(paciente => {
          if (paciente.alertasMedicas && paciente.alertasMedicas.length > 0) {
            const alertaMasReciente = paciente.alertasMedicas[0];
            
            // Safely convert fecha to Date
            let fecha: Date;
            if (alertaMasReciente.fechaRegistro instanceof Timestamp) {
              fecha = alertaMasReciente.fechaRegistro.toDate();
            } else if (alertaMasReciente.fechaRegistro instanceof Date) {
              fecha = alertaMasReciente.fechaRegistro;
            } else if (typeof alertaMasReciente.fechaRegistro === 'string') {
              fecha = new Date(alertaMasReciente.fechaRegistro);
            } else {
              fecha = new Date(); // Fallback to now
            }
            
            // Validate date
            if (isNaN(fecha.getTime())) {
              fecha = new Date(); // Fallback if invalid
            }
            
            alertas.push({
              id: `paciente-${paciente.id}`,
              tipo: 'paciente',
              titulo: `Alerta: ${paciente.nombre} ${paciente.apellido}`,
              descripcion: alertaMasReciente.descripcion,
              severidad: alertaMasReciente.severidad,
              fecha: fecha,
              pacienteId: paciente.id,
              pacienteNombre: `${paciente.nombre} ${paciente.apellido}`,
            });
          }
        });

        // Exam alerts (critical results from orden examen)
        ordenesConAlertas.slice(0, 5).forEach(orden => {
          const alertaData = (orden as any).alerta;
          if (alertaData && alertaData.esCritico) {
            
            // Safely convert fecha to Date
            let fecha: Date;
            if (orden.fecha instanceof Timestamp) {
              fecha = orden.fecha.toDate();
            } else if (orden.fecha instanceof Date) {
              fecha = orden.fecha;
            } else if (typeof orden.fecha === 'string') {
              fecha = new Date(orden.fecha);
            } else {
              fecha = new Date(); // Fallback to now
            }
            
            // Validate date
            if (isNaN(fecha.getTime())) {
              fecha = new Date(); // Fallback if invalid
            }
            
            alertas.push({
              id: `orden-${orden.id}`,
              tipo: 'examen',
              titulo: `Examen crítico`,
              descripcion: alertaData.razon || 'Valores fuera de rango',
              severidad: alertaData.severidad || 'alta',
              fecha: fecha,
              pacienteId: orden.idPaciente,
            });
          }
        });

        // Sort by date (most recent first) and severity
        return alertas
          .sort((a, b) => {
            const severityOrder = { critica: 4, alta: 3, media: 2, baja: 1 };
            const severityDiff = severityOrder[b.severidad] - severityOrder[a.severidad];
            if (severityDiff !== 0) return severityDiff;
            return b.fecha.getTime() - a.fecha.getTime();
          })
          .slice(0, 10); // Top 10 alerts
      })
    );
  }

  /**
   * Get quick actions for dashboard
   */
  getQuickActions(): AccionRapida[] {
    return [
      {
        id: 'nuevo-paciente',
        titulo: 'Nuevo Paciente',
        descripcion: 'Registrar nuevo paciente en el sistema',
        icono: 'person-add-outline',
        ruta: '/tabs/tab2', // Navigate to patients tab
        color: 'primary',
      },
      {
        id: 'buscar-paciente',
        titulo: 'Buscar Paciente',
        descripcion: 'Buscar y ver fichas médicas',
        icono: 'search-outline',
        ruta: '/tabs/tab2',
        color: 'secondary',
      },
      {
        id: 'nueva-consulta',
        titulo: 'Nueva Consulta',
        descripcion: 'Registrar consulta médica',
        icono: 'document-text-outline',
        ruta: '/tabs/tab3',
        color: 'tertiary',
      },
      {
        id: 'orden-examen',
        titulo: 'Orden de Examen',
        descripcion: 'Crear nueva orden de examen',
        icono: 'flask-outline',
        ruta: '/tabs/tab5',
        color: 'success',
      },
      {
        id: 'nueva-receta',
        titulo: 'Nueva Receta',
        descripcion: 'Prescribir medicamentos',
        icono: 'medical-outline',
        ruta: '/tabs/tab4',
        color: 'warning',
      },
    ];
  }

  /**
   * Get recent activity feed
   * Combines recent consultations, exams, and prescriptions
   */
  getRecentActivity(): Observable<ActividadReciente[]> {
    return combineLatest([
      this.consultasService.getRecentConsultations(10),
      this.medicamentosService.getRecetasRecientes(10)
    ]).pipe(
      map(([consultas, recetas]) => {
        const actividades: ActividadReciente[] = [];

        // Recent consultations
        consultas.forEach(consulta => {
          // Safely convert fecha to Date
          let fecha: Date;
          if (consulta.fecha instanceof Timestamp) {
            fecha = consulta.fecha.toDate();
          } else if (consulta.fecha instanceof Date) {
            fecha = consulta.fecha;
          } else if (typeof consulta.fecha === 'string') {
            fecha = new Date(consulta.fecha);
          } else {
            fecha = new Date(); // Fallback to now
          }
          
          // Validate date
          if (isNaN(fecha.getTime())) {
            fecha = new Date(); // Fallback if invalid
          }
          
          actividades.push({
            id: `consulta-${consulta.id}`,
            tipo: 'consulta',
            titulo: 'Consulta registrada',
            descripcion: consulta.motivo || 'Sin motivo especificado',
            fecha: fecha,
            icono: 'document-text-outline',
          });
        });

        // Recent prescriptions
        recetas.forEach(receta => {
          const medicamentos = receta.medicamentos && receta.medicamentos.length > 0
            ? receta.medicamentos.map(m => m.nombreMedicamento).join(', ')
            : 'Medicamentos varios';
          
          // Safely convert fecha to Date
          let fecha: Date;
          if (receta.fecha instanceof Timestamp) {
            fecha = receta.fecha.toDate();
          } else if (receta.fecha instanceof Date) {
            fecha = receta.fecha;
          } else if (typeof receta.fecha === 'string') {
            fecha = new Date(receta.fecha);
          } else {
            fecha = new Date(); // Fallback to now
          }
          
          // Validate date
          if (isNaN(fecha.getTime())) {
            fecha = new Date(); // Fallback if invalid
          }
          
          actividades.push({
            id: `receta-${receta.id}`,
            tipo: 'medicamento',
            titulo: 'Receta emitida',
            descripcion: medicamentos,
            fecha: fecha,
            icono: 'medical-outline',
          });
        });

        // Sort by date (most recent first)
        return actividades
          .sort((a, b) => b.fecha.getTime() - a.fecha.getTime())
          .slice(0, 15); // Top 15 activities
      })
    );
  }

  /**
   * Get monthly statistics for charts/graphs
   */
  async getMonthlyStats(): Promise<{
    consultas: number;
    pacientesNuevos: number;
    examenes: number;
  }> {
    const firstDayOfMonth = new Date();
    firstDayOfMonth.setDate(1);
    firstDayOfMonth.setHours(0, 0, 0, 0);
    
    const lastDayOfMonth = new Date();
    lastDayOfMonth.setMonth(lastDayOfMonth.getMonth() + 1);
    lastDayOfMonth.setDate(0);
    lastDayOfMonth.setHours(23, 59, 59, 999);

    const [consultas, examenes] = await Promise.all([
      this.consultasService.getConsultationsCountByDateRange(firstDayOfMonth, lastDayOfMonth),
      this.examenesService.getExamCountByDateRange(firstDayOfMonth, lastDayOfMonth),
    ]);

    // Get new patients this month
    const pacientesRef = collection(this.firestore, 'pacientes');
    const q = query(
      pacientesRef,
      where('createdAt', '>=', Timestamp.fromDate(firstDayOfMonth)),
      where('createdAt', '<=', Timestamp.fromDate(lastDayOfMonth))
    );
    const pacientesSnapshot = await getDocs(q);

    return {
      consultas,
      pacientesNuevos: pacientesSnapshot.size,
      examenes,
    };
  }

  /**
   * Get patients with upcoming appointments (if appointment system is implemented)
   * Returns patients with recent activity as a proxy
   */
  getPacientesConCitasProximas(): Observable<any[]> {
    // Since we don't have an appointment system yet,
    // return patients with recent consultations as proxy
    const ref = collection(this.firestore, 'consultas');
    const sevenDaysFromNow = new Date();
    sevenDaysFromNow.setDate(sevenDaysFromNow.getDate() + 7);
    
    const q = query(
      ref,
      where('fecha', '<=', Timestamp.fromDate(sevenDaysFromNow)),
      orderBy('fecha', 'asc'),
      limit(5)
    );
    
    return collectionData(q, { idField: 'id' });
  }

  /**
   * Search across all entities (patients, consultations, exams)
   * Global search functionality
   */
  globalSearch(searchTerm: string): Observable<{
    pacientes: any[];
    consultas: any[];
    examenes: any[];
  }> {
    if (!searchTerm || searchTerm.trim().length === 0) {
      return from(Promise.resolve({
        pacientes: [],
        consultas: [],
        examenes: []
      }));
    }

    return combineLatest([
      this.pacientesService.searchPacientes(searchTerm),
      this.consultasService.getRecentConsultations(20),
      // Exam search would require patient context
    ]).pipe(
      map(([pacientes, consultas]) => {
        // Filter consultations that match search term
        const term = searchTerm.toLowerCase();
        const consultasFiltered = consultas.filter(c => 
          c.motivo?.toLowerCase().includes(term) ||
          c.tratamiento?.toLowerCase().includes(term) ||
          c.observaciones?.toLowerCase().includes(term)
        );

        return {
          pacientes,
          consultas: consultasFiltered,
          examenes: [] // Would need patient ID to search exams
        };
      })
    );
  }
}
