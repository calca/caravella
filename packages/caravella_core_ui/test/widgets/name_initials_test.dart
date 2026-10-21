import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('two letters from a single name', () {
    expect(nameInitials('Gigi'), 'GI');
    expect(nameInitials('anna'), 'AN');
  });

  test('first and last word of a full name', () {
    expect(nameInitials('John Doe'), 'JD');
    expect(nameInitials('  Maria  de la Cruz '), 'MC');
  });

  test('short and empty names', () {
    expect(nameInitials('A'), 'A');
    expect(nameInitials('   '), '');
  });

  test('emoji and accents count as one letter', () {
    expect(nameInitials('Élodie'), 'ÉL');
    expect(nameInitials('👍🏽Bob'), '👍🏽B');
  });
}
