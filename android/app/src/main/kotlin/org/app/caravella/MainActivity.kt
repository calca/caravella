package org.app.caravella

import android.app.backup.BackupManager
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "org.app.caravella/backup"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Abilita l'edge-to-edge per Android 10+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestBackup" -> {
                    try {
                        val backupManager = BackupManager(this)
                        backupManager.requestBackup()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("BACKUP_ERROR", "Failed to request backup: ${e.message}", null)
                    }
                }
                "isBackupEnabled" -> {
                    try {
                        // Check if auto backup is enabled for this app
                        val backupManager = BackupManager(this)
                        // Note: There's no direct API to check if backup is enabled
                        // We'll assume it's enabled if allowBackup is true in manifest
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("BACKUP_ERROR", "Failed to check backup status: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
