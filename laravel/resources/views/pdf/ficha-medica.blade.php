<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ficha Médica - {{ $usuario['displayName'] }}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Arial', sans-serif;
            font-size: 12px;
            line-height: 1.6;
            color: #333;
            padding: 20px;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 3px solid #2563eb;
            padding-bottom: 20px;
        }

        .header h1 {
            color: #2563eb;
            font-size: 24px;
            margin-bottom: 5px;
        }

        .header p {
            color: #666;
            font-size: 14px;
        }

        .patient-info {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .patient-info h2 {
            color: #2563eb;
            font-size: 18px;
            margin-bottom: 10px;
            border-bottom: 2px solid #2563eb;
            padding-bottom: 5px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            margin-top: 10px;
        }

        .info-item {
            padding: 8px 0;
        }

        .info-label {
            font-weight: bold;
            color: #555;
            display: block;
            margin-bottom: 3px;
        }

        .info-value {
            color: #333;
        }

        .section {
            margin-bottom: 20px;
            page-break-inside: avoid;
        }

        .section-title {
            background-color: #2563eb;
            color: white;
            padding: 10px 15px;
            font-size: 16px;
            font-weight: bold;
            margin-bottom: 15px;
            border-radius: 5px;
        }

        .antecedente {
            margin-bottom: 15px;
            padding: 10px;
            border-left: 3px solid #2563eb;
            background-color: #f8f9fa;
        }

        .antecedente-title {
            font-weight: bold;
            color: #2563eb;
            margin-bottom: 5px;
        }

        .antecedente-content {
            color: #555;
            padding-left: 10px;
        }

        .alergias {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 5px;
        }

        .alergia-badge {
            background-color: #dc2626;
            color: white;
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 11px;
            font-weight: bold;
        }

        .sin-datos {
            color: #999;
            font-style: italic;
        }

        .observaciones {
            background-color: #fffbeb;
            border: 1px solid #fbbf24;
            padding: 15px;
            border-radius: 5px;
            margin-top: 10px;
        }

        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #e5e7eb;
            text-align: center;
            color: #666;
            font-size: 10px;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin: 20px 0;
        }

        .stat-box {
            background-color: #f0f9ff;
            border: 1px solid #2563eb;
            padding: 15px;
            text-align: center;
            border-radius: 8px;
        }

        .stat-label {
            font-size: 10px;
            color: #666;
            text-transform: uppercase;
            margin-bottom: 5px;
        }

        .stat-value {
            font-size: 20px;
            font-weight: bold;
            color: #2563eb;
        }

        .emergency-contact {
            background-color: #fef2f2;
            border: 2px solid #dc2626;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
        }

        .emergency-title {
            color: #dc2626;
            font-weight: bold;
            font-size: 14px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header">
        <h1>FICHA MÉDICA</h1>
        <p>Documento generado el {{ $fecha }}</p>
    </div>

    <!-- Información del Paciente -->
    <div class="patient-info">
        <h2>Información del Paciente</h2>
        <div class="info-grid">
            <div class="info-item">
                <span class="info-label">Nombre Completo:</span>
                <span class="info-value">{{ $usuario['displayName'] }}</span>
            </div>
            <div class="info-item">
                <span class="info-label">RUT:</span>
                <span class="info-value">{{ $usuario['rut'] ?? 'Sin RUT' }}</span>
            </div>
            <div class="info-item">
                <span class="info-label">Email:</span>
                <span class="info-value">{{ $usuario['email'] }}</span>
            </div>
            <div class="info-item">
                <span class="info-label">Teléfono:</span>
                <span class="info-value">{{ $usuario['telefono'] ?? 'Sin teléfono' }}</span>
            </div>
            <div class="info-item">
                <span class="info-label">Grupo Sanguíneo:</span>
                <span class="info-value">{{ $paciente['grupoSanguineo'] ?? 'Sin datos' }}</span>
            </div>
            <div class="info-item">
                <span class="info-label">Previsión:</span>
                <span class="info-value">{{ $paciente['prevision'] ?? 'Sin datos' }}</span>
            </div>
        </div>
    </div>

    <!-- Estadísticas -->
    <div class="stats">
        <div class="stat-box">
            <div class="stat-label">Total Consultas</div>
            <div class="stat-value">{{ $ficha['totalConsultas'] ?? 0 }}</div>
        </div>
        <div class="stat-box">
            <div class="stat-label">Última Consulta</div>
            <div class="stat-value" style="font-size: 12px;">
                {{ $ficha['ultimaConsulta'] ? \Carbon\Carbon::parse($ficha['ultimaConsulta'])->format('d/m/Y') : 'Sin consultas' }}
            </div>
        </div>
        <div class="stat-box">
            <div class="stat-label">Ficha Creada</div>
            <div class="stat-value" style="font-size: 12px;">
                {{ $ficha['createdAt'] ? \Carbon\Carbon::parse($ficha['createdAt'])->format('d/m/Y') : 'Sin fecha' }}
            </div>
        </div>
    </div>

    <!-- Alergias -->
    <div class="section">
        <div class="section-title">⚠️ Alergias</div>
        @if(!empty($ficha['antecedentes']['alergias']))
            <div class="alergias">
                @foreach($ficha['antecedentes']['alergias'] as $alergia)
                    <span class="alergia-badge">{{ $alergia }}</span>
                @endforeach
            </div>
        @else
            <p class="sin-datos">No se registran alergias</p>
        @endif
    </div>

    <!-- Antecedentes Médicos -->
    <div class="section">
        <div class="section-title">📋 Antecedentes Médicos</div>

        <div class="antecedente">
            <div class="antecedente-title">Antecedentes Personales</div>
            <div class="antecedente-content">
                {{ $ficha['antecedentes']['personales'] ?? 'Sin datos' }}
            </div>
        </div>

        <div class="antecedente">
            <div class="antecedente-title">Antecedentes Familiares</div>
            <div class="antecedente-content">
                {{ $ficha['antecedentes']['familiares'] ?? 'Sin datos' }}
            </div>
        </div>

        <div class="antecedente">
            <div class="antecedente-title">Antecedentes Quirúrgicos</div>
            <div class="antecedente-content">
                {{ $ficha['antecedentes']['quirurgicos'] ?? 'Sin datos' }}
            </div>
        </div>

        <div class="antecedente">
            <div class="antecedente-title">Hospitalizaciones</div>
            <div class="antecedente-content">
                {{ $ficha['antecedentes']['hospitalizaciones'] ?? 'Sin datos' }}
            </div>
        </div>
    </div>

    <!-- Observaciones -->
    @if(!empty($ficha['observacion']))
        <div class="section">
            <div class="section-title">📝 Observaciones Generales</div>
            <div class="observaciones">
                {{ $ficha['observacion'] }}
            </div>
        </div>
    @endif

    <!-- Contacto de Emergencia -->
    @if(!empty($paciente['contactoEmergencia']))
        <div class="emergency-contact">
            <div class="emergency-title">🚨 Contacto de Emergencia</div>
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Nombre:</span>
                    <span class="info-value">{{ $paciente['contactoEmergencia']['nombre'] ?? 'Sin datos' }}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Teléfono:</span>
                    <span class="info-value">{{ $paciente['contactoEmergencia']['telefono'] ?? 'Sin datos' }}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Relación:</span>
                    <span class="info-value">{{ $paciente['contactoEmergencia']['relacion'] ?? 'Sin datos' }}</span>
                </div>
            </div>
        </div>
    @endif

    <!-- Footer -->
    <div class="footer">
        <p>Este documento es confidencial y contiene información médica protegida.</p>
        <p>Generado automáticamente por el Sistema de Gestión Médica - {{ config('app.name') }}</p>
    </div>
</body>
</html>
