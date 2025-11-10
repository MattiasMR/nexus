import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/paciente.dart';
import '../../../models/examen.dart';
import '../../../services/examenes_service.dart';
import '../../../services/auth_service.dart';

class NuevaOrdenExamenPage extends StatefulWidget {
  static const routeName = '/nueva-orden-examen';

  final Paciente paciente;

  const NuevaOrdenExamenPage({super.key, required this.paciente});

  @override
  State<NuevaOrdenExamenPage> createState() => _NuevaOrdenExamenPageState();
}

class _NuevaOrdenExamenPageState extends State<NuevaOrdenExamenPage> {
  final _examenesService = ExamenesService();
  final _authService = AuthService();
  
  final _motivoController = TextEditingController();
  final _indicacionesController = TextEditingController();
  final List<ExamenSolicitado> _examenesSolicitados = [];
  List<Examen> _catalogoExamenes = [];
  bool _cargando = false;
  bool _guardando = false;
  bool _urgente = false;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  @override
  void dispose() {
    _motivoController.dispose();
    _indicacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogo() async {
    setState(() => _cargando = true);
    try {
      _examenesService.getAllExamenes().first.then((catalogo) {
        if (mounted) {
          setState(() {
            _catalogoExamenes = catalogo;
            _cargando = false;
          });
        }
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar exámenes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Orden de Exámenes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info del paciente
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border(
                      bottom: BorderSide(color: Colors.blue[200]!),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Paciente: ${widget.paciente.nombreCompleto}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('RUT: ${widget.paciente.rut}'),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Motivo
                        const Text(
                          'Motivo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _motivoController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Motivo de la orden de exámenes...',
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Urgente
                        CheckboxListTile(
                          title: const Text('Orden Urgente'),
                          value: _urgente,
                          onChanged: (value) {
                            setState(() => _urgente = value ?? false);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 16),
                        
                        // Exámenes solicitados
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Exámenes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _agregarExamen,
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        if (_examenesSolicitados.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'No hay exámenes agregados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _examenesSolicitados.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final examen = _examenesSolicitados[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: const Icon(Icons.science, color: Colors.white),
                                  ),
                                  title: Text(examen.nombreExamen),
                                  subtitle: examen.resultado != null
                                      ? Text('Resultado: ${examen.resultado}')
                                      : const Text('Pendiente'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarExamen(index),
                                  ),
                                ),
                              );
                            },
                          ),
                        
                        const SizedBox(height: 24),
                        
                        // Indicaciones generales
                        const Text(
                          'Indicaciones Generales',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _indicacionesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Indicaciones adicionales para los exámenes...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Botón guardar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _guardarOrden,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: _guardando
                          ? const CircularProgressIndicator()
                          : const Text('Guardar Orden'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _agregarExamen() {
    if (_catalogoExamenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay exámenes disponibles en el catálogo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _ExamenDialog(
        catalogoExamenes: _catalogoExamenes,
        onAgregar: (examenSolicitado) {
          setState(() {
            _examenesSolicitados.add(examenSolicitado);
          });
        },
      ),
    );
  }

  void _eliminarExamen(int index) {
    setState(() {
      _examenesSolicitados.removeAt(index);
    });
  }

  Future<void> _guardarOrden() async {
    if (_examenesSolicitados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un examen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_motivoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe especificar el motivo de la orden'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar permisos
    if (_authService.puedeRegistrarConsultas == false) {
      _authService.mostrarPermisosDenegados(context);
      return;
    }

    final usuarioActual = _authService.usuarioActual;
    if (usuarioActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay un usuario autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final orden = OrdenExamen(
        idPaciente: widget.paciente.id!,
        idProfesional: usuarioActual.id,
        fecha: DateTime.now(),
        examenes: _examenesSolicitados,
        estado: 'pendiente',
      );

      await _examenesService.createOrden(orden);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orden de exámenes guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar orden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }
}

class _ExamenDialog extends StatefulWidget {
  final List<Examen> catalogoExamenes;
  final Function(ExamenSolicitado) onAgregar;

  const _ExamenDialog({
    required this.catalogoExamenes,
    required this.onAgregar,
  });

  @override
  State<_ExamenDialog> createState() => _ExamenDialogState();
}

class _ExamenDialogState extends State<_ExamenDialog> {
  Examen? _examenSeleccionado;
  final _indicacionesController = TextEditingController();

  @override
  void dispose() {
    _indicacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Examen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Examen', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Examen>(
              value: _examenSeleccionado,
              items: widget.catalogoExamenes.map((examen) {
                return DropdownMenuItem(
                  value: examen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(examen.nombre),
                      Text(
                        'Tipo: ${examen.tipo}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _examenSeleccionado = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Seleccione un examen',
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Indicaciones', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _indicacionesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Indicaciones específicas para este examen (opcional)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _agregar,
          child: const Text('Agregar'),
        ),
      ],
    );
  }

  void _agregar() {
    if (_examenSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un examen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final examenSolicitado = ExamenSolicitado(
      idExamen: _examenSeleccionado!.id!,
      nombreExamen: _examenSeleccionado!.nombre,
      resultado: _indicacionesController.text.trim().isEmpty
          ? null
          : _indicacionesController.text.trim(),
    );

    widget.onAgregar(examenSolicitado);
    Navigator.of(context).pop();
  }
}
