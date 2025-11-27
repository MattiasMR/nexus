import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../models/examen.dart';
import '../../providers/auth_provider.dart';
import '../../services/documentos_service.dart' show Documento, TipoDocumento;
import '../../services/examenes_service.dart';
import '../../utils/app_colors.dart';

/// Página para revisar exámenes médicos del paciente
class MisExamenesPage extends StatefulWidget {
  const MisExamenesPage({super.key});

  @override
  State<MisExamenesPage> createState() => _MisExamenesPageState();
}

class _MisExamenesPageState extends State<MisExamenesPage> {
  final ExamenesService _examenesService = ExamenesService();
  String _filtroActual = 'Examen';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final usuario = authProvider.currentUser;

    if (usuario == null || usuario.idPaciente == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario o ID de paciente no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Exámenes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filtroActual = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Todos', child: Text('Todos')),
              const PopupMenuItem(value: 'Examen', child: Text('Exámenes')),
              const PopupMenuItem(value: 'Imagen', child: Text('Imágenes')),
              const PopupMenuItem(value: 'Informe', child: Text('Informes')),
              const PopupMenuItem(value: 'Otro', child: Text('Otros')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Documento>>(
        stream: _obtenerExamenesPaciente(usuario.idPaciente!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final documentos = snapshot.data ?? [];
          final documentosFiltrados = _filtroActual == 'Todos'
              ? documentos
              : documentos
                  .where((d) => _getTipoTexto(d.tipo) == _filtroActual)
                  .toList();

          if (documentosFiltrados.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documentosFiltrados.length,
            itemBuilder: (context, index) {
              final documento = documentosFiltrados[index];
              return _buildExamenCard(documento);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _filtroActual == 'Todos'
                ? 'No tienes exámenes disponibles'
                : 'No hay exámenes de tipo $_filtroActual',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los exámenes que suba tu equipo médico en Ionic aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamenCard(Documento documento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _mostrarDetalleExamen(documento),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTipoColor(documento.tipo).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTipoIcono(documento.tipo),
                  color: _getTipoColor(documento.tipo),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documento.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatFecha(documento.fecha),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.file_present,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          documento.tamanioFormateado,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (documento.url == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          'Aún no hay archivo adjunto',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, documento),
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'ver',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20),
                        SizedBox(width: 12),
                        Text('Ver'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'descargar',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 12),
                        Text('Descargar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleExamen(Documento documento) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTipoColor(documento.tipo).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTipoIcono(documento.tipo),
                    color: _getTipoColor(documento.tipo),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documento.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTipoTexto(documento.tipo),
                        style: TextStyle(
                          fontSize: 13,
                          color: _getTipoColor(documento.tipo),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow(Icons.calendar_today, 'Fecha de subida',
                _formatFecha(documento.fecha)),
            const SizedBox(height: 12),
            _buildDetailRow(
                Icons.file_present, 'Tamaño', documento.tamanioFormateado),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                       await _abrirExamen(documento);
                    },
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                       await _descargarExamen(documento);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Documento>> _obtenerExamenesPaciente(String idPaciente) {
    return _examenesService
        .getOrdenesByPaciente(idPaciente)
        .map(_ordenesADocumentos);
  }

  List<Documento> _ordenesADocumentos(List<OrdenExamen> ordenes) {
    final resultados = <Documento>[];

    for (final orden in ordenes) {
      if (orden.examenes.isEmpty) {
        continue;
      }

      for (final examen in orden.examenes) {
        final documentos = examen.documentos;

        if (documentos.isEmpty) {
          resultados.add(
            Documento(
              id: '${orden.id ?? 'sinId'}_${examen.idExamen}',
              idPaciente: orden.idPaciente,
              nombre: examen.nombreExamen.isNotEmpty
                  ? examen.nombreExamen
                  : 'Examen sin nombre',
              tipo: TipoDocumento.examen,
              url: null,
              storagePath: null,
              tamanio: null,
              fecha: orden.fecha,
              createdAt: orden.createdAt ?? orden.fecha,
              updatedAt: orden.updatedAt ?? orden.fecha,
            ),
          );
          continue;
        }

        for (var i = 0; i < documentos.length; i++) {
          final adjunto = documentos[i];
          resultados.add(
            Documento(
              id: '${orden.id ?? 'sinId'}_${examen.idExamen}_$i',
              idPaciente: orden.idPaciente,
              nombre: _resolverNombreAdjunto(adjunto, examen.nombreExamen),
              tipo: _inferirTipoDesdeMime(
                adjunto.tipo,
                nombreArchivo: adjunto.nombre,
              ),
              url: adjunto.url.isNotEmpty ? adjunto.url : null,
              storagePath: null,
              tamanio: adjunto.tamanio,
              fecha: adjunto.fechaSubida,
              createdAt: adjunto.fechaSubida,
              updatedAt: adjunto.fechaSubida,
            ),
          );
        }
      }
    }

    resultados.sort((a, b) => b.fecha.compareTo(a.fecha));
    return resultados;
  }

  String _resolverNombreAdjunto(DocumentoExamen adjunto, String nombreExamen) {
    if (adjunto.nombre.trim().isNotEmpty) {
      return adjunto.nombre.trim();
    }
    if (nombreExamen.trim().isNotEmpty) {
      return nombreExamen.trim();
    }
    return 'Examen sin nombre';
  }

  TipoDocumento _inferirTipoDesdeMime(String? mimeType, {String? nombreArchivo}) {
    final mime = mimeType?.toLowerCase() ?? '';
    final nombre = nombreArchivo?.toLowerCase() ?? '';

    if (mime.startsWith('image/') || nombre.endsWith('.png') || nombre.endsWith('.jpg') || nombre.endsWith('.jpeg')) {
      return TipoDocumento.imagen;
    }

    if (mime.contains('pdf') || nombre.endsWith('.pdf')) {
      return TipoDocumento.informe;
    }

    if (mime.contains('report') || nombre.contains('informe')) {
      return TipoDocumento.informe;
    }

    return TipoDocumento.examen;
  }

  Future<Uint8List> _obtenerBytesExamen(String url) async {
    if (url.startsWith('data:')) {
      return UriData.parse(url).contentAsBytes();
    } else {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout al descargar el examen');
        },
      );
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    }
  }

  Future<void> _abrirExamen(Documento documento) async {
    if (documento.url == null) {
      _mostrarMensaje('URL del examen no disponible');
      return;
    }

    try {
      debugPrint('📄 Abriendo examen: ${documento.nombre}');
      _mostrarMensaje('Procesando examen...');

      final bytes = await _obtenerBytesExamen(documento.url!);

      final directory = await getApplicationDocumentsDirectory();
      final docsDir = Directory('${directory.path}\\Examenes');

      if (!await docsDir.exists()) {
        await docsDir.create(recursive: true);
      }

      final fileName = documento.nombre
          .replaceAll(RegExp(r'[^\w\s-]'), '_')
          .replaceAll(' ', '_');
      
      // Determinar extensión
      String extension = '.pdf';
      if (documento.url!.startsWith('data:image/png')) extension = '.png';
      if (documento.url!.startsWith('data:image/jpeg')) extension = '.jpg';
      if (documento.nombre.toLowerCase().endsWith('.png')) extension = '.png';
      if (documento.nombre.toLowerCase().endsWith('.jpg')) extension = '.jpg';
      
      final filePath = '${docsDir.path}\\$fileName$extension';
      final file = File(filePath);

      await file.writeAsBytes(bytes);
      debugPrint('✅ Examen guardado en: $filePath');

      if (await file.exists()) {
        final uri = Uri.file(filePath);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (launched) {
          _mostrarMensaje('✓ Examen abierto correctamente');
        } else {
          _mostrarMensaje('Examen guardado en: ${docsDir.path}');
          await launchUrl(Uri.file(docsDir.path));
        }
      }
    } catch (e) {
      debugPrint('❌ Error al abrir examen: $e');
      _mostrarMensaje('Error al abrir examen: $e');
    }
  }

  Future<void> _descargarExamen(Documento documento) async {
    if (documento.url == null) {
      _mostrarMensaje('URL del examen no disponible');
      return;
    }

    try {
      debugPrint('💾 Descargando examen: ${documento.nombre}');
      _mostrarMensaje('Descargando examen...');

      final bytes = await _obtenerBytesExamen(documento.url!);

      final directory = await getApplicationDocumentsDirectory();
      final docsDir = Directory('${directory.path}\\Examenes');

      if (!await docsDir.exists()) {
        await docsDir.create(recursive: true);
      }

      final fileName = documento.nombre
          .replaceAll(RegExp(r'[^\w\s-]'), '_')
          .replaceAll(' ', '_');
      
      String extension = '.pdf';
      if (documento.url!.startsWith('data:image/png')) extension = '.png';
      if (documento.url!.startsWith('data:image/jpeg')) extension = '.jpg';
      if (documento.nombre.toLowerCase().endsWith('.png')) extension = '.png';
      if (documento.nombre.toLowerCase().endsWith('.jpg')) extension = '.jpg';

      final filePath = '${docsDir.path}\\$fileName$extension';
      final file = File(filePath);

      await file.writeAsBytes(bytes);
      debugPrint('✅ Examen descargado: $filePath');

      _mostrarMensaje('✓ Examen descargado exitosamente');
      await launchUrl(Uri.file(docsDir.path));
    } catch (e) {
      _mostrarMensaje('Error al descargar examen: $e');
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(String action, Documento documento) async {
    switch (action) {
      case 'ver':
        await _abrirExamen(documento);
        break;
      case 'descargar':
        await _descargarExamen(documento);
        break;
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  IconData _getTipoIcono(TipoDocumento tipo) {
    switch (tipo) {
      case TipoDocumento.examen:
        return Icons.science;
      case TipoDocumento.imagen:
        return Icons.image;
      case TipoDocumento.informe:
        return Icons.description;
      case TipoDocumento.otro:
        return Icons.insert_drive_file;
    }
  }

  Color _getTipoColor(TipoDocumento tipo) {
    switch (tipo) {
      case TipoDocumento.examen:
        return Colors.blue;
      case TipoDocumento.imagen:
        return Colors.purple;
      case TipoDocumento.informe:
        return Colors.orange;
      case TipoDocumento.otro:
        return Colors.grey;
    }
  }

  String _getTipoTexto(TipoDocumento tipo) {
    switch (tipo) {
      case TipoDocumento.examen:
        return 'Examen';
      case TipoDocumento.imagen:
        return 'Imagen';
      case TipoDocumento.informe:
        return 'Informe';
      case TipoDocumento.otro:
        return 'Otro';
    }
  }

  String _formatFecha(DateTime fecha) {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }
}
