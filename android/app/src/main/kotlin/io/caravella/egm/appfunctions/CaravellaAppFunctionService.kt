package io.caravella.egm.appfunctions

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.os.ResultReceiver
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.appfunctions.AppFunctionData
import androidx.appfunctions.AppFunctionException
import androidx.appfunctions.AppFunctionInvalidArgumentException
import androidx.appfunctions.AppFunctionElementNotFoundException
import androidx.appfunctions.AppFunctionDisabledException
import androidx.appfunctions.AppFunctionFunctionNotFoundException
import androidx.appfunctions.ExecuteAppFunctionResponse
import io.caravella.egm.MainActivity

/**
 * Android App Functions service for Caravella.
 *
 * Exposes four capabilities to Android AI agents (e.g. Google Gemini):
 *  - [FUNCTION_ADD_EXPENSE]          – navigate to the add-expense screen.
 *  - [FUNCTION_GET_BALANCE]          – total balance for a group.
 *  - [FUNCTION_GET_RECENT_EXPENSES]  – last 3 expenses for a group.
 *  - [FUNCTION_GET_TODAY_TOTAL]      – sum of today's expenses for a group.
 *
 * Read-only functions are handled entirely in Kotlin via [AppFunctionStorageReader]
 * without requiring a running Flutter engine.  [FUNCTION_ADD_EXPENSE] launches
 * [MainActivity] with pre-fill extras so the Flutter UI can open the add-expense
 * form ready to use.
 *
 * All functions are gated behind the user's privacy toggle
 * (`app_functions_enabled`, stored in Flutter's `FlutterSharedPreferences`).
 * When the user has disabled App Functions the service returns a
 * `FUNCTIONS_DISABLED` error without touching any data.
 *
 * Declared in AndroidManifest.xml – see app_function_declarations.xml for the
 * full parameter/return schema.
 *
 * Uses `androidx.appfunctions:appfunctions:1.0.0-alpha01` data types
 * ([AppFunctionData], [ExecuteAppFunctionResponse]) for the response format.
 *
 * The service handles incoming intents with the following extras:
 *  - `function_id` (String) – the function identifier to execute
 *  - `parameters`  (Bundle) – the function parameters
 *  - `result_receiver` (ResultReceiver) – optional callback for results
 */
@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE) // API 34+
class CaravellaAppFunctionService : Service() {

    companion object {
        private const val TAG = "CaravellaAppFunctions"

        const val FUNCTION_ADD_EXPENSE = "io.caravella.egm.addExpense"
        const val FUNCTION_GET_BALANCE = "io.caravella.egm.getGroupBalance"
        const val FUNCTION_GET_RECENT_EXPENSES = "io.caravella.egm.getRecentExpenses"
        const val FUNCTION_GET_TODAY_TOTAL = "io.caravella.egm.getTodayTotal"

        private const val PARAM_GROUP_ID = "groupId"
        private const val PARAM_AMOUNT = "amount"
        private const val PARAM_CATEGORY_NAME = "categoryName"
        private const val PARAM_NOTE = "note"

        // Intent extras
        const val EXTRA_FUNCTION_ID = "function_id"
        const val EXTRA_PARAMETERS = "parameters"
        const val EXTRA_RESULT_RECEIVER = "result_receiver"

        // Result codes for ResultReceiver
        const val RESULT_SUCCESS = 0
        const val RESULT_ERROR = 1

        // Flutter SharedPreferences key (Flutter stores keys with "flutter." prefix)
        private const val FLUTTER_PREFS_NAME = "FlutterSharedPreferences"
        private const val PREF_KEY_APP_FUNCTIONS_ENABLED = "flutter.app_functions_enabled"
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            stopSelf(startId)
            return START_NOT_STICKY
        }

        val functionId = intent.getStringExtra(EXTRA_FUNCTION_ID)
        val params = intent.getBundleExtra(EXTRA_PARAMETERS) ?: Bundle()
        val receiver = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(EXTRA_RESULT_RECEIVER, ResultReceiver::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(EXTRA_RESULT_RECEIVER)
        }

        if (functionId == null) {
            sendError(receiver, AppFunctionFunctionNotFoundException("No function_id in intent"))
            stopSelf(startId)
            return START_NOT_STICKY
        }

        val response = executeFunction(functionId, params)
        when (response) {
            is ExecuteAppFunctionResponse.Success -> {
                receiver?.send(RESULT_SUCCESS, Bundle().apply {
                    putString("return_value", response.returnValue.toString())
                })
            }
            is ExecuteAppFunctionResponse.Error -> {
                receiver?.send(RESULT_ERROR, Bundle().apply {
                    putString("error_message", response.error.errorMessage)
                })
            }
        }

        stopSelf(startId)
        return START_NOT_STICKY
    }

    /** Returns true when the user has enabled App Functions in the privacy settings. */
    private fun isAppFunctionsEnabled(): Boolean {
        val prefs = getSharedPreferences(FLUTTER_PREFS_NAME, Context.MODE_PRIVATE)
        // Default is false (disabled) – mirrors _PreferenceDefaults.appFunctionsEnabled
        return prefs.getBoolean(PREF_KEY_APP_FUNCTIONS_ENABLED, false)
    }

    /**
     * Routes [functionId] to the appropriate handler.
     * @return [ExecuteAppFunctionResponse] using the AppFunctions library types.
     */
    private fun executeFunction(
        functionId: String,
        params: Bundle,
    ): ExecuteAppFunctionResponse {
        if (!isAppFunctionsEnabled()) {
            return ExecuteAppFunctionResponse.Error(
                AppFunctionDisabledException(
                    "App Functions are disabled. Enable them in Caravella Settings → Privacy.",
                ),
            )
        }
        return try {
            when (functionId) {
                FUNCTION_ADD_EXPENSE -> handleAddExpense(params)
                FUNCTION_GET_BALANCE -> handleGetBalance(params)
                FUNCTION_GET_RECENT_EXPENSES -> handleGetRecentExpenses(params)
                FUNCTION_GET_TODAY_TOTAL -> handleGetTodayTotal(params)
                else -> ExecuteAppFunctionResponse.Error(
                    AppFunctionFunctionNotFoundException("Unknown function: $functionId"),
                )
            }
        } catch (e: AppFunctionException) {
            ExecuteAppFunctionResponse.Error(e)
        } catch (e: Exception) {
            Log.e(TAG, "Error executing $functionId", e)
            ExecuteAppFunctionResponse.Error(
                AppFunctionInvalidArgumentException(e.message ?: "Internal error"),
            )
        }
    }

    // ------------------------------------------------------------------
    // Add Expense
    // ------------------------------------------------------------------

    private fun handleAddExpense(params: Bundle): ExecuteAppFunctionResponse {
        val groupId = params.getString(PARAM_GROUP_ID)
            ?: throw AppFunctionInvalidArgumentException(
                "'$PARAM_GROUP_ID' is required for addExpense",
            )
        val amount: Double? = if (params.containsKey(PARAM_AMOUNT)) {
            params.getDouble(PARAM_AMOUNT).takeIf { it > 0.0 }
        } else {
            null
        }
        val categoryName: String? = params.getString(PARAM_CATEGORY_NAME)
        val note: String? = params.getString(PARAM_NOTE)

        if (amount != null) {
            return when (
                val result = AppFunctionStorageReader.saveExpense(
                    this, groupId, amount, categoryName, note,
                )
            ) {
                is AppFunctionStorageReader.SaveExpenseResult.Success -> {
                    val data = AppFunctionData.Builder(FUNCTION_ADD_EXPENSE, groupId)
                        .setString("expenseId", result.expenseId)
                        .setString("groupId", groupId)
                        .setDouble("amount", amount)
                        .build()
                    ExecuteAppFunctionResponse.Success(data)
                }

                is AppFunctionStorageReader.SaveExpenseResult.Failure ->
                    ExecuteAppFunctionResponse.Error(
                        AppFunctionInvalidArgumentException(result.reason),
                    )
            }
        }

        // Amount not provided – open the app so the user can complete the entry
        val groups = AppFunctionStorageReader.getActiveGroups(this)
        val groupTitle = groups.firstOrNull { it.id == groupId }?.title ?: groupId

        val intent = Intent(this, MainActivity::class.java).apply {
            action = "io.caravella.egm.ADD_EXPENSE"
            putExtra("groupId", groupId)
            putExtra("groupTitle", groupTitle)
            categoryName?.let { putExtra("categoryName", it) }
            note?.let { putExtra("note", it) }
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        startActivity(intent)

        return ExecuteAppFunctionResponse.Success(AppFunctionData.EMPTY)
    }

    // ------------------------------------------------------------------
    // Get Group Balance
    // ------------------------------------------------------------------

    private fun handleGetBalance(params: Bundle): ExecuteAppFunctionResponse {
        val groupId = params.getString(PARAM_GROUP_ID)
            ?: throw AppFunctionInvalidArgumentException(
                "'$PARAM_GROUP_ID' is required for getGroupBalance",
            )

        val result = AppFunctionStorageReader.getTotalBalance(this, groupId)
            ?: throw AppFunctionElementNotFoundException("Group not found: $groupId")

        val data = AppFunctionData.Builder(FUNCTION_GET_BALANCE, groupId)
            .setString("groupId", result.groupId)
            .setString("groupTitle", result.groupTitle)
            .setDouble("totalBalance", result.totalBalance)
            .setString("currency", result.currency)
            .build()
        return ExecuteAppFunctionResponse.Success(data)
    }

    // ------------------------------------------------------------------
    // Get Recent Expenses
    // ------------------------------------------------------------------

    private fun handleGetRecentExpenses(params: Bundle): ExecuteAppFunctionResponse {
        val groupId = params.getString(PARAM_GROUP_ID)
            ?: throw AppFunctionInvalidArgumentException(
                "'$PARAM_GROUP_ID' is required for getRecentExpenses",
            )

        val result = AppFunctionStorageReader.getRecentExpenses(this, groupId, count = 3)
            ?: throw AppFunctionElementNotFoundException("Group not found: $groupId")

        val builder = AppFunctionData.Builder(FUNCTION_GET_RECENT_EXPENSES, groupId)
            .setString("groupId", result.groupId)
            .setString("groupTitle", result.groupTitle)
            .setString("currency", result.currency)
            .setInt("expenseCount", result.expenses.size)

        result.expenses.forEachIndexed { index, expense ->
            val prefix = "expenses[$index]."
            builder.setString("${prefix}id", expense.id)
            builder.setString("${prefix}categoryName", expense.categoryName)
            if (expense.amount != null) builder.setDouble("${prefix}amount", expense.amount)
            builder.setString("${prefix}paidByName", expense.paidByName)
            builder.setString("${prefix}date", expense.date)
            expense.note?.let { builder.setString("${prefix}note", it) }
            expense.name?.let { builder.setString("${prefix}name", it) }
        }
        return ExecuteAppFunctionResponse.Success(builder.build())
    }

    // ------------------------------------------------------------------
    // Get Today Total
    // ------------------------------------------------------------------

    private fun handleGetTodayTotal(params: Bundle): ExecuteAppFunctionResponse {
        val groupId = params.getString(PARAM_GROUP_ID)
            ?: throw AppFunctionInvalidArgumentException(
                "'$PARAM_GROUP_ID' is required for getTodayTotal",
            )

        val result = AppFunctionStorageReader.getTodayTotal(this, groupId)
            ?: throw AppFunctionElementNotFoundException("Group not found: $groupId")

        val data = AppFunctionData.Builder(FUNCTION_GET_TODAY_TOTAL, groupId)
            .setString("groupId", result.groupId)
            .setString("groupTitle", result.groupTitle)
            .setDouble("todayTotal", result.todayTotal)
            .setString("currency", result.currency)
            .build()
        return ExecuteAppFunctionResponse.Success(data)
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    private fun sendError(receiver: ResultReceiver?, exception: AppFunctionException) {
        receiver?.send(RESULT_ERROR, Bundle().apply {
            putString("error_message", exception.errorMessage)
        })
    }
}
