/// Modelo de Tratamiento Médico
class Tratamiento {
  final String? id;
  final String pacienteId;
  final String fichaId;
  final String nombre;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final bool activo;
  final List<String> medicamentos;
  final String indicaciones;
  final String? medicoResponsable;

  Tratamiento({
    this.id,
    required this.pacienteId,
    required this.fichaId,
    required this.nombre,
    this.descripcion = '',
    required this.fechaInicio,
    this.fechaFin,
    this.activo = true,
    this.medicamentos = const [],
    this.indicaciones = '',
    this.medicoResponsable,
  });

  /// Crear desde Map
  factory Tratamiento.fromMap(String id, Map<String, dynamic> data) {
    return Tratamiento(
      id: id,
      pacienteId: data['pacienteId'] ?? '',
      fichaId: data['fichaId'] ?? '',
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      fechaInicio: DateTime.parse(data['fechaInicio'] ?? DateTime.now().toIso8601String()),
      fechaFin: data['fechaFin'] != null ? DateTime.parse(data['fechaFin']) : null,
      activo: data['activo'] ?? true,
      medicamentos: List<String>.from(data['medicamentos'] ?? []),
      indicaciones: data['indicaciones'] ?? '',
      medicoResponsable: data['medicoResponsable'],
    );
  }

  /// Convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'pacienteId': pacienteId,
      'fichaId': fichaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'activo': activo,
      'medicamentos': medicamentos,
      'indicaciones': indicaciones,
      'medicoResponsable': medicoResponsable,
    };
  }

  /// Duración del tratamiento en días
  int get duracionDias {
    final fin = fechaFin ?? DateTime.now();
    return fin.difference(fechaInicio).inDays;
  }

  /// Verificar si está vigente
  bool get esVigente {
    if (!activo) return false;
    if (fechaFin == null) return true;
    return DateTime.now().isBefore(fechaFin!);
  }
}
