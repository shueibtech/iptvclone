package com.shueibtech.iptvclone.data

import android.content.Context

// تخزين بسيط وثابت للمفضلة باستخدام SharedPreferences
// ما يحتاج أي مكتبة إضافية بالمشروع، ويحفظ القيم حتى لو المستخدم قفل التطبيق أو أعاد فتحه
private const val PREFS_NAME = "iptvclone_prefs"
private const val KEY_FAVORITES = "favorites"

object FavoritesStore {
    fun load(context: Context): Set<String> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getStringSet(KEY_FAVORITES, emptySet()) ?: emptySet()
    }

    fun save(context: Context, favorites: Set<String>) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putStringSet(KEY_FAVORITES, favorites).apply()
    }
}
