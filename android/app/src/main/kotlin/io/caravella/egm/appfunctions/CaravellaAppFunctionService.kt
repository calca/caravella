package io.caravella.egm.appfunctions

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.appfunctions.AppFunctionDeclaration
import androidx.appfunctions.AppFunctionDisabledException
import androidx.appfunctions.AppFunctionElementNotFoundException
import androidx.appfunctions.AppFunctionInvalidArgumentException
import androidx.appfunctions.AppFunctionSerializable
import androidx.appfunctions.AppFunctionService
import androidx.appfunctions.AppFunctionServiceEntryPoint
import io.caravella.egm.MainActivity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Caravella's App Functions: what Android AI agents (e.g. Gemini) can do in
 * the app on the user's behalf.
 *
 * Built on `androidx.appfunctions` 1.0: the functions below are declared with
 * [AppFunctionDeclaration], and the library's compiler (KSP) generates from
 * this class the concrete [CaravellaAppFunctionService] the system binds to
 * (action `android.app.appfunctions.AppFunctionService`, permission
 * `BIND_APP_FUNCTION_SERVICE`, see AndroidManifest.xml) and the XML that
 * describes them (`assets/caravella_app_functions.xml`). Their descriptions
 * for the agent are the KDoc below.
 *
 * Data is read and written natively by [AppFunctionStorageReader], without
 * starting Flutter. Every function is gated by the user's toggle in Settings →
 * Privacy (`app_functions_enabled`, off by default): the functions are
 * declared disabled and [AppFunctionsState] enables them in the system only
 * while the toggle is on; each call checks it too, and when off the agent
 * gets [AppFunctionDisabledException] and nothing is read.
 *
 * Runs on Android 16 (API 36) and later, where the platform provides App
 * Functions.
 */
@RequiresApi(Build.VERSION_CODES.BAKLAVA)
@AppFunctionServiceEntryPoint(
    serviceName = "CaravellaAppFunctionService",
    appFunctionXmlFileName = "caravella_app_functions",
)
abstract class BaseCaravellaAppFunctionService : AppFunctionService() {

    /**
     * Lists the user's active expense groups (trips, households, events…) in
     * Caravella, with the id the other functions need.
     *
     * @return The active groups, most recently used first.
     */
    @AppFunctionDeclaration(isDescribedByKDoc = true, isEnabled = false)
    suspend fun listGroups(): List<ExpenseGroupInfo> = io {
        AppFunctionStorageReader.getActiveGroups(this).map {
            ExpenseGroupInfo(groupId = it.id, title = it.title, currency = it.currency)
        }
    }

    /**
     * Adds an expense to a Caravella group. With an amount the expense is
     * saved right away, paid by the group's first participant; without one,
     * nothing is saved and the result carries intentToOpen, which opens the
     * group in Caravella, where the user can add it.
     *
     * @param groupId The group's id, from listGroups.
     * @param amount The amount in the group's currency, greater than 0; null
     *   to let the user type it in the app.
     * @param categoryName The category, matched by name ignoring case; the
     *   group's first category when null or not found.
     * @param note What the expense was for, used as its name.
     * @return The saved expense, or, without an amount, the group to open.
     */
    @AppFunctionDeclaration(isDescribedByKDoc = true, isEnabled = false)
    suspend fun addExpense(
        groupId: String,
        amount: Double?,
        categoryName: String?,
        note: String?,
    ): AddedExpense = io {
        if (amount != null) {
            if (amount <= 0.0) {
                throw AppFunctionInvalidArgumentException("'amount' must be greater than 0")
            }
            when (
                val result = AppFunctionStorageReader.saveExpense(
                    this, groupId, amount, categoryName, note,
                )
            ) {
                is AppFunctionStorageReader.SaveExpenseResult.Success ->
                    AddedExpense(
                        expenseId = result.expenseId,
                        groupId = groupId,
                        amount = amount,
                        intentToOpen = null,
                    )
                is AppFunctionStorageReader.SaveExpenseResult.Failure ->
                    throw AppFunctionInvalidArgumentException(result.reason)
            }
        } else {
            val group = AppFunctionStorageReader.getActiveGroups(this)
                .firstOrNull { it.id == groupId }
                ?: throw AppFunctionElementNotFoundException("Group not found: $groupId")
            // A PendingIntent for the agent to open (it is in the
            // foreground), rather than startActivity from this service, which
            // Android blocks from the background.
            val form = Intent(this, MainActivity::class.java).apply {
                action = ACTION_ADD_EXPENSE
                putExtra("groupId", groupId)
                putExtra("groupTitle", group.title)
                categoryName?.let { putExtra("categoryName", it) }
                note?.let { putExtra("note", it) }
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            AddedExpense(
                expenseId = null,
                groupId = groupId,
                amount = null,
                intentToOpen = PendingIntent.getActivity(
                    this,
                    groupId.hashCode(),
                    form,
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                ),
            )
        }
    }

    /**
     * Gets how much a Caravella group has spent in all.
     *
     * @param groupId The group's id, from listGroups.
     * @return The group's total spending and its currency.
     */
    @AppFunctionDeclaration(isDescribedByKDoc = true, isEnabled = false)
    suspend fun getGroupBalance(groupId: String): GroupBalance = io {
        val r = AppFunctionStorageReader.getTotalBalance(this, groupId)
            ?: throw AppFunctionElementNotFoundException("Group not found: $groupId")
        GroupBalance(r.groupId, r.groupTitle, r.totalBalance, r.currency)
    }

    /**
     * Gets the last three expenses of a Caravella group.
     *
     * @param groupId The group's id, from listGroups.
     * @return The newest expenses first, with who paid and the category.
     */
    @AppFunctionDeclaration(isDescribedByKDoc = true, isEnabled = false)
    suspend fun getRecentExpenses(groupId: String): RecentExpenses = io {
        val r = AppFunctionStorageReader.getRecentExpenses(this, groupId, count = RECENT_COUNT)
            ?: throw AppFunctionElementNotFoundException("Group not found: $groupId")
        RecentExpenses(
            groupId = r.groupId,
            groupTitle = r.groupTitle,
            currency = r.currency,
            expenses = r.expenses.map {
                ExpenseInfo(
                    expenseId = it.id,
                    name = it.name,
                    categoryName = it.categoryName,
                    amount = it.amount,
                    paidByName = it.paidByName,
                    date = it.date,
                    note = it.note,
                )
            },
        )
    }

    /**
     * Gets how much a Caravella group has spent today.
     *
     * @param groupId The group's id, from listGroups.
     * @return Today's total and the group's currency.
     */
    @AppFunctionDeclaration(isDescribedByKDoc = true, isEnabled = false)
    suspend fun getTodayTotal(groupId: String): TodayTotal = io {
        val r = AppFunctionStorageReader.getTodayTotal(this, groupId)
            ?: throw AppFunctionElementNotFoundException("Group not found: $groupId")
        TodayTotal(r.groupId, r.groupTitle, r.todayTotal, r.currency)
    }

    /**
     * Runs [block] off the main thread (the reader does disk I/O), after
     * checking the user's privacy toggle.
     *
     * Errors come back as a value and are thrown here, on the service's own
     * coroutine: an AppFunctionException thrown across the switch back from
     * [Dispatchers.IO] makes kotlinx.coroutines copy it by reflection, which
     * fails (fatally) where the system's App Functions extension classes it
     * refers to are missing.
     */
    private suspend fun <T> io(block: () -> T): T {
        if (!isEnabled(this)) {
            throw AppFunctionDisabledException(
                "App Functions are off. Turn them on in Caravella › Settings › Privacy.",
            )
        }
        return withContext(Dispatchers.IO) { runCatching(block) }.getOrThrow()
    }

    companion object {
        /** Opens the new-expense form on MainActivity (handled in Flutter). */
        const val ACTION_ADD_EXPENSE = "io.caravella.egm.ADD_EXPENSE"

        private const val RECENT_COUNT = 3

        // Flutter's SharedPreferences file and key (Flutter adds "flutter.").
        private const val FLUTTER_PREFS_NAME = "FlutterSharedPreferences"
        const val PREF_KEY_ENABLED = "flutter.app_functions_enabled"

        /** Flutter's SharedPreferences, where the privacy toggle lives. */
        fun prefs(context: Context) =
            context.getSharedPreferences(FLUTTER_PREFS_NAME, Context.MODE_PRIVATE)

        /** The privacy toggle; off by default, as `_PreferenceDefaults`. */
        fun isEnabled(context: Context): Boolean = prefs(context).getBoolean(PREF_KEY_ENABLED, false)
    }
}

/** An expense group in Caravella. */
@AppFunctionSerializable(isDescribedByKDoc = true)
class ExpenseGroupInfo(
    /** The id to pass to the other functions. */
    val groupId: String,
    /** The group's name. */
    val title: String,
    /** The currency symbol of the group's amounts. */
    val currency: String,
)

/** The outcome of addExpense. */
@AppFunctionSerializable(isDescribedByKDoc = true)
class AddedExpense(
    /** The new expense's id; null when nothing was saved (no amount given). */
    val expenseId: String?,
    /** The group's id. */
    val groupId: String,
    /** The saved amount; null when nothing was saved. */
    val amount: Double?,
    /**
     * Without an amount: opens the group in Caravella, where the user can add
     * the expense. Null when the expense was saved.
     */
    val intentToOpen: PendingIntent?,
)

/** How much a group has spent in all. */
@AppFunctionSerializable(isDescribedByKDoc = true)
class GroupBalance(
    /** The group's id. */
    val groupId: String,
    /** The group's name. */
    val groupTitle: String,
    /** The sum of all the group's expenses. */
    val totalBalance: Double,
    /** The currency symbol. */
    val currency: String,
)

/** An expense. */
@AppFunctionSerializable(isDescribedByKDoc = true)
class ExpenseInfo(
    /** The expense's id. */
    val expenseId: String,
    /** What the expense was for. */
    val name: String?,
    /** Its category. */
    val categoryName: String,
    /** The amount; null when none was recorded. */
    val amount: Double?,
    /** Who paid. */
    val paidByName: String,
    /** The day, as ISO-8601 (yyyy-MM-dd). */
    val date: String,
    /** A note, if any. */
    val note: String?,
)

/** A group's latest expenses. */
@AppFunctionSerializable(isDescribedByKDoc = true)
class RecentExpenses(
    /** The group's id. */
    val groupId: String,
    /** The group's name. */
    val groupTitle: String,
    /** The currency symbol. */
    val currency: String,
    /** The expenses, newest first. */
    val expenses: List<ExpenseInfo>,
)

/** How much a group has spent today. */
@AppFunctionSerializable(isDescribedByKDoc = true)
class TodayTotal(
    /** The group's id. */
    val groupId: String,
    /** The group's name. */
    val groupTitle: String,
    /** The sum of today's expenses. */
    val todayTotal: Double,
    /** The currency symbol. */
    val currency: String,
)
