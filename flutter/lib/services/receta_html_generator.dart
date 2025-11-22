import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/medicamento.dart';

/// Servicio para generar recetas médicas en formato HTML
class RecetaHtmlGenerator {
  /// Genera HTML de receta médica con formato profesional
  static String generarRecetaHtml(Receta receta, {
    required String nombrePaciente,
    required String rutPaciente,
  }) {
    final fechaFormateada = _formatFecha(receta.fecha);
    final medicamentosHtml = receta.medicamentos
        .map((med) => _generarMedicamentoHtml(med))
        .join('\n');

    return '''<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receta Médica - $nombrePaciente</title>
    <style>
        @media print {
            @page { size: letter; margin: 1cm; }
            body { margin: 0; }
            .no-print { display: none; }
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; padding: 20px; }
        .receta-container { max-width: 800px; margin: 0 auto; background: white; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); border-radius: 8px; overflow: hidden; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
        .header h1 { font-size: 28px; margin-bottom: 10px; font-weight: 600; }
        .header p { font-size: 14px; opacity: 0.9; }
        .info-section { padding: 30px; border-bottom: 2px solid #e0e0e0; }
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .info-item { padding: 12px; background: #f8f9fa; border-radius: 6px; }
        .info-label { font-size: 12px; color: #666; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px; }
        .info-value { font-size: 16px; font-weight: 600; color: #333; }
        .medicamentos-section { padding: 30px; }
        .section-title { font-size: 20px; font-weight: 600; color: #333; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 3px solid #667eea; }
        .medicamento-card { background: #f8f9fa; border-left: 4px solid #667eea; padding: 20px; margin-bottom: 20px; border-radius: 6px; }
        .medicamento-nombre { font-size: 18px; font-weight: 700; color: #667eea; margin-bottom: 15px; }
        .medicamento-detalle { display: flex; align-items: center; margin-bottom: 10px; padding: 8px 0; }
        .medicamento-detalle-label { font-weight: 600; color: #555; min-width: 120px; font-size: 14px; }
        .medicamento-detalle-value { color: #333; font-size: 14px; }
        .observaciones-section { padding: 30px; background: #fff8e1; border-top: 2px solid #e0e0e0; }
        .observaciones-content { font-size: 14px; line-height: 1.6; color: #555; }
        .footer { padding: 30px; background: #f8f9fa; border-top: 2px solid #e0e0e0; }
        .firma-section { margin-top: 40px; text-align: center; }
        .firma-line { border-top: 2px solid #333; width: 300px; margin: 0 auto 10px; }
        .firma-info { font-size: 14px; color: #555; }
        .firma-nombre { font-weight: 700; color: #333; font-size: 16px; }
        .disclaimer { margin-top: 30px; padding: 15px; background: #e3f2fd; border-radius: 6px; font-size: 12px; color: #555; text-align: center; }
        .print-button { position: fixed; bottom: 30px; right: 30px; background: #667eea; color: white; border: none; padding: 15px 30px; border-radius: 50px; font-size: 16px; font-weight: 600; cursor: pointer; box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3); transition: all 0.3s; }
        .print-button:hover { background: #5568d3; box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4); }
        .vigente-badge { display: inline-block; background: #4caf50; color: white; padding: 6px 16px; border-radius: 20px; font-size: 12px; font-weight: 600; margin-top: 10px; }
        .vencida-badge { display: inline-block; background: #9e9e9e; color: white; padding: 6px 16px; border-radius: 20px; font-size: 12px; font-weight: 600; margin-top: 10px; }
    </style>
</head>
<body>
    <div class="receta-container">
        <div class="header">
            <h1>📋 RECETA MÉDICA</h1>
            <p>Sistema Médico Nexus</p>
            <span class="${receta.vigente ? 'vigente-badge' : 'vencida-badge'}">${receta.vigente ? '✓ VIGENTE' : 'VENCIDA'}</span>
        </div>
        <div class="info-section">
            <div class="info-grid">
                <div class="info-item"><div class="info-label">Paciente</div><div class="info-value">$nombrePaciente</div></div>
                <div class="info-item"><div class="info-label">RUT</div><div class="info-value">$rutPaciente</div></div>
                <div class="info-item"><div class="info-label">Médico</div><div class="info-value">${receta.nombreProfesional ?? 'No especificado'}</div></div>
                <div class="info-item"><div class="info-label">Especialidad</div><div class="info-value">${receta.especialidadProfesional ?? 'No especificado'}</div></div>
                <div class="info-item"><div class="info-label">Fecha de Emisión</div><div class="info-value">$fechaFormateada</div></div>
                <div class="info-item"><div class="info-label">N° de Receta</div><div class="info-value">${receta.id?.substring(0, 8).toUpperCase() ?? 'N/A'}</div></div>
            </div>
        </div>
        <div class="medicamentos-section">
            <h2 class="section-title">💊 Medicamentos Recetados</h2>
            $medicamentosHtml
        </div>
        ${receta.observaciones != null ? '<div class="observaciones-section"><h2 class="section-title">📝 Observaciones</h2><div class="observaciones-content">${receta.observaciones}</div></div>' : ''}
        <div class="footer">
            <div class="firma-section">
                <div class="firma-line"></div>
                <div class="firma-nombre">${receta.nombreProfesional ?? 'Dr(a). No especificado'}</div>
                <div class="firma-info">${receta.especialidadProfesional ?? 'Medicina General'}</div>
            </div>
            <div class="disclaimer"><strong>⚠️ IMPORTANTE:</strong> Esta receta médica es un documento oficial. No automedicarse. Seguir estrictamente las indicaciones del médico. En caso de efectos adversos, contactar inmediatamente al profesional de salud.</div>
        </div>
    </div>
    <button class="print-button no-print" onclick="window.print()">🖨️ Imprimir Receta</button>
</body>
</html>''';
  }

  static String _generarMedicamentoHtml(MedicamentoRecetado med) {
    return '''<div class="medicamento-card">
            <div class="medicamento-nombre">${med.nombreMedicamento}</div>
            <div class="medicamento-detalle"><span class="medicamento-detalle-label">💊 Dosis:</span><span class="medicamento-detalle-value">${med.dosis}</span></div>
            <div class="medicamento-detalle"><span class="medicamento-detalle-label">⏰ Frecuencia:</span><span class="medicamento-detalle-value">${med.frecuencia}</span></div>
            <div class="medicamento-detalle"><span class="medicamento-detalle-label">📅 Duración:</span><span class="medicamento-detalle-value">${med.duracion}</span></div>
            ${med.indicaciones != null ? '<div class="medicamento-detalle"><span class="medicamento-detalle-label">ℹ️ Indicaciones:</span><span class="medicamento-detalle-value">${med.indicaciones}</span></div>' : ''}
        </div>''';
  }

  static String _formatFecha(DateTime fecha) {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }

  /// Guarda la receta HTML en un archivo y retorna la ruta
  static Future<String> guardarRecetaHtml(
    Receta receta, {
    required String nombrePaciente,
    required String rutPaciente,
  }) async {
    final html = generarRecetaHtml(
      receta,
      nombrePaciente: nombrePaciente,
      rutPaciente: rutPaciente,
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final recetasDir = Directory('${directory.path}/Recetas');
      
      // Crear directorio si no existe
      if (!await recetasDir.exists()) {
        await recetasDir.create(recursive: true);
      }

      final fileName = 'receta_${receta.id ?? DateTime.now().millisecondsSinceEpoch}.html';
      final file = File('${recetasDir.path}/$fileName');
      
      await file.writeAsString(html);
      
      debugPrint('Receta guardada en: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('Error guardando receta: $e');
      rethrow;
    }
  }
}
