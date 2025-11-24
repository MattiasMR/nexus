# WebPay Plus - Integración de Compra de Bonos

## 📋 Descripción

Esta es una integración completa de WebPay Plus de Transbank para permitir que los pacientes compren bonos médicos a través de pagos seguros con tarjeta de crédito o débito.

## 🚀 Características

- ✅ Integración completa con WebPay Plus (ambiente de pruebas)
- ✅ Formulario simple para ingresar datos del paciente y monto
- ✅ Monto variable configurable
- ✅ Proceso de pago seguro a través de Transbank
- ✅ Descarga de comprobantes en formato JSON y HTML
- ✅ No requiere autenticación
- ✅ No requiere base de datos (todo se maneja en sesión)

## 🔗 URL de Acceso

La página está disponible en:

```
http://localhost:8000/comprar-bono
```

O en el puerto que estés usando para tu servidor Laravel.

## 🏗️ Archivos Creados

### Configuración
- `config/transbank.php` - Configuración de credenciales de Transbank

### Controlador
- `app/Http/Controllers/WebPayController.php` - Lógica de negocio para WebPay

### Rutas
Las siguientes rutas fueron agregadas a `routes/web.php`:
- `GET /comprar-bono` - Formulario de compra
- `POST /comprar-bono/iniciar` - Iniciar transacción
- `GET /comprar-bono/confirmar` - Confirmar transacción (callback de WebPay)
- `POST /comprar-bono/confirmar` - Confirmar transacción (callback de WebPay)
- `GET /comprar-bono/descargar-comprobante` - Descargar comprobante JSON
- `GET /comprar-bono/descargar-comprobante-html` - Descargar comprobante HTML

### Vistas
- `resources/views/webpay/comprar-bono.blade.php` - Formulario de compra
- `resources/views/webpay/resultado.blade.php` - Resultado de la transacción
- `resources/views/webpay/comprobante.blade.php` - Comprobante descargable

## 🧪 Tarjetas de Prueba

Para realizar pruebas en el ambiente de integración, usa las siguientes tarjetas:

### ✅ Transacciones Aprobadas

**VISA (Venta Normal)**
- Número: `4051885600446623`
- CVV: `123`
- Fecha: Cualquier fecha futura
- RUT: `11.111.111-1`
- Clave: `123`

**Mastercard (Venta Normal)**
- Número: `5186059559590568`
- CVV: `123`
- Fecha: Cualquier fecha futura
- RUT: `11.111.111-1`
- Clave: `123`

**VISA (3 cuotas sin interés)**
- Número: `4051885600446623`
- CVV: `123`
- Fecha: Cualquier fecha futura
- RUT: `11.111.111-1`
- Clave: `123`
- Cuotas: Seleccionar "3 cuotas sin interés"

**Redcompra (Débito)**
- Número: `4051885600446623`
- CVV: No aplica
- Fecha: No aplica
- RUT: `11.111.111-1`
- Clave: `123`

### ❌ Transacciones Rechazadas

Para simular rechazo, usa:
- Número: `4051885600446623`
- CVV: `123`
- RUT: `11.111.111-1`
- Clave: `123`
- Cuando aparezca el formulario de WebPay, presiona "Rechazar"

## 📝 Flujo de Compra

1. **Acceder al formulario**: Ir a `/comprar-bono`
2. **Llenar datos**:
   - Nombre completo del paciente
   - RUT
   - Email
   - Teléfono
   - Monto del bono (mínimo $50, máximo $1.000.000)
3. **Proceder al pago**: Se redirige a WebPay Plus
4. **Ingresar datos de tarjeta**: Usar tarjetas de prueba
5. **Confirmar pago**: Aprobar o rechazar en el formulario de WebPay
6. **Ver resultado**: Se muestra el resultado con todos los detalles
7. **Descargar comprobante**: Opción de descargar en JSON o HTML

## 🔧 Configuración

El ambiente está configurado en el archivo `.env`:

```env
TRANSBANK_ENVIRONMENT=integration
```

Para cambiar a producción (cuando tengas credenciales reales):

```env
TRANSBANK_ENVIRONMENT=production
TRANSBANK_COMMERCE_CODE=tu_codigo_comercio
TRANSBANK_API_KEY=tu_api_key
```

## 📦 Dependencias Instaladas

- `transbank/transbank-sdk: ^5.1` - SDK oficial de Transbank para PHP

## 🛠️ Comandos Útiles

### Iniciar el servidor
```bash
php artisan serve
```

### Limpiar caché de configuración
```bash
php artisan config:clear
```

### Ver rutas disponibles
```bash
php artisan route:list
```

## 🔐 Seguridad

- ✅ Validación de datos del formulario
- ✅ Protección CSRF en formularios
- ✅ Manejo seguro de sesiones
- ✅ Comunicación encriptada con Transbank
- ✅ Logs de errores para debugging

## 📊 Datos que se Capturan

### Datos del Paciente
- Nombre completo
- RUT
- Email
- Teléfono
- Monto del bono

### Datos de la Transacción (desde WebPay)
- Número de orden
- Código de autorización
- Fecha de transacción
- Número de tarjeta (últimos 4 dígitos)
- Tipo de pago
- Número de cuotas (si aplica)
- Estado de la transacción
- Código de respuesta
- Y más...

## 📥 Formatos de Descarga

### JSON
Archivo `.json` con toda la información de la transacción en formato estructurado, ideal para:
- Integración con otros sistemas
- Procesamiento automático
- Respaldo de datos

### HTML
Archivo `.html` con un comprobante formateado y legible, ideal para:
- Impresión
- Archivo PDF (imprimir a PDF)
- Visualización directa

## 🐛 Debugging

Los errores se registran en los logs de Laravel:

```bash
tail -f storage/logs/laravel.log
```

## 📚 Recursos Adicionales

- [Documentación oficial de Transbank](https://www.transbankdevelopers.cl/)
- [SDK de Transbank para PHP](https://github.com/TransbankDevelopers/transbank-sdk-php)
- [Ambiente de integración](https://www.transbankdevelopers.cl/documentacion/como_empezar#credenciales-en-webpay)

## ⚠️ Notas Importantes

1. **Ambiente de Pruebas**: Esta implementación usa el ambiente de integración de Transbank. No se realizan cargos reales.

2. **Sin Base de Datos**: Los datos se almacenan temporalmente en sesión. Si necesitas persistencia, deberías crear una migración y modelo para almacenar las transacciones.

3. **Montos**: Los montos en WebPay Plus deben ser números enteros (sin decimales). El sistema ya maneja esto automáticamente.

4. **Timeout de Sesión**: Las sesiones de WebPay tienen un timeout. Si el usuario tarda mucho en completar el pago, la transacción puede expirar.

5. **URLs de Retorno**: Las URLs de retorno (`return_url`) deben ser accesibles desde internet en producción. Para desarrollo local, asegúrate de que tu servidor esté corriendo.

## 🎯 Próximos Pasos (Opcional)

Si quieres mejorar la implementación:

1. **Crear migración** para almacenar transacciones en la base de datos
2. **Enviar emails** con el comprobante después del pago exitoso
3. **Generar códigos de bono** únicos para cada compra
4. **Dashboard administrativo** para ver todas las transacciones
5. **Integrar con sistema de citas** médicas
6. **Agregar validación de RUT** chileno más robusta
7. **Implementar notificaciones** en tiempo real

## 📞 Soporte

Para problemas o dudas sobre la integración de WebPay, consulta:
- [Centro de ayuda de Transbank](https://www.transbankdevelopers.cl/documentacion/webpay-plus)
- [GitHub de Transbank](https://github.com/TransbankDevelopers)

---

**Hecho con ❤️ para el sistema de bonos médicos**
