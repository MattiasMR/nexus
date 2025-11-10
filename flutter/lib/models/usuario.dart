/// Roles de usuario en el sistema
enum RolUsuario {
  medico,
  enfermera,
  admin,
}

/// Modelo de Usuario del sistema
class Usuario {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final RolUsuario rol;
  final String? especialidad; // Para médicos
  final String? licencia; // Número de licencia profesional

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.rol,
    this.especialidad,
    this.licencia,
  });

  String get nombreCompleto => '$nombre $apellido';

  /// Permisos según rol
  bool get puedeRegistrarConsultas => rol == RolUsuario.medico || rol == RolUsuario.enfermera;
  bool get puedeEditarPacientes => rol == RolUsuario.medico || rol == RolUsuario.admin;
  bool get puedeEliminarPacientes => rol == RolUsuario.admin;
  bool get puedeVerEstadisticas => rol == RolUsuario.medico || rol == RolUsuario.admin;
  bool get puedeGestionarUsuarios => rol == RolUsuario.admin;
  bool get puedeRecetarMedicamentos => rol == RolUsuario.medico;
  bool get puedeOrdenarExamenes => rol == RolUsuario.medico;
  bool get puedeRegistrarHospitalizaciones => rol == RolUsuario.medico;

  String get rolTexto {
    switch (rol) {
      case RolUsuario.medico:
        return 'Médico';
      case RolUsuario.enfermera:
        return 'Enfermera';
      case RolUsuario.admin:
        return 'Administrador';
    }
  }

  /// Crear desde credenciales de login (temporal)
  factory Usuario.fromLogin(String email) {
    if (email == 'medico@nexus.com') {
      return Usuario(
        id: 'medico_1',
        nombre: 'Carlos',
        apellido: 'Ramírez',
        email: email,
        rol: RolUsuario.medico,
        especialidad: 'Medicina General',
        licencia: 'MED-12345',
      );
    } else if (email == 'enfermera@nexus.com') {
      return Usuario(
        id: 'enfermera_1',
        nombre: 'María',
        apellido: 'González',
        email: email,
        rol: RolUsuario.enfermera,
      );
    } else {
      return Usuario(
        id: 'admin_1',
        nombre: 'Admin',
        apellido: 'Sistema',
        email: email,
        rol: RolUsuario.admin,
      );
    }
  }
}
