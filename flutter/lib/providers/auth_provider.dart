import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/paciente.dart';
import '../services/auth_service.dart';

/// Estados de autenticación
enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

/// Provider para gestionar el estado de autenticación (APP DE PACIENTES)
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  Usuario? _currentUser;
  Paciente? _currentPaciente;
  String? _errorMessage;

  AuthStatus get status => _status;
  Usuario? get currentUser => _currentUser;
  Paciente? get currentPaciente => _currentPaciente;
  PacienteCompleto? get pacienteCompleto =>
      (_currentUser != null && _currentPaciente != null)
      ? PacienteCompleto(usuario: _currentUser!, paciente: _currentPaciente!)
      : null;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;
  bool get hasError => _status == AuthStatus.error;

  Future<bool> getRememberMePreference() => _authService.getRememberMe();
  Future<String?> getLastEmailPreference() => _authService.getLastEmail();

  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final completo = await _authService.getPacienteCompleto();
      if (completo != null) {
        _currentUser = completo.usuario;
        _currentPaciente = completo.paciente;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Error al inicializar auth: $e');
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final completo = await _authService.login(
        email,
        password,
        rememberMe: rememberMe,
      );
      _currentUser = completo.usuario;
      _currentPaciente = completo.paciente;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rut,
    required String telefono,
    DateTime? fechaNacimiento,
    String? sexo,
    String? direccion,
    String? prevision,
    String? contactoEmergenciaNombre,
    String? contactoEmergenciaTelefono,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final completo = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        rut: rut,
        telefono: telefono,
        fechaNacimiento: fechaNacimiento,
        sexo: sexo,
        direccion: direccion,
        prevision: prevision,
        contactoEmergenciaNombre: contactoEmergenciaNombre,
        contactoEmergenciaTelefono: contactoEmergenciaTelefono,
      );
      _currentUser = completo.usuario;
      _currentPaciente = completo.paciente;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _currentPaciente = null;
      _errorMessage = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: $e';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al enviar email: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> reloadUser() async {
    if (!isAuthenticated) return;

    try {
      final usuario = await _authService.getCurrentUser();
      final paciente = await _authService.getCurrentPaciente();
      if (usuario != null && paciente != null) {
        _currentUser = usuario;
        _currentPaciente = paciente;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al recargar sesión: $e');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null || _currentPaciente == null) {
      _errorMessage = 'No hay sesión activa';
      notifyListeners();
      return false;
    }

    final userUpdates = <String, dynamic>{};
    final pacienteUpdates = <String, dynamic>{};

    if (updates.containsKey('displayName')) {
      userUpdates['displayName'] = updates['displayName'];
    }
    if (updates.containsKey('telefono')) {
      userUpdates['telefono'] = updates['telefono'];
    }
    if (updates.containsKey('rut')) {
      userUpdates['rut'] = updates['rut'];
    }

    if (updates.containsKey('direccion')) {
      pacienteUpdates['direccion'] = updates['direccion'];
    }
    if (updates.containsKey('prevision')) {
      pacienteUpdates['prevision'] = updates['prevision'];
    }

    // Contacto de emergencia (guardar como objeto)
    if (updates.containsKey('contactoEmergencia') ||
        updates.containsKey('telefonoEmergencia')) {
      final contacto = Map<String, dynamic>.from(
        _currentPaciente?.contactoEmergencia ?? {},
      );
      if (updates.containsKey('contactoEmergencia')) {
        contacto['nombre'] = updates['contactoEmergencia'];
      }
      if (updates.containsKey('telefonoEmergencia')) {
        contacto['telefono'] = updates['telefonoEmergencia'];
      }
      pacienteUpdates['contactoEmergencia'] = contacto;
    }

    // Cualquier otro campo se envía directo a pacientes
    for (final entry in updates.entries) {
      if (![
        'displayName',
        'telefono',
        'direccion',
        'prevision',
        'contactoEmergencia',
        'telefonoEmergencia',
      ].contains(entry.key)) {
        pacienteUpdates[entry.key] = entry.value;
      }
    }

    try {
      if (userUpdates.isNotEmpty) {
        await _authService.updateUserProfile(
          displayName: userUpdates['displayName'] as String?,
          telefono: userUpdates['telefono'] as String?,
          rut: userUpdates['rut'] as String?,
        );
      }

      if (pacienteUpdates.isNotEmpty) {
        await _authService.updatePacienteData(pacienteUpdates);
      }

      await reloadUser();
      _errorMessage = null;
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = isAuthenticated
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ========== PERMISOS (PACIENTES) ==========
  List<String> get userHospitals => [];
  void setActiveHospital(String hospitalId) {}
  bool puedeVerEstadisticas() => false;
  bool puedeOrdenarExamenes() => false;
  bool puedeRecetarMedicamentos() => false;
}
