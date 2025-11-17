import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para verificar permisos granulares de usuarios
class PermisosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verificar si un usuario tiene un permiso específico en un hospital
  Future<bool> verificarPermiso({
    required String idUsuario,
    required String idHospital,
    required String permiso,
  }) async {
    try {
      // Obtener documento de permisos
      final permisoDoc = await _firestore
          .collection('permisos-usuario')
          .where('idUsuario', isEqualTo: idUsuario)
          .where('idHospital', isEqualTo: idHospital)
          .limit(1)
          .get();

      if (permisoDoc.docs.isEmpty) {
        return false;
      }

      final data = permisoDoc.docs.first.data();
      final permisos = List<String>.from(data['permisos'] ?? []);
      final fechaFin = data['fechaFin'] as Timestamp?;

      // Verificar si está activo
      if (fechaFin != null && fechaFin.toDate().isBefore(DateTime.now())) {
        return false;
      }

      // Verificar si tiene el permiso
      return permisos.contains(permiso);
    } catch (e) {
      print('Error al verificar permiso: $e');
      return false;
    }
  }

  /// Verificar múltiples permisos a la vez
  Future<Map<String, bool>> verificarPermisos({
    required String idUsuario,
    required String idHospital,
    required List<String> permisos,
  }) async {
    final resultado = <String, bool>{};

    for (final permiso in permisos) {
      resultado[permiso] = await verificarPermiso(
        idUsuario: idUsuario,
        idHospital: idHospital,
        permiso: permiso,
      );
    }

    return resultado;
  }

  /// Obtener todos los permisos de un usuario en un hospital
  Future<List<String>> obtenerPermisos({
    required String idUsuario,
    required String idHospital,
  }) async {
    try {
      final permisoDoc = await _firestore
          .collection('permisos-usuario')
          .where('idUsuario', isEqualTo: idUsuario)
          .where('idHospital', isEqualTo: idHospital)
          .limit(1)
          .get();

      if (permisoDoc.docs.isEmpty) {
        return [];
      }

      final data = permisoDoc.docs.first.data();
      return List<String>.from(data['permisos'] ?? []);
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }

  /// Verificar si el usuario tiene acceso total (super admin)
  Future<bool> tieneAccesoTotal(String idUsuario) async {
    try {
      final userDoc =
          await _firestore.collection('usuarios').doc(idUsuario).get();

      if (!userDoc.exists) return false;

      final rol = userDoc.data()?['rol'];
      return rol == 'super_admin';
    } catch (e) {
      print('Error al verificar acceso total: $e');
      return false;
    }
  }
}
