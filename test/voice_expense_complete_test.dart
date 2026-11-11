import 'package:caravella_core/caravella_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:io_caravella_egm/home/cards/widgets/group_card_voice_button.dart';
import 'package:io_caravella_egm/services/voice_input_service.dart';

final _anna = ExpenseParticipant(id: 'a', name: 'Anna');
final _food = ExpenseCategory(id: 'f', name: 'Food');

bool _complete(String said) {
  final parsed = VoiceInputService.parseExpenseFromText(
    said,
    participantNames: ['Anna'],
  );
  return voiceExpenseIsComplete(
    amount: parsed['amount'] as double?,
    name: parsed['name'] as String?,
    paidBy: _anna,
    category: _food,
  );
}

void main() {
  test('an amount with a description is saved directly', () {
    expect(_complete('20 euro cena'), isTrue);
    expect(_complete('cena 20 euro'), isTrue);
  });

  test('an amount alone opens the form: the expense needs a name', () {
    // Saved directly, it had no name: SQLite refused it (expenses.name is
    // NOT NULL) while the app said "saved".
    expect(_complete('20 euro'), isFalse);
    expect(_complete('speso 20 euro'), isFalse);
  });

  test('missing amount, payer or category opens the form', () {
    expect(
      voiceExpenseIsComplete(
        amount: null,
        name: 'Cena',
        paidBy: _anna,
        category: _food,
      ),
      isFalse,
    );
    expect(
      voiceExpenseIsComplete(
        amount: 20,
        name: '  ',
        paidBy: _anna,
        category: _food,
      ),
      isFalse,
    );
    expect(
      voiceExpenseIsComplete(
        amount: 20,
        name: 'Cena',
        paidBy: null,
        category: _food,
      ),
      isFalse,
    );
  });
}
