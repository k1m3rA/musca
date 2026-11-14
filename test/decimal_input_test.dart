import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musca/utils/decimal_input.dart';

void main() {
  test('tryParseDecimal acepta punto y coma', () {
    expect(tryParseDecimal('4.5'), 4.5);
    expect(tryParseDecimal('4,5'), 4.5);
    expect(tryParseDecimal(' 4,5 '), 4.5);
    expect(tryParseDecimal('0'), 0.0);
    expect(tryParseDecimal('-1,25'), -1.25);
    expect(tryParseDecimal('abc'), isNull);
    expect(tryParseDecimal(''), isNull);
    expect(tryParseDecimal(null), isNull);
  });

  test('parseDecimal lanza con entrada no válida', () {
    expect(parseDecimal('4,5'), 4.5);
    expect(() => parseDecimal('abc'), throwsFormatException);
  });

  test('DecimalPointFormatter reescribe la coma conservando la selección', () {
    const formatter = DecimalPointFormatter();
    const value = TextEditingValue(
      text: '12,5',
      selection: TextSelection.collapsed(offset: 4),
    );
    final result = formatter.formatEditUpdate(TextEditingValue.empty, value);
    expect(result.text, '12.5');
    expect(result.selection.baseOffset, 4);

    const sinComa = TextEditingValue(text: '12.5');
    expect(formatter.formatEditUpdate(TextEditingValue.empty, sinComa).text,
        '12.5');
  });
}
