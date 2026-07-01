package com.shueibtech.iptvclone.data

import android.app.Activity
import android.content.Context
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.runtime.mutableStateOf
import androidx.core.os.LocaleListCompat

enum class ThemeMode { SYSTEM, LIGHT, DARK }

private const val PREFS_NAME = "iptvclone_prefs"
private const val KEY_THEME = "theme_mode"
private const val KEY_LANGUAGE = "language"

object SettingsStore {
    val themeMode = mutableStateOf(ThemeMode.SYSTEM)
    val language = mutableStateOf("en")

    fun init(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        themeMode.value = ThemeMode.valueOf(
            prefs.getString(KEY_THEME, ThemeMode.SYSTEM.name) ?: ThemeMode.SYSTEM.name
        )
        language.value = prefs.getString(KEY_LANGUAGE, "en") ?: "en"
    }

    fun setThemeMode(context: Context, mode: ThemeMode) {
        themeMode.value = mode
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putString(KEY_THEME, mode.name).apply()
    }

    fun setLanguage(context: Context, code: String) {
        language.value = code
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putString(KEY_LANGUAGE, code).apply()
        AppCompatDelegate.setApplicationLocales(LocaleListCompat.forLanguageTags(code))
        (context as? Activity)?.recreate()
    }
}
