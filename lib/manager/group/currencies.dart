/// Centralized list of supported currencies for the app.
///
/// Each entry contains:
/// - symbol: display symbol
/// - code: ISO 4217 currency code
/// - name: localized (currently Italian) display name
///
/// If future localization is required, consider replacing `name` with a key
/// looked up via the localization system instead of hard-coded strings.
const List<Map<String, String>> kCurrencies = [
  {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
  {'symbol': '£', 'code': 'GBP', 'name': 'Sterlina'},
  {'symbol': r'$', 'code': 'USD', 'name': 'Dollaro USA'},
];
