import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

/**
 * Skeleton loader component for displaying loading states
 * Provides shimmer effect for better UX during data fetching
 */
@Component({
  selector: 'app-skeleton-loader',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="skeleton-container">
      <!-- Patient card skeleton -->
      <div class="skeleton-card" *ngIf="type === 'patient-card'">
        <div class="skeleton-header">
          <div class="skeleton-avatar"></div>
          <div class="skeleton-text-block">
            <div class="skeleton-line skeleton-line-title"></div>
            <div class="skeleton-line skeleton-line-subtitle"></div>
          </div>
        </div>
        <div class="skeleton-body">
          <div class="skeleton-line skeleton-line-full"></div>
          <div class="skeleton-line skeleton-line-medium"></div>
          <div class="skeleton-line skeleton-line-small"></div>
        </div>
        <div class="skeleton-footer">
          <div class="skeleton-button"></div>
          <div class="skeleton-button"></div>
        </div>
      </div>

      <!-- List skeleton -->
      <div class="skeleton-list" *ngIf="type === 'list'">
        <div class="skeleton-item" *ngFor="let item of [1,2,3,4,5]">
          <div class="skeleton-avatar-sm"></div>
          <div class="skeleton-text-block">
            <div class="skeleton-line skeleton-line-medium"></div>
            <div class="skeleton-line skeleton-line-small"></div>
          </div>
        </div>
      </div>

      <!-- Stats card skeleton -->
      <div class="skeleton-stat-card" *ngIf="type === 'stat-card'">
        <div class="skeleton-line skeleton-line-small"></div>
        <div class="skeleton-line skeleton-line-title"></div>
        <div class="skeleton-line skeleton-line-small"></div>
      </div>

      <!-- Medical record skeleton -->
      <div class="skeleton-medical-record" *ngIf="type === 'medical-record'">
        <div class="skeleton-section">
          <div class="skeleton-line skeleton-line-title"></div>
          <div class="skeleton-grid">
            <div class="skeleton-line skeleton-line-medium"></div>
            <div class="skeleton-line skeleton-line-medium"></div>
            <div class="skeleton-line skeleton-line-medium"></div>
            <div class="skeleton-line skeleton-line-medium"></div>
          </div>
        </div>
        <div class="skeleton-section">
          <div class="skeleton-line skeleton-line-title"></div>
          <div class="skeleton-line skeleton-line-full"></div>
          <div class="skeleton-line skeleton-line-full"></div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .skeleton-container {
      width: 100%;
    }

    /* Base skeleton styles */
    .skeleton-line,
    .skeleton-avatar,
    .skeleton-avatar-sm,
    .skeleton-button,
    .skeleton-card,
    .skeleton-stat-card {
      background: linear-gradient(
        90deg,
        #e0e0e0 0%,
        #f0f0f0 50%,
        #e0e0e0 100%
      );
      background-size: 200% 100%;
      animation: shimmer 1.5s infinite;
      border-radius: 8px;
    }

    @keyframes shimmer {
      0% {
        background-position: -200% 0;
      }
      100% {
        background-position: 200% 0;
      }
    }

    /* Patient Card Skeleton */
    .skeleton-card {
      padding: 16px;
      margin-bottom: 16px;
      border: 1px solid #e0e0e0;
    }

    .skeleton-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 16px;
    }

    .skeleton-avatar {
      width: 48px;
      height: 48px;
      border-radius: 12px;
      flex-shrink: 0;
    }

    .skeleton-avatar-sm {
      width: 32px;
      height: 32px;
      border-radius: 8px;
      flex-shrink: 0;
    }

    .skeleton-text-block {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .skeleton-line {
      height: 12px;
      border-radius: 4px;
    }

    .skeleton-line-title {
      height: 20px;
      width: 60%;
    }

    .skeleton-line-subtitle {
      height: 14px;
      width: 40%;
    }

    .skeleton-line-full {
      width: 100%;
    }

    .skeleton-line-medium {
      width: 70%;
    }

    .skeleton-line-small {
      width: 40%;
    }

    .skeleton-body {
      display: flex;
      flex-direction: column;
      gap: 8px;
      margin-bottom: 16px;
    }

    .skeleton-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }

    .skeleton-button {
      width: 100px;
      height: 36px;
      border-radius: 10px;
    }

    /* List Skeleton */
    .skeleton-list {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .skeleton-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px;
      background: white;
      border-radius: 8px;
      border: 1px solid #e0e0e0;
    }

    /* Stat Card Skeleton */
    .skeleton-stat-card {
      padding: 20px;
      background: white;
      border: 1px solid #e0e0e0;
      display: flex;
      flex-direction: column;
      gap: 12px;
      min-height: 120px;
    }

    /* Medical Record Skeleton */
    .skeleton-medical-record {
      display: flex;
      flex-direction: column;
      gap: 24px;
    }

    .skeleton-section {
      padding: 20px;
      background: white;
      border-radius: 12px;
      border: 1px solid #e0e0e0;
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    .skeleton-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 12px;
    }
  `]
})
export class SkeletonLoaderComponent {
  @Input() type: 'patient-card' | 'list' | 'stat-card' | 'medical-record' = 'patient-card';
}
