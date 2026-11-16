package io.caravella.egm.appfunctions

/**
 * Tells the running app what an App Function changed, so its screens reload.
 *
 * The functions write to the database natively, without Flutter;
 * [MainActivity][io.caravella.egm.MainActivity] listens while its Flutter
 * engine is alive and forwards the event to Dart. With no app open there is
 * no listener and nothing to reload.
 */
object AppFunctionEvents {
    /** Called with the id of the group an expense was added to; any thread. */
    @Volatile
    var onExpenseAdded: ((groupId: String) -> Unit)? = null

    fun expenseAdded(groupId: String) {
        onExpenseAdded?.invoke(groupId)
    }
}
