<?php

/**
 * Script de verificación de WebPay Plus
 * 
 * Este script verifica que todas las dependencias y configuraciones
 * estén correctamente instaladas para usar WebPay Plus.
 */

echo "🔍 Verificando instalación de WebPay Plus...\n\n";

// Cargar autoload de Composer
require_once __DIR__ . '/vendor/autoload.php';

// Verificar que el SDK de Transbank esté instalado
echo "1. Verificando SDK de Transbank... ";
if (class_exists('Transbank\Webpay\WebpayPlus\Transaction')) {
    echo "✅ OK\n";
} else {
    echo "❌ FALLO - Ejecuta: composer require transbank/transbank-sdk\n";
    exit(1);
}

// Verificar archivo de configuración
echo "2. Verificando configuración... ";
$configPath = __DIR__ . '/config/transbank.php';
if (file_exists($configPath)) {
    echo "✅ OK\n";
} else {
    echo "❌ FALLO - Archivo config/transbank.php no encontrado\n";
    exit(1);
}

// Verificar controlador
echo "3. Verificando controlador... ";
$controllerPath = __DIR__ . '/app/Http/Controllers/WebPayController.php';
if (file_exists($controllerPath)) {
    echo "✅ OK\n";
} else {
    echo "❌ FALLO - Archivo WebPayController.php no encontrado\n";
    exit(1);
}

// Verificar vistas
echo "4. Verificando vistas... ";
$views = [
    __DIR__ . '/resources/views/webpay/comprar-bono.blade.php',
    __DIR__ . '/resources/views/webpay/resultado.blade.php',
    __DIR__ . '/resources/views/webpay/comprobante.blade.php',
];
$allViewsExist = true;
foreach ($views as $view) {
    if (!file_exists($view)) {
        echo "\n   ❌ Falta: " . basename($view) . "\n";
        $allViewsExist = false;
    }
}
if ($allViewsExist) {
    echo "✅ OK (3 vistas encontradas)\n";
} else {
    exit(1);
}

// Verificar configuración de Transbank
echo "5. Verificando credenciales... ";

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

$environment = config('transbank.environment');
$commerceCode = config("transbank.{$environment}.commerce_code");
$apiKey = config("transbank.{$environment}.api_key");

if ($environment && $commerceCode && $apiKey) {
    echo "✅ OK\n";
    echo "   Ambiente: {$environment}\n";
    echo "   Código de comercio: {$commerceCode}\n";
} else {
    echo "❌ FALLO - Configuración incompleta\n";
    exit(1);
}

echo "\n✅ ¡Todas las verificaciones pasaron exitosamente!\n\n";
echo "📝 Próximos pasos:\n";
echo "   1. Ejecuta: php artisan serve\n";
echo "   2. Abre: http://localhost:8000/comprar-bono\n";
echo "   3. Usa tarjeta de prueba: 4051885600446623\n\n";
echo "📚 Documentación completa en: WEBPAY_README.md\n";
echo "⚡ Guía rápida en: INICIO_RAPIDO_WEBPAY.md\n\n";
