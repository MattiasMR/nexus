import 'package:cloud_firestore/cloud_firestore.dart';

/// Roles de usuario en el sistema
enum RolUsuario {
  paciente,
  medico,
  enfermera,
  admin,
  superAdmin;

  /// Convertir desde string
  static RolUsuario fromString(String rol) {
    switch (rol.toLowerCase()) {
      case 'paciente':
        return RolUsuario.paciente;
      case 'medico':
        return RolUsuario.medico;
      case 'enfermera':
        return RolUsuario.enfermera;
      case 'admin':
        return RolUsuario.admin;
      case 'super_admin':
        return RolUsuario.superAdmin;
      default:
        return RolUsuario.paciente;
    }
  }

  /// Convertir a string para Firestore
  String toFirestore() {
    switch (this) {
      case RolUsuario.paciente:
        return 'paciente';
      case RolUsuario.medico:
        return 'medico';
      case RolUsuario.enfermera:
        return 'enfermera';
      case RolUsuario.admin:
        return 'admin';
      case RolUsuario.superAdmin:
        return 'super_admin';
    }
  }

  /// Obtener texto legible
  String get displayName {
    switch (this) {
      case RolUsuario.paciente:
        return 'Paciente';
      case RolUsuario.medico:
        return 'Médico';
      case RolUsuario.enfermera:
        return 'Enfermera';
      case RolUsuario.admin:
        return 'Administrador';
      case RolUsuario.superAdmin:
        return 'Super Administrador';
    }
  }
}

/// Modelo de Usuario del sistema
/// Representa un usuario autenticado con rol y permisos
class Usuario {
  final String id; // Firebase Auth UID
  final String email;
  final String displayName;
  final RolUsuario rol;
  final bool activo;
  final String? photoURL;
  final String? telefono;
  final String? idPaciente; // Si rol = 'paciente'
  final String? idProfesional; // Si rol = 'medico', 'enfermera'
  final List<String> hospitalesAsignados; // Para médicos/admins
  final List<String> especialidades; // Solo para médicos
  final DateTime? ultimoAcceso;
  final DateTime createdAt;
  final DateTime updatedAt;

  Usuario({
    required this.id,
    required this.email,
    required this.displayName,
    required this.rol,
    required this.activo,
    this.photoURL,
    this.telefono,
    this.idPaciente,
    this.idProfesional,
    this.hospitalesAsignados = const [],
    this.especialidades = const [],
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
    return Usuario(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      rol: RolUsuario.fromString(map['rol'] ?? 'paciente'),
      activo: map['activo'] ?? true,
      photoURL: map['photoURL'],
      telefono: map['telefono'],
      idPaciente: map['idPaciente'],
      idProfesional: map['idProfesional'],
      hospitalesAsignados: List<String>.from(map['hospitalesAsignados'] ?? []),
      especialidades: List<String>.from(map['especialidades'] ?? []),
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
      'displayName': displayName,
      'rol': rol.toFirestore(),
      'activo': activo,
      'photoURL': photoURL,
      'telefono': telefono,
      'idPaciente': idPaciente,
      'idProfesional': idProfesional,
      'hospitalesAsignados': hospitalesAsignados,
      'especialidades': especialidades,
      'ultimoAcceso':
          ultimoAcceso != null ? Timestamp.fromDate(ultimoAcceso!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ========== PROPIEDADES DE VERIFICACIÓN ==========

  /// Verificar si el usuario es personal médico (puede usar Flutter app)
  bool get esPersonalMedico =>
      rol == RolUsuario.medico ||
      rol == RolUsuario.enfermera ||
      rol == RolUsuario.admin;

  /// Verificar si es médico
  bool get esMedico => rol == RolUsuario.medico;

  /// Verificar si es enfermera
  bool get esEnfermera => rol == RolUsuario.enfermera;

  /// Verificar si es administrador
  bool get esAdmin => rol == RolUsuario.admin || rol == RolUsuario.superAdmin;

  /// Verificar si tiene múltiples hospitales asignados
  bool get tieneMultiplesHospitales => hospitalesAsignados.length > 1;

  /// Obtener nombre completo
  String get nombreCompleto => displayName;

  /// Obtener rol como texto
  String get rolTexto => rol.displayName;

  // ========== PERMISOS ==========

  /// Permisos según rol
  bool get puedeRegistrarConsultas => esMedico || esEnfermera;
  bool get puedeEditarPacientes => esMedico || esAdmin;
  bool get puedeEliminarPacientes => esAdmin;
  bool get puedeVerEstadisticas => esMedico || esAdmin;
  bool get puedeGestionarUsuarios => esAdmin;
  bool get puedeRecetarMedicamentos => esMedico;
  bool get puedeOrdenarExamenes => esMedico;
  bool get puedeRegistrarHospitalizaciones => esMedico;

  /// Copiar con modificaciones
  Usuario copyWith({
    String? email,
    String? displayName,
    RolUsuario? rol,
    bool? activo,
    String? photoURL,
    String? telefono,
    String? idPaciente,
    String? idProfesional,
    List<String>? hospitalesAsignados,
    List<String>? especialidades,
    DateTime? ultimoAcceso,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Usuario(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      photoURL: photoURL ?? this.photoURL,
      telefono: telefono ?? this.telefono,
      idPaciente: idPaciente ?? this.idPaciente,
      idProfesional: idProfesional ?? this.idProfesional,
      hospitalesAsignados: hospitalesAsignados ?? this.hospitalesAsignados,
      especialidades: especialidades ?? this.especialidades,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, email: $email, displayName: $displayName, rol: ${rol.displayName})';
  }
}

