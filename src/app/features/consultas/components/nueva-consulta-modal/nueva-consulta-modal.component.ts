import { Component, Input, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
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
  IonSelectOption,
  IonDatetime,
  IonDatetimeButton,
  IonModal,
  ModalController,
  IonGrid,
  IonRow,
  IonCol,
} from '@ionic/angular/standalone';
import { Timestamp } from '@angular/fire/firestore';

/**
 * Modal component for creating a new consultation
 * Receives patient data and returns consultation data
 */
@Component({
  selector: 'app-nueva-consulta-modal',
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
    IonDatetime,
    IonDatetimeButton,
    IonModal,
    IonGrid,
    IonRow,
    IonCol,
  ],
  templateUrl: './nueva-consulta-modal.component.html',
  styleUrls: ['./nueva-consulta-modal.component.scss'],
})
export class NuevaConsultaModalComponent {
  private modalCtrl = inject(ModalController);

  // Patient data passed from parent
  @Input() pacienteId!: string;
  @Input() fichaMedicaId!: string;
  @Input() pacienteNombre!: string;

  // Form data
  fechaConsulta: string = new Date().toISOString();
  maxDate: string = new Date().toISOString();
  motivoConsulta: string = '';
  diagnostico: string = '';
  tratamiento: string = '';
  signosVitales = {
    presionArterial: '',
    frecuenciaCardiaca: '',
    temperatura: '',
    saturacionOxigeno: '',
    peso: '',
    talla: '',
  };
  observaciones: string = '';

  // Validation flags
  formSubmitted = false;

  /**
   * Dismiss modal without saving
   */
  cancel() {
    this.modalCtrl.dismiss(null, 'cancel');
  }

  /**
   * Validate and submit the consultation
   */
  async confirm() {
    this.formSubmitted = true;

    // Validate required fields
    if (!this.motivoConsulta.trim()) {
      return;
    }

    // Build consultation object - use 'motivo' not 'motivoConsulta' to match Consulta model
    const nuevaConsulta = {
      idPaciente: this.pacienteId,
      idFichaMedica: this.fichaMedicaId,
      idProfesional: 'TEMP_PROF_001', // TODO: Replace with actual logged-in user ID (Phase 3)
      fecha: Timestamp.fromDate(new Date(this.fechaConsulta)),
      motivo: this.motivoConsulta.trim(), // ← Fixed: use 'motivo' to match model
      tratamiento: this.tratamiento.trim() || undefined,
      observaciones: this.observaciones.trim() || undefined,
      notas: [], // Empty array for quick notes
    };

    // Return data to parent component
    this.modalCtrl.dismiss(nuevaConsulta, 'confirm');
  }

  /**
   * Clean vital signs - only include fields that have values
   */
  private cleanSignosVitales(): Record<string, string> | undefined {
    const cleaned: Record<string, string> = {};
    let hasValues = false;

    if (this.signosVitales.presionArterial.trim()) {
      cleaned['presionArterial'] = this.signosVitales.presionArterial.trim();
      hasValues = true;
    }
    if (this.signosVitales.frecuenciaCardiaca.trim()) {
      cleaned['frecuenciaCardiaca'] = this.signosVitales.frecuenciaCardiaca.trim();
      hasValues = true;
    }
    if (this.signosVitales.temperatura.trim()) {
      cleaned['temperatura'] = this.signosVitales.temperatura.trim();
      hasValues = true;
    }
    if (this.signosVitales.saturacionOxigeno.trim()) {
      cleaned['saturacionOxigeno'] = this.signosVitales.saturacionOxigeno.trim();
      hasValues = true;
    }
    if (this.signosVitales.peso.trim()) {
      cleaned['peso'] = this.signosVitales.peso.trim();
      hasValues = true;
    }
    if (this.signosVitales.talla.trim()) {
      cleaned['talla'] = this.signosVitales.talla.trim();
      hasValues = true;
    }

    return hasValues ? cleaned : undefined;
  }

  /**
   * Check if form is valid
   */
  isFormValid(): boolean {
    return this.motivoConsulta.trim().length > 0;
  }
}
