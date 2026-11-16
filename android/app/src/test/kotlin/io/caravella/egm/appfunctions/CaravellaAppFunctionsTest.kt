package io.caravella.egm.appfunctions

import android.app.PendingIntent
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import androidx.appfunctions.AppFunctionData
import androidx.appfunctions.AppFunctionDisabledException
import androidx.appfunctions.AppFunctionElementNotFoundException
import androidx.appfunctions.AppFunctionInvalidArgumentException
import androidx.appfunctions.AppFunctionManager
import androidx.appfunctions.AppFunctionSearchSpec
import androidx.appfunctions.ExecuteAppFunctionRequest
import androidx.appfunctions.ExecuteAppFunctionResponse
import androidx.appfunctions.metadata.AppFunctionMetadata
import androidx.appfunctions.testing.AppFunctionTestRule
import androidx.test.core.app.ApplicationProvider
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLog
import kotlinx.coroutines.withTimeout

/**
 * Caravella's App Functions called the way an agent calls them: found by
 * search and executed through the service the compiler generates and the
 * manifest declares, over a small SQLite database shaped like the app's.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [36])
class CaravellaAppFunctionsTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @get:Rule
    val rule = AppFunctionTestRule(context)

    private val manager by lazy { rule.getAppFunctionManager() }

    @Before
    fun setUp() {
        ShadowLog.stream = System.out
        enable(true)
        val path = context.getDatabasePath("expense_groups.db")
        path.parentFile?.mkdirs()
        SQLiteDatabase.openOrCreateDatabase(path, null).use { db ->
            db.execSQL(
                "CREATE TABLE groups (id TEXT PRIMARY KEY, title TEXT, currency TEXT, " +
                    "timestamp INTEGER, color INTEGER, file TEXT, archived INTEGER DEFAULT 0, " +
                    "device_id TEXT NOT NULL DEFAULT '', updated_at INTEGER NOT NULL DEFAULT 0)",
            )
            db.execSQL("CREATE TABLE participants (id TEXT PRIMARY KEY, group_id TEXT, name TEXT)")
            db.execSQL("CREATE TABLE categories (id TEXT PRIMARY KEY, group_id TEXT, name TEXT)")
            db.execSQL(
                "CREATE TABLE expenses (id TEXT PRIMARY KEY, group_id TEXT, name TEXT, " +
                    "amount REAL, date INTEGER, category_id TEXT, paid_by_id TEXT, note TEXT, " +
                    "created_by_device_id TEXT, created_by_user_name TEXT, " +
                    "updated_by_device_id TEXT, updated_by_user_name TEXT)",
            )
            db.execSQL("INSERT INTO groups VALUES ('g1', 'Norway', '€', 2, NULL, NULL, 0, '', 1)")
            db.execSQL("INSERT INTO groups VALUES ('old', 'Archived', '€', 1, NULL, NULL, 1, '', 1)")
            db.execSQL("INSERT INTO participants VALUES ('anna', 'g1', 'Anna')")
            db.execSQL("INSERT INTO categories VALUES ('food', 'g1', 'Food')")
            db.execSQL("INSERT INTO categories VALUES ('ferry', 'g1', 'Transport')")
            db.execSQL(
                "INSERT INTO expenses VALUES ('e1', 'g1', 'Fish soup', 54.5, " +
                    "${System.currentTimeMillis()}, 'food', 'anna', NULL, NULL, NULL, NULL, NULL)",
            )
        }
    }

    /** The privacy toggle, as the app sets it: the preference, then the system state. */
    private fun enable(on: Boolean) {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit().putBoolean("flutter.app_functions_enabled", on).commit()
        runBlocking { AppFunctionsState.sync(manager, on) }
    }

    private fun enabledInSystem(): List<Boolean> = runBlocking {
        AppFunctionsState.FUNCTION_IDS.map { manager.isAppFunctionEnabled(it) }
    }

    private suspend fun function(name: String): AppFunctionMetadata =
        manager.searchAppFunctions(AppFunctionSearchSpec(packageNames = setOf(context.packageName)))
            .single { it.id.endsWith("#$name") }

    private suspend fun call(
        name: String,
        params: AppFunctionData.Builder.() -> Unit = {},
    ): ExecuteAppFunctionResponse {
        val f = function(name)
        return withTimeout(20_000) { manager.executeAppFunction(
            ExecuteAppFunctionRequest(
                targetPackageName = context.packageName,
                functionIdentifier = f.id,
                functionParameters = AppFunctionData.Builder(f.parameters, f.components)
                    .apply(params)
                    .build(),
            ),
        ) }
    }

    private fun ExecuteAppFunctionResponse.value(): AppFunctionData {
        assertTrue(
            "expected success, got ${(this as? ExecuteAppFunctionResponse.Error)?.error}",
            this is ExecuteAppFunctionResponse.Success,
        )
        return (this as ExecuteAppFunctionResponse.Success).returnValue
    }

    private fun ExecuteAppFunctionResponse.error(): Any {
        assertTrue("expected an error, got $this", this is ExecuteAppFunctionResponse.Error)
        return (this as ExecuteAppFunctionResponse.Error).error
    }

    private val returned = ExecuteAppFunctionResponse.Success.PROPERTY_RETURN_VALUE

    @Test
    fun `the five functions are found`() = runBlocking {
        val ids = manager.searchAppFunctions(
            AppFunctionSearchSpec(packageNames = setOf(context.packageName)),
        ).map { it.id.substringAfter('#') }.toSet()
        assertEquals(
            setOf("listGroups", "addExpense", "getGroupBalance", "getRecentExpenses", "getTodayTotal"),
            ids,
        )
    }

    @Test
    fun `listGroups returns the active groups`() = runBlocking {
        val groups = call("listGroups").value().getAppFunctionDataList(returned)!!
        assertEquals(1, groups.size)
        assertEquals("g1", groups[0].getString("groupId"))
        assertEquals("Norway", groups[0].getString("title"))
    }

    @Test
    fun `addExpense with an amount saves it`() = runBlocking {
        val added = call("addExpense") {
            setString("groupId", "g1")
            setDouble("amount", 12.5)
            setString("categoryName", "transport")
            setString("note", "Bus")
        }.value().getAppFunctionData(returned)!!
        assertNotNull(added.getString("expenseId"))
        assertEquals(12.5, added.getDouble("amount"), 1e-9)

        val total = call("getGroupBalance") { setString("groupId", "g1") }
            .value().getAppFunctionData(returned)!!
        assertEquals(67.0, total.getDouble("totalBalance"), 1e-9)
    }

    @Test
    fun `an added expense is stamped for sync`() = runBlocking {
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE).edit()
            .putString("flutter.sync_device_id", "this-phone")
            .putString("flutter.user_name", "Anna")
            .commit()
        val before = System.currentTimeMillis()
        val id = call("addExpense") {
            setString("groupId", "g1")
            setDouble("amount", 5.0)
        }.value().getAppFunctionData(returned)!!.getString("expenseId")

        SQLiteDatabase.openDatabase(
            context.getDatabasePath("expense_groups.db").path, null, SQLiteDatabase.OPEN_READONLY,
        ).use { db ->
            // The group moved, or sync would never send the expense.
            db.rawQuery("SELECT updated_at, device_id FROM groups WHERE id = 'g1'", null).use {
                assertTrue(it.moveToFirst())
                assertTrue(it.getLong(0) >= before)
                assertEquals("this-phone", it.getString(1))
            }
            // The archived group is untouched.
            db.rawQuery("SELECT updated_at FROM groups WHERE id = 'old'", null).use {
                assertTrue(it.moveToFirst())
                assertEquals(1L, it.getLong(0))
            }
            db.rawQuery(
                "SELECT created_by_device_id, created_by_user_name, updated_by_device_id " +
                    "FROM expenses WHERE id = ?",
                arrayOf(id),
            ).use {
                assertTrue(it.moveToFirst())
                assertEquals("this-phone", it.getString(0))
                assertEquals("Anna", it.getString(1))
                assertEquals("this-phone", it.getString(2))
            }
        }
    }

    @Test
    fun `addExpense without an amount gives the form to open`() = runBlocking {
        val added = call("addExpense") { setString("groupId", "g1") }
            .value().getAppFunctionData(returned)!!
        assertNull(added.getStringOrNull("expenseId"))
        val form = added.getParcelable("intentToOpen", PendingIntent::class.java)
        assertNotNull(form)
        // Nothing saved: still only the fish soup.
        val total = call("getGroupBalance") { setString("groupId", "g1") }
            .value().getAppFunctionData(returned)!!
        assertEquals(54.5, total.getDouble("totalBalance"), 1e-9)
    }

    @Test
    fun `addExpense refuses a non-positive amount`() = runBlocking {
        val error = call("addExpense") {
            setString("groupId", "g1")
            setDouble("amount", 0.0)
        }.error()
        assertTrue(error.toString(), error is AppFunctionInvalidArgumentException)
    }

    @Test
    fun `recent expenses and today's total`() = runBlocking {
        val recent = call("getRecentExpenses") { setString("groupId", "g1") }
            .value().getAppFunctionData(returned)!!
        val expenses = recent.getAppFunctionDataList("expenses")!!
        assertEquals("Fish soup", expenses.single().getString("name"))
        assertEquals("Anna", expenses.single().getString("paidByName"))

        val today = call("getTodayTotal") { setString("groupId", "g1") }
            .value().getAppFunctionData(returned)!!
        assertEquals(54.5, today.getDouble("todayTotal"), 1e-9)
    }

    @Test
    fun `an unknown group is not found`() = runBlocking {
        val error = call("getGroupBalance") { setString("groupId", "nope") }.error()
        assertTrue(error.toString(), error is AppFunctionElementNotFoundException)
    }

    @Test
    fun `with the privacy toggle off every function is refused`() = runBlocking {
        enable(false)
        val error = call("listGroups").error()
        assertTrue(error.toString(), error is AppFunctionDisabledException)
    }

    @Test
    fun `the system sees the functions enabled only with the toggle on`() {
        assertEquals(List(5) { true }, enabledInSystem())
        enable(false)
        assertEquals(List(5) { false }, enabledInSystem())
        enable(true)
        assertEquals(List(5) { true }, enabledInSystem())
    }

    @Test
    fun `the functions are declared disabled`() = runBlocking {
        val declared = manager.searchAppFunctions(
            AppFunctionSearchSpec(packageNames = setOf(context.packageName)),
        )
        assertEquals(AppFunctionsState.FUNCTION_IDS.toSet(), declared.map { it.id }.toSet())
        // Reset to what the XML declares: off until the user turns them on.
        AppFunctionsState.FUNCTION_IDS.forEach {
            manager.setAppFunctionEnabled(it, AppFunctionManager.APP_FUNCTION_STATE_DEFAULT)
        }
        assertEquals(List(5) { false }, enabledInSystem())
    }
}
