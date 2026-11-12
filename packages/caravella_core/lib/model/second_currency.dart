/// A currency a group also takes expenses in, besides its own, and the rate
/// to its own: [rate] units of this currency make one of the group's
/// (`1 € = 11.63 kr` → `rate: 11.63`). Set in the group's General settings
/// and synced with the group.
///
/// Expenses entered in it keep their own copy ([OriginalAmount]), so a
/// later change of [rate] only applies to new ones.
class SecondCurrency {
  /// ISO 4217 code, e.g. `NOK` (symbols are shared: "kr" is also SEK, DKK).
  final String code;

  /// The symbol shown next to amounts, e.g. `kr`.
  final String symbol;

  /// Units of this currency in one unit of the group's currency.
  final double rate;

  const SecondCurrency({
    required this.code,
    required this.symbol,
    required this.rate,
  });

  /// [amount] of this currency in the group's currency, to the cent.
  double toGroup(double amount) => roundToCents(amount / rate);

  Map<String, dynamic> toJson() => {
    'code': code,
    'symbol': symbol,
    'rate': rate,
  };

  /// The currency in [json], or null when there is none or it is unreadable
  /// (no code or symbol, or no positive rate).
  static SecondCurrency? fromJson(Object? json) {
    if (json is! Map) return null;
    final code = json['code'];
    final symbol = json['symbol'];
    final rate = json['rate'];
    if (code is! String || code.isEmpty) return null;
    if (symbol is! String || symbol.isEmpty) return null;
    if (rate is! num || rate <= 0) return null;
    return SecondCurrency(code: code, symbol: symbol, rate: rate.toDouble());
  }

  SecondCurrency copyWith({double? rate}) =>
      SecondCurrency(code: code, symbol: symbol, rate: rate ?? this.rate);

  @override
  bool operator ==(Object other) =>
      other is SecondCurrency &&
      other.code == code &&
      other.symbol == symbol &&
      other.rate == rate;

  @override
  int get hashCode => Object.hash(code, symbol, rate);

  @override
  String toString() => 'SecondCurrency($code $symbol @ $rate)';
}

/// What an expense entered in a [SecondCurrency] was on the receipt: its
/// [amount] in that currency and the [rate] used. The expense's own amount
/// is the group-currency one, which every total, balance and chart counts.
class OriginalAmount {
  final double amount;
  final String code;
  final String symbol;

  /// Units of [code] in one unit of the group's currency, when entered.
  final double rate;

  const OriginalAmount({
    required this.amount,
    required this.code,
    required this.symbol,
    required this.rate,
  });

  /// The amount in the group's currency, to the cent.
  double get groupAmount => roundToCents(amount / rate);

  /// The currency this was entered in, at the rate used then.
  SecondCurrency get currency =>
      SecondCurrency(code: code, symbol: symbol, rate: rate);

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'code': code,
    'symbol': symbol,
    'rate': rate,
  };

  /// The original amount in [json], or null when there is none or it is
  /// unreadable.
  static OriginalAmount? fromJson(Object? json) {
    if (json is! Map) return null;
    final amount = json['amount'];
    final currency = SecondCurrency.fromJson(json);
    if (amount is! num || amount <= 0 || currency == null) return null;
    return OriginalAmount(
      amount: amount.toDouble(),
      code: currency.code,
      symbol: currency.symbol,
      rate: currency.rate,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OriginalAmount &&
      other.amount == amount &&
      other.code == code &&
      other.symbol == symbol &&
      other.rate == rate;

  @override
  int get hashCode => Object.hash(amount, code, symbol, rate);

  @override
  String toString() => 'OriginalAmount($amount $code @ $rate)';
}

/// [value] rounded to two decimals.
double roundToCents(double value) => (value * 100).roundToDouble() / 100;
