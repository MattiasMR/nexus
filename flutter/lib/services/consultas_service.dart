import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/consulta.dart';

/// Servicio para gestionar consultas médicas en Firestore
class ConsultasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'consultas';

  /// Obtener todas las consultas de un paciente
  Stream<List<Consulta>> getConsultasByPaciente(String pacienteId) {
    return _firestore
        .collection(_collection)
        .where('pacienteId', isEqualTo: pacienteId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Consulta.fromFirestore(doc)).toList();
    });
  }

  /// Obtener consultas de una ficha médica específica
  Stream<List<Consulta>> getConsultasByFicha(String fichaId) {
    return _firestore
        .collection(_collection)
        .where('fichaId', isEqualTo: fichaId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Consulta.fromFirestore(doc)).toList();
    });
  }

  /// Obtener una consulta por ID
  Future<Consulta?> getConsultaById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Consulta.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener consulta: $e');
    }
  }

  /// Crear una nueva consulta
  Future<String> createConsulta(Consulta consulta) async {
    try {
      final docRef = await _firestore.collection(_collection).add(
            consulta.toMap(),
          );
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear consulta: $e');
    }
  }

  /// Actualizar una consulta existente
  Future<void> updateConsulta(Consulta consulta) async {
    if (consulta.id == null) {
      throw Exception('El ID de la consulta no puede ser nulo');
    }

    try {
      await _firestore
          .collection(_collection)
          .doc(consulta.id)
          .update(consulta.toMap());
    } catch (e) {
      throw Exception('Error al actualizar consulta: $e');
    }
  }

  /// Eliminar una consulta
  Future<void> deleteConsulta(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar consulta: $e');
    }
  }

  /// Obtener últimas N consultas de un paciente
  Future<List<Consulta>> getUltimasConsultas(String pacienteId,
      {int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('pacienteId', isEqualTo: pacienteId)
          .orderBy('fecha', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Consulta.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error al obtener últimas consultas: $e');
    }
  }

  /// Obtener consultas por rango de fechas
  Stream<List<Consulta>> getConsultasByDateRange(
    String pacienteId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(_collection)
        .where('pacienteId', isEqualTo: pacienteId)
        .where('fecha', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('fecha', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Consulta.fromFirestore(doc)).toList();
    });
  }

  /// Buscar consultas por diagnóstico
  Stream<List<Consulta>> searchByDiagnostico(String searchTerm) {
    // Nota: Para búsqueda más avanzada, considera usar Algolia o similar
    return _firestore
        .collection(_collection)
        .where('diagnosticoPrincipal',
            isGreaterThanOrEqualTo: searchTerm.toUpperCase())
        .where('diagnosticoPrincipal',
            isLessThan: '${searchTerm.toUpperCase()}z')
        .orderBy('diagnosticoPrincipal')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Consulta.fromFirestore(doc)).toList();
    });
  }
}
