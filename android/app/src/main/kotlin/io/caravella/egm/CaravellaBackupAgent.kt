package io.caravella.egm

import android.app.backup.BackupAgent
import android.app.backup.BackupDataInput
import android.app.backup.BackupDataOutput
import android.app.backup.FullBackupDataOutput
import android.content.Context
import android.os.Build
import android.os.ParcelFileDescriptor
import java.io.File

/**
 * Android Auto Backup with the app's on/off switch: when the user turns
 * "Android backup" off (Settings → Data), cloud backups carry only a marker
 * file (replacing any earlier backup with the user's data);
 * device-to-device transfers still copy everything. Each cloud backup that
 * runs records its time, shown in the same settings page.
 *
 * Everything else is the platform's Auto Backup: [onFullBackup]'s default
 * implementation applies the manifest's backup / data extraction rules.
 */
class CaravellaBackupAgent : BackupAgent() {

    override fun onFullBackup(data: FullBackupDataOutput) {
        val deviceTransfer = Build.VERSION.SDK_INT >= Build.VERSION_CODES.P &&
            (data.transportFlags and FLAG_DEVICE_TO_DEVICE_TRANSFER) != 0
        if (!deviceTransfer) {
            if (!isEnabled(this)) {
                // A backup with no data is rejected and the previous one
                // would stay in the cloud: replace it with a tiny marker.
                val marker = File(filesDir, OFF_MARKER)
                marker.writeText("off")
                fullBackupFile(marker, data)
                return
            }
            recordBackupTime(this)
        }
        super.onFullBackup(data)
    }

    // Key/value backup isn't used (fullBackupOnly), but both are abstract.
    override fun onBackup(
        oldState: ParcelFileDescriptor?,
        data: BackupDataOutput?,
        newState: ParcelFileDescriptor?,
    ) = Unit

    override fun onRestore(
        data: BackupDataInput?,
        appVersionCode: Int,
        newState: ParcelFileDescriptor?,
    ) = Unit

    companion object {
        // shared_preferences stores Dart's prefs here, keys prefixed "flutter.".
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val ENABLED_KEY = "flutter.auto_backup_enabled"

        // Kept out of the Flutter prefs so Dart never overwrites it.
        private const val STATE_PREFS = "caravella_backup_state"
        private const val LAST_BACKUP_KEY = "last_cloud_backup_ms"

        private const val OFF_MARKER = "backup_off.txt"

        /** Backup is on unless the user turned it off in the app. */
        fun isEnabled(context: Context): Boolean =
            context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
                .getBoolean(ENABLED_KEY, true)

        /** Time of the last cloud backup in ms since epoch, 0 if none yet. */
        fun lastBackupTime(context: Context): Long =
            context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
                .getLong(LAST_BACKUP_KEY, 0L)

        private fun recordBackupTime(context: Context) {
            context.getSharedPreferences(STATE_PREFS, Context.MODE_PRIVATE)
                .edit()
                .putLong(LAST_BACKUP_KEY, System.currentTimeMillis())
                .commit()
        }
    }
}
