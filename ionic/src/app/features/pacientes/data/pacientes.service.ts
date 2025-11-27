import { Injectable, inject } from '@angular/core';
import {
  Firestore,
  collection,
  doc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  orderBy,
  limit,
  Timestamp,
  getDoc,
  getDocs,
  setDoc,
} from '@angular/fire/firestore';
import { Auth, createUserWithEmailAndPassword } from '@angular/fire/auth';
import { Observable, from } from 'rxjs';
import { Paciente, PacienteCompleto } from '../../../models/paciente.model';
import { Usuario } from '../../../models/usuario.model';

/**
 * Service for managing patient data in Firestore
 * 
 * ⚠️ ARQUITECTURA NORMALIZADA:
 * - Datos personales (nombre, rut, email, telefono) están en colección 'usuarios'
 * - Datos médicos están en colección 'pacientes'
 * - Para obtener datos completos, se hace JOIN entre ambas colecciones
 * 
 * Handles CRUD operations, search, pagination, and medical alerts
 */
@Injectable({
  providedIn: 'root'
})
export class PacientesService {
  private firestore = inject(Firestore);
  private auth = inject(Auth);
  private pacientesCollection = 'pacientes';
  private usuariosCollection = 'usuarios';

  /**
   * Get all patients with complete data (JOIN usuarios + pacientes)
   * 
   * ⚠️ CAMBIO: Ahora obtiene datos de ambas colecciones
   */
  getAllPacientes(): Observable<PacienteCompleto[]> {
    return from(this.getAllPacientesAsync());
  }

  private async getAllPacientesAsync(): Promise<PacienteCompleto[]> {
    const pacientesRef = collection(this.firestore, this.pacientesCollection);
    const pacientesSnapshot = await getDocs(pacientesRef);
    
    const pacientesCompletos: PacienteCompleto[] = [];
    
    for (const pacienteDoc of pacientesSnapshot.docs) {
      const paciente = { id: pacienteDoc.id, ...pacienteDoc.data() } as Paciente;
      
      // Obtener datos del usuario
      const usuarioDoc = await getDoc(doc(this.firestore, this.usuariosCollection, paciente.idUsuario));
      
      if (usuarioDoc.exists()) {
        const usuario = { id: usuarioDoc.id, ...usuarioDoc.data() } as Usuario;
        
        // Combinar datos
        const pacienteCompleto: PacienteCompleto = {
          // Datos del usuario
          id: usuario.id,
          email: usuario.email,
          displayName: usuario.displayName,
          rut: usuario.rut,
          telefono: usuario.telefono,
          photoURL: usuario.photoURL,
          rol: usuario.rol,
          activo: usuario.activo,
          
          // Datos del paciente
          idPaciente: paciente.id!,
          idUsuario: paciente.idUsuario,
          fechaNacimiento: paciente.fechaNacimiento,
          sexo: paciente.sexo,
          grupoSanguineo: paciente.grupoSanguineo,
          alergias: paciente.alergias,
          enfermedadesCronicas: paciente.enfermedadesCronicas,
          medicamentosActuales: paciente.medicamentosActuales,
          contactoEmergencia: paciente.contactoEmergencia,
          prevision: paciente.prevision,
          numeroFicha: paciente.numeroFicha,
          observaciones: paciente.observaciones,
          alertasMedicas: paciente.alertasMedicas,
          
          // Para compatibilidad con código existente
          nombreCompleto: usuario.displayName,
          nombre: usuario.displayName.split(' ')[0],
          apellido: usuario.displayName.split(' ').slice(1).join(' ')
        };
        
        pacientesCompletos.push(pacienteCompleto);
      }
    }
    
    // Ordenar por displayName
    return pacientesCompletos.sort((a, b) => 
      a.displayName.localeCompare(b.displayName)
    );
  }

  /**
   * Get a single patient by ID with complete data
   * 
   * ⚠️ CAMBIO: El ID puede ser el idUsuario o el idPaciente
   */
  getPacienteById(id: string): Observable<PacienteCompleto | undefined> {
    return from(this.getPacienteByIdAsync(id));
  }

  private async getPacienteByIdAsync(id: string): Promise<PacienteCompleto | undefined> {
    // Intentar buscar primero por idUsuario en la colección pacientes
    const pacientesRef = collection(this.firestore, this.pacientesCollection);
    const q = query(pacientesRef, where('idUsuario', '==', id));
    const querySnapshot = await getDocs(q);
    
    let pacienteDoc;
    
    if (!querySnapshot.empty) {
      // Encontrado por idUsuario
      pacienteDoc = querySnapshot.docs[0];
    } else {
      // Intentar buscar por ID del documento paciente
      const docRef = doc(this.firestore, `${this.pacientesCollection}/${id}`);
      const docSnap = await getDoc(docRef);
      
      if (!docSnap.exists()) {
        return undefined;
      }
      pacienteDoc = docSnap;
    }
    
    const paciente = { id: pacienteDoc.id, ...pacienteDoc.data() } as Paciente;
    
    // Obtener datos del usuario
    const usuarioDoc = await getDoc(doc(this.firestore, this.usuariosCollection, paciente.idUsuario));
    
    if (!usuarioDoc.exists()) {
      console.error('Usuario no encontrado para paciente:', paciente.id);
      return undefined;
    }
    
    const usuario = { id: usuarioDoc.id, ...usuarioDoc.data() } as Usuario;
    
    // Combinar datos
    return {
      id: usuario.id,
      email: usuario.email,
      displayName: usuario.displayName,
      rut: usuario.rut,
      telefono: usuario.telefono,
      photoURL: usuario.photoURL,
      rol: usuario.rol,
      activo: usuario.activo,
      
      idPaciente: paciente.id!,
      idUsuario: paciente.idUsuario,
      fechaNacimiento: paciente.fechaNacimiento,
      sexo: paciente.sexo,
      grupoSanguineo: paciente.grupoSanguineo,
      alergias: paciente.alergias,
      enfermedadesCronicas: paciente.enfermedadesCronicas,
      medicamentosActuales: paciente.medicamentosActuales,
      contactoEmergencia: paciente.contactoEmergencia,
      prevision: paciente.prevision,
      numeroFicha: paciente.numeroFicha,
      observaciones: paciente.observaciones,
      alertasMedicas: paciente.alertasMedicas,
      
      nombreCompleto: usuario.displayName,
      nombre: usuario.displayName.split(' ')[0],
      apellido: usuario.displayName.split(' ').slice(1).join(' ')
    };
  }

  /**
   * Search patients by RUT, name, or medical record number
   * 
   * ⚠️ CAMBIO: Ahora busca en la colección 'usuarios' primero
   */
  searchPacientes(searchTerm: string): Observable<PacienteCompleto[]> {
    return from(this.searchPacientesAsync(searchTerm));
  }

  private async searchPacientesAsync(searchTerm: string): Promise<PacienteCompleto[]> {
    const term = searchTerm.toLowerCase().trim();
    
    if (!term) {
      return this.getAllPacientesAsync();
    }
    
    // Buscar en usuarios con rol='paciente'
    const usuariosRef = collection(this.firestore, this.usuariosCollection);
    const usuariosQuery = query(usuariosRef, where('rol', '==', 'paciente'));
    const usuariosSnapshot = await getDocs(usuariosQuery);
    
    const pacientesCompletos: PacienteCompleto[] = [];
    
    for (const usuarioDoc of usuariosSnapshot.docs) {
      const usuario = { id: usuarioDoc.id, ...usuarioDoc.data() } as Usuario;
      
      // Filtrar por término de búsqueda
      const displayName = usuario.displayName.toLowerCase();
      const rut = usuario.rut.toLowerCase();
      const email = usuario.email?.toLowerCase() || '';
      
      if (displayName.includes(term) || rut.includes(term) || email.includes(term)) {
        // Obtener datos del paciente
        if (usuario.idPaciente) {
          const pacienteDoc = await getDoc(doc(this.firestore, this.pacientesCollection, usuario.idPaciente));
          
          if (pacienteDoc.exists()) {
            const paciente = { id: pacienteDoc.id, ...pacienteDoc.data() } as Paciente;
            
            pacientesCompletos.push({
              id: usuario.id,
              email: usuario.email,
              displayName: usuario.displayName,
              rut: usuario.rut,
              telefono: usuario.telefono,
              photoURL: usuario.photoURL,
              rol: usuario.rol,
              activo: usuario.activo,
              
              idPaciente: paciente.id!,
              idUsuario: paciente.idUsuario,
              fechaNacimiento: paciente.fechaNacimiento,
              sexo: paciente.sexo,
              grupoSanguineo: paciente.grupoSanguineo,
              alergias: paciente.alergias,
              enfermedadesCronicas: paciente.enfermedadesCronicas,
              medicamentosActuales: paciente.medicamentosActuales,
              contactoEmergencia: paciente.contactoEmergencia,
              prevision: paciente.prevision,
              numeroFicha: paciente.numeroFicha,
              observaciones: paciente.observaciones,
              alertasMedicas: paciente.alertasMedicas,
              
              nombreCompleto: usuario.displayName,
              nombre: usuario.displayName.split(' ')[0],
              apellido: usuario.displayName.split(' ').slice(1).join(' ')
            });
          }
        }
      }
    }
    
    return pacientesCompletos;
  }

  /**
   * Get patients with pagination
   * @param pageSize Number of patients per page
   * @param lastVisible Last document from previous page (for cursor-based pagination)
   */
  getPacientesPaginated(pageSize: number = 20): Observable<PacienteCompleto[]> {
    return from(this.getPacientesPaginatedAsync(pageSize));
  }

  private async getPacientesPaginatedAsync(pageSize: number): Promise<PacienteCompleto[]> {
    // Para simplificar, obtener todos y limitar en memoria
    // En producción, implementar paginación cursor-based
    const todos = await this.getAllPacientesAsync();
    return todos.slice(0, pageSize);
  }

  /**
   * Get patients with medical alerts (allergies, chronic diseases, critical conditions)
   */
  getPacientesWithAlerts(): Observable<PacienteCompleto[]> {
    return from(this.getPacientesWithAlertsAsync());
  }

  private async getPacientesWithAlertsAsync(): Promise<PacienteCompleto[]> {
    const pacientes = await this.getAllPacientesAsync();
    
    return pacientes.filter((p: PacienteCompleto) => {
      const hasAlergias = p.alergias && p.alergias.length > 0;
      const hasEnfermedades = p.enfermedadesCronicas && p.enfermedadesCronicas.length > 0;
      const hasAlertas = p.alertasMedicas && p.alertasMedicas.length > 0;
      
      return hasAlergias || hasEnfermedades || hasAlertas;
    });
  }

  /**
   * Create a complete patient following the new architecture
   * 
   * FLUJO COMPLETO:
   * 1. Crear usuario en Firebase Auth
   * 2. Crear documento en colección 'usuarios'
   * 3. Crear documento en colección 'pacientes' con idUsuario
   * 4. Actualizar usuario con idPaciente
   * 
   * @param datosPersonales Datos personales (email, rut, displayName, telefono)
   * @param datosMedicos Datos médicos del paciente
   * @returns PacienteCompleto con todos los datos
   */
  async createPacienteCompleto(
    datosPersonales: {
      email: string;
      password: string;  // Temporal para crear cuenta
      displayName: string;
      rut: string;
      telefono?: string;
    },
    datosMedicos: Partial<Omit<Paciente, 'id' | 'idUsuario'>>
  ): Promise<PacienteCompleto> {
    console.log('🔄 Iniciando creación de paciente completo...');
    
    try {
      // 1. Crear usuario en Firebase Auth
      console.log('1️⃣ Creando usuario en Firebase Auth...');
      const userCredential = await createUserWithEmailAndPassword(
        this.auth,
        datosPersonales.email,
        datosPersonales.password
      );
      const uid = userCredential.user.uid;
      console.log('✅ Usuario creado en Auth:', uid);
      
      // 2. Crear documento en colección 'usuarios'
      console.log('2️⃣ Creando documento en colección usuarios...');
      const usuarioData: Omit<Usuario, 'idPaciente' | 'idProfesional'> = {
        id: uid,
        email: datosPersonales.email,
        displayName: datosPersonales.displayName,
        rut: datosPersonales.rut,
        telefono: datosPersonales.telefono,
        rol: 'paciente',
        activo: true,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now()
      };
      
      await setDoc(doc(this.firestore, this.usuariosCollection, uid), usuarioData);
      console.log('✅ Documento usuario creado');
      
      // 3. Crear documento en colección 'pacientes'
      console.log('3️⃣ Creando documento en colección pacientes...');
      const pacienteData: Omit<Paciente, 'id'> = {
        idUsuario: uid,
        ...datosMedicos,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now()
      };
      
      const pacienteRef = await addDoc(
        collection(this.firestore, this.pacientesCollection),
        pacienteData
      );
      const idPaciente = pacienteRef.id;
      console.log('✅ Documento paciente creado:', idPaciente);
      
      // 4. Actualizar usuario con idPaciente
      console.log('4️⃣ Actualizando usuario con idPaciente...');
      await updateDoc(doc(this.firestore, this.usuariosCollection, uid), {
        idPaciente: idPaciente,
        updatedAt: Timestamp.now()
      });
      console.log('✅ Usuario actualizado con idPaciente');
      
      // 5. Retornar PacienteCompleto
      const pacienteCompleto: PacienteCompleto = {
        // Datos del usuario
        id: uid,
        email: usuarioData.email,
        displayName: usuarioData.displayName,
        rut: usuarioData.rut,
        telefono: usuarioData.telefono,
        rol: usuarioData.rol,
        activo: usuarioData.activo,
        
        // Datos del paciente
        idPaciente: idPaciente,
        idUsuario: uid,
        ...datosMedicos,
        
        // Campos de compatibilidad
        nombre: usuarioData.displayName.split(' ')[0],
        apellido: usuarioData.displayName.split(' ').slice(1).join(' '),
        nombreCompleto: usuarioData.displayName
      };
      
      console.log('🎉 Paciente completo creado exitosamente');
      return pacienteCompleto;
      
    } catch (error: any) {
      console.error('❌ Error al crear paciente completo:', error);
      throw new Error(`Error al crear paciente: ${error.message}`);
    }
  }

  /**
   * Create a new patient (LEGACY - Solo para compatibilidad)
   * 
   * ⚠️ IMPORTANTE: Este método solo crea el documento en 'pacientes'.
   * Para crear un paciente completo con usuario, usar createPacienteCompleto()
   */
  async createPaciente(paciente: Omit<Paciente, 'id'>): Promise<string> {
    if (!paciente.idUsuario) {
      throw new Error('idUsuario es obligatorio para crear un paciente');
    }
    
    const ref = collection(this.firestore, this.pacientesCollection);
    
    const docRef = await addDoc(ref, {
      ...paciente,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now()
    });
    
    return docRef.id;
  }

  /**
   * Update an existing patient (solo datos médicos)
   * 
   * ⚠️ NOTA: Para actualizar datos personales (nombre, rut, telefono, email),
   * actualizar en la colección 'usuarios' directamente
   */
  async updatePaciente(id: string, paciente: Partial<Paciente>): Promise<void> {
    const docRef = doc(this.firestore, `${this.pacientesCollection}/${id}`);
    
    const updates: any = {
      ...paciente,
      updatedAt: Timestamp.now()
    };
    
    // Prevenir cambio de idUsuario
    delete updates.idUsuario;
    
    await updateDoc(docRef, updates);
  }

  /**
   * Update complete patient data (usuarios + pacientes)
   * 
   * @param idPaciente ID del documento en la colección 'pacientes'
   * @param datosPersonales Datos personales a actualizar en 'usuarios'
   * @param datosMedicos Datos médicos a actualizar en 'pacientes'
   */
  async updatePacienteCompleto(
    idPaciente: string,
    datosPersonales?: {
      displayName?: string;
      telefono?: string;
    },
    datosMedicos?: Partial<Omit<Paciente, 'id' | 'idUsuario'>>
  ): Promise<void> {
    console.log('🔄 Actualizando paciente completo...', { idPaciente });
    
    try {
      // 1. Obtener el documento del paciente para obtener el idUsuario
      const pacienteDoc = await getDoc(doc(this.firestore, this.pacientesCollection, idPaciente));
      
      if (!pacienteDoc.exists()) {
        throw new Error('Paciente no encontrado');
      }
      
      const paciente = { id: pacienteDoc.id, ...pacienteDoc.data() } as Paciente;
      
      // 2. Actualizar datos en 'usuarios' si hay cambios personales
      if (datosPersonales && Object.keys(datosPersonales).length > 0) {
        console.log('📝 Actualizando datos personales en usuarios...');
        await updateDoc(
          doc(this.firestore, this.usuariosCollection, paciente.idUsuario),
          {
            ...datosPersonales,
            updatedAt: Timestamp.now()
          }
        );
        console.log('✅ Datos personales actualizados');
      }
      
      // 3. Actualizar datos en 'pacientes' si hay cambios médicos
      if (datosMedicos && Object.keys(datosMedicos).length > 0) {
        console.log('🏥 Actualizando datos médicos en pacientes...');
        await updateDoc(
          doc(this.firestore, this.pacientesCollection, idPaciente),
          {
            ...datosMedicos,
            updatedAt: Timestamp.now()
          }
        );
        console.log('✅ Datos médicos actualizados');
      }
      
      console.log('🎉 Paciente actualizado exitosamente');
      
    } catch (error: any) {
      console.error('❌ Error al actualizar paciente completo:', error);
      throw new Error(`Error al actualizar paciente: ${error.message}`);
    }
  }

  /**
   * Delete a patient (soft delete recommended in production)
   */
  async deletePaciente(id: string): Promise<void> {
    const docRef = doc(this.firestore, `${this.pacientesCollection}/${id}`);
    await deleteDoc(docRef);
  }

  /**
   * Add a medical alert to a patient
   */
  async addAlertaMedica(
    pacienteId: string, 
    alerta: {
      tipo: 'alergia' | 'enfermedad_cronica' | 'medicamento_critico' | 'otro';
      descripcion: string;
      severidad: 'baja' | 'media' | 'alta' | 'critica';
    }
  ): Promise<void> {
    const docRef = doc(this.firestore, `${this.pacientesCollection}/${pacienteId}`);
    const currentDoc = await getDoc(docRef);
    
    if (currentDoc.exists()) {
      const currentData = currentDoc.data() as Paciente;
      const alertas = currentData.alertasMedicas || [];
      
      alertas.push({
        ...alerta,
        fechaRegistro: Timestamp.now()
      });
      
      await updateDoc(docRef, {
        alertasMedicas: alertas,
        updatedAt: Timestamp.now()
      });
    }
  }

  /**
   * Get active patients (patients with recent activity)
   * For dashboard KPIs
   */
  async getActivePatientsCount(): Promise<number> {
    const ref = collection(this.firestore, this.pacientesCollection);
    const snapshot = await getDocs(ref);
    return snapshot.size;
  }

  /**
   * Get patients by gender for statistics
   */
  getPacientesByGender(gender: 'M' | 'F' | 'Otro'): Observable<PacienteCompleto[]> {
    return from(this.getPacientesByGenderAsync(gender));
  }

  private async getPacientesByGenderAsync(gender: 'M' | 'F' | 'Otro'): Promise<PacienteCompleto[]> {
    const todos = await this.getAllPacientesAsync();
    return todos.filter(p => p.sexo === gender);
  }

  /**
   * Get patients by blood type
   */
  getPacientesByBloodType(bloodType: string): Observable<PacienteCompleto[]> {
    return from(this.getPacientesByBloodTypeAsync(bloodType));
  }

  private async getPacientesByBloodTypeAsync(bloodType: string): Promise<PacienteCompleto[]> {
    const todos = await this.getAllPacientesAsync();
    return todos.filter(p => p.grupoSanguineo === bloodType);
  }
}
