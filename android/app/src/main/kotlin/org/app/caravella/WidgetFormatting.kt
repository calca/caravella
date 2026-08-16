package io.caravella.egm

import android.graphics.BitmapFactory
import androidx.compose.ui.graphics.Color
import java.util.Locale

/** Formats [amount] with 2 decimal places and a trailing currency symbol/code, e.g. "12.50 €". */
internal fun formatWidgetAmount(amount: Double, currency: String): String {
    return String.format(Locale.getDefault(), "%.2f %s", amount, currency)
}

/** Converts a packed ARGB [Int] (as stored by the Dart side) into a Compose [Color]. */
internal fun widgetColor(colorValue: Int): Color = Color(colorValue)

/**
 * Computes the smallest power-of-two [BitmapFactory.Options.inSampleSize] that
 * still decodes an image at least [reqWidth]x[reqHeight] on each axis, so a
 * multi-megapixel photo isn't decoded at full resolution just to be cropped
 * into a small widget cell.
 */
internal fun calculateBitmapSampleSize(
    options: BitmapFactory.Options,
    reqWidth: Int,
    reqHeight: Int,
): Int {
    val height = options.outHeight
    val width = options.outWidth
    var inSampleSize = 1
    if (height > reqHeight || width > reqWidth) {
        val halfHeight = height / 2
        val halfWidth = width / 2
        while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
            inSampleSize *= 2
        }
    }
    return inSampleSize
}
