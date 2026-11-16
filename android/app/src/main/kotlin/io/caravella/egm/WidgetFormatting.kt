package io.caravella.egm

import java.util.Locale

/** Formats [amount] with 2 decimal places and a trailing currency symbol/code, e.g. "12.50 €". */
internal fun formatWidgetAmount(amount: Double, currency: String): String {
    return String.format(Locale.getDefault(), "%.2f %s", amount, currency)
}
