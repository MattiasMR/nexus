import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  IonHeader, IonToolbar, IonTitle, IonContent, IonButton, IonButtons,
  IonIcon, IonItem, IonLabel, IonInput, IonTextarea, IonSelect, IonSelectOption,
  ModalController
} from '@ionic/angular/standalone';

@Component({
  selector: 'app-subir-examen-modal',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButton,
    IonButtons,
    IonIcon,
    IonItem,
    IonLabel,
    IonInput,
    IonTextarea,
    IonSelect,
    IonSelectOption
  ],
  templateUrl: './subir-examen-modal.component.html',
  styleUrls: ['./subir-examen-modal.component.scss']
})
export class SubirExamenModalComponent {
  @Input() pacienteId!: string;
  @Input() fichaMedicaId!: string;
  @Input() pacienteNombre!: string;

  nombreExamen = '';
  tipoExamen = '';
  resultado = '';

  constructor(private modalCtrl: ModalController) {}

  cancel() {
    this.modalCtrl.dismiss(null, 'cancel');
  }

  confirm() {
    const data = {
      nombreExamen: this.nombreExamen,
      tipoExamen: this.tipoExamen,
      resultado: this.resultado
    };
    this.modalCtrl.dismiss(data, 'confirm');
  }
}
