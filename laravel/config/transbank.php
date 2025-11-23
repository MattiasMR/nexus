<?php

return [
    /*
    |--------------------------------------------------------------------------
    | WebPay Plus Configuration
    |--------------------------------------------------------------------------
    |
    | Configuración para WebPay Plus de Transbank.
    | En ambiente de pruebas se usan las credenciales por defecto del SDK.
    |
    */

    'environment' => env('TRANSBANK_ENVIRONMENT', 'integration'), // integration o production
    
    // Credenciales para ambiente de integración (pruebas)
    // Estas son las credenciales por defecto proporcionadas por Transbank
    'integration' => [
        'commerce_code' => '597055555532',
        'api_key' => '579B532A7440BB0C9079DED94D31EA1615BACEB56610332264630D42D0A36B1C',
    ],
    
    // Credenciales para ambiente de producción
    'production' => [
        'commerce_code' => env('TRANSBANK_COMMERCE_CODE', ''),
        'api_key' => env('TRANSBANK_API_KEY', ''),
    ],
];
