import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/paciente.dart';
import '../../../models/ficha_medica.dart';
import '../../../models/consulta.dart';
import '../../../services/consultas_service.dart';
import '../../../services/fichas_medicas_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/validators.dart';
import 'package:intl/intl.dart';

/// Formulario de registro de nueva atención médica (consulta)
/// Implementa un wizard de 3 pasos
class NuevaAtencionPage extends StatefulWidget {
  final Paciente paciente;
  final FichaMedica ficha;

  const NuevaAtencionPage({
    super.key,
    required this.paciente,
    required this.ficha,
  });

  @override
  State<NuevaAtencionPage> createState() => _NuevaAtencionPageState();
}

class _NuevaAtencionPageState extends State<NuevaAtencionPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  
  final _consultasService = ConsultasService();
  final _fichasService = FichasMedicasService();

  // Controladores de formulario
  final _motivoController = TextEditingController();
  final _sintomasController = TextEditingController();
  final _presionController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _saturacionController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _planController = TextEditingController();
  
  bool _guardando = false;

  @override
  void dispose() {
    _pageController.dispose();
    _motivoController.dispose();
    _sintomasController.dispose();
    _presionController.dispose();
    _frecuenciaController.dispose();
    _temperaturaController.dispose();
    _saturacionController.dispose();
    _diagnosticoController.dispose();
    _observacionesController.dispose();
    _planController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Atención'),
        actions: [
          TextButton.icon(
            onPressed: _currentStep == 2 ? _guardarConsulta : null,
            icon: _guardando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              'Guardar',
              style: TextStyle(
                color: _currentStep == 2 ? Colors.white : Colors.white54,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de pasos
          _buildStepIndicator(),
          
          // Contenido del formulario
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
          ),
          
          // Botones de navegación
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepItem(0, 'Datos Generales', Icons.description),
          _buildStepConnector(0),
          _buildStepItem(1, 'Diagnóstico', Icons.medical_services),
          _buildStepConnector(1),
          _buildStepItem(2, 'Tratamiento', Icons.medication),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, IconData icon) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted || isActive ? AppColors.primary : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        color: isCompleted ? AppColors.primary : Colors.grey[300],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info del paciente
          _buildPatientCard(),
          const SizedBox(height: 24),
          
          // Motivo de consulta
          const Text(
            'Motivo de Consulta',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _motivoController,
            maxLines: 3,
            inputFormatters: [
              LengthLimitingTextInputFormatter(500),
            ],
            decoration: const InputDecoration(
              hintText: 'Describa el motivo principal de la consulta...',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.minLengthValidator(value, 10, 'El motivo de consulta'),
          ),
          const SizedBox(height: 24),
          
          // Síntomas
          const Text(
            'Síntomas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _sintomasController,
            maxLines: 4,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1000),
            ],
            decoration: const InputDecoration(
              hintText: 'Describa los síntomas que presenta el paciente...',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.safeTextValidator(value, 'Los síntomas'),
          ),
          const SizedBox(height: 24),
          
          // Signos vitales
          const Text(
            'Signos Vitales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _presionController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    LengthLimitingTextInputFormatter(7), // 120/80
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Presión Arterial',
                    hintText: '120/80',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final parts = value.split('/');
                      if (parts.length != 2 || 
                          int.tryParse(parts[0]) == null || 
                          int.tryParse(parts[1]) == null) {
                        return 'Formato inválido (ej: 120/80)';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _frecuenciaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Frecuencia (bpm)',
                    hintText: '75',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final num = int.tryParse(value);
                      if (num == null || num < 30 || num > 220) {
                        return 'Rango 30-220 bpm';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _temperaturaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    LengthLimitingTextInputFormatter(4), // 36.5
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Temperatura (°C)',
                    hintText: '36.5',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final num = double.tryParse(value);
                      if (num == null || num < 33.0 || num > 43.0) {
                        return 'Rango 33-43°C';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _saturacionController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'SpO₂ (%)',
                    hintText: '98',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final num = int.tryParse(value);
                      if (num == null || num < 70 || num > 100) {
                        return 'Rango 70-100%';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diagnóstico Principal',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _diagnosticoController,
            maxLines: 3,
            inputFormatters: [
              LengthLimitingTextInputFormatter(500),
            ],
            decoration: const InputDecoration(
              hintText: 'Ingrese el diagnóstico principal...',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.minLengthValidator(value, 5, 'El diagnóstico'),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Observaciones Clínicas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _observacionesController,
            maxLines: 5,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1000),
            ],
            decoration: const InputDecoration(
              hintText: 'Notas adicionales, hallazgos, etc...',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.safeTextValidator(value, 'Las observaciones'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan de Tratamiento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _planController,
            maxLines: 6,
            inputFormatters: [
              LengthLimitingTextInputFormatter(2000),
            ],
            decoration: const InputDecoration(
              hintText: 'Describa el plan de tratamiento, medicamentos, indicaciones, etc...',
              border: OutlineInputBorder(),
            ),
            validator: (value) => Validators.minLengthValidator(value, 10, 'El plan de tratamiento'),
          ),
          const SizedBox(height: 24),
          
          // Resumen
          _buildResumenCard(),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Datos del Paciente',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Nombre', '${widget.paciente.nombre} ${widget.paciente.apellido}'),
            _buildInfoRow('RUT', widget.paciente.rut),
            _buildInfoRow('Edad', '${widget.paciente.edad} años'),
            _buildInfoRow('Fecha', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCard() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Resumen de la Consulta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (_motivoController.text.isNotEmpty)
              _buildResumenRow('Motivo', _motivoController.text),
            if (_diagnosticoController.text.isNotEmpty)
              _buildResumenRow('Diagnóstico', _diagnosticoController.text),
            if (_planController.text.isNotEmpty)
              _buildResumenRow('Tratamiento', _planController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Anterior'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < 2 ? _nextStep : _guardarConsulta,
              child: Text(_currentStep < 2 ? 'Siguiente' : 'Guardar Consulta'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    // Validar paso actual
    if (_currentStep == 0) {
      if (_motivoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete el motivo de consulta'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_diagnosticoController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete el diagnóstico principal'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() {
      _currentStep++;
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _guardarConsulta() async {
    if (_guardando) return;

    // Validar formulario completo
    if (_motivoController.text.trim().isEmpty) {
      setState(() => _currentStep = 0);
      _pageController.jumpToPage(0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete el motivo de consulta')),
      );
      return;
    }

    if (_diagnosticoController.text.trim().isEmpty) {
      setState(() => _currentStep = 1);
      _pageController.jumpToPage(1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete el diagnóstico')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      // Construir signos vitales
      final signosVitales = <String, dynamic>{};
      if (_presionController.text.isNotEmpty) {
        signosVitales['presionArterial'] = _presionController.text;
      }
      if (_frecuenciaController.text.isNotEmpty) {
        signosVitales['frecuenciaCardiaca'] = int.tryParse(_frecuenciaController.text);
      }
      if (_temperaturaController.text.isNotEmpty) {
        signosVitales['temperatura'] = double.tryParse(_temperaturaController.text);
      }
      if (_saturacionController.text.isNotEmpty) {
        signosVitales['saturacionO2'] = int.tryParse(_saturacionController.text);
      }

      // Obtener usuario actual
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuarioActual = authProvider.currentUser;
      if (usuarioActual == null) {
        throw Exception('No hay un usuario autenticado');
      }

      // Crear consulta
      final consulta = Consulta(
        pacienteId: widget.paciente.id!,
        fichaId: widget.ficha.id!,
        fecha: DateTime.now(),
        motivoConsulta: _motivoController.text.trim(),
        sintomas: _sintomasController.text.trim(),
        signosVitales: signosVitales,
        diagnosticoPrincipal: _diagnosticoController.text.trim(),
        observaciones: _observacionesController.text.trim(),
        planTratamiento: _planController.text.trim(),
        medicoId: usuarioActual.id,
        medicoNombre: usuarioActual.nombreCompleto,
      );

      // Guardar en Firestore
      await _consultasService.createConsulta(consulta);

      // Actualizar contadores de la ficha médica
      await _fichasService.incrementarConsultas(widget.ficha.id!);

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consulta registrada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Volver atrás
      Navigator.of(context).pop(true); // true indica que se guardó
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar consulta: $e'),
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
