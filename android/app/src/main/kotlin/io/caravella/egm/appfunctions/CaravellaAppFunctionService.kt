package io.caravella.egm.appfunctions

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.annotation.RequiresApi
import androidx.appfunctions.AppFunctionService
import androidx.appfunctions.ExecuteAppFunctionRequest
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
 * Requires `androidx.appfunctions:appfunctions:1.0.0-alpha01` in
 * `android/app/build.gradle.kts`.
 */
@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE) // API 34+
class CaravellaAppFunctionService : AppFunctionService() {

    companion object {
        const val FUNCTION_ADD_EXPENSE = "io.caravella.egm.addExpense"
        const val FUNCTION_GET_BALANCE = "io.caravella.egm.getGroupBalance"
        const val FUNCTION_GET_RECENT_EXPENSES = "io.caravella.egm.getRecentExpenses"
        const val FUNCTION_GET_TODAY_TOTAL = "io.caravella.egm.getTodayTotal"

        private const val PARAM_GROUP_ID = "groupId"
        private const val PARAM_AMOUNT = "amount"
        private const val PARAM_CATEGORY_NAME = "categoryName"
        private const val PARAM_NOTE = "note"

        // Error codes
        private const val ERROR_NOT_FOUND = "FUNCTION_NOT_FOUND"
        private const val ERROR_INVALID_ARG = "INVALID_ARGUMENT"
        private const val ERROR_GROUP_NOT_FOUND = "GROUP_NOT_FOUND"
        private const val ERROR_FUNCTIONS_DISABLED = "FUNCTIONS_DISABLED"

        // Flutter SharedPreferences key (Flutter stores keys with "flutter." prefix)
        private const val FLUTTER_PREFS_NAME = "FlutterSharedPreferences"
        private const val PREF_KEY_APP_FUNCTIONS_ENABLED = "flutter.app_functions_enabled"
    }

    /** Returns true when the user has enabled App Functions in the privacy settings. */
    private fun isAppFunctionsEnabled(): Boolean {
        val prefs = getSharedPreferences(FLUTTER_PREFS_NAME, Context.MODE_PRIVATE)
        // Default is false (disabled) – mirrors _PreferenceDefaults.appFunctionsEnabled
        return prefs.getBoolean(PREF_KEY_APP_FUNCTIONS_ENABLED, false)
    }

    override suspend fun onExecuteFunction(
        request: ExecuteAppFunctionRequest,
    ): ExecuteAppFunctionResponse {
        if (!isAppFunctionsEnabled()) {
            return errorResponse(
                ERROR_FUNCTIONS_DISABLED,
                "App Functions are disabled. Enable them in Caravella Settings → Privacy.",
            )
        }
        return try {
            when (request.functionIdentifier) {
                FUNCTION_ADD_EXPENSE -> handleAddExpense(request)
                FUNCTION_GET_BALANCE -> handleGetBalance(request)
                FUNCTION_GET_RECENT_EXPENSES -> handleGetRecentExpenses(request)
                FUNCTION_GET_TODAY_TOTAL -> handleGetTodayTotal(request)
                else -> errorResponse(ERROR_NOT_FOUND, "Unknown function: ${request.functionIdentifier}")
            }
        } catch (e: IllegalArgumentException) {
            errorResponse(ERROR_INVALID_ARG, e.message ?: "Invalid argument")
        } catch (e: Exception) {
            errorResponse("INTERNAL_ERROR", e.message ?: "Internal error")
        }
    }

    // ------------------------------------------------------------------
    // Add Expense
    // ------------------------------------------------------------------

    /**
     * Handles the `addExpense` App Function.
     *
     * When the AI agent supplies a valid [PARAM_AMOUNT] (> 0), the expense is
     * persisted **directly in the background** via [AppFunctionStorageReader]
     * without starting the Flutter engine or opening the app UI.
     *
     * When no amount is provided (or amount == 0) the function falls back to
     * launching [MainActivity] so the user can fill in the missing details.
     */
    private fun handleAddExpense(
        request: ExecuteAppFunctionRequest,
    ): ExecuteAppFunctionResponse {
        val params = request.parameters
        val groupId = params.getString(PARAM_GROUP_ID)
            ?: throw IllegalArgumentException("'$PARAM_GROUP_ID' is required for addExpense")
        // Only treat amounts > 0 as "provided"; 0.0 means "not specified"
        val amount: Double? = if (params.containsKey(PARAM_AMOUNT)) {
            params.getDouble(PARAM_AMOUNT).takeIf { it > 0.0 }
        } else null
        val categoryName: String? = params.getString(PARAM_CATEGORY_NAME)
        val note: String? = params.getString(PARAM_NOTE)

        if (amount != null) {
            // Background save – no app launch required
            return when (
                val result = AppFunctionStorageReader.saveExpense(
                    this, groupId, amount, categoryName, note,
                )
            ) {
                is AppFunctionStorageReader.SaveExpenseResult.Success ->
                    successResponse(Bundle().apply {
                        putString("expenseId", result.expenseId)
                        putString("groupId", groupId)
                        putDouble("amount", amount)
                    })

                is AppFunctionStorageReader.SaveExpenseResult.Failure ->
                    errorResponse("SAVE_FAILED", result.reason)
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

        return successResponse(Bundle())
    }

    // ------------------------------------------------------------------
    // Get Group Balance
    // ------------------------------------------------------------------

    private fun handleGetBalance(
        request: ExecuteAppFunctionRequest,
    ): ExecuteAppFunctionResponse {
        val groupId = request.parameters.getString(PARAM_GROUP_ID)
            ?: throw IllegalArgumentException("'$PARAM_GROUP_ID' is required for getGroupBalance")

        val result = AppFunctionStorageReader.getTotalBalance(this, groupId)
            ?: throw IllegalArgumentException("$ERROR_GROUP_NOT_FOUND: $groupId")

        return successResponse(
            Bundle().apply {
                putString("groupId", result.groupId)
                putString("groupTitle", result.groupTitle)
                putDouble("totalBalance", result.totalBalance)
                putString("currency", result.currency)
            },
        )
    }

    // ------------------------------------------------------------------
    // Get Recent Expenses
    // ------------------------------------------------------------------

    private fun handleGetRecentExpenses(
        request: ExecuteAppFunctionRequest,
    ): ExecuteAppFunctionResponse {
        val groupId = request.parameters.getString(PARAM_GROUP_ID)
            ?: throw IllegalArgumentException("'$PARAM_GROUP_ID' is required for getRecentExpenses")

        val result = AppFunctionStorageReader.getRecentExpenses(this, groupId, count = 3)
            ?: throw IllegalArgumentException("$ERROR_GROUP_NOT_FOUND: $groupId")

        return successResponse(
            Bundle().apply {
                putString("groupId", result.groupId)
                putString("groupTitle", result.groupTitle)
                putString("currency", result.currency)
                putInt("expenseCount", result.expenses.size)
                result.expenses.forEachIndexed { index, expense ->
                    val prefix = "expenses[$index]."
                    putString("${prefix}id", expense.id)
                    putString("${prefix}categoryName", expense.categoryName)
                    if (expense.amount != null) putDouble("${prefix}amount", expense.amount)
                    putString("${prefix}paidByName", expense.paidByName)
                    putString("${prefix}date", expense.date)
                    expense.note?.let { putString("${prefix}note", it) }
                    expense.name?.let { putString("${prefix}name", it) }
                }
            },
        )
    }

    // ------------------------------------------------------------------
    // Get Today Total
    // ------------------------------------------------------------------

    private fun handleGetTodayTotal(
        request: ExecuteAppFunctionRequest,
    ): ExecuteAppFunctionResponse {
        val groupId = request.parameters.getString(PARAM_GROUP_ID)
            ?: throw IllegalArgumentException("'$PARAM_GROUP_ID' is required for getTodayTotal")

        val result = AppFunctionStorageReader.getTodayTotal(this, groupId)
            ?: throw IllegalArgumentException("$ERROR_GROUP_NOT_FOUND: $groupId")

        return successResponse(
            Bundle().apply {
                putString("groupId", result.groupId)
                putString("groupTitle", result.groupTitle)
                putDouble("todayTotal", result.todayTotal)
                putString("currency", result.currency)
            },
        )
    }

    // ------------------------------------------------------------------
    // Response helpers
    // ------------------------------------------------------------------

    /**
     * Returns a successful [ExecuteAppFunctionResponse] carrying [data].
     *
     * Note: the exact constructor signature depends on the final
     * `androidx.appfunctions:appfunctions` API.  Adjust if the released
     * version uses a Builder or a different class hierarchy.
     */
    private fun successResponse(data: Bundle): ExecuteAppFunctionResponse =
        ExecuteAppFunctionResponse.Success(data)

    private fun errorResponse(code: String, message: String): ExecuteAppFunctionResponse =
        ExecuteAppFunctionResponse.Failure(code, message)
}
