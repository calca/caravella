package io.caravella.egm

import android.app.backup.BackupManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "io.caravella.egm/backup"
    private val SHORTCUTS_CHANNEL = "io.caravella.egm/shortcuts"
    private val APP_FUNCTIONS_CHANNEL = "io.caravella.egm/app_functions"

    private var shortcutsChannel: MethodChannel? = null
    private var appFunctionsChannel: MethodChannel? = null

    // Pending ADD_EXPENSE data from shortcuts (groupId + groupTitle only)
    private var pendingShortcutAction: Map<String, String>? = null

    // Pending ADD_EXPENSE data from App Functions (may include amount, categoryName, note)
    private var pendingAppFunctionAction: Map<String, Any?>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Abilita l'edge-to-edge per Android 10+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
        
        // Handle both shortcut and App Function intents
        handleAddExpenseIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleAddExpenseIntent(intent)
    }
    
    /**
     * Handles ADD_EXPENSE intents originating from either:
     *  – an app shortcut (has groupId + groupTitle)
     *  – an App Function call (also carries optional amount, categoryName, note)
     *
     * When the App Functions channel is ready the pre-fill data is sent via
     * [APP_FUNCTIONS_CHANNEL]/onAddExpense so the Flutter UI can open the
     * add-expense form pre-populated.  When only basic shortcut data is
     * present the legacy [SHORTCUTS_CHANNEL]/onShortcutTapped call is used
     * for backward compatibility.
     */
    private fun handleAddExpenseIntent(intent: Intent?) {
        if (intent?.action != "io.caravella.egm.ADD_EXPENSE") return

        val groupId = intent.getStringExtra("groupId") ?: return
        val groupTitle = intent.getStringExtra("groupTitle") ?: return

        // An amount of 0.0 is treated as "not provided" because no real expense
        // has zero value; the AI agent omits the extra when no amount was given.
        val amount: Double? = intent.getDoubleExtra("amount", 0.0).takeIf { it > 0.0 }
        val categoryName: String? = intent.getStringExtra("categoryName")
        val note: String? = intent.getStringExtra("note")

        val hasAppFunctionData = amount != null || categoryName != null || note != null

        if (hasAppFunctionData) {
            // Rich pre-fill from App Functions → use the dedicated channel
            val data = mutableMapOf<String, Any?>(
                "groupId" to groupId,
                "groupTitle" to groupTitle,
            )
            if (amount != null) data["amount"] = amount
            if (categoryName != null) data["categoryName"] = categoryName
            if (note != null) data["note"] = note

            appFunctionsChannel?.invokeMethod("onAddExpense", data)
                ?: run { pendingAppFunctionAction = data }
        } else {
            // Basic shortcut tap → legacy path
            val data = mapOf("groupId" to groupId, "groupTitle" to groupTitle)
            shortcutsChannel?.invokeMethod("onShortcutTapped", data)
                ?: run { pendingShortcutAction = data }
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "triggerBackup" -> {
                    try {
                        // Notify the BackupManager that data changed; OS will schedule backup.
                        BackupManager(this).dataChanged()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("BACKUP_ERROR", "Failed to signal backup: ${e.message}", null)
                    }
                }
                "isBackupEnabled" -> {
                    // No direct runtime check API; assume true if manifest allows backup.
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Shortcuts channel
        shortcutsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHORTCUTS_CHANNEL)
        shortcutsChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateShortcuts" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
                        try {
                            @Suppress("UNCHECKED_CAST")
                            val groups = (call.arguments as? List<Map<String, Any>>)?.map { map ->
                                ShortcutManager.GroupInfo(
                                    id = map["id"] as String,
                                    title = map["title"] as String,
                                    isPinned = map["isPinned"] as Boolean,
                                    lastUpdated = (map["lastUpdated"] as Number).toLong(),
                                    color = (map["color"] as? Number)?.toInt(),
                                    file = map["file"] as? String
                                )
                            } ?: emptyList()
                            
                            ShortcutManager.updateShortcuts(this, groups)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SHORTCUT_ERROR", "Failed to update shortcuts: ${e.message}", null)
                        }
                    } else {
                        result.success(false) // Shortcuts not supported on this API level
                    }
                }
                "clearShortcuts" -> {
                    try {
                        ShortcutManager.clearShortcuts(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SHORTCUT_ERROR", "Failed to clear shortcuts: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // App Functions channel – forwards App Function invocations to Dart
        appFunctionsChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_FUNCTIONS_CHANNEL,
        )
        // No Dart→native calls on this channel; all method calls go native→Dart.
        appFunctionsChannel?.setMethodCallHandler { _, result -> result.notImplemented() }
        
        // Send any pending shortcut action
        pendingShortcutAction?.let { data ->
            shortcutsChannel?.invokeMethod("onShortcutTapped", data)
            pendingShortcutAction = null
        }

        // Send any pending App Function action
        pendingAppFunctionAction?.let { data ->
            appFunctionsChannel?.invokeMethod("onAddExpense", data)
            pendingAppFunctionAction = null
        }
    }
}
