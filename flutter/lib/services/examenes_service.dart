import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/examen.dart';

class ExamenesService {
  final _db = FirebaseFirestore.instance;

  Stream<List<OrdenExamen>> getOrdenesByPaciente(String idPaciente) {
    return _db
        .collection('ordenes-examen')
        .where('idPaciente', isEqualTo: idPaciente)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrdenExamen.fromFirestore(doc)).toList());
  }

  Future<String> createOrden(OrdenExamen orden) async {
    final docRef = await _db.collection('ordenes-examen').add(orden.toMap());
    return docRef.id;
  }

  Stream<List<Examen>> getAllExamenes() {
    return _db
        .collection('examenes')
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Examen.fromFirestore(doc)).toList());
  }
}
