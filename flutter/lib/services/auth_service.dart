import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../models/paciente.dart';

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
  static const String _prefsUserId = 'userId';
  static const String _prefsUserRole = 'userRole';
  static const String _prefsDisplayName = 'displayName';
  static const String _prefsEmail = 'email';
  static const String _prefsRut = 'rut';
  static const String _prefsPacienteId = 'pacienteId';
  static const String _prefsAuthToken = 'authToken';
  static const String _prefsRemember = 'remember_me';
  static const String _prefsLastEmail = 'last_email';

  /// Stream del usuario actual de Firebase Auth
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actual de Firebase Auth
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  /// Login oficial (solo pacientes)
  Future<PacienteCompleto> login(
    String email,
    String password, {
    bool rememberMe = false,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AuthException('No se pudo autenticar el usuario');
      }

      var usuarioDoc = await _firestore
          .collection('usuarios')
          .doc(firebaseUser.uid)
          .get();

      if (!usuarioDoc.exists) {
        // Auto-reparación: Crear perfil si no existe (ej. usuario creado en consola)
        final pacientesRef = _firestore.collection('pacientes');
        final nuevoPacienteDoc = await pacientesRef.add({
          'idUsuario': firebaseUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'medicamentosActuales': [],
          'alergias': [],
        });

        await _firestore.collection('usuarios').doc(firebaseUser.uid).set({
          'email': email,
          'displayName': firebaseUser.displayName ?? 'Usuario Nuevo',
          'rut': '',
          'telefono': '',
          'rol': 'paciente',
          'activo': true,
          'idPaciente': nuevoPacienteDoc.id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        usuarioDoc = await _firestore
            .collection('usuarios')
            .doc(firebaseUser.uid)
            .get();
      }

      final usuario = Usuario.fromFirestore(usuarioDoc);

      if (usuario.rol != 'paciente') {
        await _auth.signOut();
        throw AuthException(
          'Esta aplicación es solo para pacientes.',
          'invalid-role',
        );
      }

      if (!usuario.activo) {
        await _auth.signOut();
        throw AuthException(
          'Tu cuenta está desactivada. Contacta al administrador.',
          'user-inactive',
        );
      }

      if (usuario.idPaciente == null) {
        await _auth.signOut();
        throw AuthException(
          'No existe un registro de paciente asociado.',
          'patient-not-linked',
        );
      }

      final pacienteDoc = await _firestore
          .collection('pacientes')
          .doc(usuario.idPaciente)
          .get();

      if (!pacienteDoc.exists) {
        await _auth.signOut();
        throw AuthException(
          'Datos médicos no encontrados para este usuario.',
          'patient-not-found',
        );
      }

      final paciente = Paciente.fromFirestore(pacienteDoc);

      await _persistSession(
        usuario,
        paciente,
        token: await firebaseUser.getIdToken(),
        rememberMe: rememberMe,
        emailForRemember: email,
      );

      return PacienteCompleto(usuario: usuario, paciente: paciente);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al iniciar sesión: ${e.toString()}');
    }
  }

  /// Registro básico respetando la arquitectura normalizada
  Future<PacienteCompleto> signUpWithEmailAndPassword({
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        throw AuthException('No se pudo crear el usuario');
      }

      final usuariosRef = _firestore.collection('usuarios').doc(uid);
      final pacientesRef = _firestore.collection('pacientes');

      await usuariosRef.set({
        'email': email,
        'displayName': '$nombre $apellido'.trim(),
        'rut': rut,
        'telefono': telefono,
        'rol': 'paciente',
        'activo': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final pacienteDoc = await pacientesRef.add({
        'idUsuario': uid,
        if (fechaNacimiento != null)
          'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
        'sexo': sexo,
        'prevision': prevision,
        'direccion': direccion,
        'contactoEmergencia':
            (contactoEmergenciaNombre != null ||
                contactoEmergenciaTelefono != null)
            ? {
                if (contactoEmergenciaNombre != null)
                  'nombre': contactoEmergenciaNombre,
                if (contactoEmergenciaTelefono != null)
                  'telefono': contactoEmergenciaTelefono,
              }
            : null,
        'medicamentosActuales': [],
        'alergias': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await usuariosRef.update({'idPaciente': pacienteDoc.id});

      final usuario = Usuario.fromFirestore(await usuariosRef.get());
      final paciente = Paciente.fromFirestore(await pacienteDoc.get());

      await _persistSession(
        usuario,
        paciente,
        token: await credential.user?.getIdToken(),
        rememberMe: true,
        emailForRemember: email,
      );

      return PacienteCompleto(usuario: usuario, paciente: paciente);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Error al registrar usuario: ${e.toString()}');
    }
  }

  /// Cerrar sesión y limpiar caché
  Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsUserId);
    await prefs.remove(_prefsUserRole);
    await prefs.remove(_prefsDisplayName);
    await prefs.remove(_prefsEmail);
    await prefs.remove(_prefsRut);
    await prefs.remove(_prefsPacienteId);
    await prefs.remove(_prefsAuthToken);
  }

  /// Enviar email para restablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Error al enviar email de recuperación: $e');
    }
  }

  Future<Usuario?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final doc = await _firestore
          .collection('usuarios')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) return null;
      return Usuario.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error obteniendo usuario actual: $e');
      return null;
    }
  }

  Future<Paciente?> getCurrentPaciente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pacienteId = prefs.getString(_prefsPacienteId);
      if (pacienteId == null) return null;

      final doc = await _firestore
          .collection('pacientes')
          .doc(pacienteId)
          .get();
      if (!doc.exists) return null;
      return Paciente.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error obteniendo paciente actual: $e');
      return null;
    }
  }

  Future<PacienteCompleto?> getPacienteCompleto() async {
    final usuario = await getCurrentUser();
    final paciente = await getCurrentPaciente();
    if (usuario == null || paciente == null) return null;
    return PacienteCompleto(usuario: usuario, paciente: paciente);
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsUserId) != null && _auth.currentUser != null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsAuthToken);
  }

  Future<void> refreshPacienteData() async {
    final usuario = await getCurrentUser();
    if (usuario == null || usuario.idPaciente == null) return;

    final pacienteDoc = await _firestore
        .collection('pacientes')
        .doc(usuario.idPaciente)
        .get();

    if (pacienteDoc.exists) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsPacienteId, pacienteDoc.id);
    }
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? telefono,
    String? photoURL,
    String? rut,
  }) async {
    final usuario = await getCurrentUser();
    if (usuario == null) {
      throw AuthException('No hay usuario autenticado');
    }

    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (displayName != null) updates['displayName'] = displayName;
    if (telefono != null) updates['telefono'] = telefono;
    if (photoURL != null) updates['photoURL'] = photoURL;
    if (rut != null) updates['rut'] = rut;

    await _firestore.collection('usuarios').doc(usuario.id).update(updates);

    final prefs = await SharedPreferences.getInstance();
    if (displayName != null) {
      await prefs.setString(_prefsDisplayName, displayName);
    }
    if (rut != null) {
      await prefs.setString(_prefsRut, rut);
    }
  }

  Future<void> updatePacienteData(Map<String, dynamic> data) async {
    final paciente = await getCurrentPaciente();
    if (paciente == null) {
      throw AuthException('No existe ficha médica asociada');
    }

    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('pacientes').doc(paciente.id).update(data);
  }

  // Preferencias "Recordar sesión"
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsRemember) ?? false;
  }

  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsLastEmail);
  }

  Future<void> _persistSession(
    Usuario usuario,
    Paciente paciente, {
    String? token,
    bool rememberMe = false,
    String? emailForRemember,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsUserId, usuario.id);
    await prefs.setString(_prefsUserRole, usuario.rol);
    await prefs.setString(_prefsDisplayName, usuario.displayName);
    await prefs.setString(_prefsEmail, usuario.email);
    await prefs.setString(_prefsRut, usuario.rut);
    await prefs.setString(_prefsPacienteId, paciente.id ?? '');
    if (token != null) {
      await prefs.setString(_prefsAuthToken, token);
    }

    if (rememberMe && emailForRemember != null) {
      await prefs.setBool(_prefsRemember, true);
      await prefs.setString(_prefsLastEmail, emailForRemember);
    } else {
      await prefs.remove(_prefsRemember);
      await prefs.remove(_prefsLastEmail);
    }
  }

  AuthException _handleFirebaseAuthException(
    firebase_auth.FirebaseAuthException e,
  ) {
    String message;
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
        break;
    }

    return AuthException(message, e.code);
  }
}
