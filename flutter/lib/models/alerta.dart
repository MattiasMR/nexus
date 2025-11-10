/// Tipos de alertas médicas
enum TipoAlerta {
  alergia,
  medicacion,
  proximaCita,
  resultadoCritico,
  tratamiento,
  otro,
}

/// Severidad de la alerta
enum SeveridadAlerta {
  baja,
  media,
  alta,
  critica,
}

/// Modelo de Alerta Médica
class Alerta {
  final String? id;
  final String pacienteId;
  final String fichaId;
  final TipoAlerta tipo;
  final SeveridadAlerta severidad;
  final String titulo;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime? fechaExpiracion;
  final bool activa;

  Alerta({
    this.id,
    required this.pacienteId,
    required this.fichaId,
    required this.tipo,
    required this.severidad,
    required this.titulo,
    required this.descripcion,
    DateTime? fechaCreacion,
    this.fechaExpiracion,
    this.activa = true,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  /// Crear desde Map
  factory Alerta.fromMap(String id, Map<String, dynamic> data) {
    return Alerta(
      id: id,
      pacienteId: data['pacienteId'] ?? '',
      fichaId: data['fichaId'] ?? '',
      tipo: TipoAlerta.values
          .firstWhere((e) => e.name == data['tipo'], orElse: () => TipoAlerta.otro),
      severidad: SeveridadAlerta.values
          .firstWhere((e) => e.name == data['severidad'], orElse: () => SeveridadAlerta.media),
      titulo: data['titulo'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fechaCreacion: DateTime.parse(data['fechaCreacion'] ?? DateTime.now().toIso8601String()),
      fechaExpiracion: data['fechaExpiracion'] != null
          ? DateTime.parse(data['fechaExpiracion'])
          : null,
      activa: data['activa'] ?? true,
    );
  }

  /// Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'fichaId': fichaId,
      'tipo': tipo.name,
      'severidad': severidad.name,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaExpiracion': fechaExpiracion?.toIso8601String(),
      'activa': activa,
    };
  }
}
