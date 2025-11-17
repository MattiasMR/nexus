import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../models/hospital.dart';

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, [this.code = 'unknown']);

  @override
  String toString() => message;
}

/// Servicio de autenticación con Firebase
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Keys para SharedPreferences
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastEmail = 'last_email';
  static const String _keyLastHospitalId = 'last_hospital_id';

  /// Stream del usuario actual de Firebase Auth
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actual de Firebase Auth
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Iniciar sesión con email y contraseña
  Future<Usuario> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Autenticar con Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('No se pudo obtener el usuario');
      }

      // Obtener datos del usuario desde Firestore
      final userDoc = await _firestore
          .collection('usuarios')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Si no existe en Firestore, cerrar sesión y lanzar error
        await _auth.signOut();
        throw AuthException(
          'Usuario no encontrado en el sistema',
          'user-not-found-firestore',
        );
      }

      final usuario = Usuario.fromFirestore(userDoc);

      // Verificar que el usuario esté activo
      if (!usuario.activo) {
        await _auth.signOut();
        throw AuthException(
          'Usuario inactivo. Contacte al administrador',
          'user-inactive',
        );
      }

      // Verificar que sea personal médico (solo ellos usan Flutter)
      if (!usuario.esPersonalMedico) {
        await _auth.signOut();
        throw AuthException(
          'Acceso denegado. Esta aplicación es solo para personal médico',
          'access-denied',
        );
      }

      // Verificar que tenga hospitales asignados
      if (usuario.hospitalesAsignados.isEmpty) {
        await _auth.signOut();
        throw AuthException(
          'No tiene hospitales asignados. Contacte al administrador',
          'no-hospitals',
        );
      }

      // Actualizar último acceso en Firestore
      await _firestore.collection('usuarios').doc(usuario.id).update({
        'ultimoAcceso': FieldValue.serverTimestamp(),
      });

      // Guardar preferencias si "recordar sesión" está activado
      if (rememberMe) {
        await _saveLoginPreferences(email);
      } else {
        await _clearLoginPreferences();
      }

      return usuario;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al iniciar sesión: ${e.toString()}');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // No limpiamos las preferencias para mantener "recordar sesión"
    } catch (e) {
      throw AuthException('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Enviar email para restablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        'Error al enviar email de recuperación: ${e.toString()}',
      );
    }
  }

  /// Obtener datos completos del usuario actual
  Future<Usuario?> getCurrentUserData() async {
    try {
      final firebaseUser = currentFirebaseUser;
      if (firebaseUser == null) return null;

      final userDoc =
          await _firestore.collection('usuarios').doc(firebaseUser.uid).get();

      if (!userDoc.exists) return null;

      return Usuario.fromFirestore(userDoc);
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  /// Obtener hospitales asignados al usuario
  Future<List<Hospital>> getUserHospitals(List<String> hospitalIds) async {
    if (hospitalIds.isEmpty) return [];

    try {
      final hospitalsSnapshot = await _firestore
          .collection('hospitales')
          .where(FieldPath.documentId, whereIn: hospitalIds)
          .where('activo', isEqualTo: true)
          .get();

      return hospitalsSnapshot.docs
          .map((doc) => Hospital.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al obtener hospitales: $e');
      return [];
    }
  }

  /// Obtener hospital por ID
  Future<Hospital?> getHospitalById(String hospitalId) async {
    try {
      final hospitalDoc =
          await _firestore.collection('hospitales').doc(hospitalId).get();

      if (!hospitalDoc.exists) return null;

      return Hospital.fromFirestore(hospitalDoc);
    } catch (e) {
      print('Error al obtener hospital: $e');
      return null;
    }
  }

  // ========== PREFERENCIAS ==========

  /// Verificar si "recordar sesión" está activado
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Obtener último email guardado
  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastEmail);
  }

  /// Guardar último hospital seleccionado
  Future<void> saveLastHospitalId(String hospitalId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastHospitalId, hospitalId);
  }

  /// Obtener último hospital seleccionado
  Future<String?> getLastHospitalId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastHospitalId);
  }

  /// Guardar preferencias de login
  Future<void> _saveLoginPreferences(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, true);
    await prefs.setString(_keyLastEmail, email);
  }

  /// Limpiar preferencias de login
  Future<void> _clearLoginPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberMe);
    await prefs.remove(_keyLastEmail);
  }

  // ========== MANEJO DE ERRORES ==========

  /// Convertir excepciones de Firebase a mensajes legibles
  AuthException _handleFirebaseAuthException(
      firebase_auth.FirebaseAuthException e) {
    String message;
    String code = e.code;

    switch (e.code) {
      case 'invalid-email':
        message = 'El correo electrónico no es válido';
        break;
      case 'user-disabled':
        message = 'Esta cuenta ha sido deshabilitada';
        break;
      case 'user-not-found':
        message = 'No existe una cuenta con este correo electrónico';
        break;
      case 'wrong-password':
        message = 'Contraseña incorrecta';
        break;
      case 'email-already-in-use':
        message = 'Ya existe una cuenta con este correo electrónico';
        break;
      case 'operation-not-allowed':
        message = 'Operación no permitida';
        break;
      case 'weak-password':
        message = 'La contraseña es demasiado débil';
        break;
      case 'invalid-credential':
        message = 'Credenciales inválidas. Verifica tu email y contraseña';
        break;
      case 'too-many-requests':
        message = 'Demasiados intentos fallidos. Intenta más tarde';
        break;
      case 'network-request-failed':
        message = 'Error de conexión. Verifica tu internet';
        break;
      default:
        message = 'Error de autenticación: ${e.message ?? e.code}';
    }

    return AuthException(message, code);
  }
}

