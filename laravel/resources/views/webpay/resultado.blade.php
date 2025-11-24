<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Resultado de la Transacción - WebPay Plus</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            width: 100%;
            padding: 40px;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .status-icon {
            font-size: 64px;
            margin-bottom: 20px;
        }

        .status-icon.success {
            color: #10b981;
        }

        .status-icon.error {
            color: #ef4444;
        }

        .header h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 10px;
        }

        .header p {
            color: #666;
            font-size: 16px;
        }

        .section {
            margin-bottom: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 12px;
            border-left: 4px solid #667eea;
        }

        .section h2 {
            color: #333;
            font-size: 18px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .data-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e0e0e0;
        }

        .data-row:last-child {
            border-bottom: none;
        }

        .data-label {
            color: #666;
            font-weight: 500;
            font-size: 14px;
        }

        .data-value {
            color: #333;
            font-weight: 600;
            font-size: 14px;
            text-align: right;
        }

        .highlight {
            background: #fff;
            padding: 4px 8px;
            border-radius: 4px;
        }

        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge.success {
            background: #d1fae5;
            color: #065f46;
        }

        .badge.error {
            background: #fee2e2;
            color: #991b1b;
        }

        .actions {
            display: flex;
            gap: 12px;
            margin-top: 30px;
        }

        .btn {
            flex: 1;
            padding: 14px;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            text-decoration: none;
            text-align: center;
            display: inline-block;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-secondary {
            background: white;
            color: #667eea;
            border: 2px solid #667eea;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
        }

        .btn:active {
            transform: translateY(0);
        }

        .amount-display {
            font-size: 32px;
            color: #10b981;
            font-weight: bold;
            text-align: center;
            margin: 20px 0;
        }

        .amount-display.error {
            color: #ef4444;
        }

        .info-text {
            text-align: center;
            color: #666;
            font-size: 13px;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="status-icon {{ $resultado['approved'] ? 'success' : 'error' }}">
                {{ $resultado['approved'] ? '✓' : '✗' }}
            </div>
            <h1>{{ $resultado['approved'] ? '¡Pago Exitoso!' : 'Pago Rechazado' }}</h1>
            <p>{{ $resultado['approved'] ? 'Tu compra de bono ha sido procesada correctamente' : 'La transacción no pudo ser completada' }}</p>
        </div>

        @if($resultado['approved'])
            <div class="amount-display">
                ${{ number_format($resultado['amount'], 0, ',', '.') }} CLP
            </div>
        @else
            <div class="amount-display error">
                ${{ number_format($resultado['amount'], 0, ',', '.') }} CLP
            </div>
        @endif

        <!-- Datos del Paciente -->
        @if(!empty($datosPaciente))
        <div class="section">
            <h2>👤 Datos del Paciente</h2>
            <div class="data-row">
                <span class="data-label">Nombre</span>
                <span class="data-value">{{ $datosPaciente['nombre'] ?? 'N/A' }}</span>
            </div>
            <div class="data-row">
                <span class="data-label">RUT</span>
                <span class="data-value">{{ $datosPaciente['rut'] ?? 'N/A' }}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Email</span>
                <span class="data-value">{{ $datosPaciente['email'] ?? 'N/A' }}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Teléfono</span>
                <span class="data-value">{{ $datosPaciente['telefono'] ?? 'N/A' }}</span>
            </div>
        </div>
        @endif

        <!-- Detalles de la Transacción -->
        <div class="section">
            <h2>📄 Detalles de la Transacción</h2>
            <div class="data-row">
                <span class="data-label">Estado</span>
                <span class="data-value">
                    <span class="badge {{ $resultado['approved'] ? 'success' : 'error' }}">
                        {{ $resultado['approved'] ? 'APROBADA' : 'RECHAZADA' }}
                    </span>
                </span>
            </div>
            <div class="data-row">
                <span class="data-label">Orden de Compra</span>
                <span class="data-value highlight">{{ $resultado['buy_order'] }}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Código de Autorización</span>
                <span class="data-value">{{ $resultado['authorization_code'] ?? 'N/A' }}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Fecha de Transacción</span>
                <span class="data-value">{{ \Carbon\Carbon::parse($resultado['transaction_date'])->format('d/m/Y H:i:s') }}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Número de Tarjeta</span>
                <span class="data-value">{{ $resultado['card_number'] }}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Tipo de Pago</span>
                <span class="data-value">
                    @if($resultado['payment_type_code'] == 'VD')
                        Venta Débito
                    @elseif($resultado['payment_type_code'] == 'VN')
                        Venta Normal
                    @elseif($resultado['payment_type_code'] == 'VC')
                        Venta en cuotas
                    @elseif($resultado['payment_type_code'] == 'SI')
                        3 cuotas sin interés
                    @elseif($resultado['payment_type_code'] == 'S2')
                        2 cuotas sin interés
                    @elseif($resultado['payment_type_code'] == 'NC')
                        N cuotas sin interés
                    @else
                        {{ $resultado['payment_type_code'] }}
                    @endif
                </span>
            </div>
            @if(isset($resultado['installments_number']) && $resultado['installments_number'] > 0)
            <div class="data-row">
                <span class="data-label">Número de Cuotas</span>
                <span class="data-value">{{ $resultado['installments_number'] }}</span>
            </div>
            @endif
            <div class="data-row">
                <span class="data-label">Código de Respuesta</span>
                <span class="data-value">{{ $resultado['response_code'] }}</span>
            </div>
            <div class="data-row">
                <span class="data-label">Estado</span>
                <span class="data-value">{{ $resultado['status'] ?? 'N/A' }}</span>
            </div>
        </div>

        <!-- Acciones -->
        <div class="actions">
            <a href="{{ route('webpay.descargar') }}" class="btn btn-primary" download>
                📥 Descargar JSON
            </a>
            <a href="{{ route('webpay.descargar.html') }}" class="btn btn-secondary" download>
                📄 Descargar HTML
            </a>
        </div>

        <div class="actions" style="margin-top: 12px;">
            <a href="{{ route('webpay.form') }}" class="btn btn-secondary">
                ← Realizar otra compra
            </a>
        </div>

        <p class="info-text">
            Este comprobante es válido como prueba de la transacción.<br>
            Guarda el archivo descargado para tus registros.
        </p>
    </div>
</body>
</html>
