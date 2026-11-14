import 'package:flutter/services.dart';

/// Normaliza el separador decimal de una entrada de usuario: convierte
/// cualquier coma en punto. El punto es el único separador válido en la app.
String normalizeDecimalSeparators(String text) => text.replaceAll(',', '.');

/// Como [double.tryParse] pero acepta entrada con coma ("4,5") además de
/// con punto ("4.5"). Devuelve null si no es un número válido.
double? tryParseDecimal(String? text) {
  if (text == null) return null;
  return double.tryParse(normalizeDecimalSeparators(text.trim()));
}

/// Como [double.parse] pero acepta entrada con coma. Lanza
/// [FormatException] si no es un número válido.
double parseDecimal(String text) {
  return double.parse(normalizeDecimalSeparators(text.trim()));
}

/// Formatter que reescribe sobre la marcha las comas del teclado en
/// español como puntos, para que el campo siempre muestre el punto como
/// separador decimal. La sustitución es 1:1 (misma longitud), así que la
/// selección no cambia de posición.
class DecimalPointFormatter extends TextInputFormatter {
  const DecimalPointFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = normalizeDecimalSeparators(newValue.text);
    if (newText == newValue.text) return newValue;
    return newValue.copyWith(
      text: newText,
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}
