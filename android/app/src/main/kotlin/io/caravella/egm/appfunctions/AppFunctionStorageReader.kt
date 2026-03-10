package io.caravella.egm.appfunctions

import android.content.Context
import android.content.ContentValues
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.util.UUID

/**
 * Reads Caravella expense data directly from Kotlin, without starting the
 * Flutter engine.
 *
 * The reader transparently supports **both** storage backends used by the app:
 *
 * ## JSON backend (`FileBasedExpenseGroupRepository`)
 * Storage file: `${context.filesDir}/expense_group_storage.json`
 * Enabled when the app was built with `--dart-define=USE_JSON_BACKEND=true`
 * or when the SQLite migration has not yet been performed.
 *
 * ## SQLite backend (`SqliteExpenseGroupRepository`) — default
 * Database file: `expense_groups.db` in the system database directory
 * (`context.getDatabasePath("expense_groups.db")`).
 * Schema:
 *  - `groups`       – id, title, currency, start_date, end_date, timestamp,
 *                     pinned, archived, …
 *  - `participants` – id, group_id, name
 *  - `categories`   – id, group_id, name
 *  - `expenses`     – id, group_id, name, amount (REAL), date (epoch ms),
 *                     category_id, paid_by_id, note, …
 *
 * ## Backend selection
 * The active backend is detected at runtime:
 * 1. If the SQLite database file exists → use SQLite.
 * 2. Otherwise fall back to JSON.
 *
 * This mirrors the logic in `ExpenseGroupRepositoryFactory.getRepository()` /
 * `StorageMigrationService.isMigrationCompleted()` on the Dart side.
 *
 * All public methods are safe to call from a background [Service] (no Flutter
 * engine required) because they perform their own synchronous I/O.
 */
internal object AppFunctionStorageReader {

    // ------------------------------------------------------------------
    // Constants – must stay in sync with Flutter side
    // ------------------------------------------------------------------

    /** JSON storage file name (matches `FileBasedExpenseGroupRepository`). */
    private const val JSON_FILE_NAME = "expense_group_storage.json"

    /** SQLite database file name (matches `SqliteExpenseGroupRepository`). */
    private const val SQLITE_DB_NAME = "expense_groups.db"

    // SQLite table / column names (mirrors SqliteExpenseGroupRepository)
    private const val TABLE_GROUPS = "groups"
    private const val TABLE_PARTICIPANTS = "participants"
    private const val TABLE_CATEGORIES = "categories"
    private const val TABLE_EXPENSES = "expenses"

    private const val TAG = "AppFunctionStorageReader"

    // ------------------------------------------------------------------
    // Backend detection
    // ------------------------------------------------------------------

    /**
     * Returns `true` when the SQLite database file exists on disk, meaning the
     * app is (or was last) using the SQLite backend.
     */
    private fun isSqliteBackend(context: Context): Boolean {
        return context.getDatabasePath(SQLITE_DB_NAME).exists()
    }

    // ------------------------------------------------------------------
    // Public API
    // ------------------------------------------------------------------

    /**
     * Returns basic info about all active (non-archived) groups.
     * Automatically selects the appropriate storage backend.
     */
    fun getActiveGroups(context: Context): List<GroupSummary> {
        return if (isSqliteBackend(context)) {
            getActiveGroupsSqlite(context)
        } else {
            getActiveGroupsJson(context)
        }
    }

    /**
     * Returns the total of all expense amounts for [groupId].
     * Returns `null` when the group cannot be found.
     */
    fun getTotalBalance(context: Context, groupId: String): BalanceResult? {
        return if (isSqliteBackend(context)) {
            getTotalBalanceSqlite(context, groupId)
        } else {
            getTotalBalanceJson(context, groupId)
        }
    }

    /**
     * Returns the [count] most-recent expenses for [groupId], sorted newest
     * first.  Returns `null` when the group cannot be found.
     */
    fun getRecentExpenses(
        context: Context,
        groupId: String,
        count: Int = 3,
    ): RecentExpensesResult? {
        return if (isSqliteBackend(context)) {
            getRecentExpensesSqlite(context, groupId, count)
        } else {
            getRecentExpensesJson(context, groupId, count)
        }
    }

    /**
     * Returns the sum of all expenses whose date falls on today's local date
     * for [groupId].  Returns `null` when the group cannot be found.
     */
    fun getTodayTotal(context: Context, groupId: String): TodayTotalResult? {
        return if (isSqliteBackend(context)) {
            getTodayTotalSqlite(context, groupId)
        } else {
            getTodayTotalJson(context, groupId)
        }
    }

    /**
     * Persists a new expense entry for [groupId] directly to the active storage
     * backend **without starting the Flutter engine**.
     *
     * This is the write counterpart of the read-only query methods and enables
     * `addExpense` App Function calls to complete silently in the background
     * when the AI agent supplies a valid [amount].
     *
     * Category resolution:
     * - If [categoryName] matches an existing category (case-insensitive) that
     *   category is reused.
     * - Otherwise the first category of the group is used as a fallback.
     * - If the group has no categories at all, a new "Other" category is created
     *   for JSON storage; SQLite inserts are skipped (no orphan rows).
     *
     * The first participant of the group is set as `paidBy`.
     *
     * @return [SaveExpenseResult.Success] (with the generated expense id) on
     *         success, or [SaveExpenseResult.Failure] with an error reason.
     */
    fun saveExpense(
        context: Context,
        groupId: String,
        amount: Double,
        categoryName: String?,
        note: String?,
    ): SaveExpenseResult {
        return if (isSqliteBackend(context)) {
            saveExpenseSqlite(context, groupId, amount, categoryName, note)
        } else {
            saveExpenseJson(context, groupId, amount, categoryName, note)
        }
    }

    // ------------------------------------------------------------------
    // SQLite implementation
    // ------------------------------------------------------------------

    private fun openDb(context: Context): SQLiteDatabase {
        val path = context.getDatabasePath(SQLITE_DB_NAME).absolutePath
        return SQLiteDatabase.openDatabase(path, null, SQLiteDatabase.OPEN_READONLY)
    }

    private fun openDbReadWrite(context: Context): SQLiteDatabase {
        val path = context.getDatabasePath(SQLITE_DB_NAME).absolutePath
        return SQLiteDatabase.openDatabase(path, null, SQLiteDatabase.OPEN_READWRITE)
    }

    private fun getActiveGroupsSqlite(context: Context): List<GroupSummary> {
        return try {
            openDb(context).use { db ->
                val cursor = db.query(
                    TABLE_GROUPS,
                    arrayOf("id", "title", "currency"),
                    "archived = 0",
                    null, null, null, "timestamp DESC",
                )
                val result = mutableListOf<GroupSummary>()
                cursor.use {
                    while (it.moveToNext()) {
                        result.add(
                            GroupSummary(
                                id = it.getString(it.getColumnIndexOrThrow("id")),
                                title = it.getString(it.getColumnIndexOrThrow("title")),
                                currency = it.getString(it.getColumnIndexOrThrow("currency")),
                            )
                        )
                    }
                }
                result
            }
        } catch (e: Exception) {
            Log.e(TAG, "getActiveGroupsSqlite failed", e)
            emptyList()
        }
    }

    private fun getTotalBalanceSqlite(context: Context, groupId: String): BalanceResult? {
        return try {
            openDb(context).use { db ->
                // Fetch group header
                val groupCursor = db.query(
                    TABLE_GROUPS,
                    arrayOf("title", "currency"),
                    "id = ? AND archived = 0",
                    arrayOf(groupId), null, null, null,
                )
                val (title, currency) = groupCursor.use {
                    if (!it.moveToFirst()) return null
                    Pair(
                        it.getString(it.getColumnIndexOrThrow("title")),
                        it.getString(it.getColumnIndexOrThrow("currency")),
                    )
                }
                // Sum all expense amounts
                val sumCursor = db.rawQuery(
                    "SELECT COALESCE(SUM(amount), 0) AS total FROM $TABLE_EXPENSES WHERE group_id = ?",
                    arrayOf(groupId),
                )
                val total = sumCursor.use {
                    if (it.moveToFirst()) it.getDouble(0) else 0.0
                }
                BalanceResult(
                    groupId = groupId,
                    groupTitle = title,
                    totalBalance = total,
                    currency = currency,
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "getTotalBalanceSqlite failed for group $groupId", e)
            null
        }
    }

    private fun getRecentExpensesSqlite(
        context: Context,
        groupId: String,
        count: Int,
    ): RecentExpensesResult? {
        return try {
            openDb(context).use { db ->
                // Fetch group header
                val groupCursor = db.query(
                    TABLE_GROUPS,
                    arrayOf("title", "currency"),
                    "id = ? AND archived = 0",
                    arrayOf(groupId), null, null, null,
                )
                val (title, currency) = groupCursor.use {
                    if (!it.moveToFirst()) return null
                    Pair(
                        it.getString(it.getColumnIndexOrThrow("title")),
                        it.getString(it.getColumnIndexOrThrow("currency")),
                    )
                }
                // Fetch recent expenses with JOIN for category and participant names
                val cursor = db.rawQuery(
                    """
                    SELECT e.id, e.name, e.amount, e.date, e.note,
                           c.name AS category_name,
                           p.name AS paid_by_name
                    FROM $TABLE_EXPENSES e
                    LEFT JOIN $TABLE_CATEGORIES c ON e.category_id = c.id
                    LEFT JOIN $TABLE_PARTICIPANTS p ON e.paid_by_id = p.id
                    WHERE e.group_id = ?
                    ORDER BY e.date DESC -- Sort by date descending (newest first)
                    LIMIT ?
                    """.trimIndent(),
                    arrayOf(groupId, count.toString()),
                )
                val expenses = mutableListOf<ExpenseSummary>()
                cursor.use {
                    while (it.moveToNext()) {
                        val epochMs = it.getLong(it.getColumnIndexOrThrow("date"))
                        // Produce an ISO-8601 UTC string compatible with Dart's DateTime.parse
                        // and consistent with the ISO format stored in the JSON backend.
                        val dateIso = java.time.Instant.ofEpochMilli(epochMs).toString()
                        val amountCol = it.getColumnIndexOrThrow("amount")
                        expenses.add(
                            ExpenseSummary(
                                id = it.getString(it.getColumnIndexOrThrow("id")),
                                categoryName = it.getString(it.getColumnIndexOrThrow("category_name")) ?: "",
                                amount = if (it.isNull(amountCol)) null else it.getDouble(amountCol),
                                paidByName = it.getString(it.getColumnIndexOrThrow("paid_by_name")) ?: "",
                                date = dateIso,
                                note = it.getString(it.getColumnIndexOrThrow("note")),
                                name = it.getString(it.getColumnIndexOrThrow("name")),
                            )
                        )
                    }
                }
                RecentExpensesResult(
                    groupId = groupId,
                    groupTitle = title,
                    currency = currency,
                    expenses = expenses,
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "getRecentExpensesSqlite failed for group $groupId", e)
            null
        }
    }

    private fun getTodayTotalSqlite(context: Context, groupId: String): TodayTotalResult? {
        return try {
            openDb(context).use { db ->
                // Fetch group header
                val groupCursor = db.query(
                    TABLE_GROUPS,
                    arrayOf("title", "currency"),
                    "id = ? AND archived = 0",
                    arrayOf(groupId), null, null, null,
                )
                val (title, currency) = groupCursor.use {
                    if (!it.moveToFirst()) return null
                    Pair(
                        it.getString(it.getColumnIndexOrThrow("title")),
                        it.getString(it.getColumnIndexOrThrow("currency")),
                    )
                }
                // Compute start/end of today in epoch milliseconds
                val zone = ZoneId.systemDefault()
                val today = LocalDate.now(zone)
                val todayStart = today.atStartOfDay(zone).toInstant().toEpochMilli()
                val todayEnd = today.plusDays(1).atStartOfDay(zone).toInstant().toEpochMilli()

                val sumCursor = db.rawQuery(
                    """
                    SELECT COALESCE(SUM(amount), 0) AS total
                    FROM $TABLE_EXPENSES
                    WHERE group_id = ? AND date >= ? AND date < ?
                    """.trimIndent(),
                    arrayOf(groupId, todayStart.toString(), todayEnd.toString()),
                )
                val total = sumCursor.use {
                    if (it.moveToFirst()) it.getDouble(0) else 0.0
                }
                TodayTotalResult(
                    groupId = groupId,
                    groupTitle = title,
                    todayTotal = total,
                    currency = currency,
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "getTodayTotalSqlite failed for group $groupId", e)
            null
        }
    }

    // ------------------------------------------------------------------
    // JSON implementation
    // ------------------------------------------------------------------

    private fun loadGroupsArray(context: Context): JSONArray? {
        return try {
            val file = File(context.filesDir, JSON_FILE_NAME)
            if (!file.exists()) return null
            val root = JSONObject(file.readText())
            root.optJSONArray("groups")
        } catch (_: Exception) {
            null
        }
    }

    private fun findGroupJson(context: Context, groupId: String): JSONObject? {
        val array = loadGroupsArray(context) ?: return null
        for (i in 0 until array.length()) {
            val obj = array.optJSONObject(i) ?: continue
            if (obj.optString("id") == groupId) return obj
        }
        return null
    }

    private fun getActiveGroupsJson(context: Context): List<GroupSummary> {
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

    private fun getTotalBalanceJson(context: Context, groupId: String): BalanceResult? {
        val group = findGroupJson(context, groupId) ?: return null
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

    private fun getRecentExpensesJson(
        context: Context,
        groupId: String,
        count: Int,
    ): RecentExpensesResult? {
        val group = findGroupJson(context, groupId) ?: return null
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

    private fun getTodayTotalJson(context: Context, groupId: String): TodayTotalResult? {
        val group = findGroupJson(context, groupId) ?: return null
        val expenses = group.optJSONArray("expenses") ?: JSONArray()

        val today = LocalDate.now(ZoneId.systemDefault()).toString() // yyyy-MM-dd
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
    // SQLite write implementation
    // ------------------------------------------------------------------

    /**
     * Inserts a new expense row directly into the SQLite database.
     *
     * Category resolution order:
     * 1. Exact (case-insensitive) name match in the group's categories.
     * 2. First category in the group.
     * The first participant of the group is used as `paid_by`.
     *
     * Uses WAL-compatible READWRITE mode; safe even when the Flutter engine
     * is concurrently accessing the same database.
     */
    private fun saveExpenseSqlite(
        context: Context,
        groupId: String,
        amount: Double,
        categoryName: String?,
        note: String?,
    ): SaveExpenseResult {
        return try {
            openDbReadWrite(context).use { db ->
                // Verify group exists
                val groupCursor = db.query(
                    TABLE_GROUPS,
                    arrayOf("id"),
                    "id = ? AND archived = 0",
                    arrayOf(groupId), null, null, null,
                )
                val groupExists = groupCursor.use { it.moveToFirst() }
                if (!groupExists) {
                    return SaveExpenseResult.Failure("Group not found: $groupId")
                }

                // Resolve category_id
                val allCategories = db.query(
                    TABLE_CATEGORIES,
                    arrayOf("id", "name"),
                    "group_id = ?",
                    arrayOf(groupId), null, null, null,
                )
                var resolvedCategoryId: String? = null
                allCategories.use { cur ->
                    // Try name match first
                    if (categoryName != null) {
                        while (cur.moveToNext()) {
                            if (cur.getString(cur.getColumnIndexOrThrow("name"))
                                    .equals(categoryName, ignoreCase = true)) {
                                resolvedCategoryId = cur.getString(cur.getColumnIndexOrThrow("id"))
                                break
                            }
                        }
                    }
                    // Fallback to first category (reset cursor position first)
                    if (resolvedCategoryId == null && cur.moveToFirst()) {
                        resolvedCategoryId = cur.getString(cur.getColumnIndexOrThrow("id"))
                    }
                }
                if (resolvedCategoryId == null) {
                    return SaveExpenseResult.Failure("No categories defined for group $groupId")
                }

                // Resolve paid_by_id (first participant)
                val participantCursor = db.query(
                    TABLE_PARTICIPANTS,
                    arrayOf("id"),
                    "group_id = ?",
                    arrayOf(groupId), null, null, null, "1",
                )
                val paidById = participantCursor.use { cur ->
                    if (cur.moveToFirst()) cur.getString(cur.getColumnIndexOrThrow("id")) else null
                }
                if (paidById == null) {
                    return SaveExpenseResult.Failure("No participants defined for group $groupId")
                }

                // Insert the new expense row
                // `name` stores the user-visible description; use note when available,
                // otherwise the category name, so the expense is identifiable in the UI.
                val expenseId = UUID.randomUUID().toString()
                val values = ContentValues().apply {
                    put("id", expenseId)
                    put("group_id", groupId)
                    put("name", note ?: categoryName ?: "Untitled Expense")
                    put("amount", amount)
                    put("date", Instant.now().toEpochMilli())
                    put("category_id", resolvedCategoryId)
                    put("paid_by_id", paidById)
                    if (note != null) put("note", note)
                }
                // insertOrThrow throws on constraint violation – no -1 check needed
                db.insertOrThrow(TABLE_EXPENSES, null, values)
                Log.i(TAG, "saveExpenseSqlite: inserted expense $expenseId in group $groupId (amount=$amount)")
                SaveExpenseResult.Success(expenseId)
            }
        } catch (e: Exception) {
            Log.e(TAG, "saveExpenseSqlite failed for group $groupId", e)
            SaveExpenseResult.Failure(e.message ?: "Unknown error")
        }
    }

    // ------------------------------------------------------------------
    // JSON write implementation
    // ------------------------------------------------------------------

    /**
     * Appends a new expense object to the JSON storage file.
     *
     * The write is performed atomically: data is written to a temporary file
     * first, then renamed over the original to avoid partial writes on crash.
     * The expense JSON schema mirrors `ExpenseDetails.toJson()` on the Dart side.
     */
    private fun saveExpenseJson(
        context: Context,
        groupId: String,
        amount: Double,
        categoryName: String?,
        note: String?,
    ): SaveExpenseResult {
        return try {
            val file = File(context.filesDir, JSON_FILE_NAME)
            if (!file.exists()) return SaveExpenseResult.Failure("Storage file not found")

            val root = JSONObject(file.readText())
            val groups = root.optJSONArray("groups")
                ?: return SaveExpenseResult.Failure("'groups' array missing in storage file")

            // Find group index
            var groupIndex = -1
            var groupObj: JSONObject? = null
            for (i in 0 until groups.length()) {
                val g = groups.optJSONObject(i) ?: continue
                if (g.optString("id") == groupId) {
                    groupIndex = i
                    groupObj = g
                    break
                }
            }
            if (groupObj == null) return SaveExpenseResult.Failure("Group not found: $groupId")

            // Resolve category
            val categoriesArr = groupObj.optJSONArray("categories") ?: JSONArray()
            var resolvedCategory: JSONObject? = null
            if (categoryName != null) {
                for (i in 0 until categoriesArr.length()) {
                    val c = categoriesArr.optJSONObject(i) ?: continue
                    if (c.optString("name").equals(categoryName, ignoreCase = true)) {
                        resolvedCategory = c
                        break
                    }
                }
            }
            if (resolvedCategory == null && categoriesArr.length() > 0) {
                resolvedCategory = categoriesArr.optJSONObject(0)
            }
            if (resolvedCategory == null) {
                // No existing categories – create a new one and persist it to the group's list
                // so the Flutter app can find it when resolving the expense reference.
                val now = Instant.now().toString()
                val newCategory = JSONObject().apply {
                    put("id", UUID.randomUUID().toString())
                    put("name", categoryName ?: "Other")
                    put("createdAt", now)
                }
                categoriesArr.put(newCategory)
                groupObj.put("categories", categoriesArr)
                resolvedCategory = newCategory
            }

            // Resolve participant (first in list); if no participants exist, create and persist one
            // so that the expense reference is consistent when the Flutter app reads the file.
            val participantsArr = groupObj.optJSONArray("participants") ?: JSONArray().also {
                groupObj.put("participants", it)
            }
            val paidBy: JSONObject = participantsArr.optJSONObject(0) ?: run {
                val newParticipant = JSONObject().apply {
                    put("id", UUID.randomUUID().toString())
                    put("name", "Me")
                    put("createdAt", Instant.now().toString())
                }
                participantsArr.put(newParticipant)
                groupObj.put("participants", participantsArr)
                newParticipant
            }

            // Build the expense JSON (mirrors ExpenseDetails.toJson())
            // `name` is the user-visible description; use note if available, otherwise category name.
            val expenseId = UUID.randomUUID().toString()
            val expenseObj = JSONObject().apply {
                put("id", expenseId)
                put("category", resolvedCategory)
                put("amount", amount)
                put("paidBy", paidBy)
                put("date", Instant.now().toString())
                put("name", note ?: categoryName ?: "Untitled Expense")
                if (note != null) put("note", note)
            }

            // Append expense to the group
            val expenses = groupObj.optJSONArray("expenses") ?: JSONArray().also {
                groupObj.put("expenses", it)
            }
            expenses.put(expenseObj)

            // Replace the group entry in the root array
            groups.put(groupIndex, groupObj)
            root.put("groups", groups)

            // Atomic write: write to a temp file then rename over the original
            val tmpFile = File(context.filesDir, "$JSON_FILE_NAME.tmp")
            tmpFile.writeText(root.toString())
            if (!tmpFile.renameTo(file)) {
                // rename() can fail across file systems; the original file is unchanged so
                // no data is corrupted, but the new expense was NOT saved.
                Log.e(TAG, "saveExpenseJson: atomic rename failed – expense $expenseId was not saved")
                tmpFile.delete()
                return SaveExpenseResult.Failure("Failed to persist new expense: file rename failed")
            }

            Log.i(TAG, "saveExpenseJson: inserted expense $expenseId in group $groupId (amount=$amount)")
            SaveExpenseResult.Success(expenseId)
        } catch (e: Exception) {
            Log.e(TAG, "saveExpenseJson failed for group $groupId", e)
            SaveExpenseResult.Failure(e.message ?: "Unknown error")
        }
    }

    // ------------------------------------------------------------------
    // Result data classes (shared between both backends)
    // ------------------------------------------------------------------

    /** Result of [saveExpense]. */
    sealed class SaveExpenseResult {
        data class Success(val expenseId: String) : SaveExpenseResult()
        data class Failure(val reason: String) : SaveExpenseResult()
    }

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
        /** Expense amount; `null` for entries where no amount was recorded. */
        val amount: Double?,
        val paidByName: String,
        /** ISO-8601 date string. */
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
