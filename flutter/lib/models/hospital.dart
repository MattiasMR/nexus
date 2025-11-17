import 'package:cloud_firestore/cloud_firestore.dart';

/// Configuración específica del hospital
class ConfigHospital {
  final bool permitirAutoRegistroPacientes;
  final HorarioAtencion? horarioAtencion;
  final String? logoURL;
  final String? colorPrimario;
  final String? colorSecundario;

  ConfigHospital({
    this.permitirAutoRegistroPacientes = false,
    this.horarioAtencion,
    this.logoURL,
    this.colorPrimario,
    this.colorSecundario,
  });

  factory ConfigHospital.fromMap(Map<String, dynamic> map) {
    return ConfigHospital(
      permitirAutoRegistroPacientes: map['permitirAutoRegistroPacientes'] ?? false,
      horarioAtencion: map['horarioAtencion'] != null
          ? HorarioAtencion.fromMap(map['horarioAtencion'])
          : null,
      logoURL: map['logoURL'],
      colorPrimario: map['colorPrimario'],
      colorSecundario: map['colorSecundario'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'permitirAutoRegistroPacientes': permitirAutoRegistroPacientes,
      'horarioAtencion': horarioAtencion?.toMap(),
      'logoURL': logoURL,
      'colorPrimario': colorPrimario,
      'colorSecundario': colorSecundario,
    };
  }
}

/// Horario de atención del hospital
class HorarioAtencion {
  final String inicio; // "08:00"
  final String fin; // "20:00"

  HorarioAtencion({
    required this.inicio,
    required this.fin,
  });

  factory HorarioAtencion.fromMap(Map<String, dynamic> map) {
    return HorarioAtencion(
      inicio: map['inicio'] ?? '00:00',
      fin: map['fin'] ?? '23:59',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inicio': inicio,
      'fin': fin,
    };
  }
}

/// Modelo de Hospital
class Hospital {
  final String id;
  final String nombre;
  final String direccion;
  final String ciudad;
  final String region;
  final String telefono;
  final String email;
  final String codigoHospital;
  final String tipo; // 'publico', 'privado', 'clinica'
  final List<String> servicios;
  final bool activo;
  final ConfigHospital? configuracion;
  final DateTime createdAt;
  final DateTime updatedAt;

  Hospital({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    required this.region,
    required this.telefono,
    required this.email,
    required this.codigoHospital,
    required this.tipo,
    this.servicios = const [],
    required this.activo,
    this.configuracion,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear Hospital desde Firestore Document
  factory Hospital.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Hospital.fromMap(data, doc.id);
  }

  /// Crear Hospital desde Map
  factory Hospital.fromMap(Map<String, dynamic> map, String id) {
    return Hospital(
      id: id,
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      ciudad: map['ciudad'] ?? '',
      region: map['region'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      codigoHospital: map['codigoHospital'] ?? '',
      tipo: map['tipo'] ?? 'hospital',
      servicios: List<String>.from(map['servicios'] ?? []),
      activo: map['activo'] ?? true,
      configuracion: map['configuracion'] != null
          ? ConfigHospital.fromMap(map['configuracion'])
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
      'region': region,
      'telefono': telefono,
      'email': email,
      'codigoHospital': codigoHospital,
      'tipo': tipo,
      'servicios': servicios,
      'activo': activo,
      'configuracion': configuracion?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Copiar con modificaciones
  Hospital copyWith({
    String? nombre,
    String? direccion,
    String? ciudad,
    String? region,
    String? telefono,
    String? email,
    String? codigoHospital,
    String? tipo,
    List<String>? servicios,
    bool? activo,
    ConfigHospital? configuracion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Hospital(
      id: id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      region: region ?? this.region,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      codigoHospital: codigoHospital ?? this.codigoHospital,
      tipo: tipo ?? this.tipo,
      servicios: servicios ?? this.servicios,
      activo: activo ?? this.activo,
      configuracion: configuracion ?? this.configuracion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Hospital(id: $id, nombre: $nombre, ciudad: $ciudad, tipo: $tipo)';
  }
}
