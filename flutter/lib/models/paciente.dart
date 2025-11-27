import 'package:cloud_firestore/cloud_firestore.dart';
import 'usuario.dart';

/// Modelo híbrido que mantiene compatibilidad con la estructura histórica de
/// `pacientes` y los campos normalizados recientes.
class Paciente {
  final String? id;
  final String? idUsuario;
  final String rut;
  final String nombre;
  final String apellido;
  final DateTime? fechaNacimiento;
  final String direccion;
  final String telefono;
  final String? email;
  final String sexo;
  final String? grupoSanguineo;
  final List<String>? alergias;
  final List<String>? enfermedadesCronicas;
  final List<Map<String, dynamic>>? medicamentosActuales;
  final List<AlertaMedica>? alertasMedicas;
  final Map<String, dynamic>? contactoEmergencia;
  final String? prevision;
  final String? numeroFicha;
  final String? observaciones;
  final String? estado;
  final String? estadoCivil;
  final String? ocupacion;
  final String? diagnostico;
  final String? nombreCompleto;
  final String? direccionSecundaria;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Paciente({
    this.id,
    this.idUsuario,
    this.rut = '',
    this.nombre = '',
    this.apellido = '',
    this.fechaNacimiento,
    this.direccion = '',
    this.telefono = '',
    this.email,
    this.sexo = 'No especificado',
    this.grupoSanguineo,
    this.alergias,
    this.enfermedadesCronicas,
    this.medicamentosActuales,
    this.alertasMedicas,
    this.contactoEmergencia,
    this.prevision,
    this.numeroFicha,
    this.observaciones,
    this.estado,
    this.estadoCivil,
    this.ocupacion,
    this.diagnostico,
    this.nombreCompleto,
    this.direccionSecundaria,
    this.createdAt,
    this.updatedAt,
  });

  /// Calcula la edad aproximada del paciente.
  int get edad {
    final fecha = fechaNacimiento;
    if (fecha == null) return 0;
    final now = DateTime.now();
    int age = now.year - fecha.year;
    if (now.month < fecha.month ||
        (now.month == fecha.month && now.day < fecha.day)) {
      age--;
    }
    return age;
  }

  /// Devuelve las iniciales derivadas del nombre y apellido.
  String get iniciales {
    final n = nombre.isNotEmpty ? nombre[0].toUpperCase() : '';
    final a = apellido.isNotEmpty ? apellido[0].toUpperCase() : '';
    return '$n$a'.trim();
  }

  /// Nombre completo preferido (usa campo dedicado o concatena nombre+apellido).
  String get nombreParaMostrar {
    final custom = nombreCompleto?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    return '$nombre $apellido'.trim();
  }

  String? get contactoEmergenciaNombre =>
      contactoEmergencia?['nombre'] as String?;

  String? get contactoEmergenciaTelefono =>
      contactoEmergencia?['telefono'] as String?;

  /// Conversión bidireccional con Firestore para soportar ambos modelos.
  factory Paciente.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Paciente(
      id: doc.id,
      idUsuario: data['idUsuario'],
      rut: (data['rut'] ?? '').toString(),
      nombre: (data['nombre'] ?? '').toString(),
      apellido: (data['apellido'] ?? '').toString(),
      fechaNacimiento: _asDate(data['fechaNacimiento']),
      direccion: (data['direccion'] ?? '').toString(),
      telefono: (data['telefono'] ?? '').toString(),
      email: data['email']?.toString(),
      sexo: (data['sexo'] ?? 'No especificado').toString(),
      grupoSanguineo: data['grupoSanguineo']?.toString(),
      alergias: data['alergias'] != null
          ? List<String>.from(data['alergias'] as List)
          : null,
      enfermedadesCronicas: data['enfermedadesCronicas'] != null
          ? List<String>.from(data['enfermedadesCronicas'] as List)
          : null,
        medicamentosActuales: data['medicamentosActuales'] != null
          ? List<Map<String, dynamic>>.from(
              (data['medicamentosActuales'] as List)
                  .map((item) => Map<String, dynamic>.from(item as Map)),
            )
          : null,
        alertasMedicas: data['alertasMedicas'] != null
          ? (data['alertasMedicas'] as List)
            .map((value) =>
              AlertaMedica.fromMap(Map<String, dynamic>.from(value as Map)))
            .toList()
          : null,
      contactoEmergencia: data['contactoEmergencia'] != null
          ? Map<String, dynamic>.from(data['contactoEmergencia'] as Map)
          : null,
      prevision: data['prevision']?.toString(),
      numeroFicha: data['numeroFicha']?.toString(),
      observaciones: data['observaciones']?.toString(),
      estado: data['estado']?.toString(),
      estadoCivil: data['estadoCivil']?.toString(),
      ocupacion: data['ocupacion']?.toString(),
      diagnostico: data['diagnostico']?.toString(),
      nombreCompleto: data['nombreCompleto']?.toString(),
      direccionSecundaria: data['direccionSecundaria']?.toString(),
      createdAt: _asDate(data['createdAt']),
      updatedAt: _asDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (idUsuario != null) 'idUsuario': idUsuario,
      'rut': rut,
      'nombre': nombre,
      'apellido': apellido,
      if (fechaNacimiento != null)
        'fechaNacimiento': Timestamp.fromDate(fechaNacimiento!),
      'direccion': direccion,
      'telefono': telefono,
      if (email != null) 'email': email,
      'sexo': sexo,
      if (grupoSanguineo != null) 'grupoSanguineo': grupoSanguineo,
      if (alergias != null) 'alergias': alergias,
      if (enfermedadesCronicas != null)
        'enfermedadesCronicas': enfermedadesCronicas,
      if (medicamentosActuales != null)
        'medicamentosActuales': medicamentosActuales,
      if (alertasMedicas != null)
        'alertasMedicas': alertasMedicas!.map((a) => a.toMap()).toList(),
      if (contactoEmergencia != null)
        'contactoEmergencia': contactoEmergencia,
      if (prevision != null) 'prevision': prevision,
      if (numeroFicha != null) 'numeroFicha': numeroFicha,
      if (observaciones != null) 'observaciones': observaciones,
      if (estado != null) 'estado': estado,
      if (estadoCivil != null) 'estadoCivil': estadoCivil,
      if (ocupacion != null) 'ocupacion': ocupacion,
      if (diagnostico != null) 'diagnostico': diagnostico,
      if (nombreCompleto != null) 'nombreCompleto': nombreCompleto,
      if (direccionSecundaria != null)
        'direccionSecundaria': direccionSecundaria,
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  Paciente copyWith({
    String? id,
    String? idUsuario,
    String? rut,
    String? nombre,
    String? apellido,
    DateTime? fechaNacimiento,
    String? direccion,
    String? telefono,
    String? email,
    String? sexo,
    String? grupoSanguineo,
    List<String>? alergias,
    List<String>? enfermedadesCronicas,
    List<Map<String, dynamic>>? medicamentosActuales,
    List<AlertaMedica>? alertasMedicas,
    Map<String, dynamic>? contactoEmergencia,
    String? prevision,
    String? numeroFicha,
    String? observaciones,
    String? estado,
    String? estadoCivil,
    String? ocupacion,
    String? diagnostico,
    String? nombreCompleto,
    String? direccionSecundaria,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Paciente(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      rut: rut ?? this.rut,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      sexo: sexo ?? this.sexo,
      grupoSanguineo: grupoSanguineo ?? this.grupoSanguineo,
      alergias: alergias ?? this.alergias,
      enfermedadesCronicas: enfermedadesCronicas ?? this.enfermedadesCronicas,
      medicamentosActuales: medicamentosActuales ?? this.medicamentosActuales,
      alertasMedicas: alertasMedicas ?? this.alertasMedicas,
      contactoEmergencia: contactoEmergencia ?? this.contactoEmergencia,
      prevision: prevision ?? this.prevision,
      numeroFicha: numeroFicha ?? this.numeroFicha,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      ocupacion: ocupacion ?? this.ocupacion,
      diagnostico: diagnostico ?? this.diagnostico,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      direccionSecundaria: direccionSecundaria ?? this.direccionSecundaria,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _asDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}

/// View-model para combinar datos personales y médicos.
class PacienteCompleto {
  final Usuario usuario;
  final Paciente paciente;

  const PacienteCompleto({required this.usuario, required this.paciente});

  String get displayName => usuario.displayName;
  String get email => usuario.email;
  String get rut => usuario.rut;
  String get telefono => usuario.telefono;
  String? get photoURL => usuario.photoURL;
  bool get activo => usuario.activo;
  String get rol => usuario.rol;
  String get idUsuario => usuario.id;
  String get idPaciente => paciente.id ?? '';
  DateTime? get fechaNacimiento => paciente.fechaNacimiento;
  String? get grupoSanguineo => paciente.grupoSanguineo;
  List<String>? get alergias => paciente.alergias;
  List<String>? get enfermedades => paciente.enfermedadesCronicas;
  Map<String, dynamic>? get contactoEmergencia => paciente.contactoEmergencia;
  String? get prevision => paciente.prevision;
  String get direccion => paciente.direccion;
  String get sexo => paciente.sexo;
}

/// Modelo auxiliar reutilizado por pantallas heredadas (alertas médicas).
class AlertaMedica {
  final String tipo;
  final String descripcion;
  final String severidad;
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
