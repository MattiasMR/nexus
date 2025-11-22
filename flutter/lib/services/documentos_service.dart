import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Modelo para Documento
class Documento {
  final String? id;
  final String idPaciente;
  final String nombre;
  final TipoDocumento tipo;
  final String? url;
  final String? storagePath;
  final int? tamanio;
  final DateTime fecha;
  final DateTime createdAt;
  final DateTime updatedAt;

  Documento({
    this.id,
    required this.idPaciente,
    required this.nombre,
    required this.tipo,
    this.url,
    this.storagePath,
    this.tamanio,
    required this.fecha,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Documento.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Documento(
      id: doc.id,
      idPaciente: data['idPaciente'] ?? '',
      nombre: data['nombre'] ?? data['titulo'] ?? '', // Soportar ambos campos
      tipo: _tipoFromString(data['tipo'] ?? 'otro'),
      url: data['url'],
      storagePath: data['storagePath'],
      tamanio: data['tamanio'],
      fecha: (data['fecha'] as Timestamp).toDate(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'idPaciente': idPaciente,
      'nombre': nombre,
      'tipo': tipo.toString().split('.').last,
      if (url != null) 'url': url,
      if (storagePath != null) 'storagePath': storagePath,
      if (tamanio != null) 'tamanio': tamanio,
      'fecha': Timestamp.fromDate(fecha),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static TipoDocumento _tipoFromString(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'examen':
      case 'resultado_examen':
        return TipoDocumento.examen;
      case 'imagen':
        return TipoDocumento.imagen;
      case 'informe':
      case 'informe_medico':
        return TipoDocumento.informe;
      case 'certificado':
      case 'otro':
      default:
        return TipoDocumento.otro;
    }
  }

  String get tamanioFormateado {
    if (tamanio == null) return 'Desconocido';
    final kb = tamanio! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(0)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

enum TipoDocumento {
  examen,
  imagen,
  informe,
  otro,
}

/// Servicio para gestionar documentos
class DocumentosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'documentos';

  /// Obtener todos los documentos de un paciente
  Stream<List<Documento>> obtenerDocumentosPaciente(String idPaciente) {
    return _firestore
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Documento.fromFirestore(doc)).toList());
  }

  /// Obtener documentos por tipo
  Stream<List<Documento>> obtenerDocumentosPorTipo(
      String idPaciente, TipoDocumento tipo) {
    return _firestore
        .collection(_collection)
        .where('idPaciente', isEqualTo: idPaciente)
        .where('tipo', isEqualTo: tipo.toString().split('.').last)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Documento.fromFirestore(doc)).toList());
  }

  /// Subir documento
  Future<Documento> subirDocumento({
    required String idPaciente,
    required File archivo,
    required String nombre,
    required TipoDocumento tipo,
  }) async {
    try {
      // Crear path en Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = archivo.path.split('.').last;
      final storagePath = 'documentos/$idPaciente/$timestamp.$extension';

      // Subir archivo a Storage
      final uploadTask = _storage.ref(storagePath).putFile(archivo);
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      // Obtener tamaño del archivo
      final tamanio = await archivo.length();

      // Crear documento en Firestore
      final documento = Documento(
        idPaciente: idPaciente,
        nombre: nombre,
        tipo: tipo,
        url: url,
        storagePath: storagePath,
        tamanio: tamanio,
        fecha: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef =
          await _firestore.collection(_collection).add(documento.toFirestore());

      return documento.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Error al subir documento: $e');
      rethrow;
    }
  }

  /// Eliminar documento
  Future<void> eliminarDocumento(String documentoId, String? storagePath) async {
    try {
      // Eliminar de Firestore
      await _firestore.collection(_collection).doc(documentoId).delete();

      // Eliminar de Storage si existe
      if (storagePath != null && storagePath.isNotEmpty) {
        try {
          await _storage.ref(storagePath).delete();
        } catch (e) {
          debugPrint('Error al eliminar archivo de Storage: $e');
        }
      }
    } catch (e) {
      debugPrint('Error al eliminar documento: $e');
      rethrow;
    }
  }
}

extension DocumentoCopyWith on Documento {
  Documento copyWith({
    String? id,
    String? idPaciente,
    String? nombre,
    TipoDocumento? tipo,
    String? url,
    String? storagePath,
    int? tamanio,
    DateTime? fecha,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Documento(
      id: id ?? this.id,
      idPaciente: idPaciente ?? this.idPaciente,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      url: url ?? this.url,
      storagePath: storagePath ?? this.storagePath,
      tamanio: tamanio ?? this.tamanio,
      fecha: fecha ?? this.fecha,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
