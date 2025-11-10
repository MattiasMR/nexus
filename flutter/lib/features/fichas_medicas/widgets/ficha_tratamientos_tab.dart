import 'package:flutter/material.dart';
import '../../../models/tratamiento.dart';
import '../../../utils/app_colors.dart';
import 'package:intl/intl.dart';

/// Tab de tratamientos activos
/// Muestra tratamientos vigentes y finalizados del paciente
class FichaTratamientosTab extends StatelessWidget {
  final String fichaId;
  final String pacienteId;

  const FichaTratamientosTab({
    super.key,
    required this.fichaId,
    required this.pacienteId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar Stream desde Firestore cuando se cree el servicio de tratamientos
    // Por ahora mostramos un placeholder con tratamientos de ejemplo
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    // Tratamientos de ejemplo
    final tratamientos = [
      Tratamiento(
        id: '1',
        pacienteId: pacienteId,
        fichaId: fichaId,
        nombre: 'Tratamiento de Hipertensión',
        descripcion: 'Control de presión arterial con medicación',
        fechaInicio: DateTime.now().subtract(const Duration(days: 60)),
        fechaFin: DateTime.now().add(const Duration(days: 120)),
        medicamentos: ['Enalapril 10mg - 1 vez al día', 'Amlodipino 5mg - 1 vez al día'],
        indicaciones: 'Tomar en ayunas, medir presión diariamente',
      ),
      Tratamiento(
        id: '2',
        pacienteId: pacienteId,
        fichaId: fichaId,
        nombre: 'Tratamiento Antibiótico',
        descripcion: 'Infección respiratoria',
        fechaInicio: DateTime.now().subtract(const Duration(days: 5)),
        fechaFin: DateTime.now().add(const Duration(days: 2)),
        medicamentos: ['Amoxicilina 500mg - Cada 8 horas'],
        indicaciones: 'Completar ciclo de 7 días',
      ),
      Tratamiento(
        id: '3',
        pacienteId: pacienteId,
        fichaId: fichaId,
        nombre: 'Tratamiento Finalizado - Vitamina D',
        descripcion: 'Suplementación vitamínica',
        fechaInicio: DateTime.now().subtract(const Duration(days: 90)),
        fechaFin: DateTime.now().subtract(const Duration(days: 30)),
        activo: false,
        medicamentos: ['Vitamina D3 1000 UI - 1 vez al día'],
        indicaciones: 'Tomar con comida',
      ),
    ];

    final vigentes = tratamientos.where((t) => t.esVigente).toList();
    final finalizados = tratamientos.where((t) => !t.esVigente).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estadísticas
        _buildStatsCard(vigentes.length, finalizados.length),
        const SizedBox(height: 16),
        
        // Tratamientos vigentes
        if (vigentes.isNotEmpty) ...[
          _buildSectionHeader('Tratamientos Vigentes', Icons.medication, Colors.green),
          const SizedBox(height: 12),
          ...vigentes.map((t) => _buildTratamientoCard(context, t, true)),
          const SizedBox(height: 24),
        ],
        
        // Tratamientos finalizados
        if (finalizados.isNotEmpty) ...[
          _buildSectionHeader('Tratamientos Finalizados', Icons.check_circle, Colors.grey),
          const SizedBox(height: 12),
          ...finalizados.map((t) => _buildTratamientoCard(context, t, false)),
        ],
        
        // Empty state
        if (tratamientos.isEmpty) ...[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Icon(Icons.medication_liquid, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Sin Tratamientos Registrados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No hay tratamientos para este paciente',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsCard(int vigentes, int finalizados) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Vigentes',
                vigentes,
                Icons.medication,
                Colors.green,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildStatItem(
                'Finalizados',
                finalizados,
                Icons.check_circle,
                Colors.grey,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildStatItem(
                'Total',
                vigentes + finalizados,
                Icons.list_alt,
                AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTratamientoCard(BuildContext context, Tratamiento tratamiento, bool esVigente) {
    final duracion = tratamiento.duracionDias;
    final fechaInicioStr = DateFormat('dd/MM/yyyy').format(tratamiento.fechaInicio);
    final fechaFinStr = tratamiento.fechaFin != null 
        ? DateFormat('dd/MM/yyyy').format(tratamiento.fechaFin!)
        : 'Indefinido';
    
    // Calcular progreso si tiene fecha de fin
    double? progreso;
    if (tratamiento.fechaFin != null) {
      final total = tratamiento.fechaFin!.difference(tratamiento.fechaInicio).inDays;
      final transcurrido = DateTime.now().difference(tratamiento.fechaInicio).inDays;
      progreso = (transcurrido / total).clamp(0.0, 1.0);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: esVigente ? 3 : 1,
        color: esVigente ? null : Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tratamiento.nombre,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: esVigente ? Colors.black : Colors.grey[700],
                      ),
                    ),
                  ),
                  if (esVigente)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Descripción
              if (tratamiento.descripcion.isNotEmpty) ...[
                Text(
                  tratamiento.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Fechas y duración
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Inicio: $fechaInicioStr',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Fin: $fechaFinStr',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Duración: $duracion días',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              
              // Barra de progreso
              if (progreso != null && esVigente) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progreso * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progreso,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progreso >= 0.9 ? Colors.orange : Colors.green,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Medicamentos
              if (tratamiento.medicamentos.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.medication, size: 18, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Medicamentos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...tratamiento.medicamentos.map((med) => Padding(
                      padding: const EdgeInsets.only(left: 26, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              med,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              
              // Indicaciones
              if (tratamiento.indicaciones.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Indicaciones:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tratamiento.indicaciones,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
