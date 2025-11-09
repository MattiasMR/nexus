import { Component, EnvironmentInjector, inject, OnInit, OnDestroy } from '@angular/core';
import { IonTabs, IonTabBar, IonTabButton, IonIcon, IonLabel, IonBadge } from '@ionic/angular/standalone';
import { RouterModule } from '@angular/router';
import { addIcons } from 'ionicons';
import { triangle, ellipse, square } from 'ionicons/icons';
import { CommonModule } from '@angular/common';
import { Subscription } from 'rxjs';
import { DashboardService, AlertaDashboard } from '../features/dashboard/data/dashboard.service';

@Component({
  selector: 'app-tabs',
  templateUrl: 'tabs.page.html',
  styleUrls: ['tabs.page.scss'],
  imports: [IonTabs, IonTabBar, IonTabButton, IonIcon, IonLabel, IonBadge, RouterModule, CommonModule],
})
export class TabsPage implements OnInit, OnDestroy {
  public environmentInjector = inject(EnvironmentInjector);
  
  // Alert counter
  alertasCriticasCount = 0;
  private subscriptions: Subscription[] = [];

  constructor(private dashboardService: DashboardService) {
    addIcons({ triangle, ellipse, square });
  }
  
  ngOnInit() {
    // Subscribe to critical alerts
    this.subscriptions.push(
      this.dashboardService.getDashboardAlerts().subscribe((alertas: AlertaDashboard[]) => {
        this.alertasCriticasCount = alertas.filter(
          (a: AlertaDashboard) => a.severidad === 'critica' || a.severidad === 'alta'
        ).length;
      })
    );
  }
  
  ngOnDestroy() {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}
