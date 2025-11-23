<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comprobante de Pago - Bono Médico</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }

        .comprobante {
            background: white;
            padding: 40px;
            border: 2px solid #333;
        }

        .header {
            text-align: center;
            border-bottom: 3px solid #333;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }

        .header h1 {
            margin: 0;
            font-size: 28px;
            color: #333;
        }

        .header p {
            margin: 5px 0;
            color: #666;
        }

        .section {
            margin-bottom: 30px;
        }

        .section-title {
            background: #333;
            color: white;
            padding: 10px;
            font-weight: bold;
            margin-bottom: 15px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        table td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }

        table td:first-child {
            font-weight: bold;
            width: 40%;
            color: #333;
        }

        table td:last-child {
            color: #666;
        }

        .amount-box {
            background: #f0f0f0;
            border: 2px solid #333;
            padding: 20px;
            text-align: center;
            margin: 30px 0;
        }

        .amount-box .label {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
        }

        .amount-box .amount {
            font-size: 36px;
            font-weight: bold;
            color: #333;
        }

        .status {
            display: inline-block;
            padding: 8px 20px;
            border-radius: 4px;
            font-weight: bold;
        }

        .status.approved {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .status.rejected {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #333;
            text-align: center;
            color: #666;
            font-size: 12px;
        }

        .timestamp {
            text-align: right;
            font-size: 12px;
            color: #999;
            margin-top: 20px;
        }

        @media print {
            body {
                background: white;
            }
        }
    </style>
</head>
<body>
    <div class="comprobante">
        <div class="header">
            <h1>COMPROBANTE DE PAGO</h1>
            <p>Sistema de Compra de Bonos Médicos</p>
            <p>WebPay Plus - Transbank</p>
        </div>

        <div class="amount-box">
            <div class="label">MONTO TOTAL</div>
            <div class="amount">${{ number_format($resultado['amount'] ?? 0, 0, ',', '.') }} CLP</div>
        </div>

        <div class="section">
            <div class="section-title">ESTADO DE LA TRANSACCIÓN</div>
            <table>
                <tr>
                    <td>Estado:</td>
                    <td>
                        <span class="status {{ ($resultado['approved'] ?? false) ? 'approved' : 'rejected' }}">
                            {{ ($resultado['approved'] ?? false) ? 'APROBADA' : 'RECHAZADA' }}
                        </span>
                    </td>
                </tr>
            </table>
        </div>

        @if(!empty($resultado['nombre']))
        <div class="section">
            <div class="section-title">DATOS DEL PACIENTE</div>
            <table>
                <tr>
                    <td>Nombre Completo:</td>
                    <td>{{ $resultado['nombre'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>RUT:</td>
                    <td>{{ $resultado['rut'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>Email:</td>
                    <td>{{ $resultado['email'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>Teléfono:</td>
                    <td>{{ $resultado['telefono'] ?? 'N/A' }}</td>
                </tr>
            </table>
        </div>
        @endif

        <div class="section">
            <div class="section-title">DETALLES DE LA TRANSACCIÓN</div>
            <table>
                <tr>
                    <td>Número de Orden:</td>
                    <td>{{ $resultado['buy_order'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>Código de Autorización:</td>
                    <td>{{ $resultado['authorization_code'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>Fecha de Transacción:</td>
                    <td>
                        @if(isset($resultado['transaction_date']))
                            {{ \Carbon\Carbon::parse($resultado['transaction_date'])->format('d/m/Y H:i:s') }}
                        @else
                            N/A
                        @endif
                    </td>
                </tr>
                <tr>
                    <td>Fecha Contable:</td>
                    <td>{{ $resultado['accounting_date'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>Número de Tarjeta:</td>
                    <td>{{ $resultado['card_number'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>Tipo de Pago:</td>
                    <td>
                        @php
                            $paymentTypes = [
                                'VD' => 'Venta Débito',
                                'VN' => 'Venta Normal',
                                'VC' => 'Venta en cuotas',
                                'SI' => '3 cuotas sin interés',
                                'S2' => '2 cuotas sin interés',
                                'NC' => 'N cuotas sin interés',
                            ];
                            $paymentCode = $resultado['payment_type_code'] ?? '';
                            echo $paymentTypes[$paymentCode] ?? $paymentCode;
                        @endphp
                    </td>
                </tr>
                @if(isset($resultado['installments_number']) && $resultado['installments_number'] > 0)
                <tr>
                    <td>Número de Cuotas:</td>
                    <td>{{ $resultado['installments_number'] }}</td>
                </tr>
                @endif
                <tr>
                    <td>Código de Respuesta:</td>
                    <td>{{ $resultado['response_code'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>ID de Sesión:</td>
                    <td>{{ $resultado['session_id'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>Estado:</td>
                    <td>{{ $resultado['status'] ?? 'N/A' }}</td>
                </tr>
                <tr>
                    <td>VCI:</td>
                    <td>{{ $resultado['vci'] ?? 'N/A' }}</td>
                </tr>
            </table>
        </div>

        <div class="footer">
            <p><strong>Este documento es un comprobante válido de la transacción realizada.</strong></p>
            <p>Ambiente: {{ config('transbank.environment') === 'integration' ? 'PRUEBAS/INTEGRACIÓN' : 'PRODUCCIÓN' }}</p>
            <p>WebPay Plus - Transbank S.A.</p>
        </div>

        <div class="timestamp">
            Documento generado el {{ now()->format('d/m/Y H:i:s') }}
        </div>
    </div>
</body>
</html>
