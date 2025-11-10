import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { Router } from '@angular/router';
import {
  IonContent, IonGrid, IonRow, IonCol,
  IonCard, IonCardHeader, IonCardTitle, IonCardSubtitle, IonCardContent,
  IonIcon, IonAvatar, IonButton, IonSpinner, IonToast
} from '@ionic/angular/standalone';
import { NgFor, NgClass, NgIf, DatePipe, UpperCasePipe } from '@angular/common';
import { Timestamp } from '@angular/fire/firestore';
import { 
  DashboardService, 
  DashboardStats, 
  AlertaDashboard, 
  AccionRapida 
} from '../data/dashboard.service';
import { Subscription } from 'rxjs';
import { StatCardComponent } from '../../../shared/components/stat-card/stat-card.component';
import { AvatarUtils } from '../../../shared/utils/avatar.utils';

/**
 * Interface for stat cards displayed on dashboard
 */
interface StatCard {
  title: string;
  value: number | string;
  sub: string;
  icon: string;
  color?: 'primary' | 'success' | 'warning' | 'danger' | 'secondary';
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    IonContent, IonGrid, IonRow, IonCol,
    IonCardContent,
    IonIcon, IonAvatar, IonSpinner, IonToast,
    NgFor, NgClass, NgIf, DatePipe, UpperCasePipe,
    StatCardComponent
  ],
  templateUrl: './dashboard.page.html',
  styleUrls: ['./dashboard.page.scss']
})
export class DashboardPage implements OnInit, OnDestroy {
  // Component state
  stats: StatCard[] = [];
  alertas: AlertaDashboard[] = [];
  isLoading = false;
  error: string | null = null;
  
  private subscriptions: Subscription[] = [];
  private router = inject(Router);
  private dashboardService = inject(DashboardService);

  ngOnInit() {
    this.loadDashboardData();
  }

  ngOnDestroy() {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }

  /**
   * Load dashboard data from Firestore
   */
  private loadDashboardData() {
    this.isLoading = true;
    this.error = null;

    // Load dashboard statistics (KPIs)
    this.subscriptions.push(
      this.dashboardService.getDashboardStats().subscribe({
        next: (dashboardStats: DashboardStats) => {
          this.stats = this.transformStatsToCards(dashboardStats);
          this.isLoading = false;
          console.log('Dashboard stats loaded:', dashboardStats);
        },
        error: (error) => {
          console.error('Error loading dashboard stats:', error);
          this.error = 'Error al cargar las estadísticas del dashboard';
          this.isLoading = false;
        }
      })
    );

    // Load dashboard alerts
    this.subscriptions.push(
      this.dashboardService.getDashboardAlerts().subscribe({
        next: (alerts) => {
          this.alertas = alerts;
          console.log('Dashboard alerts loaded:', alerts);
        },
        error: (error) => {
          console.error('Error loading dashboard alerts:', error);
        }
      })
    );
  }

  /**
   * Transform DashboardStats to StatCard array for display
   */
  private transformStatsToCards(stats: DashboardStats): StatCard[] {
    return [
      {
        title: 'Consultas Hoy',
        value: stats.consultasHoy,
        sub: 'Atenciones del día',
        icon: 'calendar-outline',
        color: 'primary'
      },
      {
        title: 'Pacientes Activos',
        value: stats.pacientesActivos,
        sub: 'Total en sistema',
        icon: 'people-outline',
        color: 'success'
      },
      {
        title: 'Exámenes Pendientes',
        value: stats.examenPendientes,
        sub: 'Órdenes sin completar',
        icon: 'flask-outline',
        color: 'warning'
      },
      {
        title: 'Alertas Críticas',
        value: stats.alertasCriticas,
        sub: 'Requieren atención',
        icon: 'warning-outline',
        color: 'danger'
      }
    ];
  }

  /**
   * Refresh dashboard data
   */
  refreshDashboard() {
    this.loadDashboardData();
  }

  /**
   * Navigate to patients page
   */
  goToPatients() {
    this.router.navigateByUrl('/tabs/tab2');
  }

  /**
   * View patient exams
   */
  verExamenesPaciente(pacienteId: string) {
    this.router.navigate(['/tabs/tab5'], { 
      queryParams: { patientId: pacienteId } 
    });
  }

  /**
   * View patient medical record
   */
  verFichaPaciente(pacienteId: string) {
    this.router.navigate(['/tabs/tab3'], { 
      queryParams: { patientId: pacienteId } 
    });
  }

  /**
   * Handle alert click
   */
  onAlertClick(alerta: AlertaDashboard) {
    if (alerta.pacienteId) {
      // Navigate based on alert type
      switch (alerta.tipo) {
        case 'examen':
          this.verExamenesPaciente(alerta.pacienteId);
          break;
        case 'paciente':
        case 'medicamento':
        default:
          this.verFichaPaciente(alerta.pacienteId);
          break;
      }
    }
  }

  /**
   * Get color for alerts based on severity
   */
  getAlertColor(severidad: 'baja' | 'media' | 'alta' | 'critica'): string {
    switch (severidad) {
      case 'critica': return 'danger';
      case 'alta': return 'danger';
      case 'media': return 'warning';
      case 'baja': return 'primary';
      default: return 'medium';
    }
  }

  /**
   * Get icon for alerts based on type
   */
  getAlertIcon(tipo: 'paciente' | 'examen' | 'medicamento' | 'sistema'): string {
    switch (tipo) {
      case 'paciente': return 'person-outline';
      case 'examen': return 'flask-outline';
      case 'medicamento': return 'medical-outline';
      case 'sistema': return 'information-circle-outline';
      default: return 'notifications-outline';
    }
  }

  /**
   * Get critical and high priority alerts
   */
  getAlertasCriticas(): AlertaDashboard[] {
    return this.alertas.filter(alerta => 
      alerta.severidad === 'critica' || alerta.severidad === 'alta'
    );
  }

  /**
   * Get exam-related alerts
   */
  getAlertasExamenes(): AlertaDashboard[] {
    return this.alertas.filter(alerta => alerta.tipo === 'examen');
  }

  /**
   * Get patient-related alerts
   */
  getAlertasPacientes(): AlertaDashboard[] {
    return this.alertas.filter(alerta => alerta.tipo === 'paciente');
  }

  /**
   * Clear error message
   */
  clearError() {
    this.error = null;
  }

  /**
   * Helper method to convert Timestamp to Date for date pipe
   */
  formatAlertaFecha(fecha: Date | Timestamp): Date {
    return fecha instanceof Date ? fecha : fecha.toDate();
  }
  
  /**
   * Get patient initials for avatar
   */
  getInitials(nombre?: string): string {
    if (!nombre) return '??';
    const parts = nombre.trim().split(/\s+/);
    return AvatarUtils.getInitials(parts[0], parts[parts.length - 1]);
  }
  
  /**
   * Get avatar color for patient
   */
  getAvatarColor(nombre?: string): string {
    return AvatarUtils.getAvatarColor(nombre || '');
  }
  
  /**
   * Count total critical alerts
   */
  getTotalAlertasCriticas(): number {
    return this.alertas.filter(a => 
      a.severidad === 'critica' || a.severidad === 'alta'
    ).length;
  }
}
