import '../../../l10n/app_localizations.dart';

/// Lista di valute (solo simbolo + codice). I nomi sono localizzati via ARB.
final List<Map<String, String>> kCurrencies = [
  {'symbol': 'د.إ', 'code': 'AED'},
  {'symbol': '؋', 'code': 'AFN'},
  {'symbol': 'L', 'code': 'ALL'},
  {'symbol': '֏', 'code': 'AMD'},
  {'symbol': 'ƒ', 'code': 'ANG'},
  {'symbol': 'Kz', 'code': 'AOA'},
  {'symbol': r'$', 'code': 'ARS'},
  {'symbol': r'$', 'code': 'AUD'},
  {'symbol': 'ƒ', 'code': 'AWG'},
  {'symbol': '₼', 'code': 'AZN'},
  {'symbol': 'KM', 'code': 'BAM'},
  {'symbol': r'$', 'code': 'BBD'},
  {'symbol': '৳', 'code': 'BDT'},
  {'symbol': 'лв', 'code': 'BGN'},
  {'symbol': 'ب.د', 'code': 'BHD'},
  {'symbol': 'Fr', 'code': 'BIF'},
  {'symbol': r'$', 'code': 'BMD'},
  {'symbol': r'$', 'code': 'BND'},
  {'symbol': 'Bs.', 'code': 'BOB'},
  {'symbol': r'R$', 'code': 'BRL'},
  {'symbol': r'$', 'code': 'BSD'},
  {'symbol': 'Nu.', 'code': 'BTN'},
  {'symbol': 'P', 'code': 'BWP'},
  {'symbol': 'Br', 'code': 'BYN'},
  {'symbol': r'$', 'code': 'BZD'},
  {'symbol': r'$', 'code': 'CAD'},
  {'symbol': 'Fr', 'code': 'CDF'},
  {'symbol': 'CHF', 'code': 'CHF'},
  {'symbol': r'$', 'code': 'CLP'},
  {'symbol': '¥', 'code': 'CNY'},
  {'symbol': r'$', 'code': 'COP'},
  {'symbol': '₡', 'code': 'CRC'},
  {'symbol': r'$', 'code': 'CUP'},
  {'symbol': r'$', 'code': 'CVE'},
  {'symbol': 'Kč', 'code': 'CZK'},
  {'symbol': 'Fr', 'code': 'DJF'},
  {'symbol': 'kr', 'code': 'DKK'},
  {'symbol': r'$', 'code': 'DOP'},
  {'symbol': 'دج', 'code': 'DZD'},
  {'symbol': '£', 'code': 'EGP'},
  {'symbol': 'Nfk', 'code': 'ERN'},
  {'symbol': 'Br', 'code': 'ETB'},
  {'symbol': '€', 'code': 'EUR'},
  {'symbol': r'$', 'code': 'FJD'},
  {'symbol': '£', 'code': 'FKP'},
  {'symbol': '£', 'code': 'GBP'},
  {'symbol': '₾', 'code': 'GEL'},
  {'symbol': '₵', 'code': 'GHS'},
  {'symbol': '£', 'code': 'GIP'},
  {'symbol': 'D', 'code': 'GMD'},
  {'symbol': 'Fr', 'code': 'GNF'},
  {'symbol': 'Q', 'code': 'GTQ'},
  {'symbol': r'$', 'code': 'GYD'},
  {'symbol': r'$', 'code': 'HKD'},
  {'symbol': 'L', 'code': 'HNL'},
  {'symbol': 'G', 'code': 'HTG'},
  {'symbol': 'Ft', 'code': 'HUF'},
  {'symbol': 'Rp', 'code': 'IDR'},
  {'symbol': '₪', 'code': 'ILS'},
  {'symbol': '₹', 'code': 'INR'},
  {'symbol': 'ع.د', 'code': 'IQD'},
  {'symbol': '﷼', 'code': 'IRR'},
  {'symbol': 'kr', 'code': 'ISK'},
  {'symbol': r'$', 'code': 'JMD'},
  {'symbol': 'د.أ', 'code': 'JOD'},
  {'symbol': '¥', 'code': 'JPY'},
  {'symbol': 'Sh', 'code': 'KES'},
  {'symbol': '⃀', 'code': 'KGS'},
  {'symbol': '៛', 'code': 'KHR'},
  {'symbol': r'$', 'code': 'KID'},
  {'symbol': 'Fr', 'code': 'KMF'},
  {'symbol': '₩', 'code': 'KPW'},
  {'symbol': '₩', 'code': 'KRW'},
  {'symbol': 'د.ك', 'code': 'KWD'},
  {'symbol': r'$', 'code': 'KYD'},
  {'symbol': '₸', 'code': 'KZT'},
  {'symbol': '₭', 'code': 'LAK'},
  {'symbol': 'ل.ل', 'code': 'LBP'},
  {'symbol': 'Rs', 'code': 'LKR'},
  {'symbol': r'$', 'code': 'LRD'},
  {'symbol': 'L', 'code': 'LSL'},
  {'symbol': 'ل.د', 'code': 'LYD'},
  {'symbol': 'د.م.', 'code': 'MAD'},
  {'symbol': 'L', 'code': 'MDL'},
  {'symbol': 'Ar', 'code': 'MGA'},
  {'symbol': 'ден', 'code': 'MKD'},
  {'symbol': 'K', 'code': 'MMK'},
  {'symbol': '₮', 'code': 'MNT'},
  {'symbol': 'P', 'code': 'MOP'},
  {'symbol': 'UM', 'code': 'MRU'},
  {'symbol': '₨', 'code': 'MUR'},
  {'symbol': 'Rf', 'code': 'MVR'},
  {'symbol': 'MK', 'code': 'MWK'},
  {'symbol': r'$', 'code': 'MXN'},
  {'symbol': 'RM', 'code': 'MYR'},
  {'symbol': 'MT', 'code': 'MZN'},
  {'symbol': r'$', 'code': 'NAD'},
  {'symbol': '₦', 'code': 'NGN'},
  {'symbol': r'C$', 'code': 'NIO'},
  {'symbol': 'kr', 'code': 'NOK'},
  {'symbol': '₨', 'code': 'NPR'},
  {'symbol': r'$', 'code': 'NZD'},
  {'symbol': 'ر.ع.', 'code': 'OMR'},
  {'symbol': 'B/.', 'code': 'PAB'},
  {'symbol': 'S/.', 'code': 'PEN'},
  {'symbol': 'K', 'code': 'PGK'},
  {'symbol': '₱', 'code': 'PHP'},
  {'symbol': 'Rs', 'code': 'PKR'},
  {'symbol': 'zł', 'code': 'PLN'},
  {'symbol': 'Gs', 'code': 'PYG'},
  {'symbol': 'ر.ق', 'code': 'QAR'},
  {'symbol': 'L', 'code': 'RON'},
  {'symbol': 'дин', 'code': 'RSD'},
  {'symbol': '₽', 'code': 'RUB'},
  {'symbol': 'Fr', 'code': 'RWF'},
  {'symbol': '﷼', 'code': 'SAR'},
  {'symbol': r'$', 'code': 'SBD'},
  {'symbol': '₨', 'code': 'SCR'},
  {'symbol': '£', 'code': 'SDG'},
  {'symbol': 'kr', 'code': 'SEK'},
  {'symbol': r'$', 'code': 'SGD'},
  {'symbol': '£', 'code': 'SHP'},
  {'symbol': 'Le', 'code': 'SLE'},
  {'symbol': 'Le', 'code': 'SLL'},
  {'symbol': 'Sh', 'code': 'SOS'},
  {'symbol': r'$', 'code': 'SRD'},
  {'symbol': '£', 'code': 'SSP'},
  {'symbol': 'Db', 'code': 'STN'},
  {'symbol': r'$', 'code': 'SVC'},
  {'symbol': '£S', 'code': 'SYP'},
  {'symbol': 'L', 'code': 'SZL'},
  {'symbol': '฿', 'code': 'THB'},
  {'symbol': 'ЅМ', 'code': 'TJS'},
  {'symbol': 'm', 'code': 'TMT'},
  {'symbol': 'د.ت', 'code': 'TND'},
  {'symbol': r'T$', 'code': 'TOP'},
  {'symbol': '₺', 'code': 'TRY'},
  {'symbol': r'$', 'code': 'TTD'},
  {'symbol': r'$', 'code': 'TVD'},
  {'symbol': r'$', 'code': 'TWD'},
  {'symbol': 'Sh', 'code': 'TZS'},
  {'symbol': '₴', 'code': 'UAH'},
  {'symbol': 'Sh', 'code': 'UGX'},
  {'symbol': r'$', 'code': 'USD'},
  {'symbol': r'$', 'code': 'UYU'},
  {'symbol': 'лв', 'code': 'UZS'},
  {'symbol': 'Bs.', 'code': 'VED'},
  {'symbol': 'Bs.', 'code': 'VES'},
  {'symbol': '₫', 'code': 'VND'},
  {'symbol': 'Vt', 'code': 'VUV'},
  {'symbol': r'WS$', 'code': 'WST'},
  {'symbol': 'Fr', 'code': 'XAF'},
  {'symbol': 'Fr', 'code': 'XOF'},
  {'symbol': '₣', 'code': 'XPF'},
  {'symbol': '﷼', 'code': 'YER'},
  {'symbol': 'R', 'code': 'ZAR'},
  {'symbol': 'K', 'code': 'ZMW'},
  {'symbol': r'$', 'code': 'ZWL'},
];

String localizedCurrencyName(AppLocalizations l, String code) {
  switch (code) {
    case 'AED':
      return l.currency_AED;
    case 'AFN':
      return l.currency_AFN;
    case 'ALL':
      return l.currency_ALL;
    case 'AMD':
      return l.currency_AMD;
    case 'ANG':
      return l.currency_ANG;
    case 'AOA':
      return l.currency_AOA;
    case 'ARS':
      return l.currency_ARS;
    case 'AUD':
      return l.currency_AUD;
    case 'AWG':
      return l.currency_AWG;
    case 'AZN':
      return l.currency_AZN;
    case 'BAM':
      return l.currency_BAM;
    case 'BBD':
      return l.currency_BBD;
    case 'BDT':
      return l.currency_BDT;
    case 'BGN':
      return l.currency_BGN;
    case 'BHD':
      return l.currency_BHD;
    case 'BIF':
      return l.currency_BIF;
    case 'BMD':
      return l.currency_BMD;
    case 'BND':
      return l.currency_BND;
    case 'BOB':
      return l.currency_BOB;
    case 'BRL':
      return l.currency_BRL;
    case 'BSD':
      return l.currency_BSD;
    case 'BTN':
      return l.currency_BTN;
    case 'BWP':
      return l.currency_BWP;
    case 'BYN':
      return l.currency_BYN;
    case 'BZD':
      return l.currency_BZD;
    case 'CAD':
      return l.currency_CAD;
    case 'CDF':
      return l.currency_CDF;
    case 'CHF':
      return l.currency_CHF;
    case 'CLP':
      return l.currency_CLP;
    case 'CNY':
      return l.currency_CNY;
    case 'COP':
      return l.currency_COP;
    case 'CRC':
      return l.currency_CRC;
    case 'CUP':
      return l.currency_CUP;
    case 'CVE':
      return l.currency_CVE;
    case 'CZK':
      return l.currency_CZK;
    case 'DJF':
      return l.currency_DJF;
    case 'DKK':
      return l.currency_DKK;
    case 'DOP':
      return l.currency_DOP;
    case 'DZD':
      return l.currency_DZD;
    case 'EGP':
      return l.currency_EGP;
    case 'ERN':
      return l.currency_ERN;
    case 'ETB':
      return l.currency_ETB;
    case 'EUR':
      return l.currency_EUR;
    case 'FJD':
      return l.currency_FJD;
    case 'FKP':
      return l.currency_FKP;
    case 'GBP':
      return l.currency_GBP;
    case 'GEL':
      return l.currency_GEL;
    case 'GHS':
      return l.currency_GHS;
    case 'GIP':
      return l.currency_GIP;
    case 'GMD':
      return l.currency_GMD;
    case 'GNF':
      return l.currency_GNF;
    case 'GTQ':
      return l.currency_GTQ;
    case 'GYD':
      return l.currency_GYD;
    case 'HKD':
      return l.currency_HKD;
    case 'HNL':
      return l.currency_HNL;
    case 'HTG':
      return l.currency_HTG;
    case 'HUF':
      return l.currency_HUF;
    case 'IDR':
      return l.currency_IDR;
    case 'ILS':
      return l.currency_ILS;
    case 'INR':
      return l.currency_INR;
    case 'IQD':
      return l.currency_IQD;
    case 'IRR':
      return l.currency_IRR;
    case 'ISK':
      return l.currency_ISK;
    case 'JMD':
      return l.currency_JMD;
    case 'JOD':
      return l.currency_JOD;
    case 'JPY':
      return l.currency_JPY;
    case 'KES':
      return l.currency_KES;
    case 'KGS':
      return l.currency_KGS;
    case 'KHR':
      return l.currency_KHR;
    case 'KID':
      return l.currency_KID;
    case 'KMF':
      return l.currency_KMF;
    case 'KPW':
      return l.currency_KPW;
    case 'KRW':
      return l.currency_KRW;
    case 'KWD':
      return l.currency_KWD;
    case 'KYD':
      return l.currency_KYD;
    case 'KZT':
      return l.currency_KZT;
    case 'LAK':
      return l.currency_LAK;
    case 'LBP':
      return l.currency_LBP;
    case 'LKR':
      return l.currency_LKR;
    case 'LRD':
      return l.currency_LRD;
    case 'LSL':
      return l.currency_LSL;
    case 'LYD':
      return l.currency_LYD;
    case 'MAD':
      return l.currency_MAD;
    case 'MDL':
      return l.currency_MDL;
    case 'MGA':
      return l.currency_MGA;
    case 'MKD':
      return l.currency_MKD;
    case 'MMK':
      return l.currency_MMK;
    case 'MNT':
      return l.currency_MNT;
    case 'MOP':
      return l.currency_MOP;
    case 'MRU':
      return l.currency_MRU;
    case 'MUR':
      return l.currency_MUR;
    case 'MVR':
      return l.currency_MVR;
    case 'MWK':
      return l.currency_MWK;
    case 'MXN':
      return l.currency_MXN;
    case 'MYR':
      return l.currency_MYR;
    case 'MZN':
      return l.currency_MZN;
    case 'NAD':
      return l.currency_NAD;
    case 'NGN':
      return l.currency_NGN;
    case 'NIO':
      return l.currency_NIO;
    case 'NOK':
      return l.currency_NOK;
    case 'NPR':
      return l.currency_NPR;
    case 'NZD':
      return l.currency_NZD;
    case 'OMR':
      return l.currency_OMR;
    case 'PAB':
      return l.currency_PAB;
    case 'PEN':
      return l.currency_PEN;
    case 'PGK':
      return l.currency_PGK;
    case 'PHP':
      return l.currency_PHP;
    case 'PKR':
      return l.currency_PKR;
    case 'PLN':
      return l.currency_PLN;
    case 'PYG':
      return l.currency_PYG;
    case 'QAR':
      return l.currency_QAR;
    case 'RON':
      return l.currency_RON;
    case 'RSD':
      return l.currency_RSD;
    case 'RUB':
      return l.currency_RUB;
    case 'RWF':
      return l.currency_RWF;
    case 'SAR':
      return l.currency_SAR;
    case 'SBD':
      return l.currency_SBD;
    case 'SCR':
      return l.currency_SCR;
    case 'SDG':
      return l.currency_SDG;
    case 'SEK':
      return l.currency_SEK;
    case 'SGD':
      return l.currency_SGD;
    case 'SHP':
      return l.currency_SHP;
    case 'SLE':
      return l.currency_SLE;
    case 'SLL':
      return l.currency_SLL;
    case 'SOS':
      return l.currency_SOS;
    case 'SRD':
      return l.currency_SRD;
    case 'SSP':
      return l.currency_SSP;
    case 'STN':
      return l.currency_STN;
    case 'SVC':
      return l.currency_SVC;
    case 'SYP':
      return l.currency_SYP;
    case 'SZL':
      return l.currency_SZL;
    case 'THB':
      return l.currency_THB;
    case 'TJS':
      return l.currency_TJS;
    case 'TMT':
      return l.currency_TMT;
    case 'TND':
      return l.currency_TND;
    case 'TOP':
      return l.currency_TOP;
    case 'TRY':
      return l.currency_TRY;
    case 'TTD':
      return l.currency_TTD;
    case 'TVD':
      return l.currency_TVD;
    case 'TWD':
      return l.currency_TWD;
    case 'TZS':
      return l.currency_TZS;
    case 'UAH':
      return l.currency_UAH;
    case 'UGX':
      return l.currency_UGX;
    case 'USD':
      return l.currency_USD;
    case 'UYU':
      return l.currency_UYU;
    case 'UZS':
      return l.currency_UZS;
    case 'VED':
      return l.currency_VED;
    case 'VES':
      return l.currency_VES;
    case 'VND':
      return l.currency_VND;
    case 'VUV':
      return l.currency_VUV;
    case 'WST':
      return l.currency_WST;
    case 'XAF':
      return l.currency_XAF;
    case 'XOF':
      return l.currency_XOF;
    case 'XPF':
      return l.currency_XPF;
    case 'YER':
      return l.currency_YER;
    case 'ZAR':
      return l.currency_ZAR;
    case 'ZMW':
      return l.currency_ZMW;
    case 'ZWL':
      return l.currency_ZWL;
  }
  return code;
}
