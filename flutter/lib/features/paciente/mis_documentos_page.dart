import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';
import '../../services/documentos_service.dart';
import '../../utils/app_colors.dart';

/// Página para gestionar documentos médicos del paciente
class MisDocumentosPage extends StatefulWidget {
  const MisDocumentosPage({super.key});

  @override
  State<MisDocumentosPage> createState() => _MisDocumentosPageState();
}

class _MisDocumentosPageState extends State<MisDocumentosPage> {
  final DocumentosService _documentosService = DocumentosService();
  String _filtroActual = 'Todos';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final usuario = authProvider.currentUser;

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('Error: Usuario no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Documentos'),
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
        stream: _documentosService.obtenerDocumentosPaciente(usuario.id),
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
              : documentos.where((d) => _getTipoTexto(d.tipo) == _filtroActual).toList();

          if (documentosFiltrados.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: documentosFiltrados.length,
            itemBuilder: (context, index) {
              final documento = documentosFiltrados[index];
              return _buildDocumentoCard(documento);
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
                ? 'No tienes documentos'
                : 'No hay documentos de tipo $_filtroActual',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sube tus documentos médicos con el botón +',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentoCard(Documento documento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _mostrarDetalleDocumento(documento),
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
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, documento),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'ver',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20),
                        SizedBox(width: 12),
                        Text('Ver'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'descargar',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 12),
                        Text('Descargar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
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

  void _mostrarDetalleDocumento(Documento documento) {
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
                      await _abrirDocumento(documento);
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
                      await _descargarDocumento(documento);
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

  Future<void> _abrirDocumento(Documento documento) async {
    if (documento.url == null) {
      _mostrarMensaje('URL del documento no disponible');
      return;
    }

    try {
      debugPrint('📄 Abriendo documento: ${documento.nombre}');
      debugPrint('🔗 URL: ${documento.url}');
      
      _mostrarMensaje('Descargando documento...');
      
      // Intentar descargar el PDF
      final response = await http.get(Uri.parse(documento.url!)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ Timeout al descargar');
          throw Exception('Timeout al descargar el documento');
        },
      );
      
      debugPrint('📡 HTTP Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final docsDir = Directory('${directory.path}\\Documentos');
        
        if (!await docsDir.exists()) {
          await docsDir.create(recursive: true);
        }
        
        // Limpiar nombre de archivo
        final fileName = documento.nombre
            .replaceAll(RegExp(r'[^\w\s-]'), '_')
            .replaceAll(' ', '_');
        final filePath = '${docsDir.path}\\$fileName.pdf';
        final file = File(filePath);
        
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Documento guardado en: $filePath');
        debugPrint('📦 Tamaño: ${response.bodyBytes.length} bytes');
        
        // Verificar que el archivo existe
        if (await file.exists()) {
          debugPrint('✓ Archivo existe, intentando abrir...');
          
          // Abrir el archivo con la aplicación predeterminada
          final uri = Uri.file(filePath);
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          
          if (launched) {
            _mostrarMensaje('✓ Documento abierto correctamente');
          } else {
            // Si no se puede abrir, mostrar la ubicación
            _mostrarMensaje('Documento guardado en: ${docsDir.path}');
            // Intentar abrir el explorador de archivos
            await launchUrl(Uri.file(docsDir.path));
          }
        } else {
          debugPrint('❌ El archivo no existe después de guardarlo');
          _mostrarMensaje('Error: El archivo no se guardó correctamente');
        }
      } else {
        debugPrint('❌ Error HTTP: ${response.statusCode}');
        debugPrint('📝 Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        
        // Intentar abrir URL directamente como fallback
        _mostrarMensaje('Intentando abrir en navegador...');
        final uri = Uri.parse(documento.url!);
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        if (!launched) {
          _mostrarMensaje('No se pudo abrir el documento (HTTP ${response.statusCode})');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error al abrir documento: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Último intento: abrir URL directamente en el navegador
      try {
        _mostrarMensaje('Intentando abrir en navegador...');
        final uri = Uri.parse(documento.url!);
        final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        
        if (!launched) {
          _mostrarMensaje('Error: No se pudo abrir el documento\n$e');
        }
      } catch (e2) {
        _mostrarMensaje('Error: $e');
      }
    }
  }

  Future<void> _descargarDocumento(Documento documento) async {
    if (documento.url == null) {
      _mostrarMensaje('URL del documento no disponible');
      return;
    }

    try {
      debugPrint('💾 Descargando documento: ${documento.nombre}');
      
      _mostrarMensaje('Descargando documento...');
      
      final response = await http.get(Uri.parse(documento.url!)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final docsDir = Directory('${directory.path}\\Documentos');
        
        if (!await docsDir.exists()) {
          await docsDir.create(recursive: true);
        }
        
        final fileName = documento.nombre
            .replaceAll(RegExp(r'[^\w\s-]'), '_')
            .replaceAll(' ', '_');
        final filePath = '${docsDir.path}\\$fileName.pdf';
        final file = File(filePath);
        
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('✅ Documento descargado: $filePath');
        
        _mostrarMensaje('✓ Documento descargado exitosamente');
        
        // Abrir el explorador de archivos en la carpeta
        await launchUrl(Uri.file(docsDir.path));
      } else {
        _mostrarMensaje('Error al descargar: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _mostrarMensaje('Error al descargar documento: $e');
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
        await _abrirDocumento(documento);
        break;
      case 'descargar':
        await _descargarDocumento(documento);
        break;
      case 'eliminar':
        _confirmarEliminacion(documento);
        break;
    }
  }

  void _confirmarEliminacion(Documento documento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Documento'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${documento.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _documentosService.eliminarDocumento(
                  documento.id!,
                  documento.storagePath,
                );
                _mostrarMensaje('Documento eliminado');
              } catch (e) {
                _mostrarMensaje('Error al eliminar: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
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
