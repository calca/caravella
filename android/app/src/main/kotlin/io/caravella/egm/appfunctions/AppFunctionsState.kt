package io.caravella.egm.appfunctions

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import androidx.appfunctions.AppFunctionManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * Keeps the system's view of Caravella's App Functions in step with the
 * user's toggle in Settings › Privacy.
 *
 * The functions are declared disabled (`isEnabled = false`), so after an
 * install agents don't offer them. Turning the toggle on enables them in the
 * system ([AppFunctionManager.setAppFunctionEnabled]); turning it off disables
 * them again. [BaseCaravellaAppFunctionService] still checks the toggle on
 * every call, in case the two ever drift apart.
 *
 * [MainActivity][io.caravella.egm.MainActivity] calls [watch] at start: it
 * syncs once (the toggle may have changed without the app running, e.g. a
 * backup restore) and then on every change of the preference, which Flutter
 * writes while the app is open.
 */
object AppFunctionsState {
    private const val TAG = "AppFunctionsState"

    /** Every function's id, as the compiler generates them. */
    val FUNCTION_IDS: List<String> = listOf(
        CaravellaAppFunctionService.FUNCTION_ID_LIST_GROUPS,
        CaravellaAppFunctionService.FUNCTION_ID_ADD_EXPENSE,
        CaravellaAppFunctionService.FUNCTION_ID_GET_GROUP_BALANCE,
        CaravellaAppFunctionService.FUNCTION_ID_GET_RECENT_EXPENSES,
        CaravellaAppFunctionService.FUNCTION_ID_GET_TODAY_TOTAL,
    )

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    // SharedPreferences keeps listeners weakly: hold it here.
    private var listener: SharedPreferences.OnSharedPreferenceChangeListener? = null

    /** Syncs now and on every change of the toggle (Android 16+ only). */
    fun watch(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.BAKLAVA) return
        val app = context.applicationContext
        syncAsync(app)
        if (listener != null) return
        val l = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
            if (key == BaseCaravellaAppFunctionService.PREF_KEY_ENABLED) syncAsync(app)
        }
        listener = l
        BaseCaravellaAppFunctionService.prefs(app).registerOnSharedPreferenceChangeListener(l)
    }

    private fun syncAsync(context: Context) {
        scope.launch {
            runCatching {
                // Null where the device has no App Functions.
                val manager = AppFunctionManager.getInstance(context) ?: return@launch
                sync(manager, BaseCaravellaAppFunctionService.isEnabled(context))
            }.onFailure { Log.w(TAG, "Could not update App Functions state", it) }
        }
    }

    /** Enables or disables every function in the system. */
    suspend fun sync(manager: AppFunctionManager, enabled: Boolean) {
        val state = if (enabled) {
            AppFunctionManager.APP_FUNCTION_STATE_ENABLED
        } else {
            AppFunctionManager.APP_FUNCTION_STATE_DISABLED
        }
        FUNCTION_IDS.forEach { manager.setAppFunctionEnabled(it, state) }
    }
}
