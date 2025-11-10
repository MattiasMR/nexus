import 'package:flutter/material.dart';
import '../../../models/paciente.dart';
import '../../../models/ficha_medica.dart';
import '../../../utils/app_colors.dart';
import '../widgets/ficha_resumen_tab.dart';
import '../widgets/ficha_historial_tab.dart';
import '../widgets/ficha_alertas_tab.dart';
import '../widgets/ficha_tratamientos_tab.dart';
import 'nueva_atencion_page.dart';

/// Página de visualización detallada de Ficha Médica
/// Muestra tabs con: Resumen, Historial, Alertas, Tratamientos
class FichaMedicaDetailPage extends StatefulWidget {
  static const routeName = '/ficha-medica-detail';

  final Paciente paciente;
  final FichaMedica ficha;

  const FichaMedicaDetailPage({
    super.key,
    required this.paciente,
    required this.ficha,
  });

  @override
  State<FichaMedicaDetailPage> createState() => _FichaMedicaDetailPageState();
}

class _FichaMedicaDetailPageState extends State<FichaMedicaDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.paciente.nombre} ${widget.paciente.apellido}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Ficha Médica',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.summarize), text: 'Resumen'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
            Tab(icon: Icon(Icons.warning_amber), text: 'Alertas'),
            Tab(icon: Icon(Icons.medication), text: 'Tratamientos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Resumen
          FichaResumenTab(
            paciente: widget.paciente,
            ficha: widget.ficha,
          ),
          
          // Tab 2: Historial Médico
          FichaHistorialTab(
            fichaId: widget.ficha.id!,
            pacienteId: widget.paciente.id!,
          ),
          
          // Tab 3: Alertas
          FichaAlertasTab(
            fichaId: widget.ficha.id!,
            pacienteId: widget.paciente.id!,
          ),
          
          // Tab 4: Tratamientos Activos
          FichaTratamientosTab(
            fichaId: widget.ficha.id!,
            pacienteId: widget.paciente.id!,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => NuevaAtencionPage(
                paciente: widget.paciente,
                ficha: widget.ficha,
              ),
            ),
          );
          
          // Si se guardó la consulta, mostrar confirmación
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Consulta registrada correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Atención'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
