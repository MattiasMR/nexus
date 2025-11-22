import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/paciente.dart';
import '../../services/pacientes_service.dart';
import '../../utils/validators.dart';

class PatientFormPage extends StatefulWidget {
  final Paciente? paciente;

  const PatientFormPage({super.key, this.paciente});

  @override
  State<PatientFormPage> createState() => _PatientFormPageState();
}

class _PatientFormPageState extends State<PatientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = PacientesService();
  
  // Controllers
  late TextEditingController _rutController;
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _ocupacionController;
  
  DateTime? _fechaNacimiento;
  String _sexo = 'M';
  String? _grupoSanguineo;
  String _estado = 'activo';
  String? _estadoCivil;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.paciente;
    
    _rutController = TextEditingController(text: p?.rut ?? '');
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _apellidoController = TextEditingController(text: p?.apellido ?? '');
    _direccionController = TextEditingController(text: p?.direccion ?? '');
    _telefonoController = TextEditingController(text: p?.telefono ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _ocupacionController = TextEditingController(text: p?.ocupacion ?? '');
    
    _fechaNacimiento = p?.fechaNacimiento;
    _sexo = p?.sexo ?? 'M';
    _grupoSanguineo = p?.grupoSanguineo;
    _estado = p?.estado ?? 'activo';
    _estadoCivil = p?.estadoCivil;
  }

  @override
  void dispose() {
    _rutController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _ocupacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paciente != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Paciente' : 'Nuevo Paciente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Información Personal'),
            _buildTextField(
              controller: _rutController,
              label: 'RUT',
              icon: Icons.badge,
              required: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9kK.\-]')),
              ],
              validator: Validators.rutValidator,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nombreController,
              label: 'Nombre',
              icon: Icons.person,
              required: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              ],
              validator: (value) => Validators.nameValidator(value, 'El nombre'),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _apellidoController,
              label: 'Apellido',
              icon: Icons.person_outline,
              required: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              ],
              validator: (value) => Validators.nameValidator(value, 'El apellido'),
            ),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildSexoField(),
            const SizedBox(height: 24),
            _buildSectionTitle('Información de Contacto'),
            _buildTextField(
              controller: _direccionController,
              label: 'Dirección',
              icon: Icons.home,
              required: true,
              validator: Validators.addressValidator,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _telefonoController,
              label: 'Teléfono',
              icon: Icons.phone,
              required: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              validator: Validators.phoneValidator,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email (opcional)',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.emailValidator(value);
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Información Adicional'),
            _buildDropdownField(
              value: _grupoSanguineo,
              label: 'Grupo Sanguíneo',
              icon: Icons.bloodtype,
              items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
              onChanged: (value) => setState(() => _grupoSanguineo = value),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              value: _estadoCivil,
              label: 'Estado Civil',
              icon: Icons.favorite,
              items: ['soltero', 'casado', 'divorciado', 'viudo', 'union_libre'],
              onChanged: (value) => setState(() => _estadoCivil = value),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ocupacionController,
              label: 'Ocupación (opcional)',
              icon: Icons.work,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              value: _estado,
              label: 'Estado',
              icon: Icons.toggle_on,
              items: ['activo', 'inactivo'],
              required: true,
              onChanged: (value) => setState(() => _estado = value!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Actualizar' : 'Crear Paciente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha de Nacimiento *',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          _fechaNacimiento != null
              ? '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}'
              : 'Seleccione una fecha',
        ),
      ),
    );
  }

  Widget _buildSexoField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.wc, color: Colors.grey),
          const SizedBox(width: 12),
          const Text('Sexo *', style: TextStyle(fontSize: 16)),
          const Spacer(),
          Expanded(
            child: RadioGroup<String>(
              groupValue: _sexo,
              onChanged: (value) => setState(() => _sexo = value!),
              child: Row(
                children: [
                  Radio<String>(value: 'M'),
                  const Text('M'),
                  const SizedBox(width: 8),
                  Radio<String>(value: 'F'),
                  const Text('F'),
                  const SizedBox(width: 8),
                  Radio<String>(value: 'Otro'),
                  const Text('Otro'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    bool required = false,
  }) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      value: value,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione la fecha de nacimiento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paciente = Paciente(
        id: widget.paciente?.id,
        rut: _rutController.text.trim(),
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        fechaNacimiento: _fechaNacimiento!,
        direccion: _direccionController.text.trim(),
        telefono: _telefonoController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        sexo: _sexo,
        grupoSanguineo: _grupoSanguineo,
        estado: _estado,
        estadoCivil: _estadoCivil,
        ocupacion: _ocupacionController.text.trim().isEmpty ? null : _ocupacionController.text.trim(),
        createdAt: widget.paciente?.createdAt,
      );

      if (widget.paciente == null) {
        await _service.createPaciente(paciente);
      } else {
        await _service.updatePaciente(widget.paciente!.id!, paciente);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
