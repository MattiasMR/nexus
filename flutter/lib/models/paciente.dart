import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Paciente que coincide con la estructura de Firestore
/// y la versión Ionic del proyecto
class Paciente {
  final String? id;
  final String rut;
  final String nombre;
  final String apellido;
  final DateTime fechaNacimiento;
  final String direccion;
  final String telefono;
  final String? email;
  final String sexo; // 'M', 'F', 'Otro'
  final String? grupoSanguineo;
  
  // Campos adicionales para la UI
  final String? estado; // 'activo', 'inactivo'
  final String? estadoCivil; // 'soltero', 'casado', 'divorciado', 'viudo', 'union_libre'
  final String? ocupacion;
  final String? diagnostico;
  
  // Problem List
  final List<String>? alergias;
  final List<String>? enfermedadesCronicas;
  final List<AlertaMedica>? alertasMedicas;
  
  // Para búsqueda mejorada
  final String? nombreCompleto;
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Paciente({
    this.id,
    required this.rut,
    required this.nombre,
    required this.apellido,
    required this.fechaNacimiento,
    required this.direccion,
    required this.telefono,
    this.email,
    required this.sexo,
    this.grupoSanguineo,
    this.estado,
    this.estadoCivil,
    this.ocupacion,
    this.diagnostico,
    this.alergias,
    this.enfermedadesCronicas,
    this.alertasMedicas,
    this.nombreCompleto,
    this.createdAt,
    this.updatedAt,
  });

  /// Calcula la edad del paciente
  int get edad {
    final now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month ||
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  /// Obtiene las iniciales del paciente
  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final a = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$n$a';
  }

  /// Convierte el modelo a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'rut': rut,
      'nombre': nombre,
      'apellido': apellido,
      'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
      'direccion': direccion,
      'telefono': telefono,
      if (email != null) 'email': email,
      'sexo': sexo,
      if (grupoSanguineo != null) 'grupoSanguineo': grupoSanguineo,
      if (estado != null) 'estado': estado,
      if (estadoCivil != null) 'estadoCivil': estadoCivil,
      if (ocupacion != null) 'ocupacion': ocupacion,
      if (diagnostico != null) 'diagnostico': diagnostico,
      if (alergias != null) 'alergias': alergias,
      if (enfermedadesCronicas != null) 'enfermedadesCronicas': enfermedadesCronicas,
      if (alertasMedicas != null)
        'alertasMedicas': alertasMedicas!.map((a) => a.toMap()).toList(),
      'nombreCompleto': '$nombre $apellido',
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
    };
  }

  /// Crea un modelo desde un documento de Firestore
  factory Paciente.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Paciente(
      id: doc.id,
      rut: data['rut'] ?? '',
      nombre: data['nombre'] ?? '',
      apellido: data['apellido'] ?? '',
      fechaNacimiento: data['fechaNacimiento'] != null 
          ? (data['fechaNacimiento'] as Timestamp).toDate()
          : DateTime.now(),
      direccion: data['direccion'] ?? '',
      telefono: data['telefono'] ?? '',
      email: data['email'],
      sexo: data['sexo'] ?? 'Otro',
      grupoSanguineo: data['grupoSanguineo'],
      estado: data['estado'],
      estadoCivil: data['estadoCivil'],
      ocupacion: data['ocupacion'],
      diagnostico: data['diagnostico'],
      alergias: data['alergias'] != null ? List<String>.from(data['alergias']) : null,
      enfermedadesCronicas: data['enfermedadesCronicas'] != null
          ? List<String>.from(data['enfermedadesCronicas'])
          : null,
      alertasMedicas: data['alertasMedicas'] != null
          ? (data['alertasMedicas'] as List)
              .map((a) => AlertaMedica.fromMap(a as Map<String, dynamic>))
              .toList()
          : null,
      nombreCompleto: data['nombreCompleto'],
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  /// Crea una copia del modelo con campos actualizados
  Paciente copyWith({
    String? id,
    String? rut,
    String? nombre,
    String? apellido,
    DateTime? fechaNacimiento,
    String? direccion,
    String? telefono,
    String? email,
    String? sexo,
    String? grupoSanguineo,
    String? estado,
    String? estadoCivil,
    String? ocupacion,
    String? diagnostico,
    List<String>? alergias,
    List<String>? enfermedadesCronicas,
    List<AlertaMedica>? alertasMedicas,
    String? nombreCompleto,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Paciente(
      id: id ?? this.id,
      rut: rut ?? this.rut,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      sexo: sexo ?? this.sexo,
      grupoSanguineo: grupoSanguineo ?? this.grupoSanguineo,
      estado: estado ?? this.estado,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      ocupacion: ocupacion ?? this.ocupacion,
      diagnostico: diagnostico ?? this.diagnostico,
      alergias: alergias ?? this.alergias,
      enfermedadesCronicas: enfermedadesCronicas ?? this.enfermedadesCronicas,
      alertasMedicas: alertasMedicas ?? this.alertasMedicas,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo de Alerta Médica
class AlertaMedica {
  final String tipo; // 'alergia', 'enfermedad_cronica', 'medicamento_critico', 'otro'
  final String descripcion;
  final String severidad; // 'baja', 'media', 'alta', 'critica'
  final DateTime fechaRegistro;

  AlertaMedica({
    required this.tipo,
    required this.descripcion,
    required this.severidad,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'descripcion': descripcion,
      'severidad': severidad,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  factory AlertaMedica.fromMap(Map<String, dynamic> map) {
    return AlertaMedica(
      tipo: map['tipo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      severidad: map['severidad'] ?? 'baja',
      fechaRegistro: map['fechaRegistro'] != null
          ? (map['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
