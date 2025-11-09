import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ficha_medica.dart';

/// Servicio para gestionar operaciones CRUD de fichas médicas en Firestore
class FichasMedicasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'fichas-medicas';

  /// Obtiene la referencia a la colección de fichas médicas
  CollectionReference<Map<String, dynamic>> get _fichasRef =>
      _firestore.collection(_collection);

  /// Obtiene todas las fichas médicas
  Stream<List<FichaMedica>> getAllFichas() {
    return _fichasRef.orderBy(FieldPath.documentId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => FichaMedica.fromFirestore(doc))
              .toList(),
        );
  }

  /// Obtiene una ficha médica por ID
  Future<FichaMedica?> getFichaById(String id) async {
    try {
      final doc = await _fichasRef.doc(id).get();
      if (doc.exists) {
        return FichaMedica.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener ficha médica: $e');
    }
  }

  /// Obtiene fichas médicas de un paciente específico
  Stream<List<FichaMedica>> getFichasByPaciente(String idPaciente) {
    return _fichasRef
        .where('idPaciente', isEqualTo: idPaciente)
        .orderBy('fechaMedica', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FichaMedica.fromFirestore(doc))
              .toList(),
        );
  }

  /// Crea una nueva ficha médica
  Future<String> createFicha(FichaMedica ficha) async {
    try {
      // Crear la ficha con timestamps
      final fichaConTimestamps = ficha.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _fichasRef.add(fichaConTimestamps.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear ficha médica: $e');
    }
  }

  /// Actualiza una ficha médica existente
  Future<void> updateFicha(String id, FichaMedica ficha) async {
    try {
      // Actualizar con nuevo timestamp
      final fichaActualizada = ficha.copyWith(
        updatedAt: DateTime.now(),
      );

      await _fichasRef.doc(id).update(fichaActualizada.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar ficha médica: $e');
    }
  }

  /// Elimina una ficha médica
  Future<void> deleteFicha(String id) async {
    try {
      await _fichasRef.doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar ficha médica: $e');
    }
  }

  /// Obtiene el conteo total de fichas médicas
  Future<int> getTotalFichas() async {
    try {
      final snapshot = await _fichasRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Error al obtener conteo de fichas: $e');
    }
  }

  /// Incrementa el contador de consultas de una ficha
  Future<void> incrementarConsultas(String id) async {
    try {
      await _fichasRef.doc(id).update({
        'totalConsultas': FieldValue.increment(1),
        'ultimaConsulta': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Error al incrementar consultas: $e');
    }
  }
}
