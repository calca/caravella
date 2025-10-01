package io.caravella.egm

import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.content.pm.ShortcutInfoCompat
import androidx.core.content.pm.ShortcutManagerCompat
import androidx.core.graphics.drawable.IconCompat

object ShortcutManager {
    private const val MAX_SHORTCUTS = 4
    private const val ACTION_ADD_EXPENSE = "io.caravella.egm.ADD_EXPENSE"

    @RequiresApi(Build.VERSION_CODES.N_MR1)
    fun updateShortcuts(context: Context, groups: List<GroupInfo>) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) {
            return
        }

        val shortcuts = mutableListOf<ShortcutInfoCompat>()
        var shortcutCount = 0

        // Add pinned group first if available
        val pinnedGroup = groups.firstOrNull { it.isPinned }
        if (pinnedGroup != null && shortcutCount < MAX_SHORTCUTS) {
            shortcuts.add(createShortcut(context, pinnedGroup, shortcutCount++))
        }

        // Add up to 3 recently updated groups (excluding pinned)
        val recentGroups = groups
            .filter { !it.isPinned }
            .sortedByDescending { it.lastUpdated }
            .take(3)
        
        for (group in recentGroups) {
            if (shortcutCount >= MAX_SHORTCUTS) break
            shortcuts.add(createShortcut(context, group, shortcutCount++))
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

        return ShortcutInfoCompat.Builder(context, "group_${group.id}")
            .setShortLabel(shortLabel.take(25)) // Max 25 chars for short label
            .setLongLabel(longLabel.take(125)) // Max 125 chars for long label
            .setIcon(IconCompat.createWithResource(context, android.R.drawable.ic_menu_add))
            .setIntent(intent)
            .setRank(rank)
            .build()
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
        val lastUpdated: Long
    )
}
