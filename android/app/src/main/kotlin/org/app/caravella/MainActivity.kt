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
    private var shortcutsChannel: MethodChannel? = null
    private var pendingShortcutAction: Map<String, String>? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Abilita l'edge-to-edge per Android 10+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
        
        // Handle shortcut intent
        handleShortcutIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleShortcutIntent(intent)
    }
    
    private fun handleShortcutIntent(intent: Intent?) {
        if (intent?.action == "io.caravella.egm.ADD_EXPENSE") {
            val groupId = intent.getStringExtra("groupId")
            val groupTitle = intent.getStringExtra("groupTitle")
            if (groupId != null && groupTitle != null) {
                val data = mapOf("groupId" to groupId, "groupTitle" to groupTitle)
                // If channel is ready, send immediately; otherwise store for later
                shortcutsChannel?.invokeMethod("onShortcutTapped", data)
                    ?: run { pendingShortcutAction = data }
            }
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
                                    lastUpdated = (map["lastUpdated"] as Number).toLong()
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
        
        // Send any pending shortcut action
        pendingShortcutAction?.let { data ->
            shortcutsChannel?.invokeMethod("onShortcutTapped", data)
            pendingShortcutAction = null
        }
    }
}
