import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonIcon, IonCard, IonCardHeader, IonCardTitle, IonCardSubtitle } from '@ionic/angular/standalone';

/**
 * Enhanced stat card component for dashboard
 * Displays key metrics with icons and trend indicators
 */
@Component({
  selector: 'app-stat-card',
  standalone: true,
  imports: [CommonModule, IonIcon],
  template: `
    <div class="stat-card-enhanced" [ngClass]="'stat-card-' + color">
      <div class="stat-card-header">
        <div class="stat-icon-wrapper">
          <ion-icon [name]="icon" class="stat-icon"></ion-icon>
        </div>
        <div class="stat-badge" *ngIf="trend">
          <ion-icon 
            [name]="trend === 'up' ? 'trending-up-outline' : 'trending-down-outline'" 
            [class.trend-up]="trend === 'up'"
            [class.trend-down]="trend === 'down'">
          </ion-icon>
          <span>{{ trendValue }}%</span>
        </div>
      </div>
      
      <div class="stat-content">
        <div class="stat-value">{{ value }}</div>
        <div class="stat-label">{{ label }}</div>
        <div class="stat-sublabel" *ngIf="sublabel">{{ sublabel }}</div>
      </div>
      
      <div class="stat-footer" *ngIf="footerText">
        <ion-icon name="time-outline" class="footer-icon"></ion-icon>
        <span>{{ footerText }}</span>
      </div>
    </div>
  `,
  styles: [`
    .stat-card-enhanced {
      background: white;
      border-radius: 16px;
      padding: 20px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      border: 1px solid #e0e0e0;
      transition: all 0.3s ease;
      position: relative;
      overflow: hidden;
      min-height: 160px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    .stat-card-enhanced::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 4px;
      background: linear-gradient(90deg, var(--card-color-start), var(--card-color-end));
    }

    .stat-card-enhanced:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
    }

    /* Color variants */
    .stat-card-primary {
      --card-color-start: #3880ff;
      --card-color-end: #5598ff;
    }

    .stat-card-success {
      --card-color-start: #2dd36f;
      --card-color-end: #4de88b;
    }

    .stat-card-warning {
      --card-color-start: #ffc409;
      --card-color-end: #ffca22;
    }

    .stat-card-danger {
      --card-color-start: #eb445a;
      --card-color-end: #f25268;
    }

    .stat-card-secondary {
      --card-color-start: #6c63ff;
      --card-color-end: #8b84ff;
    }

    .stat-card-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 16px;
    }

    .stat-icon-wrapper {
      width: 56px;
      height: 56px;
      border-radius: 14px;
      display: grid;
      place-items: center;
      background: linear-gradient(135deg, var(--card-color-start), var(--card-color-end));
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }

    .stat-icon {
      font-size: 28px;
      color: white;
    }

    .stat-badge {
      display: flex;
      align-items: center;
      gap: 4px;
      padding: 4px 10px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 700;
    }

    .stat-badge ion-icon {
      font-size: 16px;
    }

    .trend-up {
      color: #2dd36f;
    }

    .trend-down {
      color: #eb445a;
    }

    .stat-badge:has(.trend-up) {
      background: #e6f9ee;
      color: #2dd36f;
    }

    .stat-badge:has(.trend-down) {
      background: #fdeaed;
      color: #eb445a;
    }

    .stat-content {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 4px;
    }

    .stat-value {
      font-size: 32px;
      font-weight: 900;
      color: #1a1a1a;
      line-height: 1;
      letter-spacing: -0.5px;
    }

    .stat-label {
      font-size: 14px;
      font-weight: 600;
      color: #666;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-top: 4px;
    }

    .stat-sublabel {
      font-size: 12px;
      color: #999;
      margin-top: 2px;
    }

    .stat-footer {
      display: flex;
      align-items: center;
      gap: 6px;
      margin-top: 12px;
      padding-top: 12px;
      border-top: 1px solid #f0f0f0;
      font-size: 12px;
      color: #999;
    }

    .footer-icon {
      font-size: 14px;
      color: #ccc;
    }

    /* Responsive */
    @media (max-width: 768px) {
      .stat-card-enhanced {
        min-height: 140px;
        padding: 16px;
      }

      .stat-value {
        font-size: 28px;
      }

      .stat-icon-wrapper {
        width: 48px;
        height: 48px;
      }

      .stat-icon {
        font-size: 24px;
      }
    }
  `]
})
export class StatCardComponent {
  @Input() value: string | number = '0';
  @Input() label: string = 'Stat';
  @Input() sublabel?: string;
  @Input() icon: string = 'analytics-outline';
  @Input() color: 'primary' | 'success' | 'warning' | 'danger' | 'secondary' = 'primary';
  @Input() trend?: 'up' | 'down';
  @Input() trendValue?: string | number;
  @Input() footerText?: string;
}
