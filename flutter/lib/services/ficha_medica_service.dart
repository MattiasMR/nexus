import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/ficha_medica.dart';

/// Servicio para gestionar las fichas médicas de los pacientes
class FichaMedicaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'fichas-medicas';

  /// Obtener la ficha médica de un paciente
  Future<FichaMedica?> obtenerFichaMedica(String idPaciente) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('idPaciente', isEqualTo: idPaciente)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return FichaMedica.fromFirestore(query.docs.first);
    } catch (e) {
      debugPrint('Error al obtener ficha médica: $e');
      rethrow;
    }
  }

  /// Escuchar cambios en la ficha médica de un paciente
  Stream<FichaMedica?> escucharFichaMedica(String idPaciente) {
    return _firestore
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return null;
      }
      return FichaMedica.fromFirestore(snapshot.docs.first);
    });
  }

  /// Actualizar antecedentes de la ficha médica
  Future<void> actualizarAntecedentes(
    String fichaId,
    Antecedentes antecedentes,
  ) async {
    try {
      await _firestore.collection(_collection).doc(fichaId).update({
        'antecedentes': antecedentes.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error al actualizar antecedentes: $e');
      rethrow;
    }
  }

  /// Agregar alergia
  Future<void> agregarAlergia(String fichaId, String alergia) async {
    try {
      await _firestore.collection(_collection).doc(fichaId).update({
        'alergias': FieldValue.arrayUnion([alergia]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error al agregar alergia: $e');
      rethrow;
    }
  }

  /// Eliminar alergia
  Future<void> eliminarAlergia(String fichaId, String alergia) async {
    try {
      await _firestore.collection(_collection).doc(fichaId).update({
        'alergias': FieldValue.arrayRemove([alergia]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error al eliminar alergia: $e');
      rethrow;
    }
  }

  /// Actualizar grupo sanguíneo
  Future<void> actualizarGrupoSanguineo(
    String fichaId,
    String grupoSanguineo,
  ) async {
    try {
      await _firestore.collection(_collection).doc(fichaId).update({
        'grupoSanguineo': grupoSanguineo,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error al actualizar grupo sanguíneo: $e');
      rethrow;
    }
  }
}
