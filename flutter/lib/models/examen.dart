import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Examen (Catálogo)
class Examen {
  final String? id;
  final String nombre;
  final String? descripcion;
  final String tipo; // 'laboratorio', 'imagenologia', 'otro'
  final String? codigo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Examen({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.tipo,
    this.codigo,
    this.createdAt,
    this.updatedAt,
  });

  factory Examen.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Examen(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'],
      tipo: data['tipo'] ?? 'otro',
      codigo: data['codigo'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'tipo': tipo,
      if (codigo != null) 'codigo': codigo,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}

/// Documento de examen adjunto
class DocumentoExamen {
  final String url;
  final String nombre;
  final String tipo; // MIME type
  final int tamanio;
  final DateTime fechaSubida;
  final String subidoPor;

  DocumentoExamen({
    required this.url,
    required this.nombre,
    required this.tipo,
    required this.tamanio,
    required this.fechaSubida,
    required this.subidoPor,
  });

  factory DocumentoExamen.fromMap(Map<String, dynamic> data) {
    return DocumentoExamen(
      url: data['url'] ?? '',
      nombre: data['nombre'] ?? '',
      tipo: data['tipo'] ?? '',
      tamanio: data['tamanio'] ?? 0,
      fechaSubida: DateTime.parse(data['fechaSubida'] ?? DateTime.now().toIso8601String()),
      subidoPor: data['subidoPor'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'nombre': nombre,
      'tipo': tipo,
      'tamanio': tamanio,
      'fechaSubida': fechaSubida.toIso8601String(),
      'subidoPor': subidoPor,
    };
  }
}

/// Examen solicitado (sub-objeto de OrdenExamen)
class ExamenSolicitado {
  final String idExamen;
  final String nombreExamen;
  final String? resultado;
  final DateTime? fechaResultado;
  final List<DocumentoExamen> documentos;

  ExamenSolicitado({
    required this.idExamen,
    required this.nombreExamen,
    this.resultado,
    this.fechaResultado,
    this.documentos = const [],
  });

  factory ExamenSolicitado.fromMap(Map<String, dynamic> data) {
    return ExamenSolicitado(
      idExamen: data['idExamen'] ?? '',
      nombreExamen: data['nombreExamen'] ?? '',
      resultado: data['resultado'],
      fechaResultado: data['fechaResultado'] != null
          ? DateTime.parse(data['fechaResultado'])
          : null,
      documentos: (data['documentos'] as List<dynamic>?)
              ?.map((d) => DocumentoExamen.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idExamen': idExamen,
      'nombreExamen': nombreExamen,
      if (resultado != null) 'resultado': resultado,
      if (fechaResultado != null) 'fechaResultado': fechaResultado!.toIso8601String(),
      'documentos': documentos.map((d) => d.toMap()).toList(),
    };
  }

  bool get tieneResultado => resultado != null && resultado!.isNotEmpty;
}

/// Modelo de Orden de Examen
class OrdenExamen {
  final String? id;
  final String idPaciente;
  final String idProfesional;
  final String? idConsulta;
  final String? idHospitalizacion;
  final DateTime fecha;
  final String estado; // 'pendiente', 'realizado', 'cancelado'
  final List<ExamenSolicitado> examenes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrdenExamen({
    this.id,
    required this.idPaciente,
    required this.idProfesional,
    this.idConsulta,
    this.idHospitalizacion,
    required this.fecha,
    required this.estado,
    required this.examenes,
    this.createdAt,
    this.updatedAt,
  });

  factory OrdenExamen.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrdenExamen(
      id: doc.id,
      idPaciente: data['idPaciente'] ?? '',
      idProfesional: data['idProfesional'] ?? '',
      idConsulta: data['idConsulta'],
      idHospitalizacion: data['idHospitalizacion'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      estado: data['estado'] ?? 'pendiente',
      examenes: (data['examenes'] as List<dynamic>?)
              ?.map((e) => ExamenSolicitado.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPaciente': idPaciente,
      'idProfesional': idProfesional,
      if (idConsulta != null) 'idConsulta': idConsulta,
      if (idHospitalizacion != null) 'idHospitalizacion': idHospitalizacion,
      'fecha': Timestamp.fromDate(fecha),
      'estado': estado,
      'examenes': examenes.map((e) => e.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime.now()),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  int get totalExamenes => examenes.length;
  int get examenesRealizados => examenes.where((e) => e.tieneResultado).length;
  bool get estaCompleto => examenesRealizados == totalExamenes && totalExamenes > 0;
  double get progreso => totalExamenes > 0 ? examenesRealizados / totalExamenes : 0;
}
