import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Modelo para Cita Médica
class Cita {
  final String? id;
  final String idPaciente;
  final DateTime fecha;
  final String hora;
  final String especialidad;
  final String? medico;
  final String? idMedico;
  final EstadoCita estado;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cita({
    this.id,
    required this.idPaciente,
    required this.fecha,
    required this.hora,
    required this.especialidad,
    this.medico,
    this.idMedico,
    required this.estado,
    this.observaciones,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cita.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Cita(
      id: doc.id,
      idPaciente: data['idPaciente'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      hora: data['hora'] ?? '',
      especialidad: data['especialidad'] ?? '',
      medico: data['medico'],
      idMedico: data['idMedico'],
      estado: _estadoFromString(data['estado'] ?? 'pendiente'),
      observaciones: data['observaciones'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'idPaciente': idPaciente,
      'fecha': Timestamp.fromDate(fecha),
      'hora': hora,
      'especialidad': especialidad,
      if (medico != null) 'medico': medico,
      if (idMedico != null) 'idMedico': idMedico,
      'estado': estado.toString().split('.').last,
      if (observaciones != null) 'observaciones': observaciones,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static EstadoCita _estadoFromString(String estado) {
    switch (estado) {
      case 'confirmada':
        return EstadoCita.confirmada;
      case 'completada':
        return EstadoCita.completada;
      case 'cancelada':
        return EstadoCita.cancelada;
      default:
        return EstadoCita.pendiente;
    }
  }
}

enum EstadoCita {
  confirmada,
  pendiente,
  completada,
  cancelada,
}

/// Servicio para gestionar citas médicas
class CitasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'citas';

  /// Obtener todas las citas de un paciente
  Stream<List<Cita>> obtenerCitasPaciente(String idPaciente) {
    return _firestore
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Cita.fromFirestore(doc)).toList());
  }

  /// Obtener citas próximas
  Stream<List<Cita>> obtenerCitasProximas(String idPaciente) {
    final ahora = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(ahora))
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Cita.fromFirestore(doc)).toList());
  }

  /// Obtener citas pasadas
  Stream<List<Cita>> obtenerCitasPasadas(String idPaciente) {
    final ahora = DateTime.now();
    return _firestore
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .where('fecha', isLessThan: Timestamp.fromDate(ahora))
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Cita.fromFirestore(doc)).toList());
  }

  /// Cancelar una cita
  Future<void> cancelarCita(String citaId) async {
    try {
      await _firestore.collection(_collection).doc(citaId).update({
        'estado': 'cancelada',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error al cancelar cita: $e');
      rethrow;
    }
  }

  /// Crear nueva cita
  Future<void> crearCita(Cita cita) async {
    try {
      await _firestore.collection(_collection).add(cita.toFirestore());
    } catch (e) {
      debugPrint('Error al crear cita: $e');
      rethrow;
    }
  }
}
