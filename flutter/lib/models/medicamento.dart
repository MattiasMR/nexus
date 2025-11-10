import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Medicamento (Catálogo)
class Medicamento {
  final String? id;
  final String nombre;
  final String? nombreGenerico;
  final String? presentacion;
  final String? concentracion;
  final List<String> viaAdministracion;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Medicamento({
    this.id,
    required this.nombre,
    this.nombreGenerico,
    this.presentacion,
    this.concentracion,
    this.viaAdministracion = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Medicamento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medicamento(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      nombreGenerico: data['nombreGenerico'],
      presentacion: data['presentacion'],
      concentracion: data['concentracion'],
      viaAdministracion: List<String>.from(data['viaAdministracion'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      if (nombreGenerico != null) 'nombreGenerico': nombreGenerico,
      if (presentacion != null) 'presentacion': presentacion,
      if (concentracion != null) 'concentracion': concentracion,
      'viaAdministracion': viaAdministracion,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}

/// Medicamento recetado (sub-objeto de Receta)
class MedicamentoRecetado {
  final String idMedicamento;
  final String nombreMedicamento;
  final String dosis;
  final String frecuencia;
  final String duracion;
  final String? indicaciones;

  MedicamentoRecetado({
    required this.idMedicamento,
    required this.nombreMedicamento,
    required this.dosis,
    required this.frecuencia,
    required this.duracion,
    this.indicaciones,
  });

  factory MedicamentoRecetado.fromMap(Map<String, dynamic> data) {
    return MedicamentoRecetado(
      idMedicamento: data['idMedicamento'] ?? '',
      nombreMedicamento: data['nombreMedicamento'] ?? '',
      dosis: data['dosis'] ?? '',
      frecuencia: data['frecuencia'] ?? '',
      duracion: data['duracion'] ?? '',
      indicaciones: data['indicaciones'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idMedicamento': idMedicamento,
      'nombreMedicamento': nombreMedicamento,
      'dosis': dosis,
      'frecuencia': frecuencia,
      'duracion': duracion,
      if (indicaciones != null) 'indicaciones': indicaciones,
    };
  }
}

/// Modelo de Receta Médica
class Receta {
  final String? id;
  final String idPaciente;
  final String idProfesional;
  final String? idConsulta;
  final DateTime fecha;
  final List<MedicamentoRecetado> medicamentos;
  final String? observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Receta({
    this.id,
    required this.idPaciente,
    required this.idProfesional,
    this.idConsulta,
    required this.fecha,
    required this.medicamentos,
    this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  factory Receta.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Receta(
      id: doc.id,
      idPaciente: data['idPaciente'] ?? '',
      idProfesional: data['idProfesional'] ?? '',
      idConsulta: data['idConsulta'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      medicamentos: (data['medicamentos'] as List<dynamic>?)
              ?.map((m) => MedicamentoRecetado.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      observaciones: data['observaciones'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'idProfesional': idProfesional,
      if (idConsulta != null) 'idConsulta': idConsulta,
      'fecha': Timestamp.fromDate(fecha),
      'medicamentos': medicamentos.map((m) => m.toMap()).toList(),
      if (observaciones != null) 'observaciones': observaciones,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }
}
