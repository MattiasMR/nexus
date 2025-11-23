# 🚀 Guía Rápida - WebPay Plus

## ⚡ Inicio Rápido

### 1. Iniciar el servidor Laravel
```bash
cd c:\Users\milan\UDD\Tecnologias\nexus\laravel
php artisan serve
```

### 2. Acceder a la página de compra
Abre tu navegador en: **http://localhost:8000/comprar-bono**

### 3. Completar el formulario
- **Nombre**: Juan Pérez García
- **RUT**: 11111111-1
- **Email**: test@ejemplo.com
- **Teléfono**: +56912345678
- **Monto**: 25000 (o el que prefieras entre $50 y $1.000.000)

### 4. Usar tarjeta de prueba en WebPay
Cuando te redirija a WebPay, usa estos datos:

**VISA (Aprobada)**
- Número: `4051885600446623`
- CVV: `123`
- Fecha: Cualquier fecha futura (ej: 12/25)

**En el formulario de WebPay:**
- RUT: `11.111.111-1`
- Clave: `123`

### 5. Aprobar o Rechazar
- Presiona **"Aceptar"** para simular pago exitoso
- Presiona **"Rechazar"** para simular pago fallido

### 6. Ver resultado y descargar
- Verás todos los detalles de la transacción
- Puedes descargar el comprobante en JSON o HTML

## 📋 Otras Tarjetas de Prueba

### Mastercard
- **Número**: 5186059559590568
- **CVV**: 123

### Redcompra (Débito)
- **Número**: 4051885600446623
- **Solo necesitas RUT y Clave**

## 🔍 Verificar que todo funciona

```bash
# Ver las rutas registradas
php artisan route:list --path=comprar-bono

# Ver los logs en tiempo real
php artisan pail
# o
tail -f storage/logs/laravel.log
```

## ✅ Checklist de Pruebas

- [ ] Formulario se muestra correctamente
- [ ] Se validan los campos requeridos
- [ ] Redirección a WebPay funciona
- [ ] Pago exitoso retorna correctamente
- [ ] Pago rechazado retorna correctamente
- [ ] Se puede descargar comprobante JSON
- [ ] Se puede descargar comprobante HTML
- [ ] Los datos del paciente se muestran en el resultado

## 🐛 Problemas Comunes

### Error: "Class 'Transbank\Webpay\WebpayPlus\Transaction' not found"
**Solución**: Ejecuta `composer dump-autoload`

### Error: "Route [webpay.form] not defined"
**Solución**: Ejecuta `php artisan config:clear` y `php artisan route:clear`

### Error: "Session store not set on request"
**Solución**: Verifica que el middleware web esté activo (ya debería estarlo)

### La redirección no funciona
**Solución**: Asegúrate de que el servidor Laravel esté corriendo en http://localhost:8000

## 📞 URLs Importantes

- **Formulario**: http://localhost:8000/comprar-bono
- **Documentación**: Ver `WEBPAY_README.md`

---

¡Listo para probar! 🎉
