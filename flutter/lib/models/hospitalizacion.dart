import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Hospitalización
class Hospitalizacion {
  final String? id;
  final String idPaciente;
  final String idProfesional;
  final DateTime fechaIngreso;
  final DateTime? fechaAlta;
  final String? habitacion;
  final String motivoIngreso;
  final String? observaciones;
  final List<String> intervencion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Hospitalizacion({
    this.id,
    required this.idPaciente,
    required this.idProfesional,
    required this.fechaIngreso,
    this.fechaAlta,
    this.habitacion,
    required this.motivoIngreso,
    this.observaciones,
    this.intervencion = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Hospitalizacion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Hospitalizacion(
      id: doc.id,
      idPaciente: data['idPaciente'] ?? '',
      idProfesional: data['idProfesional'] ?? '',
      fechaIngreso: (data['fechaIngreso'] as Timestamp).toDate(),
      fechaAlta: (data['fechaAlta'] as Timestamp?)?.toDate(),
      habitacion: data['habitacion'],
      motivoIngreso: data['motivoIngreso'] ?? '',
      observaciones: data['observaciones'],
      intervencion: List<String>.from(data['intervencion'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'idProfesional': idProfesional,
      'fechaIngreso': Timestamp.fromDate(fechaIngreso),
      if (fechaAlta != null) 'fechaAlta': Timestamp.fromDate(fechaAlta!),
      if (habitacion != null) 'habitacion': habitacion,
      'motivoIngreso': motivoIngreso,
      if (observaciones != null) 'observaciones': observaciones,
      'intervencion': intervencion,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  bool get estaActivo => fechaAlta == null;
  
  int get diasHospitalizado {
    final fin = fechaAlta ?? DateTime.now();
    return fin.difference(fechaIngreso).inDays;
  }

  String get estadoTexto => estaActivo ? 'Activo' : 'Alta';
}
