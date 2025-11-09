import { Component, Input, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonButtons,
  IonIcon, IonItem, IonLabel, IonTextarea, IonSelect,
  IonSelectOption, IonDatetime, IonDatetimeButton, IonModal,
  ModalController
} from '@ionic/angular/standalone';
import { Timestamp } from '@angular/fire/firestore';

@Component({
  selector: 'app-nueva-orden-examen-modal',
  standalone: true,
  imports: [
    CommonModule, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonButtons,
    IonIcon, IonItem, IonLabel, IonTextarea, IonSelect,
    IonSelectOption, IonDatetime, IonDatetimeButton, IonModal
  ],
  templateUrl: './nueva-orden-examen-modal.component.html',
  styleUrls: ['./nueva-orden-examen-modal.component.scss'],
})
export class NuevaOrdenExamenModalComponent {
  private modalCtrl = inject(ModalController);

  @Input() pacienteId!: string;
  @Input() pacienteNombre!: string;

  // Form data
  tipoExamen: string = '';
  urgencia: 'normal' | 'urgente' | 'emergencia' = 'normal';
  indicacionesClinicas: string = '';
  fechaSolicitud: string = new Date().toISOString();
  maxDate: string = new Date().toISOString();

  // Common exam types
  examenesComunes = [
    { value: 'hemograma', label: 'Hemograma Completo' },
    { value: 'perfil_bioquimico', label: 'Perfil Bioquímico' },
    { value: 'glucosa', label: 'Glucosa' },
    { value: 'hemoglobina_glicosilada', label: 'Hemoglobina Glicosilada (HbA1c)' },
    { value: 'perfil_lipidico', label: 'Perfil Lipídico' },
    { value: 'tsh', label: 'TSH (Hormona Tiroidea)' },
    { value: 'creatinina', label: 'Creatinina' },
    { value: 'orina_completa', label: 'Orina Completa' },
    { value: 'rx_torax', label: 'Radiografía de Tórax' },
    { value: 'ecografia_abdominal', label: 'Ecografía Abdominal' },
    { value: 'electrocardiograma', label: 'Electrocardiograma' },
    { value: 'otro', label: 'Otro (especificar)' }
  ];

  formSubmitted = false;

  cancel() {
    this.modalCtrl.dismiss(null, 'cancel');
  }

  async confirm() {
    this.formSubmitted = true;

    if (!this.tipoExamen.trim() || !this.indicacionesClinicas.trim()) {
      return;
    }

    const ordenData = {
      idPaciente: this.pacienteId,
      idProfesional: 'TEMP_PROF_001', // TODO: Replace with auth user
      fechaSolicitud: Timestamp.fromDate(new Date(this.fechaSolicitud)),
      examenes: [{
        tipoExamen: this.tipoExamen,
        estado: 'solicitado',
      }],
      urgencia: this.urgencia,
      indicacionesClinicas: this.indicacionesClinicas.trim(),
      estado: 'pendiente'
    };

    this.modalCtrl.dismiss(ordenData, 'confirm');
  }

  isFormValid(): boolean {
    return this.tipoExamen.trim().length > 0 && 
           this.indicacionesClinicas.trim().length > 0;
  }
}
