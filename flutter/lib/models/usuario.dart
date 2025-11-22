import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de Usuario del sistema (PACIENTES)
/// Esta app de Flutter es exclusivamente para pacientes
/// Los médicos usan la app Ionic
class Usuario {
  final String id; // Firebase Auth UID
  final String email;
  final String nombre;
  final String apellido;
  final String rut;
  final String telefono;
  final bool activo;
  final String? photoURL;
  final String? direccion;
  final String? fechaNacimiento; // Formato: YYYY-MM-DD
  final String? sexo; // M, F, Otro
  final String? prevision; // Isapre, Fonasa, etc.
  final String? contactoEmergencia;
  final String? telefonoEmergencia;
  final DateTime? ultimoAcceso;
  final DateTime createdAt;
  final DateTime updatedAt;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.rut,
    required this.telefono,
    this.activo = true,
    this.photoURL,
    this.direccion,
    this.fechaNacimiento,
    this.sexo,
    this.prevision,
    this.contactoEmergencia,
    this.telefonoEmergencia,
    this.ultimoAcceso,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear Usuario desde Firestore Document
  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Usuario.fromMap(data, doc.id);
  }

  /// Crear Usuario desde Map
  factory Usuario.fromMap(Map<String, dynamic> map, String id) {
    // Helper para convertir fechaNacimiento (puede ser String o Timestamp)
    String? parseFechaNacimiento(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Timestamp) {
        final date = value.toDate();
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      return null;
    }

    return Usuario(
      id: id,
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      rut: map['rut'] ?? '',
      telefono: map['telefono'] ?? '',
      activo: map['activo'] ?? true,
      photoURL: map['photoURL'],
      direccion: map['direccion'],
      fechaNacimiento: parseFechaNacimiento(map['fechaNacimiento']),
      sexo: map['sexo'],
      prevision: map['prevision'],
      contactoEmergencia: map['contactoEmergencia'],
      telefonoEmergencia: map['telefonoEmergencia'],
      ultimoAcceso: map['ultimoAcceso'] != null
          ? (map['ultimoAcceso'] as Timestamp).toDate()
          : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'rut': rut,
      'telefono': telefono,
      'activo': activo,
      'photoURL': photoURL,
      'direccion': direccion,
      'fechaNacimiento': fechaNacimiento,
      'sexo': sexo,
      'prevision': prevision,
      'contactoEmergencia': contactoEmergencia,
      'telefonoEmergencia': telefonoEmergencia,
      'ultimoAcceso':
          ultimoAcceso != null ? Timestamp.fromDate(ultimoAcceso!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ========== PROPIEDADES ==========

  /// Obtener nombre completo
  String get nombreCompleto => '$nombre $apellido';
  
  /// Alias para compatibilidad (displayName)
  String get displayName => nombreCompleto;
  
  /// Rol del usuario (siempre Paciente en esta app)
  String get rolTexto => 'Paciente';

  /// Verificar si tiene foto de perfil
  bool get tieneFoto => photoURL != null && photoURL!.isNotEmpty;

  /// Obtener edad (si tiene fecha de nacimiento)
  int? get edad {
    if (fechaNacimiento == null) return null;
    try {
      final birth = DateTime.parse(fechaNacimiento!);
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  /// Copiar con modificaciones
  Usuario copyWith({
    String? email,
    String? nombre,
    String? apellido,
    String? rut,
    String? telefono,
    bool? activo,
    String? photoURL,
    String? direccion,
    String? fechaNacimiento,
    String? sexo,
    String? prevision,
    String? contactoEmergencia,
    String? telefonoEmergencia,
    DateTime? ultimoAcceso,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rut: rut ?? this.rut,
      telefono: telefono ?? this.telefono,
      activo: activo ?? this.activo,
      photoURL: photoURL ?? this.photoURL,
      direccion: direccion ?? this.direccion,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      sexo: sexo ?? this.sexo,
      prevision: prevision ?? this.prevision,
      contactoEmergencia: contactoEmergencia ?? this.contactoEmergencia,
      telefonoEmergencia: telefonoEmergencia ?? this.telefonoEmergencia,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, email: $email, nombreCompleto: $nombreCompleto, rut: $rut)';
  }
}

