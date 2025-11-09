import { Routes } from '@angular/router';
import { TabsPage } from './tabs.page';

export const routes: Routes = [
  {
    path: 'tabs',
    component: TabsPage,
    children: [
      {
        path: 'tab1',
        loadComponent: () =>
          import('../features/dashboard/pages/dashboard.page').then((m) => m.DashboardPage),
      },
      {
        path: 'tab2',
        loadComponent: () =>
          import('../features/pacientes/pages/patient-list.page').then((m) => m.PatientListPage),
      },
      {
        path: 'tab3',
        loadComponent: () =>
          import('../features/consultas/pages/consultas.page').then((m) => m.ConsultasPage),
      },
      {
        path: 'tab4',
        loadComponent: () =>
          import('../features/medicamentos/pages/medicamentos.page').then((m) => m.MedicamentosPage),
      },
      {
        path: 'tab5',
        loadComponent: () =>
          import('../features/examenes/pages/examenes.page').then((m) => m.ExamenesPage),
      },
      {
        path: '',
        redirectTo: '/tabs/tab1',
        pathMatch: 'full',
      },
    ],
  },
  {
    path: '',
    redirectTo: '/tabs/tab1',
    pathMatch: 'full',
  },
];
