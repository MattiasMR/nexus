import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Consulta Médica
class Consulta {
  final String? id;
  final String pacienteId;
  final String fichaId;
  final DateTime fecha;
  final String motivoConsulta;
  final String sintomas;
  final Map<String, dynamic> signosVitales;
  final String diagnosticoPrincipal;
  final List<String> diagnosticosSecundarios;
  final List<String> procedimientos;
  final String observaciones;
  final String planTratamiento;
  final List<String> medicamentos;
  final List<String> examenessolicitados;
  final DateTime? proximoControl;
  final String medicoId;
  final String medicoNombre;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consulta({
    this.id,
    required this.pacienteId,
    required this.fichaId,
    required this.fecha,
    required this.motivoConsulta,
    this.sintomas = '',
    this.signosVitales = const {},
    required this.diagnosticoPrincipal,
    this.diagnosticosSecundarios = const [],
    this.procedimientos = const [],
    this.observaciones = '',
    this.planTratamiento = '',
    this.medicamentos = const [],
    this.examenessolicitados = const [],
    this.proximoControl,
    required this.medicoId,
    required this.medicoNombre,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Crear desde Firestore
  factory Consulta.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Consulta(
      id: doc.id,
      pacienteId: data['pacienteId'] ?? '',
      fichaId: data['fichaId'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      motivoConsulta: data['motivoConsulta'] ?? '',
      sintomas: data['sintomas'] ?? '',
      signosVitales: Map<String, dynamic>.from(data['signosVitales'] ?? {}),
      diagnosticoPrincipal: data['diagnosticoPrincipal'] ?? '',
      diagnosticosSecundarios:
          List<String>.from(data['diagnosticosSecundarios'] ?? []),
      procedimientos: List<String>.from(data['procedimientos'] ?? []),
      observaciones: data['observaciones'] ?? '',
      planTratamiento: data['planTratamiento'] ?? '',
      medicamentos: List<String>.from(data['medicamentos'] ?? []),
      examenessolicitados: List<String>.from(data['examenessolicitados'] ?? []),
      proximoControl: data['proximoControl'] != null
          ? (data['proximoControl'] as Timestamp).toDate()
          : null,
      medicoId: data['medicoId'] ?? '',
      medicoNombre: data['medicoNombre'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'fichaId': fichaId,
      'fecha': Timestamp.fromDate(fecha),
      'motivoConsulta': motivoConsulta,
      'sintomas': sintomas,
      'signosVitales': signosVitales,
      'diagnosticoPrincipal': diagnosticoPrincipal,
      'diagnosticosSecundarios': diagnosticosSecundarios,
      'procedimientos': procedimientos,
      'observaciones': observaciones,
      'planTratamiento': planTratamiento,
      'medicamentos': medicamentos,
      'examenessolicitados': examenessolicitados,
      'proximoControl':
          proximoControl != null ? Timestamp.fromDate(proximoControl!) : null,
      'medicoId': medicoId,
      'medicoNombre': medicoNombre,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Copiar con modificaciones
  Consulta copyWith({
    String? id,
    String? pacienteId,
    String? fichaId,
    DateTime? fecha,
    String? motivoConsulta,
    String? sintomas,
    Map<String, dynamic>? signosVitales,
    String? diagnosticoPrincipal,
    List<String>? diagnosticosSecundarios,
    List<String>? procedimientos,
    String? observaciones,
    String? planTratamiento,
    List<String>? medicamentos,
    List<String>? examenessolicitados,
    DateTime? proximoControl,
    String? medicoId,
    String? medicoNombre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Consulta(
      id: id ?? this.id,
      pacienteId: pacienteId ?? this.pacienteId,
      fichaId: fichaId ?? this.fichaId,
      fecha: fecha ?? this.fecha,
      motivoConsulta: motivoConsulta ?? this.motivoConsulta,
      sintomas: sintomas ?? this.sintomas,
      signosVitales: signosVitales ?? this.signosVitales,
      diagnosticoPrincipal: diagnosticoPrincipal ?? this.diagnosticoPrincipal,
      diagnosticosSecundarios:
          diagnosticosSecundarios ?? this.diagnosticosSecundarios,
      procedimientos: procedimientos ?? this.procedimientos,
      observaciones: observaciones ?? this.observaciones,
      planTratamiento: planTratamiento ?? this.planTratamiento,
      medicamentos: medicamentos ?? this.medicamentos,
      examenessolicitados: examenessolicitados ?? this.examenessolicitados,
      proximoControl: proximoControl ?? this.proximoControl,
      medicoId: medicoId ?? this.medicoId,
      medicoNombre: medicoNombre ?? this.medicoNombre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
