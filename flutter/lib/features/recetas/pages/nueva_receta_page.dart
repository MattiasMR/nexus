import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../models/paciente.dart';
import '../../../models/medicamento.dart';
import '../../../services/recetas_service.dart';
import '../../../providers/auth_provider.dart';

class NuevaRecetaPage extends StatefulWidget {
  static const routeName = '/nueva-receta';

  final Paciente paciente;

  const NuevaRecetaPage({super.key, required this.paciente});

  @override
  State<NuevaRecetaPage> createState() => _NuevaRecetaPageState();
}

class _NuevaRecetaPageState extends State<NuevaRecetaPage> {
  final _recetasService = RecetasService();
  
  final _indicacionesController = TextEditingController();
  final List<MedicamentoRecetado> _medicamentosRecetados = [];
  List<Medicamento> _catalogoMedicamentos = [];
  bool _cargando = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarCatalogo();
  }

  @override
  void dispose() {
    _indicacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogo() async {
    setState(() => _cargando = true);
    try {
      _recetasService.getAllMedicamentos().first.then((catalogo) {
        if (mounted) {
          setState(() {
            _catalogoMedicamentos = catalogo;
            _cargando = false;
          });
        }
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar medicamentos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Receta'),
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
                        // Medicamentos recetados
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Medicamentos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _agregarMedicamento,
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
                        
                        if (_medicamentosRecetados.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'No hay medicamentos agregados',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _medicamentosRecetados.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final med = _medicamentosRecetados[index];
                              return Card(
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.medication),
                                  ),
                                  title: Text(med.nombreMedicamento),
                                  subtitle: Text(
                                    '${med.dosis} - ${med.frecuencia}\nDuración: ${med.duracion}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarMedicamento(index),
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
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(500),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Indicaciones adicionales para el paciente...',
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
                      onPressed: _guardando ? null : _guardarReceta,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: _guardando
                          ? const CircularProgressIndicator()
                          : const Text('Guardar Receta'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _agregarMedicamento() {
    if (_catalogoMedicamentos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay medicamentos disponibles en el catálogo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _MedicamentoDialog(
        catalogoMedicamentos: _catalogoMedicamentos,
        onAgregar: (medicamentoRecetado) {
          setState(() {
            _medicamentosRecetados.add(medicamentoRecetado);
          });
        },
      ),
    );
  }

  void _eliminarMedicamento(int index) {
    setState(() {
      _medicamentosRecetados.removeAt(index);
    });
  }

  Future<void> _guardarReceta() async {
    if (_medicamentosRecetados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un medicamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Verificar permisos
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.puedeRecetarMedicamentos()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No tienes permisos para prescribir medicamentos (Rol: ${authProvider.currentUser?.rolTexto})'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final usuarioActual = authProvider.currentUser;
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
      final receta = Receta(
        idPaciente: widget.paciente.id!,
        idProfesional: usuarioActual.id,
        fecha: DateTime.now(),
        medicamentos: _medicamentosRecetados,
        observaciones: _indicacionesController.text.trim(),
      );

      await _recetasService.createReceta(receta);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receta guardada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar receta: $e'),
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

class _MedicamentoDialog extends StatefulWidget {
  final List<Medicamento> catalogoMedicamentos;
  final Function(MedicamentoRecetado) onAgregar;

  const _MedicamentoDialog({
    required this.catalogoMedicamentos,
    required this.onAgregar,
  });

  @override
  State<_MedicamentoDialog> createState() => _MedicamentoDialogState();
}

class _MedicamentoDialogState extends State<_MedicamentoDialog> {
  Medicamento? _medicamentoSeleccionado;
  final _dosisController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _duracionController = TextEditingController();

  @override
  void dispose() {
    _dosisController.dispose();
    _frecuenciaController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Medicamento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Medicamento', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Medicamento>(
              initialValue: _medicamentoSeleccionado,
              items: widget.catalogoMedicamentos.map((med) {
                return DropdownMenuItem(
                  value: med,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(med.nombre),
                      Text(
                        '${med.presentacion} - ${med.concentracion}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _medicamentoSeleccionado = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Seleccione un medicamento',
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Dosis', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _dosisController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: 1 comprimido',
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Frecuencia', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _frecuenciaController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: Cada 8 horas',
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('Duración', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _duracionController,
              inputFormatters: [
                LengthLimitingTextInputFormatter(50),
              ],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej: 7 días',
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
    if (_medicamentoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un medicamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_dosisController.text.trim().isEmpty ||
        _frecuenciaController.text.trim().isEmpty ||
        _duracionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete todos los campos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final medicamentoRecetado = MedicamentoRecetado(
      idMedicamento: _medicamentoSeleccionado!.id!,
      nombreMedicamento: _medicamentoSeleccionado!.nombre,
      dosis: _dosisController.text.trim(),
      frecuencia: _frecuenciaController.text.trim(),
      duracion: _duracionController.text.trim(),
    );

    widget.onAgregar(medicamentoRecetado);
    Navigator.of(context).pop();
  }
}
