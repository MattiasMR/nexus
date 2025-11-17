import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Profesional de la salud
class Profesional {
  final String id;
  final String? idUsuario; // Referencia a usuarios (si tiene cuenta)
  final String rut;
  final String nombre;
  final String apellido;
  final String? especialidad;
  final String? telefono;
  final String? email;
  final String? licencia;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profesional({
    required this.id,
    this.idUsuario,
    required this.rut,
    required this.nombre,
    required this.apellido,
    this.especialidad,
    this.telefono,
    this.email,
    this.licencia,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Nombre completo del profesional
  String get nombreCompleto => '$nombre $apellido';

  /// Crear Profesional desde Firestore Document
  factory Profesional.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profesional.fromMap(data, doc.id);
  }

  /// Crear Profesional desde Map
  factory Profesional.fromMap(Map<String, dynamic> map, String id) {
    return Profesional(
      id: id,
      idUsuario: map['idUsuario'],
      rut: map['rut'] ?? '',
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      especialidad: map['especialidad'],
      telefono: map['telefono'],
      email: map['email'],
      licencia: map['licencia'],
      activo: map['activo'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'rut': rut,
      'nombre': nombre,
      'apellido': apellido,
      'especialidad': especialidad,
      'telefono': telefono,
      'email': email,
      'licencia': licencia,
      'activo': activo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Copiar con modificaciones
  Profesional copyWith({
    String? idUsuario,
    String? rut,
    String? nombre,
    String? apellido,
    String? especialidad,
    String? telefono,
    String? email,
    String? licencia,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profesional(
      id: id,
      idUsuario: idUsuario ?? this.idUsuario,
      rut: rut ?? this.rut,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      especialidad: especialidad ?? this.especialidad,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      licencia: licencia ?? this.licencia,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Profesional(id: $id, nombreCompleto: $nombreCompleto, especialidad: $especialidad)';
  }
}
