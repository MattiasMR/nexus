import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Ficha Médica que coincide con la estructura de Firestore
class FichaMedica {
  final String? id;
  final String idPaciente;
  final DateTime fechaMedica;
  final String? observacion;
  final Antecedentes? antecedentes;
  final int? totalConsultas;
  final DateTime? ultimaConsulta;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FichaMedica({
    this.id,
    required this.idPaciente,
    required this.fechaMedica,
    this.observacion,
    this.antecedentes,
    this.totalConsultas,
    this.ultimaConsulta,
    this.createdAt,
    this.updatedAt,
  });

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'idPaciente': idPaciente,
      'fechaMedica': Timestamp.fromDate(fechaMedica),
      if (observacion != null) 'observacion': observacion,
      if (antecedentes != null) 'antecedentes': antecedentes!.toMap(),
      if (totalConsultas != null) 'totalConsultas': totalConsultas,
      if (ultimaConsulta != null) 'ultimaConsulta': Timestamp.fromDate(ultimaConsulta!),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  /// Crea un modelo desde un documento de Firestore
  factory FichaMedica.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FichaMedica(
      id: doc.id,
      idPaciente: data['idPaciente'] ?? '',
      fechaMedica: (data['fechaMedica'] as Timestamp).toDate(),
      observacion: data['observacion'],
      antecedentes: data['antecedentes'] != null
          ? Antecedentes.fromMap(data['antecedentes'] as Map<String, dynamic>)
          : null,
      totalConsultas: data['totalConsultas'],
      ultimaConsulta: data['ultimaConsulta'] != null
          ? (data['ultimaConsulta'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  /// Crea una copia del modelo con campos actualizados
  FichaMedica copyWith({
    String? id,
    String? idPaciente,
    DateTime? fechaMedica,
    String? observacion,
    Antecedentes? antecedentes,
    int? totalConsultas,
    DateTime? ultimaConsulta,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FichaMedica(
      id: id ?? this.id,
      idPaciente: idPaciente ?? this.idPaciente,
      fechaMedica: fechaMedica ?? this.fechaMedica,
      observacion: observacion ?? this.observacion,
      antecedentes: antecedentes ?? this.antecedentes,
      totalConsultas: totalConsultas ?? this.totalConsultas,
      ultimaConsulta: ultimaConsulta ?? this.ultimaConsulta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo de Antecedentes Médicos
class Antecedentes {
  final String? familiares;
  final String? personales;
  final String? quirurgicos;
  final String? hospitalizaciones;
  final List<String>? alergias;

  Antecedentes({
    this.familiares,
    this.personales,
    this.quirurgicos,
    this.hospitalizaciones,
    this.alergias,
  });

  Map<String, dynamic> toMap() {
    return {
      if (familiares != null) 'familiares': familiares,
      if (personales != null) 'personales': personales,
      if (quirurgicos != null) 'quirurgicos': quirurgicos,
      if (hospitalizaciones != null) 'hospitalizaciones': hospitalizaciones,
      if (alergias != null) 'alergias': alergias,
    };
  }

  factory Antecedentes.fromMap(Map<String, dynamic> map) {
    return Antecedentes(
      familiares: map['familiares'],
      personales: map['personales'],
      quirurgicos: map['quirurgicos'],
      hospitalizaciones: map['hospitalizaciones'],
      alergias: map['alergias'] != null ? List<String>.from(map['alergias']) : null,
    );
  }
}
