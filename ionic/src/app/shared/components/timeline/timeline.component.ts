import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonIcon, IonBadge } from '@ionic/angular/standalone';
import { Timestamp } from '@angular/fire/firestore';

/**
 * Timeline item interface
 */
export interface TimelineItem {
  id?: string;
  title: string;
  description?: string;
  date: Date | Timestamp;
  type: 'consultation' | 'exam' | 'medication' | 'alert' | 'note';
  icon: string;
  color: 'primary' | 'success' | 'warning' | 'danger' | 'secondary';
  metadata?: any;
}

/**
 * Timeline component for displaying chronological events
 * Used for consultation history, medical events, etc.
 */
@Component({
  selector: 'app-timeline',
  standalone: true,
  imports: [CommonModule, IonIcon, IonBadge],
  template: `
    <div class="timeline-container">
      <!-- Group by date headers -->
      <div *ngFor="let group of groupedItems" class="timeline-group">
        <div class="timeline-date-header">
          <span class="date-badge">{{ formatDateHeader(group.date) }}</span>
        </div>
        
        <div class="timeline-items">
          <div 
            *ngFor="let item of group.items; let last = last" 
            class="timeline-item"
            [class.timeline-item-last]="last"
          >
            <!-- Icon marker -->
            <div class="timeline-marker" [class]="'marker-' + item.color">
              <ion-icon [name]="item.icon"></ion-icon>
            </div>
            
            <!-- Connecting line -->
            <div class="timeline-line" *ngIf="!last"></div>
            
            <!-- Content -->
            <div class="timeline-content">
              <div class="timeline-header">
                <h4 class="timeline-title">{{ item.title }}</h4>
                <span class="timeline-time">{{ formatTime(item.date) }}</span>
              </div>
              
              <p class="timeline-description" *ngIf="item.description">
                {{ item.description }}
              </p>
              
              <!-- Type badge -->
              <ion-badge 
                [color]="item.color" 
                class="timeline-badge"
              >
                {{ getTypeLabel(item.type) }}
              </ion-badge>
              
              <!-- Additional metadata -->
              <div class="timeline-metadata" *ngIf="item.metadata">
                <div class="metadata-item" *ngFor="let key of getMetadataKeys(item.metadata)">
                  <span class="meta-label">{{ formatMetaLabel(key) }}:</span>
                  <span class="meta-value">{{ item.metadata[key] }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Empty state -->
      <div class="timeline-empty" *ngIf="items.length === 0">
        <ion-icon name="calendar-outline" class="empty-icon"></ion-icon>
        <p>{{ emptyMessage || 'No hay eventos registrados' }}</p>
      </div>
    </div>
  `,
  styles: [`
    .timeline-container {
      width: 100%;
      padding: 20px 0;
    }

    .timeline-group {
      margin-bottom: 32px;
    }

    .timeline-date-header {
      margin-bottom: 20px;
      padding-left: 60px;
    }

    .date-badge {
      display: inline-block;
      padding: 6px 16px;
      background: linear-gradient(135deg, #3880ff, #5598ff);
      color: white;
      border-radius: 20px;
      font-size: 13px;
      font-weight: 700;
      letter-spacing: 0.3px;
      box-shadow: 0 2px 8px rgba(56, 128, 255, 0.25);
    }

    .timeline-items {
      position: relative;
    }

    .timeline-item {
      position: relative;
      padding-left: 60px;
      margin-bottom: 24px;
    }

    .timeline-item-last {
      margin-bottom: 0;
    }

    .timeline-marker {
      position: absolute;
      left: 0;
      top: 0;
      width: 40px;
      height: 40px;
      border-radius: 50%;
      display: grid;
      place-items: center;
      background: white;
      border: 3px solid;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
      z-index: 2;
      transition: transform 0.2s ease;
    }

    .timeline-marker:hover {
      transform: scale(1.1);
    }

    .timeline-marker ion-icon {
      font-size: 20px;
    }

    .marker-primary {
      border-color: #3880ff;
    }
    .marker-primary ion-icon {
      color: #3880ff;
    }

    .marker-success {
      border-color: #2dd36f;
    }
    .marker-success ion-icon {
      color: #2dd36f;
    }

    .marker-warning {
      border-color: #ffc409;
    }
    .marker-warning ion-icon {
      color: #ffc409;
    }

    .marker-danger {
      border-color: #eb445a;
    }
    .marker-danger ion-icon {
      color: #eb445a;
    }

    .marker-secondary {
      border-color: #6c63ff;
    }
    .marker-secondary ion-icon {
      color: #6c63ff;
    }

    .timeline-line {
      position: absolute;
      left: 19px;
      top: 40px;
      bottom: -24px;
      width: 2px;
      background: linear-gradient(
        to bottom,
        #e0e0e0,
        #f0f0f0
      );
      z-index: 1;
    }

    .timeline-content {
      background: white;
      border: 1px solid #e0e0e0;
      border-radius: 12px;
      padding: 16px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
      transition: all 0.2s ease;
    }

    .timeline-content:hover {
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
      border-color: #3880ff;
    }

    .timeline-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 8px;
      gap: 12px;
    }

    .timeline-title {
      margin: 0;
      font-size: 16px;
      font-weight: 700;
      color: #1a1a1a;
      flex: 1;
    }

    .timeline-time {
      font-size: 12px;
      color: #999;
      font-weight: 600;
      white-space: nowrap;
    }

    .timeline-description {
      margin: 0 0 12px 0;
      font-size: 14px;
      color: #666;
      line-height: 1.5;
    }

    .timeline-badge {
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      padding: 4px 10px;
    }

    .timeline-metadata {
      margin-top: 12px;
      padding-top: 12px;
      border-top: 1px solid #f0f0f0;
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
    }

    .metadata-item {
      display: flex;
      gap: 6px;
      font-size: 13px;
    }

    .meta-label {
      color: #999;
      font-weight: 600;
    }

    .meta-value {
      color: #333;
      font-weight: 500;
    }

    .timeline-empty {
      text-align: center;
      padding: 60px 20px;
      color: #999;
    }

    .empty-icon {
      font-size: 64px;
      color: #ddd;
      margin-bottom: 16px;
    }

    .timeline-empty p {
      margin: 0;
      font-size: 16px;
      color: #666;
    }

    /* Responsive */
    @media (max-width: 576px) {
      .timeline-item {
        padding-left: 50px;
      }

      .timeline-marker {
        width: 36px;
        height: 36px;
      }

      .timeline-marker ion-icon {
        font-size: 18px;
      }

      .timeline-line {
        left: 17px;
      }

      .timeline-date-header {
        padding-left: 50px;
      }
    }
  `]
})
export class TimelineComponent {
  @Input() items: TimelineItem[] = [];
  @Input() emptyMessage?: string;
  
  /**
   * Group items by date
   */
  get groupedItems(): { date: Date; items: TimelineItem[] }[] {
    const groups: { [key: string]: TimelineItem[] } = {};
    
    this.items.forEach(item => {
      const date = item.date instanceof Timestamp 
        ? item.date.toDate() 
        : item.date;
      const dateKey = date.toDateString();
      
      if (!groups[dateKey]) {
        groups[dateKey] = [];
      }
      groups[dateKey].push(item);
    });
    
    return Object.keys(groups)
      .map(key => ({
        date: new Date(key),
        items: groups[key].sort((a, b) => {
          const dateA = a.date instanceof Timestamp ? a.date.toDate() : a.date;
          const dateB = b.date instanceof Timestamp ? b.date.toDate() : b.date;
          return dateB.getTime() - dateA.getTime();
        })
      }))
      .sort((a, b) => b.date.getTime() - a.date.getTime());
  }
  
  /**
   * Format date header
   */
  formatDateHeader(date: Date): string {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    
    if (date.toDateString() === today.toDateString()) {
      return 'Hoy';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Ayer';
    } else {
      return date.toLocaleDateString('es-CL', { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric' 
      });
    }
  }
  
  /**
   * Format time
   */
  formatTime(date: Date | Timestamp): string {
    const d = date instanceof Timestamp ? date.toDate() : date;
    return d.toLocaleTimeString('es-CL', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  }
  
  /**
   * Get type label
   */
  getTypeLabel(type: string): string {
    const labels: { [key: string]: string } = {
      consultation: 'Consulta',
      exam: 'Examen',
      medication: 'Medicamento',
      alert: 'Alerta',
      note: 'Nota'
    };
    return labels[type] || type;
  }
  
  /**
   * Get metadata keys
   */
  getMetadataKeys(metadata: any): string[] {
    return Object.keys(metadata || {});
  }
  
  /**
   * Format metadata label
   */
  formatMetaLabel(key: string): string {
    const labels: { [key: string]: string } = {
      doctor: 'Médico',
      specialty: 'Especialidad',
      diagnosis: 'Diagnóstico',
      resultado: 'Resultado',
      dosis: 'Dosis'
    };
    return labels[key] || key;
  }
}
