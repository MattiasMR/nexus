import 'package:flutter/material.dart';
import '../models/usuario.dart';

/// Servicio singleton para gestionar el usuario actual
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Usuario? _usuarioActual;

  Usuario? get usuarioActual => _usuarioActual;
  bool get estaLogueado => _usuarioActual != null;

  void login(String email) {
    _usuarioActual = Usuario.fromLogin(email);
  }

  void logout() {
    _usuarioActual = null;
  }

  // Métodos de verificación de permisos
  bool puedeRegistrarConsultas() => _usuarioActual?.puedeRegistrarConsultas ?? false;
  bool puedeEditarPacientes() => _usuarioActual?.puedeEditarPacientes ?? false;
  bool puedeEliminarPacientes() => _usuarioActual?.puedeEliminarPacientes ?? false;
  bool puedeVerEstadisticas() => _usuarioActual?.puedeVerEstadisticas ?? false;
  bool puedeRecetarMedicamentos() => _usuarioActual?.puedeRecetarMedicamentos ?? false;
  bool puedeOrdenarExamenes() => _usuarioActual?.puedeOrdenarExamenes ?? false;
  bool puedeRegistrarHospitalizaciones() => _usuarioActual?.puedeRegistrarHospitalizaciones ?? false;

  void mostrarPermisosDenegados(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No tienes permisos para realizar esta acción (Rol: ${_usuarioActual?.rolTexto})'),
        backgroundColor: Colors.orange[700],
      ),
    );
  }
}
