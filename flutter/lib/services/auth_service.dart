import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/usuario.dart';

/// Excepción personalizada para errores de autenticación
class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, [this.code = 'unknown']);

  @override
  String toString() => message;
}

/// Servicio de autenticación con Firebase (APP DE PACIENTES)
class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Keys para SharedPreferences
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastEmail = 'last_email';

  /// Stream del usuario actual de Firebase Auth
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actual de Firebase Auth
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Iniciar sesión con email y contraseña (PACIENTES)
  Future<Usuario> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      debugPrint('🔐 [AUTH_SERVICE] Iniciando autenticación para: $email');
      
      // Autenticar con Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        debugPrint('❌ [AUTH_SERVICE] Credential.user es null');
        throw AuthException('No se pudo obtener el usuario');
      }

      debugPrint('✅ [AUTH_SERVICE] Usuario autenticado en Firebase Auth: ${credential.user!.uid}');

      // Obtener datos del paciente desde Firestore
      debugPrint('🔍 [AUTH_SERVICE] Buscando paciente en Firestore con UID: ${credential.user!.uid}');
      final userDoc = await _firestore
          .collection('pacientes')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Si no existe en Firestore, cerrar sesión y lanzar error
        debugPrint('❌ [AUTH_SERVICE] Documento de paciente NO existe en Firestore');
        await _auth.signOut();
        throw AuthException(
          'Usuario no encontrado en el sistema',
          'user-not-found-firestore',
        );
      }

      debugPrint('✅ [AUTH_SERVICE] Documento encontrado en Firestore');
      final usuario = Usuario.fromFirestore(userDoc);
      debugPrint('👤 [AUTH_SERVICE] Usuario: ${usuario.nombreCompleto}, Activo: ${usuario.activo}');

      // Verificar que el usuario esté activo
      if (!usuario.activo) {
        debugPrint('❌ [AUTH_SERVICE] Usuario inactivo');
        await _auth.signOut();
        throw AuthException(
          'Usuario inactivo. Contacte al administrador',
          'user-inactive',
        );
      }

      // Actualizar último acceso en Firestore
      debugPrint('📝 [AUTH_SERVICE] Actualizando último acceso...');
      await _firestore.collection('pacientes').doc(usuario.id).update({
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
      debugPrint('❌ [AUTH_SERVICE] FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      debugPrint('❌ [AUTH_SERVICE] Error genérico: $e');
      if (e is AuthException) rethrow;
      throw AuthException('Error al iniciar sesión: ${e.toString()}');
    }
  }

  /// Registrar nuevo paciente
  Future<Usuario> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String rut,
    required String telefono,
    String? fechaNacimiento,
    String? sexo,
  }) async {
    try {
      // Crear usuario en Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthException('No se pudo crear el usuario');
      }

      final uid = credential.user!.uid;
      final now = DateTime.now();

      // Crear documento en Firestore (colección pacientes)
      final usuarioData = {
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        'rut': rut,
        'telefono': telefono,
        'fechaNacimiento': fechaNacimiento,
        'sexo': sexo,
        'activo': true,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      await _firestore.collection('pacientes').doc(uid).set(usuarioData);

      // Crear Usuario desde los datos
      final usuario = Usuario(
        id: uid,
        email: email,
        nombre: nombre,
        apellido: apellido,
        rut: rut,
        telefono: telefono,
        activo: true,
        fechaNacimiento: fechaNacimiento,
        sexo: sexo,
        createdAt: now,
        updatedAt: now,
      );

      return usuario;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al registrar usuario: ${e.toString()}');
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
          await _firestore.collection('pacientes').doc(firebaseUser.uid).get();

      if (!userDoc.exists) return null;

      return Usuario.fromFirestore(userDoc);
    } catch (e) {
      debugPrint('Error al obtener datos del usuario: $e');
      return null;
    }
  }

  /// Actualizar datos del perfil del paciente autenticado
  Future<Usuario> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.now();
      await _firestore.collection('pacientes').doc(userId).update(updates);

      final snapshot = await _firestore.collection('pacientes').doc(userId).get();
      return Usuario.fromFirestore(snapshot);
    } on FirebaseException catch (e) {
      throw AuthException(
        'No se pudo actualizar el perfil: ${e.message ?? e.code}',
        e.code,
      );
    } catch (e) {
      throw AuthException('Error al actualizar perfil: ${e.toString()}');
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

