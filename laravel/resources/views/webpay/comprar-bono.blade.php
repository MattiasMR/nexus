<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>Comprar Bono - WebPay Plus</title>
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
            max-width: 500px;
            width: 100%;
            padding: 40px;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .header h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 10px;
        }

        .header p {
            color: #666;
            font-size: 14px;
        }

        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .alert-error {
            background-color: #fee;
            border: 1px solid #fcc;
            color: #c00;
        }

        .alert-success {
            background-color: #efe;
            border: 1px solid #cfc;
            color: #0a0;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            color: #333;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .form-group input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 15px;
            transition: border-color 0.3s;
        }

        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }

        .form-group small {
            display: block;
            color: #888;
            margin-top: 4px;
            font-size: 12px;
        }

        .btn {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
        }

        .btn:active {
            transform: translateY(0);
        }

        .webpay-logo {
            text-align: center;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
        }

        .webpay-logo p {
            color: #888;
            font-size: 12px;
            margin-bottom: 8px;
        }

        .webpay-logo img {
            max-width: 120px;
            opacity: 0.7;
        }

        .info-box {
            background: #f8f9fa;
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #667eea;
        }

        .info-box h3 {
            color: #333;
            font-size: 14px;
            margin-bottom: 8px;
        }

        .info-box ul {
            list-style: none;
            color: #666;
            font-size: 13px;
            line-height: 1.6;
        }

        .info-box ul li:before {
            content: "✓ ";
            color: #667eea;
            font-weight: bold;
            margin-right: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>💳 Comprar Bono Médico</h1>
            <p>Complete el formulario para proceder con el pago</p>
        </div>

        <div class="info-box">
            <h3>🔒 Ambiente de Pruebas</h3>
            <ul>
                <li>Esta es una transacción de prueba</li>
                <li>No se realizarán cargos reales</li>
                <li>Use las tarjetas de prueba de Transbank</li>
            </ul>
        </div>

        @if(session('error'))
            <div class="alert alert-error">
                {{ session('error') }}
            </div>
        @endif

        @if(session('success'))
            <div class="alert alert-success">
                {{ session('success') }}
            </div>
        @endif

        <form action="{{ route('webpay.iniciar') }}" method="POST">
            @csrf

            <div class="form-group">
                <label for="nombre">Nombre Completo *</label>
                <input 
                    type="text" 
                    id="nombre" 
                    name="nombre" 
                    value="{{ old('nombre') }}"
                    placeholder="Ej: Juan Pérez García"
                    required
                >
                @error('nombre')
                    <small style="color: #c00;">{{ $message }}</small>
                @enderror
            </div>

            <div class="form-group">
                <label for="rut">RUT *</label>
                <input 
                    type="text" 
                    id="rut" 
                    name="rut" 
                    value="{{ old('rut') }}"
                    placeholder="Ej: 12345678-9"
                    required
                >
                @error('rut')
                    <small style="color: #c00;">{{ $message }}</small>
                @enderror
            </div>

            <div class="form-group">
                <label for="email">Email *</label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    value="{{ old('email') }}"
                    placeholder="Ej: correo@ejemplo.com"
                    required
                >
                @error('email')
                    <small style="color: #c00;">{{ $message }}</small>
                @enderror
            </div>

            <div class="form-group">
                <label for="telefono">Teléfono *</label>
                <input 
                    type="tel" 
                    id="telefono" 
                    name="telefono" 
                    value="{{ old('telefono') }}"
                    placeholder="Ej: +56912345678"
                    required
                >
                @error('telefono')
                    <small style="color: #c00;">{{ $message }}</small>
                @enderror
            </div>

            <div class="form-group">
                <label for="monto">Monto del Bono (CLP) *</label>
                <input 
                    type="number" 
                    id="monto" 
                    name="monto" 
                    value="{{ old('monto', '25000') }}"
                    min="50" 
                    max="1000000"
                    step="1"
                    placeholder="Ej: 25000"
                    required
                >
                <small>Monto mínimo: $50 - Monto máximo: $1.000.000</small>
                @error('monto')
                    <small style="color: #c00;">{{ $message }}</small>
                @enderror
            </div>

            <button type="submit" class="btn">
                Proceder al Pago con WebPay Plus
            </button>
        </form>

        <div class="webpay-logo">
            <p>Pago seguro procesado por</p>
            <svg width="120" height="40" viewBox="0 0 120 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                <text x="10" y="25" font-family="Arial, sans-serif" font-size="18" font-weight="bold" fill="#333">WebPay</text>
                <text x="10" y="35" font-family="Arial, sans-serif" font-size="10" fill="#666">Plus</text>
            </svg>
        </div>
    </div>

    <script>
        // Formatear RUT automáticamente
        const rutInput = document.getElementById('rut');
        if (rutInput) {
            rutInput.addEventListener('input', function(e) {
                let value = e.target.value.replace(/[^0-9kK]/g, '');
                if (value.length > 1) {
                    value = value.slice(0, -1) + '-' + value.slice(-1);
                }
                e.target.value = value;
            });
        }

        // Formatear monto con separador de miles
        const montoInput = document.getElementById('monto');
        if (montoInput) {
            montoInput.addEventListener('blur', function(e) {
                const value = parseInt(e.target.value);
                if (!isNaN(value)) {
                    e.target.value = value;
                }
            });
        }
    </script>
</body>
</html>
