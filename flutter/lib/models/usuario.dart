import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de usuario central equivalente a la colección `usuarios`.
class Usuario {
  final String id; // Firebase Auth UID
  final String email;
  final String displayName;
  final String rut;
  final String telefono;
  final String? photoURL;
  final String rol; // admin | profesional | paciente
  final bool activo;
  final String? idPaciente;
  final String? idProfesional;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Usuario({
    required this.id,
    required this.email,
    required this.displayName,
    required this.rut,
    this.telefono = '',
    this.photoURL,
    required this.rol,
    required this.activo,
    this.idPaciente,
    this.idProfesional,
    this.createdAt,
    this.updatedAt,
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Usuario(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? data['nombreCompleto'] ?? '',
      rut: data['rut'] ?? '',
      telefono: data['telefono'] ?? '',
      photoURL: data['photoURL'],
      rol: data['rol'] ?? 'paciente',
      activo: data['activo'] ?? true,
      idPaciente: data['idPaciente'],
      idProfesional: data['idProfesional'],
      createdAt: _asDate(data['createdAt']),
      updatedAt: _asDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'rut': rut,
      'telefono': telefono,
      'photoURL': photoURL,
      'rol': rol,
      'activo': activo,
      'idPaciente': idPaciente,
      'idProfesional': idProfesional,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Usuario copyWith({
    String? email,
    String? displayName,
    String? rut,
    String? telefono,
    String? photoURL,
    String? rol,
    bool? activo,
    String? idPaciente,
    String? idProfesional,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      rut: rut ?? this.rut,
      telefono: telefono ?? this.telefono,
      photoURL: photoURL ?? this.photoURL,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      idPaciente: idPaciente ?? this.idPaciente,
      idProfesional: idProfesional ?? this.idProfesional,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Nombre completo disponible para la UI existente.
  String get nombreCompleto => displayName;

  /// Nombre aproximado tomando la primera palabra del displayName.
  String get nombre =>
      displayName.trim().isEmpty ? '' : displayName.trim().split(' ').first;

  /// Apellido aproximado tomando el resto del displayName.
  String get apellido {
    final parts = displayName.trim().split(' ');
    if (parts.length <= 1) return '';
    return parts.sublist(1).join(' ');
  }

  /// Texto descriptivo del rol (se usa en alertas y permisos).
  String get rolTexto => rol[0].toUpperCase() + rol.substring(1);

  bool get tieneFoto => photoURL != null && photoURL!.isNotEmpty;

  static DateTime? _asDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  @override
  String toString() {
    return 'Usuario(id: $id, email: $email, displayName: $displayName, rol: $rol)';
  }
}

