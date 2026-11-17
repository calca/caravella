package io.caravella.egm

import android.app.backup.BackupManager
import android.content.Intent
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.caravella.egm.appfunctions.AppFunctionEvents
import io.caravella.egm.appfunctions.AppFunctionsState
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "io.caravella.egm/backup"
    private val SHORTCUTS_CHANNEL = "io.caravella.egm/shortcuts"
    private val APP_FUNCTIONS_CHANNEL = "io.caravella.egm/app_functions"

    private var shortcutsChannel: MethodChannel? = null
    private var appFunctionsChannel: MethodChannel? = null
    private var locationChannel: LocationChannel? = null

    // Pending ADD_EXPENSE data from shortcuts (groupId + groupTitle only)
    private var pendingShortcutAction: Map<String, String>? = null

    // Pending ADD_EXPENSE data from an agent's link (groupId, categoryName, note)
    private var pendingAppFunctionAction: Map<String, Any?>? = null

    private lateinit var startupSplash: StartupSplash

    override fun onCreate(savedInstanceState: Bundle?) {
        // Before super.onCreate: it swaps LaunchTheme for NormalTheme.
        startupSplash = StartupSplash.install(this)
        super.onCreate(savedInstanceState)
        
        // Edge-to-edge on every supported version (Android 15+ enforces it):
        // transparent system bars, Flutter's SafeArea/insets handle padding.
        WindowCompat.enableEdgeToEdge(window)
        
        // Handle both shortcut and App Function intents
        handleAddExpenseIntent(intent)
        HomeWidgetProvider.updateAllWidgets(this)
        // Agents see the App Functions only while the privacy toggle is on.
        AppFunctionsState.watch(this)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleAddExpenseIntent(intent)
        HomeWidgetProvider.updateAllWidgets(this)
    }
    
    /**
     * Handles ADD_EXPENSE intents originating from either:
     *  – an app shortcut (groupId + groupTitle);
     *  – an AI agent's link from the addExpense App Function, made when the
     *    agent had no amount (also carries the categoryName and note it
     *    suggested).
     *
     * Both open the group in Flutter: the agent's link over
     * [APP_FUNCTIONS_CHANNEL]/onAddExpense, which checks the privacy toggle,
     * a shortcut over [SHORTCUTS_CHANNEL]/onShortcutTapped.
     */
    private fun handleAddExpenseIntent(intent: Intent?) {
        if (intent?.action != "io.caravella.egm.ADD_EXPENSE") return

        val groupId = intent.getStringExtra("groupId") ?: return
        val groupTitle = intent.getStringExtra("groupTitle") ?: return
        val categoryName: String? = intent.getStringExtra("categoryName")
        val note: String? = intent.getStringExtra("note")

        if (categoryName != null || note != null) {
            val data = mutableMapOf<String, Any?>(
                "groupId" to groupId,
                "groupTitle" to groupTitle,
            )
            if (categoryName != null) data["categoryName"] = categoryName
            if (note != null) data["note"] = note

            appFunctionsChannel?.invokeMethod("onAddExpense", data)
                ?: run { pendingAppFunctionAction = data }
        } else {
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
                    // The app's own switch, read by CaravellaBackupAgent.
                    result.success(CaravellaBackupAgent.isEnabled(this))
                }
                "lastBackupTime" -> {
                    // Last cloud backup run by CaravellaBackupAgent (0 = none).
                    result.success(CaravellaBackupAgent.lastBackupTime(this))
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Home tells the launch splash it can go.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, StartupSplash.CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "homeReady") {
                    startupSplash.homeReady = true
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }

        // Shortcuts channel
        shortcutsChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHORTCUTS_CHANNEL)
        shortcutsChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateShortcuts" -> {
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

        // Location channel – platform LocationManager, used when the build has
        // no Google Play Services (F-Droid)
        locationChannel = LocationChannel(applicationContext, flutterEngine.dartExecutor.binaryMessenger)

        // App Functions channel – forwards App Function invocations to Dart
        appFunctionsChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_FUNCTIONS_CHANNEL,
        )
        // No Dart→native calls on this channel; all method calls go native→Dart.
        appFunctionsChannel?.setMethodCallHandler { _, result -> result.notImplemented() }
        // An agent added an expense while the app is open: reload the group.
        AppFunctionEvents.onExpenseAdded = { groupId ->
            runOnUiThread {
                appFunctionsChannel?.invokeMethod("onExpenseAdded", mapOf("groupId" to groupId))
            }
        }
        
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

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        AppFunctionEvents.onExpenseAdded = null
        appFunctionsChannel = null
        locationChannel?.dispose()
        locationChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
