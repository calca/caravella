package io.caravella.egm.appfunctions

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Reads the Caravella JSON storage file directly from Kotlin.
 *
 * The storage file is written by Flutter's `FileBasedExpenseGroupRepository`
 * to `${context.filesDir}/expense_group_storage.json`, which corresponds to
 * Flutter path_provider's `getApplicationDocumentsDirectory()` on Android.
 *
 * All public methods are safe to call from a background Service (i.e. without
 * a running Flutter engine) because they perform their own I/O.
 */
internal object AppFunctionStorageReader {

    private const val FILE_NAME = "expense_group_storage.json"

    // ------------------------------------------------------------------
    // Public API
    // ------------------------------------------------------------------

    /** Returns basic info about all active (non-archived) groups. */
    fun getActiveGroups(context: Context): List<GroupSummary> {
        val array = loadGroupsArray(context) ?: return emptyList()
        val result = mutableListOf<GroupSummary>()
        for (i in 0 until array.length()) {
            val obj = array.optJSONObject(i) ?: continue
            if (obj.optBoolean("archived", false)) continue
            result.add(
                GroupSummary(
                    id = obj.optString("id"),
                    title = obj.optString("title"),
                    currency = obj.optString("currency", "€"),
                )
            )
        }
        return result
    }

    /**
     * Returns the total of all expense amounts for [groupId].
     * Returns `null` if the group cannot be found.
     */
    fun getTotalBalance(context: Context, groupId: String): BalanceResult? {
        val group = findGroup(context, groupId) ?: return null
        val expenses = group.optJSONArray("expenses") ?: JSONArray()
        var total = 0.0
        for (i in 0 until expenses.length()) {
            total += expenses.optJSONObject(i)?.optDouble("amount", 0.0) ?: 0.0
        }
        return BalanceResult(
            groupId = groupId,
            groupTitle = group.optString("title"),
            totalBalance = total,
            currency = group.optString("currency", "€"),
        )
    }

    /**
     * Returns the [count] most-recent expenses for [groupId], sorted newest
     * first.  Returns `null` if the group cannot be found.
     */
    fun getRecentExpenses(
        context: Context,
        groupId: String,
        count: Int = 3,
    ): RecentExpensesResult? {
        val group = findGroup(context, groupId) ?: return null
        val expenses = group.optJSONArray("expenses") ?: JSONArray()

        data class RawExpense(val date: String, val obj: JSONObject)
        val list = mutableListOf<RawExpense>()
        for (i in 0 until expenses.length()) {
            val e = expenses.optJSONObject(i) ?: continue
            list.add(RawExpense(e.optString("date", ""), e))
        }
        list.sortByDescending { it.date }

        val summaries = list.take(count).map { raw ->
            val e = raw.obj
            ExpenseSummary(
                id = e.optString("id"),
                categoryName = e.optJSONObject("category")?.optString("name") ?: "",
                amount = if (e.has("amount")) e.optDouble("amount") else null,
                paidByName = e.optJSONObject("paidBy")?.optString("name") ?: "",
                date = e.optString("date"),
                note = e.optString("note").takeIf { it.isNotEmpty() },
                name = e.optString("name").takeIf { it.isNotEmpty() },
            )
        }

        return RecentExpensesResult(
            groupId = groupId,
            groupTitle = group.optString("title"),
            currency = group.optString("currency", "€"),
            expenses = summaries,
        )
    }

    /**
     * Returns the sum of all expenses whose date falls on today's local date
     * for [groupId].  Returns `null` if the group cannot be found.
     */
    fun getTodayTotal(context: Context, groupId: String): TodayTotalResult? {
        val group = findGroup(context, groupId) ?: return null
        val expenses = group.optJSONArray("expenses") ?: JSONArray()

        val today = java.time.LocalDate.now(java.time.ZoneId.systemDefault()).toString() // yyyy-MM-dd
        var total = 0.0
        for (i in 0 until expenses.length()) {
            val e = expenses.optJSONObject(i) ?: continue
            val dateStr = e.optString("date", "")
            if (dateStr.startsWith(today)) {
                total += e.optDouble("amount", 0.0)
            }
        }

        return TodayTotalResult(
            groupId = groupId,
            groupTitle = group.optString("title"),
            todayTotal = total,
            currency = group.optString("currency", "€"),
        )
    }

    // ------------------------------------------------------------------
    // Private helpers
    // ------------------------------------------------------------------

    private fun loadGroupsArray(context: Context): JSONArray? {
        return try {
            val file = File(context.filesDir, FILE_NAME)
            if (!file.exists()) return null
            val root = JSONObject(file.readText())
            root.optJSONArray("groups")
        } catch (_: Exception) {
            null
        }
    }

    private fun findGroup(context: Context, groupId: String): JSONObject? {
        val array = loadGroupsArray(context) ?: return null
        for (i in 0 until array.length()) {
            val obj = array.optJSONObject(i) ?: continue
            if (obj.optString("id") == groupId) return obj
        }
        return null
    }

    // ------------------------------------------------------------------
    // Result data classes
    // ------------------------------------------------------------------

    data class GroupSummary(val id: String, val title: String, val currency: String)

    data class BalanceResult(
        val groupId: String,
        val groupTitle: String,
        val totalBalance: Double,
        val currency: String,
    )

    data class ExpenseSummary(
        val id: String,
        val categoryName: String,
        val amount: Double?,
        val paidByName: String,
        val date: String,
        val note: String?,
        val name: String?,
    )

    data class RecentExpensesResult(
        val groupId: String,
        val groupTitle: String,
        val currency: String,
        val expenses: List<ExpenseSummary>,
    )

    data class TodayTotalResult(
        val groupId: String,
        val groupTitle: String,
        val todayTotal: Double,
        val currency: String,
    )
}
