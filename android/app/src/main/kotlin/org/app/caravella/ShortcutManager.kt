package io.caravella.egm

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.graphics.Rect
import android.graphics.RectF
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat
import java.io.File

object ShortcutManager {
    private const val ACTION_ADD_EXPENSE = "io.caravella.egm.ADD_EXPENSE"

    @RequiresApi(Build.VERSION_CODES.N_MR1)
    fun updateShortcuts(context: Context, groups: List<GroupInfo>) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return
        }

        // Groups are already filtered and sorted by Dart layer
        // Just create shortcuts for all provided groups
        val shortcuts = groups.mapIndexed { index, group ->
            createShortcut(context, group, index)
        }

        // Update shortcuts
        try {
            ShortcutManagerCompat.removeAllDynamicShortcuts(context)
            ShortcutManagerCompat.addDynamicShortcuts(context, shortcuts)
        } catch (e: Exception) {
            // Silently fail - shortcuts are not critical functionality
        }
    }

    @RequiresApi(Build.VERSION_CODES.N_MR1)
    private fun createShortcut(
        context: Context,
        group: GroupInfo,
        rank: Int
    ): ShortcutInfoCompat {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_ADD_EXPENSE
            putExtra("groupId", group.id)
            putExtra("groupTitle", group.title)
            // FLAG_ACTIVITY_CLEAR_TOP ensures we don't create multiple instances
            flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val shortLabel = if (group.isPinned) {
            "📌 ${group.title}"
        } else {
            group.title
        }

        val longLabel = "Add expense to ${group.title}"

        // Create dynamic icon based on group data
        val icon = createDynamicIcon(context, group)

        return ShortcutInfoCompat.Builder(context, "group_${group.id}")
            .setShortLabel(shortLabel.take(25)) // Max 25 chars for short label
            .setLongLabel(longLabel.take(125)) // Max 125 chars for long label
            .setIcon(icon)
            .setIntent(intent)
            .setRank(rank)
            .build()
    }

    /**
     * Creates a dynamic icon for the shortcut.
     * If the group has an image file, use that (as a circular icon).
     * Otherwise, create an icon with the group's initials and background color.
     */
    private fun createDynamicIcon(context: Context, group: GroupInfo): IconCompat {
        val iconSize = 192 // Size in pixels for the icon
        
        // Try to load image from file if available
        if (group.file != null && File(group.file).exists()) {
            return createImageIcon(group.file, iconSize)
        }
        
        // Create icon with initials and background color
        return createInitialsIcon(context, group, iconSize)
    }

    /**
     * Creates a circular icon from an image file.
     */
    private fun createImageIcon(filePath: String, size: Int): IconCompat {
        try {
            // Load the image
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeFile(filePath, options)
            
            // Calculate sample size for efficient loading
            options.inSampleSize = calculateInSampleSize(options, size, size)
            options.inJustDecodeBounds = false
            
            val bitmap = BitmapFactory.decodeFile(filePath, options)
            if (bitmap != null) {
                val circularBitmap = getCircularBitmap(bitmap, size)
                bitmap.recycle()
                return IconCompat.createWithBitmap(circularBitmap)
            }
        } catch (e: Exception) {
            // Fall through to default icon
        }
        
        // Fallback to default icon if image loading fails
        return IconCompat.createWithResource(null, android.R.drawable.ic_menu_add)
    }

    /**
     * Creates an icon with the group's initials on a colored background.
     */
    private fun createInitialsIcon(context: Context, group: GroupInfo, size: Int): IconCompat {
        // Create a bitmap
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        
        // Get background color (default to Material primary if not set)
        val backgroundColor = group.color?.let { 
            // Check if it's a legacy ARGB value or a palette index
            if (it >= 0 && it < 12) {
                // It's a palette index - use Material 3 theme colors
                getMaterial3Color(context, it)
            } else {
                // It's a legacy ARGB value
                it
            }
        } ?: getMaterial3Color(context, 0) // Default to primary color
        
        // Draw circular background
        val paint = Paint().apply {
            isAntiAlias = true
            color = backgroundColor
            style = Paint.Style.FILL
        }
        canvas.drawCircle(size / 2f, size / 2f, size / 2f, paint)
        
        // Get initials (first 2 characters of title, uppercase)
        val initials = if (group.title.length >= 2) {
            group.title.substring(0, 2).uppercase()
        } else {
            group.title.uppercase()
        }
        
        // Draw initials
        val textPaint = Paint().apply {
            isAntiAlias = true
            color = getContrastingTextColor(backgroundColor)
            textSize = size * 0.4f
            textAlign = Paint.Align.CENTER
            isFakeBoldText = true
        }
        
        val textBounds = Rect()
        textPaint.getTextBounds(initials, 0, initials.length, textBounds)
        val textY = size / 2f - textBounds.exactCenterY()
        
        canvas.drawText(initials, size / 2f, textY, textPaint)
        
        return IconCompat.createWithBitmap(bitmap)
    }

    /**
     * Converts a bitmap to a circular bitmap.
     */
    private fun getCircularBitmap(bitmap: Bitmap, size: Int): Bitmap {
        val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        
        val paint = Paint().apply {
            isAntiAlias = true
        }
        
        val rect = Rect(0, 0, size, size)
        val rectF = RectF(rect)
        
        canvas.drawARGB(0, 0, 0, 0)
        canvas.drawCircle(size / 2f, size / 2f, size / 2f, paint)
        
        paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
        
        // Scale bitmap to fit
        val scaledBitmap = Bitmap.createScaledBitmap(bitmap, size, size, true)
        canvas.drawBitmap(scaledBitmap, rect, rect, paint)
        scaledBitmap.recycle()
        
        return output
    }

    /**
     * Calculate sample size for efficient bitmap loading.
     */
    private fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1
        
        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2
            
            while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2
            }
        }
        
        return inSampleSize
    }

    /**
     * Returns a contrasting text color (white or black) based on the background color.
     */
    private fun getContrastingTextColor(backgroundColor: Int): Int {
        val red = Color.red(backgroundColor)
        val green = Color.green(backgroundColor)
        val blue = Color.blue(backgroundColor)
        
        // Calculate luminance
        val luminance = (0.299 * red + 0.587 * green + 0.114 * blue) / 255
        
        return if (luminance > 0.5) Color.BLACK else Color.WHITE
    }

    /**
     * Get Material 3 theme colors by palette index.
     * These match the colors defined in ExpenseGroupColorPalette.dart
     */
    private fun getMaterial3Color(context: Context, index: Int): Int {
        // Material 3 color approximations for light theme
        // In a real app, these should be resolved from the actual theme
        return when (index) {
            0 -> Color.parseColor("#6750A4") // primary
            1 -> Color.parseColor("#7D5260") // tertiary
            2 -> Color.parseColor("#625B71") // secondary
            3 -> Color.parseColor("#F9DEDC") // errorContainer
            4 -> Color.parseColor("#EADDFF") // primaryContainer
            5 -> Color.parseColor("#E8DEF8") // secondaryContainer
            6 -> Color.parseColor("#D0BCFF") // primaryFixedDim
            7 -> Color.parseColor("#CCC2DC") // secondaryFixedDim
            8 -> Color.parseColor("#FFD8E4") // tertiaryFixed
            9 -> Color.parseColor("#B3261E") // error
            10 -> Color.parseColor("#CAC4D0") // outlineVariant
            11 -> Color.parseColor("#D0BCFF") // inversePrimary
            else -> Color.parseColor("#6750A4") // Default to primary
        }
    }

    fun clearShortcuts(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            try {
                ShortcutManagerCompat.removeAllDynamicShortcuts(context)
            } catch (e: Exception) {
                // Silently fail
            }
        }
    }

    data class GroupInfo(
        val id: String,
        val title: String,
        val isPinned: Boolean,
        val lastUpdated: Long,
        val color: Int?,
        val file: String?
    )
}
