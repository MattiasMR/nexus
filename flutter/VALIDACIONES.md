# Validaciones de Formularios - Flutter App

## ✅ Validaciones Implementadas

### 📋 Formulario de Pacientes (`patient_form_page.dart`)

#### Campos con Validación:

1. **RUT**
   - ✅ Solo acepta números, K, puntos y guiones
   - ✅ Valida formato y dígito verificador chileno
   - ✅ Mensaje: "RUT inválido"

2. **Nombre**
   - ✅ Solo acepta letras (incluye áéíóúñ) y espacios
   - ✅ Mínimo 2 caracteres
   - ✅ Mensaje: "El nombre solo puede contener letras"

3. **Apellido**
   - ✅ Solo acepta letras (incluye áéíóúñ) y espacios
   - ✅ Mínimo 2 caracteres
   - ✅ Mensaje: "El apellido solo puede contener letras"

4. **Dirección**
   - ✅ Acepta letras, números, espacios, comas, puntos, guiones y #
   - ✅ Mínimo 5 caracteres
   - ✅ Mensaje: "La dirección contiene caracteres no válidos"

5. **Teléfono**
   - ✅ Solo acepta números (9 dígitos)
   - ✅ Valida formato chileno (9XXXXXXXX)
   - ✅ Limita a 9 caracteres
   - ✅ Mensaje: "Ingrese un teléfono válido (9 dígitos)"

6. **Email** (opcional)
   - ✅ Valida formato de correo electrónico
   - ✅ Pattern: usuario@dominio.com
   - ✅ Mensaje: "Ingrese un correo válido"

7. **Ocupación** (opcional)
   - ✅ Solo acepta letras y espacios
   - ✅ Sin límite de caracteres especiales

---

### 🏥 Formulario de Nueva Atención (`nueva_atencion_page.dart`)

#### Paso 1: Anamnesis

1. **Motivo de Consulta**
   - ✅ Mínimo 10 caracteres
   - ✅ Máximo 500 caracteres
   - ✅ Requerido
   - ✅ Mensaje: "El motivo de consulta debe tener al menos 10 caracteres"

2. **Síntomas**
   - ✅ Sin caracteres peligrosos (<>{};\[\\])
   - ✅ Máximo 1000 caracteres
   - ✅ Requerido
   - ✅ Mensaje: "Los síntomas contienen caracteres no permitidos"

3. **Presión Arterial**
   - ✅ Solo acepta números y barra (/)
   - ✅ Formato: 120/80
   - ✅ Máximo 7 caracteres
   - ✅ Valida dos números separados por /
   - ✅ Mensaje: "Formato inválido (ej: 120/80)"

4. **Frecuencia Cardíaca**
   - ✅ Solo números enteros
   - ✅ Rango: 30-220 bpm
   - ✅ Máximo 3 dígitos
   - ✅ Mensaje: "Rango 30-220 bpm"

5. **Temperatura**
   - ✅ Solo números y punto decimal
   - ✅ Rango: 33-43°C
   - ✅ Máximo 4 caracteres (36.5)
   - ✅ Mensaje: "Rango 33-43°C"

6. **Saturación de Oxígeno (SpO₂)**
   - ✅ Solo números enteros
   - ✅ Rango: 70-100%
   - ✅ Máximo 3 dígitos
   - ✅ Mensaje: "Rango 70-100%"

#### Paso 2: Diagnóstico

1. **Diagnóstico Principal**
   - ✅ Mínimo 5 caracteres
   - ✅ Máximo 500 caracteres
   - ✅ Requerido
   - ✅ Mensaje: "El diagnóstico debe tener al menos 5 caracteres"

2. **Observaciones Clínicas**
   - ✅ Sin caracteres peligrosos
   - ✅ Máximo 1000 caracteres
   - ✅ Requerido
   - ✅ Mensaje: "Las observaciones contienen caracteres no permitidos"

#### Paso 3: Tratamiento

1. **Plan de Tratamiento**
   - ✅ Mínimo 10 caracteres
   - ✅ Máximo 2000 caracteres
   - ✅ Requerido
   - ✅ Mensaje: "El plan de tratamiento debe tener al menos 10 caracteres"

---

### 💊 Formulario de Recetas (`nueva_receta_page.dart`)

#### Medicamentos:

1. **Dosis**
   - ✅ Máximo 100 caracteres
   - ✅ Ejemplo: "1 comprimido"

2. **Frecuencia**
   - ✅ Máximo 100 caracteres
   - ✅ Ejemplo: "Cada 8 horas"

3. **Duración**
   - ✅ Máximo 50 caracteres
   - ✅ Ejemplo: "7 días"

4. **Indicaciones Generales**
   - ✅ Máximo 500 caracteres
   - ✅ Campo multilínea

---

## 🛠️ Validadores Disponibles

### En `lib/utils/validators.dart`:

#### Validadores Booleanos (retornan true/false):
- `validateRut(String rut)` - Valida RUT chileno
- `validateEmail(String email)` - Valida email
- `validatePhone(String phone)` - Valida teléfono 9 dígitos
- `isNotEmpty(String? value)` - Verifica que no esté vacío
- `minLength(String? value, int min)` - Longitud mínima
- `maxLength(String? value, int max)` - Longitud máxima
- `isNumeric(String? value)` - Es número
- `isInteger(String? value)` - Es entero

#### Validadores para TextFormField (retornan String? con mensaje de error):
- `required(String? value, [String fieldName])` - Campo requerido
- `rutValidator(String? value)` - Validador de RUT
- `emailValidator(String? value)` - Validador de email
- `phoneValidator(String? value)` - Validador de teléfono
- `nameValidator(String? value, [String fieldName])` - Solo letras
- `addressValidator(String? value)` - Dirección válida
- `safeTextValidator(String? value, [String fieldName])` - Sin caracteres peligrosos
- `positiveNumberValidator(String? value, [String fieldName])` - Número > 0
- `minLengthValidator(String? value, int min, [String fieldName])` - Longitud mínima
- `maxLengthValidator(String? value, int max, [String fieldName])` - Longitud máxima
- `cie10Validator(String? value)` - Código CIE-10
- `alphanumericValidator(String? value, [String fieldName])` - Alfanumérico
- `combine(List<String? Function(String?)> validators)` - Combina validadores

#### Formateadores:
- `formatRut(String rut)` - Formatea RUT con puntos y guión
- `formatPhone(String phone)` - Formatea teléfono 9 1234 5678

---

## 📝 Ejemplos de Uso

### Ejemplo 1: Campo de RUT
```dart
TextFormField(
  controller: _rutController,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9kK.\-]')),
  ],
  validator: Validators.rutValidator,
  decoration: InputDecoration(
    labelText: 'RUT',
    hintText: '12.345.678-9',
  ),
)
```

### Ejemplo 2: Campo de Email
```dart
TextFormField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: Validators.emailValidator,
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'usuario@ejemplo.com',
  ),
)
```

### Ejemplo 3: Campo de Teléfono
```dart
TextFormField(
  controller: _telefonoController,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(9),
  ],
  validator: Validators.phoneValidator,
  decoration: InputDecoration(
    labelText: 'Teléfono',
    hintText: '912345678',
  ),
)
```

### Ejemplo 4: Campo de Nombre
```dart
TextFormField(
  controller: _nombreController,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
  ],
  validator: (value) => Validators.nameValidator(value, 'El nombre'),
  decoration: InputDecoration(
    labelText: 'Nombre',
  ),
)
```

### Ejemplo 5: Combinar Validadores
```dart
TextFormField(
  validator: Validators.combine([
    (value) => Validators.required(value),
    (value) => Validators.minLengthValidator(value, 5),
    (value) => Validators.maxLengthValidator(value, 100),
  ]),
)
```

---

## 🎯 Caracteres Permitidos por Campo

| Campo | Caracteres Permitidos | Regex |
|-------|----------------------|-------|
| **RUT** | Números, K, puntos, guiones | `[0-9kK.\-]` |
| **Nombre/Apellido** | Letras (con tildes), espacios | `[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]` |
| **Dirección** | Letras, números, espacios, `,.-#` | `[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s,.\-#]` |
| **Teléfono** | Solo números (9 dígitos) | `[0-9]` |
| **Email** | Formato estándar de email | Ver validador |
| **Presión** | Números y barra | `[0-9/]` |
| **Temperatura** | Números y punto | `[0-9.]` |
| **Frecuencia/SpO₂** | Solo números | `[0-9]` |

---

## ⚠️ Caracteres No Permitidos (Seguridad)

Los siguientes caracteres están bloqueados en campos de texto libre por seguridad:
- `<` `>` - Previene inyección HTML
- `{` `}` - Previene inyección de código
- `;` - Previene inyección SQL
- `[` `]` - Previene ataques
- `\` - Previene escape malicioso

---

## 🚀 Próximas Mejoras Sugeridas

1. ⬜ Agregar validación en tiempo real (onChange)
2. ⬜ Implementar auto-formato para RUT mientras se escribe
3. ⬜ Agregar validación de códigos CIE-10 contra catálogo
4. ⬜ Implementar máscara visual para teléfono (+56 9 1234 5678)
5. ⬜ Agregar validación de edad mínima/máxima en fecha de nacimiento
6. ⬜ Implementar validación de presión arterial con rangos normales
7. ⬜ Agregar sugerencias de diagnósticos mientras se escribe

---

## 📚 Referencias

- **RUT Chileno**: Algoritmo Módulo 11
- **Email**: RFC 5322 simplificado
- **Teléfonos**: Formato Chile (+56 9 XXXX XXXX)
- **CIE-10**: Clasificación Internacional de Enfermedades
- **Rangos Vitales**: Estándares médicos OMS

---

**Última actualización**: 12 de Noviembre, 2025
**Versión**: 1.0.0
