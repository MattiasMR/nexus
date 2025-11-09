import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paciente.dart';

/// Servicio para gestionar operaciones CRUD de pacientes en Firestore
class PacientesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pacientes';

  /// Obtiene la referencia a la colección de pacientes
  CollectionReference<Map<String, dynamic>> get _pacientesRef =>
      _firestore.collection(_collection);

  /// Obtiene todos los pacientes
  Stream<List<Paciente>> getAllPacientes() {
    return _pacientesRef.orderBy(FieldPath.documentId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Paciente.fromFirestore(doc))
              .toList(),
        );
  }

  /// Obtiene un paciente por ID
  Future<Paciente?> getPacienteById(String id) async {
    try {
      final doc = await _pacientesRef.doc(id).get();
      if (doc.exists) {
        return Paciente.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener paciente: $e');
    }
  }

  /// Busca pacientes por nombre, apellido o RUT
  Stream<List<Paciente>> searchPacientes(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Firestore no soporta búsqueda por texto completo, así que filtramos en el cliente
    return getAllPacientes().map((pacientes) {
      return pacientes.where((p) {
        final nombreCompleto = '${p.nombre} ${p.apellido}'.toLowerCase();
        final rut = p.rut.toLowerCase();
        return nombreCompleto.contains(lowerQuery) || rut.contains(lowerQuery);
      }).toList();
    });
  }

  /// Crea un nuevo paciente
  Future<String> createPaciente(Paciente paciente) async {
    try {
      // Verificar si el RUT ya existe
      final existingQuery = await _pacientesRef
          .where('rut', isEqualTo: paciente.rut)
          .limit(1)
          .get();
      
      if (existingQuery.docs.isNotEmpty) {
        throw Exception('Ya existe un paciente con el RUT ${paciente.rut}');
      }

      // Crear el paciente con timestamps
      final pacienteConTimestamps = paciente.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _pacientesRef.add(pacienteConTimestamps.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear paciente: $e');
    }
  }

  /// Actualiza un paciente existente
  Future<void> updatePaciente(String id, Paciente paciente) async {
    try {
      // Si se está cambiando el RUT, verificar que no exista otro paciente con ese RUT
      if (paciente.id != null && paciente.id != id) {
        final existingQuery = await _pacientesRef
            .where('rut', isEqualTo: paciente.rut)
            .limit(1)
            .get();
        
        if (existingQuery.docs.isNotEmpty && existingQuery.docs.first.id != id) {
          throw Exception('Ya existe otro paciente con el RUT ${paciente.rut}');
        }
      }

      // Actualizar con nuevo timestamp
      final pacienteActualizado = paciente.copyWith(
        updatedAt: DateTime.now(),
      );

      await _pacientesRef.doc(id).update(pacienteActualizado.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar paciente: $e');
    }
  }

  /// Elimina un paciente
  Future<void> deletePaciente(String id) async {
    try {
      await _pacientesRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar paciente: $e');
    }
  }

  /// Obtiene el conteo total de pacientes
  Future<int> getTotalPacientes() async {
    try {
      final snapshot = await _pacientesRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Error al obtener conteo de pacientes: $e');
    }
  }

  /// Obtiene pacientes por estado (activo/inactivo)
  Stream<List<Paciente>> getPacientesByEstado(String estado) {
    return _pacientesRef
        .where('estado', isEqualTo: estado)
        .orderBy(FieldPath.documentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Paciente.fromFirestore(doc))
              .toList(),
        );
  }

  /// Obtiene pacientes activos
  Stream<List<Paciente>> getPacientesActivos() {
    return getPacientesByEstado('activo');
  }

  /// Obtiene pacientes inactivos
  Stream<List<Paciente>> getPacientesInactivos() {
    return getPacientesByEstado('inactivo');
  }
}
