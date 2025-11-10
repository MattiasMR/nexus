import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospitalizacion.dart';

class HospitalizacionesService {
  final _db = FirebaseFirestore.instance;
  final String _collection = 'hospitalizaciones';

  Stream<List<Hospitalizacion>> getHospitalizacionesByPaciente(String idPaciente) {
    return _db
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .orderBy('fechaIngreso', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Hospitalizacion.fromFirestore(doc)).toList());
  }

  Stream<List<Hospitalizacion>> getHospitalizacionesActivas() {
    return _db
        .collection(_collection)
        .where('fechaAlta', isNull: true)
        .orderBy('fechaIngreso', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Hospitalizacion.fromFirestore(doc)).toList());
  }

  Future<String> createHospitalizacion(Hospitalizacion hospitalizacion) async {
    final docRef = await _db.collection(_collection).add(hospitalizacion.toMap());
    return docRef.id;
  }

  Future<void> darAlta(String id, DateTime fechaAlta) async {
    await _db.collection(_collection).doc(id).update({
      'fechaAlta': Timestamp.fromDate(fechaAlta),
      'updatedAt': Timestamp.now(),
    });
  }
}
