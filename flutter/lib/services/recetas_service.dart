import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicamento.dart';

class RecetasService {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'recetas';

  Stream<List<Receta>> getRecetasByPaciente(String idPaciente) {
    return _db
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .orderBy('fechaEmision', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Receta.fromFirestore(doc)).toList());
  }

  /// Obtener recetas vigentes
  Stream<List<Receta>> obtenerRecetasVigentes(String idPaciente) {
    return _db
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .where('estado', isEqualTo: 'activa')
        .orderBy('fechaEmision', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Receta.fromFirestore(doc)).toList());
  }

  /// Obtener recetas anteriores
  Stream<List<Receta>> obtenerRecetasAnteriores(String idPaciente) {
    return _db
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .where('estado', isEqualTo: 'vencida')
        .orderBy('fechaEmision', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Receta.fromFirestore(doc)).toList());
  }

  Future<String> createReceta(Receta receta) async {
    final docRef = await _db.collection(_collection).add(receta.toMap());
    return docRef.id;
  }

  Stream<List<Medicamento>> getAllMedicamentos() {
    return _db
        .collection('medicamentos')
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Medicamento.fromFirestore(doc)).toList());
  }
}
