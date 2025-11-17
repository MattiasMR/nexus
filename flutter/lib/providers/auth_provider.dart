import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/hospital.dart';
import '../services/auth_service.dart';

/// Estados de autenticación
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Provider para gestionar el estado de autenticación
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // Exponer auth service para acceso a métodos de preferencias
  AuthService get authService => _authService;

  AuthStatus _status = AuthStatus.initial;
  Usuario? _currentUser;
  List<Hospital> _userHospitals = [];
  Hospital? _activeHospital;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  Usuario? get currentUser => _currentUser;
  List<Hospital> get userHospitals => _userHospitals;
  Hospital? get activeHospital => _activeHospital;
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
        // Hay sesión activa, obtener datos del usuario
        final usuario = await _authService.getCurrentUserData();
        
        if (usuario != null && usuario.esPersonalMedico) {
          _currentUser = usuario;
          
          // Cargar hospitales asignados
          await _loadUserHospitals();
          
          // Cargar último hospital seleccionado
          await _loadLastHospital();
          
          _status = AuthStatus.authenticated;
        } else {
          await _authService.signOut();
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('Error al inicializar auth: $e');
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
      
      // Cargar hospitales asignados
      await _loadUserHospitals();
      
      // Si tiene un solo hospital, seleccionarlo automáticamente
      if (_userHospitals.length == 1) {
        await setActiveHospital(_userHospitals.first);
        _status = AuthStatus.authenticated;
      } else {
        // Si tiene múltiples, intentar cargar el último seleccionado
        await _loadLastHospital();
        
        // Si no hay hospital activo, requiere selección manual
        _status = AuthStatus.authenticated;
      }

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
      _userHospitals = [];
      _activeHospital = null;
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

  /// Establecer hospital activo
  Future<void> setActiveHospital(Hospital hospital) async {
    _activeHospital = hospital;
    await _authService.saveLastHospitalId(hospital.id);
    notifyListeners();
  }

  /// Verificar si necesita seleccionar hospital
  bool get needsHospitalSelection {
    return isAuthenticated && 
           _userHospitals.length > 1 && 
           _activeHospital == null;
  }

  /// Cargar hospitales del usuario
  Future<void> _loadUserHospitals() async {
    if (_currentUser == null) return;

    try {
      _userHospitals = await _authService.getUserHospitals(
        _currentUser!.hospitalesAsignados,
      );
    } catch (e) {
      print('Error al cargar hospitales: $e');
      _userHospitals = [];
    }
  }

  /// Cargar último hospital seleccionado
  Future<void> _loadLastHospital() async {
    if (_userHospitals.isEmpty) return;

    try {
      final lastHospitalId = await _authService.getLastHospitalId();
      
      if (lastHospitalId != null) {
        final hospital = _userHospitals.firstWhere(
          (h) => h.id == lastHospitalId,
          orElse: () => _userHospitals.first,
        );
        _activeHospital = hospital;
      } else if (_userHospitals.isNotEmpty) {
        // Si no hay último hospital, seleccionar el primero
        _activeHospital = _userHospitals.first;
        await _authService.saveLastHospitalId(_activeHospital!.id);
      }
    } catch (e) {
      print('Error al cargar último hospital: $e');
      if (_userHospitals.isNotEmpty) {
        _activeHospital = _userHospitals.first;
      }
    }
  }

  /// Recargar datos del usuario
  Future<void> reloadUser() async {
    if (!isAuthenticated) return;

    try {
      final usuario = await _authService.getCurrentUserData();
      if (usuario != null) {
        _currentUser = usuario;
        await _loadUserHospitals();
        notifyListeners();
      }
    } catch (e) {
      print('Error al recargar usuario: $e');
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

  // ========== PERMISOS ==========

  /// Verificar si puede realizar una acción
  bool puedeRegistrarConsultas() => _currentUser?.puedeRegistrarConsultas ?? false;
  bool puedeEditarPacientes() => _currentUser?.puedeEditarPacientes ?? false;
  bool puedeEliminarPacientes() => _currentUser?.puedeEliminarPacientes ?? false;
  bool puedeVerEstadisticas() => _currentUser?.puedeVerEstadisticas ?? false;
  bool puedeRecetarMedicamentos() => _currentUser?.puedeRecetarMedicamentos ?? false;
  bool puedeOrdenarExamenes() => _currentUser?.puedeOrdenarExamenes ?? false;
  bool puedeRegistrarHospitalizaciones() => _currentUser?.puedeRegistrarHospitalizaciones ?? false;
}
