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
}
