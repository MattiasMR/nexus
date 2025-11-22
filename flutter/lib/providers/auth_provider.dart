import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

/// Estados de autenticación
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Provider para gestionar el estado de autenticación (APP DE PACIENTES)
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // Exponer auth service para acceso a métodos de preferencias
  AuthService get authService => _authService;

  AuthStatus _status = AuthStatus.initial;
  Usuario? _currentUser;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  Usuario? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;
  bool get hasError => _status == AuthStatus.error;

  /// Inicializar el provider verificando si hay sesión activa
  Future<void> initialize() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final firebaseUser = _authService.currentFirebaseUser;
      
      if (firebaseUser != null) {
        // Hay sesión activa, obtener datos del paciente
        final usuario = await _authService.getCurrentUserData();
        
        if (usuario != null && usuario.activo) {
          _currentUser = usuario;
          _status = AuthStatus.authenticated;
        } else {
          await _authService.signOut();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Error al inicializar auth: $e');
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }

  /// Iniciar sesión
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Autenticar con Firebase
      final usuario = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      _currentUser = usuario;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Registrar nuevo paciente
  Future<bool> signUp({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rut,
    required String telefono,
    String? fechaNacimiento,
    String? sexo,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final usuario = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        rut: rut,
        telefono: telefono,
        fechaNacimiento: fechaNacimiento,
        sexo: sexo,
      );

      _currentUser = usuario;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: ${e.toString()}';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'Error al cerrar sesión: ${e.toString()}';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  /// Enviar email de recuperación de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al enviar email: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Recargar datos del usuario
  Future<void> reloadUser() async {
    if (!isAuthenticated) return;

    try {
      final usuario = await _authService.getCurrentUserData();
      if (usuario != null) {
        _currentUser = usuario;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al recargar usuario: $e');
    }
  }

  /// Actualizar datos del perfil del usuario autenticado
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) {
      _errorMessage = 'No hay usuario autenticado';
      notifyListeners();
      return false;
    }

    try {
      final updatedUser = await _authService.updateUserProfile(_currentUser!.id, updates);
      _currentUser = updatedUser;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error al actualizar perfil: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Limpiar mensaje de error
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser != null 
          ? AuthStatus.authenticated 
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
  
  // ========== PERMISOS (PACIENTES) ==========
  // Esta app es solo para pacientes, estos métodos siempre retornan false
  
  /// Hospitales del usuario (pacientes no tienen múltiples hospitales)
  List<String> get userHospitals => [];
  
  /// Establecer hospital activo (no aplica para pacientes)
  void setActiveHospital(String hospitalId) {
    // Pacientes no manejan hospitales
  }
  
  /// ¿Puede ver estadísticas? (solo personal médico)
  bool puedeVerEstadisticas() => false;
  
  /// ¿Puede ordenar exámenes? (solo médicos)
  bool puedeOrdenarExamenes() => false;
  
  /// ¿Puede recetar medicamentos? (solo médicos)
  bool puedeRecetarMedicamentos() => false;
}
