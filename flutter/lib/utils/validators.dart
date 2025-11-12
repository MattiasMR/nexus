/// Utilidades para validación de datos
class Validators {
  /// Valida un RUT chileno
  static bool validateRut(String rut) {
    if (rut.isEmpty) return false;

    // Remover puntos y guión
    final cleanRut = rut.replaceAll('.', '').replaceAll('-', '');

    // Debe tener al menos 2 caracteres (número + verificador)
    if (cleanRut.length < 2) return false;

    final body = cleanRut.substring(0, cleanRut.length - 1);
    final dv = cleanRut.substring(cleanRut.length - 1).toUpperCase();

    // Calcular dígito verificador
    int sum = 0;
    int multiplier = 2;

    for (int i = body.length - 1; i >= 0; i--) {
      sum += int.parse(body[i]) * multiplier;
      multiplier = multiplier == 7 ? 2 : multiplier + 1;
    }

    final expectedDv = 11 - (sum % 11);
    final dvStr = expectedDv == 11 ? '0' : expectedDv == 10 ? 'K' : expectedDv.toString();

    return dv == dvStr;
  }

  /// Formatea un RUT chileno (12.345.678-9)
  static String formatRut(String rut) {
    // Remover todo excepto números y K
    String clean = rut.replaceAll(RegExp(r'[^0-9kK]'), '');
    
    if (clean.isEmpty) return '';

    // Separar cuerpo y dígito verificador
    final body = clean.substring(0, clean.length - 1);
    final dv = clean.substring(clean.length - 1).toUpperCase();

    // Agregar puntos cada 3 dígitos desde la derecha
    String formatted = '';
    for (int i = body.length - 1, count = 0; i >= 0; i--, count++) {
      if (count > 0 && count % 3 == 0) {
        formatted = '.$formatted';
      }
      formatted = body[i] + formatted;
    }

    return formatted.isNotEmpty ? '$formatted-$dv' : dv;
  }

  /// Valida un email
  static bool validateEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Valida un teléfono chileno (9 dígitos)
  static bool validatePhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    return cleanPhone.length == 9;
  }

  /// Formatea un teléfono chileno
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length != 9) return phone;
    
    // Formato: 9 1234 5678
    return '${cleanPhone.substring(0, 1)} ${cleanPhone.substring(1, 5)} ${cleanPhone.substring(5)}';
  }

  /// Valida que un campo no esté vacío
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Valida que un campo tenga una longitud mínima
  static bool minLength(String? value, int min) {
    return value != null && value.trim().length >= min;
  }

  /// Valida que un campo tenga una longitud máxima
  static bool maxLength(String? value, int max) {
    return value != null && value.trim().length <= max;
  }

  /// Valida que un valor sea numérico
  static bool isNumeric(String? value) {
    if (value == null || value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Valida que un valor sea un entero
  static bool isInteger(String? value) {
    if (value == null || value.isEmpty) return false;
    return int.tryParse(value) != null;
  }

  // ============================================
  // VALIDADORES PARA TextFormField
  // ============================================

  /// Validador de campo requerido
  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  /// Validador de RUT para TextFormField
  static String? rutValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El RUT es requerido';
    }
    if (!validateRut(value)) {
      return 'RUT inválido';
    }
    return null;
  }

  /// Validador de email para TextFormField
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es requerido';
    }
    if (!validateEmail(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  /// Validador de teléfono para TextFormField
  static String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es requerido';
    }
    if (!validatePhone(value)) {
      return 'Ingrese un teléfono válido (9 dígitos)';
    }
    return null;
  }

  /// Validador de nombre (solo letras y espacios)
  static String? nameValidator(String? value, [String fieldName = 'El nombre']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return '$fieldName solo puede contener letras';
    }

    if (value.trim().length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }

    return null;
  }

  /// Validador de dirección
  static String? addressValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La dirección es requerida';
    }

    // Permitir letras, números, espacios, comas, puntos, guiones y #
    final addressRegex = RegExp(r'^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s,.\-#]+$');
    if (!addressRegex.hasMatch(value.trim())) {
      return 'La dirección contiene caracteres no válidos';
    }

    if (value.trim().length < 5) {
      return 'La dirección debe tener al menos 5 caracteres';
    }

    return null;
  }

  /// Validador de texto sin caracteres especiales peligrosos
  static String? safeTextValidator(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    // No permitir caracteres potencialmente peligrosos
    final dangerousChars = RegExp(r'[<>{};\[\]\\]');
    if (dangerousChars.hasMatch(value)) {
      return '$fieldName contiene caracteres no permitidos';
    }

    return null;
  }

  /// Validador de número positivo
  static String? positiveNumberValidator(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    final num = double.tryParse(value.trim());
    if (num == null) {
      return '$fieldName debe ser un número válido';
    }

    if (num <= 0) {
      return '$fieldName debe ser mayor a 0';
    }

    return null;
  }

  /// Validador de longitud mínima
  static String? minLengthValidator(String? value, int min, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    if (value.trim().length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }

    return null;
  }

  /// Validador de longitud máxima
  static String? maxLengthValidator(String? value, int max, [String fieldName = 'Este campo']) {
    if (value == null) return null;

    if (value.trim().length > max) {
      return '$fieldName no puede exceder $max caracteres';
    }

    return null;
  }

  /// Combina múltiples validadores
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  /// Validador de código CIE-10
  static String? cie10Validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El código CIE-10 es requerido';
    }

    // Formato CIE-10: 1 letra seguida de 2-3 números, opcionalmente seguido de punto y 1-2 dígitos
    final cie10Regex = RegExp(r'^[A-Z]\d{2,3}(\.\d{1,2})?$');
    if (!cie10Regex.hasMatch(value.trim().toUpperCase())) {
      return 'Código CIE-10 inválido (ej: J00, A09.9)';
    }

    return null;
  }

  /// Validador de texto alfanumérico
  static String? alphanumericValidator(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }

    final alphanumericRegex = RegExp(r'^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]+$');
    if (!alphanumericRegex.hasMatch(value.trim())) {
      return '$fieldName solo puede contener letras y números';
    }

    return null;
  }
}
