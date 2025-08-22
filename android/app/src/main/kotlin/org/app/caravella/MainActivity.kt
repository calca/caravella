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
    }
}
