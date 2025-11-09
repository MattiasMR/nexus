import { Component, Input, inject, OnInit } from '@angular/core';
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
  IonList,
  ModalController,
  IonGrid,
  IonRow,
  IonCol,
} from '@ionic/angular/standalone';
import { Timestamp } from '@angular/fire/firestore';
import { Receta, MedicamentoRecetado } from '../../../../models/receta.model';

/**
 * Modal component for editing medication prescription
 */
@Component({
  selector: 'app-editar-medicamento-modal',
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
    IonList,
    IonGrid,
    IonRow,
    IonCol,
  ],
  templateUrl: './editar-medicamento-modal.component.html',
  styleUrls: ['./editar-medicamento-modal.component.scss'],
})
export class EditarMedicamentoModalComponent implements OnInit {
  private modalCtrl = inject(ModalController);

  // Input: existing prescription to edit
  @Input() receta!: Receta;

  // Form data (copied from input to allow editing)
  medicamentos: MedicamentoRecetado[] = [];
  observaciones: string = '';

  // Validation
  formSubmitted = false;

  ngOnInit() {
    // Copy data from input receta
    if (this.receta) {
      this.medicamentos = [...this.receta.medicamentos]; // Deep copy
      this.observaciones = this.receta.observaciones || '';
    }
  }

  /**
   * Dismiss modal without saving
   */
  cancel() {
    this.modalCtrl.dismiss(null, 'cancel');
  }

  /**
   * Validate and submit changes
   */
  async confirm() {
    this.formSubmitted = true;

    // Validate at least one medication
    if (!this.medicamentos || this.medicamentos.length === 0) {
      return;
    }

    // Validate each medication has required fields
    const allValid = this.medicamentos.every(
      (med) => med.nombreMedicamento && med.dosis && med.frecuencia && med.duracion
    );

    if (!allValid) {
      return;
    }

    // Build updated receta object
    const updatedReceta: Partial<Receta> = {
      medicamentos: this.medicamentos,
      observaciones: this.observaciones.trim() || undefined,
    };

    // Return data to parent component
    this.modalCtrl.dismiss(updatedReceta, 'confirm');
  }

  /**
   * Update a specific medication field
   */
  updateMedicamento(index: number, field: keyof MedicamentoRecetado, value: string) {
    this.medicamentos[index] = {
      ...this.medicamentos[index],
      [field]: value,
    };
  }

  /**
   * Check if form is valid
   */
  isFormValid(): boolean {
    if (!this.medicamentos || this.medicamentos.length === 0) return false;

    return this.medicamentos.every(
      (med) =>
        med.nombreMedicamento?.trim() &&
        med.dosis?.trim() &&
        med.frecuencia?.trim() &&
        med.duracion?.trim()
    );
  }
}
