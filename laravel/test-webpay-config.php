<?php

require_once __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Transbank\Webpay\Options;
use Transbank\Webpay\WebpayPlus\Transaction;

echo "🧪 Probando configuración de WebPay...\n\n";

try {
    $environment = config('transbank.environment');
    $commerceCode = config('transbank.integration.commerce_code');
    $apiKey = config('transbank.integration.api_key');
    
    echo "Ambiente: {$environment}\n";
    echo "Código de comercio: {$commerceCode}\n";
    echo "API Key: " . substr($apiKey, 0, 20) . "...\n\n";
    
    // Crear opciones
    $options = new Options(
        $apiKey,
        $commerceCode,
        Options::ENVIRONMENT_INTEGRATION
    );
    
    echo "✅ Options creado correctamente\n";
    echo "   Integration Type: " . $options->getIntegrationType() . "\n";
    echo "   Commerce Code: " . $options->getCommerceCode() . "\n\n";
    
    // Crear instancia de Transaction
    $transaction = new Transaction($options);
    
    echo "✅ Transaction creado correctamente\n\n";
    
    echo "🎉 ¡La configuración está correcta!\n";
    echo "Ahora puedes acceder a: http://localhost:8000/comprar-bono\n";
    
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
    exit(1);
}
