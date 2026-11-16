package io.caravella.egm.appfunctions

import android.content.Context
import android.content.ContentValues
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.TemporalAdjusters
import java.time.temporal.WeekFields
import java.util.Locale
import java.util.UUID

/**
 * Reads Caravella expense data directly from Kotlin, without starting the
 * Flutter engine.
 *
 * It reads (and, for an agent's new expense, writes) the app's SQLite
 * database (`SqliteExpenseGroupRepository`), `expense_groups.db` in the
 * system database directory (`context.getDatabasePath("expense_groups.db")`).
 * Schema:
 *  - `groups`       – id, title, currency, start_date, end_date, timestamp,
 *                     pinned, archived, …
 *  - `participants` – id, group_id, name
 *  - `categories`   – id, group_id, name
 *  - `expenses`     – id, group_id, name, amount (REAL), date (epoch ms),
 *                     category_id, paid_by_id, note, …
 *
 * Without a database (the app never opened) every read finds nothing.
 *
 * All public methods are safe to call from a background [Service] (no Flutter
 * engine required) because they perform their own synchronous I/O.
 */
internal object AppFunctionStorageReader {

    // ------------------------------------------------------------------
    // Constants – must stay in sync with Flutter side
    // ------------------------------------------------------------------

    /** SQLite database file name (matches `SqliteExpenseGroupRepository`). */
    private const val SQLITE_DB_NAME = "expense_groups.db"

    // SQLite table / column names (mirrors SqliteExpenseGroupRepository)
    private const val TABLE_GROUPS = "groups"
    private const val TABLE_PARTICIPANTS = "participants"
    private const val TABLE_CATEGORIES = "categories"
    private const val TABLE_EXPENSES = "expenses"

    // All SQLite reads go through one of these two views instead of hand-rolled
    // per-function JOINs/WHERE clauses, so "which groups count as active" and
    // "how do expenses join to category/participant names" each live in one
    // place. group_summary_view backs getActiveGroupsSqlite, getTotalBalanceSqlite
    // and getWidgetTotalsSqlite; expense_details_view backs getRecentExpensesSqlite.
    private const val VIEW_GROUP_SUMMARY = "group_summary_view"
    private const val VIEW_EXPENSE_DETAILS = "expense_details_view"
    private const val DEFAULT_CURRENCY = "€"

    private const val TAG = "AppFunctionStorageReader"

    // Flutter's SharedPreferences (it adds "flutter." to its keys): this
    // device's sync id (DeviceIdentity) and the user's name.
    private const val FLUTTER_PREFS = "FlutterSharedPreferences"
    private const val PREF_DEVICE_ID = "flutter.sync_device_id"
    private const val PREF_USER_NAME = "flutter.user_name"
    @Volatile
    private var groupSummaryViewFirstDay: Int? = null
    private val viewsLock = Any()

    // ------------------------------------------------------------------
    // Public API
    // ------------------------------------------------------------------

    /**
     * Returns basic info about all active (non-archived) groups.
     */
    fun getActiveGroups(context: Context): List<GroupSummary> {
        return getActiveGroupsSqlite(context)
    }

    /**
     * Returns the total of all expense amounts for [groupId].
     * Returns `null` when the group cannot be found.
     */
    fun getTotalBalance(context: Context, groupId: String): BalanceResult? {
        return getTotalBalanceSqlite(context, groupId)
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
        return getRecentExpensesSqlite(context, groupId, count)
    }

    /**
     * Returns the sum of all expenses whose date falls on today's local date
     * for [groupId].  Returns `null` when the group cannot be found.
     */
    fun getTodayTotal(context: Context, groupId: String): TodayTotalResult? {
        return getTodayTotalSqlite(context, groupId)
    }

    /**
     * Returns the sum of all expenses in the current local week for [groupId].
     * Returns `null` when the group cannot be found.
     */
    fun getWeekTotal(context: Context, groupId: String): WeekTotalResult? {
        return getWeekTotalSqlite(context, groupId)
    }

    /**
     * Returns both widget totals in a single read for [groupId].
     */
    fun getWidgetTotals(context: Context, groupId: String): WidgetTotalsResult? {
        return getWidgetTotalsSqlite(context, groupId)
    }

    /**
     * Persists a new expense entry for [groupId] directly to the database
     * **without starting the Flutter engine**.
     *
     * This is the write counterpart of the read-only query methods and enables
     * `addExpense` App Function calls to complete silently in the background
     * when the AI agent supplies a valid [amount].
     *
     * Category resolution:
     * - If [categoryName] matches an existing category (case-insensitive) that
     *   category is reused.
     * - Otherwise the first category of the group is used as a fallback.
     * - If the group has no categories at all, nothing is saved.
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
        return saveExpenseSqlite(context, groupId, amount, categoryName, note)
    }

    // ------------------------------------------------------------------
    // SQLite implementation
    // ------------------------------------------------------------------

    // Every read below goes through openDbReadWrite() rather than a
    // read-only connection: the shared views (group_summary_view,
    // expense_details_view) are created lazily on first access via
    // CREATE VIEW IF NOT EXISTS, which needs write access.
    /** The names of [table]'s columns (older databases lack the sync ones). */
    private fun columnsOf(db: SQLiteDatabase, table: String): Set<String> =
        db.rawQuery("PRAGMA table_info($table)", null).use { c ->
            buildSet { while (c.moveToNext()) add(c.getString(1)) }
        }

    private fun openDbReadWrite(context: Context): SQLiteDatabase {
        val path = context.getDatabasePath(SQLITE_DB_NAME).absolutePath
        return SQLiteDatabase.openDatabase(path, null, SQLiteDatabase.OPEN_READWRITE)
    }

    private fun getActiveGroupsSqlite(context: Context): List<GroupSummary> {
        return try {
            openDbReadWrite(context).use { db ->
                ensureGroupSummaryView(db, currentFirstDayOfWeekSqlite())
                val cursor = db.rawQuery(
                    """
                    SELECT group_id, group_title, currency, group_color, group_background_image_path
                    FROM $VIEW_GROUP_SUMMARY
                    ORDER BY group_timestamp DESC
                    """.trimIndent(),
                    null,
                )
                val result = mutableListOf<GroupSummary>()
                cursor.use {
                    while (it.moveToNext()) {
                        result.add(
                            GroupSummary(
                                id = it.getString(it.getColumnIndexOrThrow("group_id")),
                                title = it.getString(it.getColumnIndexOrThrow("group_title")),
                                currency = it.getString(it.getColumnIndexOrThrow("currency")),
                                color = if (it.isNull(it.getColumnIndexOrThrow("group_color"))) {
                                    null
                                } else {
                                    it.getInt(it.getColumnIndexOrThrow("group_color"))
                                },
                                backgroundImagePath = it.getString(
                                    it.getColumnIndexOrThrow("group_background_image_path"),
                                )?.takeIf { filePath -> filePath.isNotBlank() },
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
            openDbReadWrite(context).use { db ->
                ensureGroupSummaryView(db, currentFirstDayOfWeekSqlite())
                val cursor = db.rawQuery(
                    """
                    SELECT group_title, currency, group_total
                    FROM $VIEW_GROUP_SUMMARY
                    WHERE group_id = ?
                    """.trimIndent(),
                    arrayOf(groupId),
                )
                cursor.use {
                    if (!it.moveToFirst()) return null
                    BalanceResult(
                        groupId = groupId,
                        groupTitle = it.getString(it.getColumnIndexOrThrow("group_title")),
                        totalBalance = it.getDouble(it.getColumnIndexOrThrow("group_total")),
                        currency = it.getString(it.getColumnIndexOrThrow("currency")),
                    )
                }
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
            openDbReadWrite(context).use { db ->
                ensureGroupSummaryView(db, currentFirstDayOfWeekSqlite())
                ensureExpenseDetailsView(db)

                // Fetch group header
                val groupCursor = db.rawQuery(
                    "SELECT group_title, currency FROM $VIEW_GROUP_SUMMARY WHERE group_id = ?",
                    arrayOf(groupId),
                )
                val (title, currency) = groupCursor.use {
                    if (!it.moveToFirst()) return null
                    Pair(
                        it.getString(it.getColumnIndexOrThrow("group_title")),
                        it.getString(it.getColumnIndexOrThrow("currency")),
                    )
                }
                // Fetch recent expenses; category/participant names already
                // joined in via expense_details_view.
                val cursor = db.rawQuery(
                    """
                    SELECT expense_id, expense_name, amount, date, note, category_name, paid_by_name
                    FROM $VIEW_EXPENSE_DETAILS
                    WHERE group_id = ?
                    ORDER BY date DESC -- Sort by date descending (newest first)
                    LIMIT ?
                    """.trimIndent(),
                    arrayOf(groupId, count.toString()),
                )
                val expenses = mutableListOf<ExpenseSummary>()
                cursor.use {
                    while (it.moveToNext()) {
                        val epochMs = it.getLong(it.getColumnIndexOrThrow("date"))
                        // Produce an ISO-8601 UTC string compatible with Dart's DateTime.parse
                        val dateIso = java.time.Instant.ofEpochMilli(epochMs).toString()
                        val amountCol = it.getColumnIndexOrThrow("amount")
                        expenses.add(
                            ExpenseSummary(
                                id = it.getString(it.getColumnIndexOrThrow("expense_id")),
                                categoryName = it.getString(it.getColumnIndexOrThrow("category_name")) ?: "",
                                amount = if (it.isNull(amountCol)) null else it.getDouble(amountCol),
                                paidByName = it.getString(it.getColumnIndexOrThrow("paid_by_name")) ?: "",
                                date = dateIso,
                                note = it.getString(it.getColumnIndexOrThrow("note")),
                                name = it.getString(it.getColumnIndexOrThrow("expense_name")),
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
            val totals = getWidgetTotalsSqlite(context, groupId) ?: return null
            TodayTotalResult(
                groupId = totals.groupId,
                groupTitle = totals.groupTitle,
                todayTotal = totals.todayTotal,
                currency = totals.currency,
            )
        } catch (e: Exception) {
            Log.e(TAG, "getTodayTotalSqlite failed for group $groupId", e)
            null
        }
    }

    private fun getWeekTotalSqlite(context: Context, groupId: String): WeekTotalResult? {
        return try {
            val totals = getWidgetTotalsSqlite(context, groupId) ?: return null
            WeekTotalResult(
                groupId = totals.groupId,
                groupTitle = totals.groupTitle,
                weekTotal = totals.weekTotal,
                currency = totals.currency,
            )
        } catch (e: Exception) {
            Log.e(TAG, "getWeekTotalSqlite failed for group $groupId", e)
            null
        }
    }

    private fun getWidgetTotalsSqlite(context: Context, groupId: String): WidgetTotalsResult? {
        return try {
            // Write access is required the first time to create/update the shared SQL view.
            openDbReadWrite(context).use { db ->
                ensureGroupSummaryView(db, currentFirstDayOfWeekSqlite())
                val cursor = db.rawQuery(
                    """
                    SELECT
                        group_id,
                        group_title,
                        currency,
                        today_total,
                        week_total,
                        group_total,
                        group_color,
                        group_background_image_path
                    FROM $VIEW_GROUP_SUMMARY
                    WHERE group_id = ?
                    """.trimIndent(),
                    arrayOf(groupId),
                )
                cursor.use {
                    if (!it.moveToFirst()) return null
                    WidgetTotalsResult(
                        groupId = it.getString(it.getColumnIndexOrThrow("group_id")),
                        groupTitle = it.getString(it.getColumnIndexOrThrow("group_title")),
                        currency = it.getString(it.getColumnIndexOrThrow("currency")),
                        todayTotal = it.getDouble(it.getColumnIndexOrThrow("today_total")),
                        weekTotal = it.getDouble(it.getColumnIndexOrThrow("week_total")),
                        groupTotal = it.getDouble(it.getColumnIndexOrThrow("group_total")),
                        groupColor = if (it.isNull(it.getColumnIndexOrThrow("group_color"))) {
                            null
                        } else {
                            it.getInt(it.getColumnIndexOrThrow("group_color"))
                        },
                        groupBackgroundImagePath = it.getString(
                            it.getColumnIndexOrThrow("group_background_image_path"),
                        )?.takeIf { path -> path.isNotBlank() },
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "getWidgetTotalsSqlite failed for group $groupId", e)
            null
        }
    }

    /** Converts ISO-8601 DayOfWeek (1=Monday..7=Sunday) to SQLite %w (0=Sunday..6=Saturday). */
    private fun currentFirstDayOfWeekSqlite(): Int =
        WeekFields.of(Locale.getDefault()).firstDayOfWeek.value % 7

    /**
     * Per-group summary used by every SQLite read except recent expenses:
     * active groups' id/title/currency/color/background plus today/week/total
     * spend. Centralizes the "archived = 0" filter and the today/week/group
     * amount aggregation so callers never hand-roll their own JOIN for it.
     */
    private fun ensureGroupSummaryView(db: SQLiteDatabase, firstDayOfWeekSqlite: Int) {
        synchronized(viewsLock) {
            // No early return on a remembered "done": the database file can be
            // replaced while the process lives (backup restore, cleared data),
            // taking the views with it. CREATE VIEW IF NOT EXISTS is cheap.
            if (groupSummaryViewFirstDay != null && groupSummaryViewFirstDay != firstDayOfWeekSqlite) {
                db.execSQL("DROP VIEW IF EXISTS $VIEW_GROUP_SUMMARY")
            }
            db.execSQL(
                """
                CREATE VIEW IF NOT EXISTS $VIEW_GROUP_SUMMARY AS
                SELECT
                    g.id AS group_id,
                    g.title AS group_title,
                    g.timestamp AS group_timestamp,
                    COALESCE(NULLIF(g.currency, ''), '$DEFAULT_CURRENCY') AS currency,
                    g.color AS group_color,
                    g.file AS group_background_image_path,
                    COALESCE(
                        SUM(
                            CASE
                                WHEN e.local_date = d.today_local THEN e.amount
                                ELSE 0
                            END
                        ),
                        0
                    ) AS today_total,
                    COALESCE(
                        SUM(
                            CASE
                                WHEN e.local_date >= d.week_start
                                    AND e.local_date < date(d.week_start, '+7 days') THEN e.amount
                                ELSE 0
                            END
                        ),
                        0
                    ) AS week_total,
                    COALESCE(SUM(e.amount), 0) AS group_total
                FROM $TABLE_GROUPS g
                LEFT JOIN (
                    -- expenses.date is stored as epoch milliseconds, so divide by 1000 for SQLite date funcs.
                    SELECT ex.group_id, ex.amount, date(ex.date / 1000, 'unixepoch', 'localtime') AS local_date
                    FROM $TABLE_EXPENSES ex
                ) e ON e.group_id = g.id
                CROSS JOIN (
                    SELECT
                        date('now', 'localtime') AS today_local,
                        -- Move from today back to the locale-specific first day of this week.
                        date(
                            'now',
                            'localtime',
                            -- SQLite %w is Sunday=0..Saturday=6; adjust using locale first-day index.
                            '-' || ((CAST(strftime('%w', 'now', 'localtime') AS INTEGER) - $firstDayOfWeekSqlite + 7) % 7) || ' days'
                        ) AS week_start
                ) d
                WHERE g.archived = 0
                GROUP BY g.id, g.title, g.timestamp, g.currency, g.color, g.file
                """.trimIndent(),
            )
            groupSummaryViewFirstDay = firstDayOfWeekSqlite
        }
    }

    /**
     * Flat per-expense rows with category/participant names already joined
     * in, so callers needing individual expenses (as opposed to per-group
     * aggregates) never hand-roll that JOIN either. Not archived-filtered
     * itself — callers only reach it after confirming the group exists via
     * [VIEW_GROUP_SUMMARY], which already excludes archived groups.
     */
    private fun ensureExpenseDetailsView(db: SQLiteDatabase) {
        synchronized(viewsLock) {
            db.execSQL(
                """
                CREATE VIEW IF NOT EXISTS $VIEW_EXPENSE_DETAILS AS
                SELECT
                    e.id AS expense_id,
                    e.group_id AS group_id,
                    e.name AS expense_name,
                    e.amount AS amount,
                    e.date AS date,
                    e.note AS note,
                    c.name AS category_name,
                    p.name AS paid_by_name
                FROM $TABLE_EXPENSES e
                LEFT JOIN $TABLE_CATEGORIES c ON e.category_id = c.id
                LEFT JOIN $TABLE_PARTICIPANTS p ON e.paid_by_id = p.id
                """.trimIndent(),
            )
        }
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
                // As the app does on every save (SqliteGroupMapper): say who
                // wrote the expense and move the group's updated_at, or sync
                // never sends it and the next incoming copy of the group
                // (Last Writer Wins) drops it.
                val now = Instant.now().toEpochMilli()
                val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
                val deviceId = prefs.getString(PREF_DEVICE_ID, null)?.takeIf { it.isNotEmpty() }
                val expenseColumns = columnsOf(db, TABLE_EXPENSES)
                if (deviceId != null && "created_by_device_id" in expenseColumns) {
                    val userName = prefs.getString(PREF_USER_NAME, null)
                    values.put("created_by_device_id", deviceId)
                    values.put("updated_by_device_id", deviceId)
                    if (userName != null) {
                        values.put("created_by_user_name", userName)
                        values.put("updated_by_user_name", userName)
                    }
                }
                // The expense's own last-change time (schema v11), which sync
                // merges by.
                if ("updated_at" in expenseColumns) values.put("updated_at", now)
                db.beginTransaction()
                try {
                    // insertOrThrow throws on constraint violation – no -1 check needed
                    db.insertOrThrow(TABLE_EXPENSES, null, values)
                    if ("updated_at" in columnsOf(db, TABLE_GROUPS)) {
                        val stamp = ContentValues().apply {
                            put("updated_at", now)
                            if (deviceId != null) put("device_id", deviceId)
                        }
                        db.update(TABLE_GROUPS, stamp, "id = ?", arrayOf(groupId))
                    }
                    db.setTransactionSuccessful()
                } finally {
                    db.endTransaction()
                }
                Log.i(TAG, "saveExpenseSqlite: inserted expense $expenseId in group $groupId (amount=$amount)")
                SaveExpenseResult.Success(expenseId)
            }
        } catch (e: Exception) {
            Log.e(TAG, "saveExpenseSqlite failed for group $groupId", e)
            SaveExpenseResult.Failure(e.message ?: "Unknown error")
        }
    }

    // ------------------------------------------------------------------
    // Result data classes
    // ------------------------------------------------------------------

    /** Result of [saveExpense]. */
    sealed class SaveExpenseResult {
        data class Success(val expenseId: String) : SaveExpenseResult()
        data class Failure(val reason: String) : SaveExpenseResult()
    }

    data class GroupSummary(
        val id: String,
        val title: String,
        val currency: String,
        val color: Int? = null,
        val backgroundImagePath: String? = null,
    )

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

    data class WeekTotalResult(
        val groupId: String,
        val groupTitle: String,
        val weekTotal: Double,
        val currency: String,
    )

    data class WidgetTotalsResult(
        val groupId: String,
        val groupTitle: String,
        val todayTotal: Double,
        val weekTotal: Double,
        val groupTotal: Double,
        val currency: String,
        val groupColor: Int?,
        val groupBackgroundImagePath: String?,
    )
}
