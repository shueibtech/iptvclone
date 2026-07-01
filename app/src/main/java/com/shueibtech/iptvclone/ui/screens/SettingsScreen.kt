package com.shueibtech.iptvclone.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DeleteSweep
import androidx.compose.material.icons.filled.HighQuality
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Language
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Palette
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.shueibtech.iptvclone.R
import com.shueibtech.iptvclone.data.SettingsStore
import com.shueibtech.iptvclone.data.ThemeMode
import com.shueibtech.iptvclone.ui.theme.Accent

@Composable
fun SettingsScreen() {
    val context = LocalContext.current
    val themeMode = SettingsStore.themeMode.value
    val language = SettingsStore.language.value

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 28.dp),
        verticalArrangement = Arrangement.spacedBy(28.dp)
    ) {
        Text(
            text = stringResource(R.string.nav_settings),
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onBackground
        )

        SettingsSection(title = stringResource(R.string.settings_appearance)) {
            SettingsOptionRow(
                icon = Icons.Filled.Palette,
                title = stringResource(R.string.theme_system),
                selected = themeMode == ThemeMode.SYSTEM,
                onClick = { SettingsStore.setThemeMode(context, ThemeMode.SYSTEM) }
            )
            SettingsOptionRow(
                icon = Icons.Filled.Palette,
                title = stringResource(R.string.theme_light),
                selected = themeMode == ThemeMode.LIGHT,
                onClick = { SettingsStore.setThemeMode(context, ThemeMode.LIGHT) }
            )
            SettingsOptionRow(
                icon = Icons.Filled.Palette,
                title = stringResource(R.string.theme_dark),
                selected = themeMode == ThemeMode.DARK,
                onClick = { SettingsStore.setThemeMode(context, ThemeMode.DARK) }
            )
        }

        SettingsSection(title = stringResource(R.string.settings_language)) {
            SettingsOptionRow(
                icon = Icons.Filled.Language,
                title = stringResource(R.string.lang_english),
                selected = language == "en",
                onClick = { SettingsStore.setLanguage(context, "en") }
            )
            SettingsOptionRow(
                icon = Icons.Filled.Language,
                title = stringResource(R.string.lang_arabic),
                selected = language == "ar",
                onClick = { SettingsStore.setLanguage(context, "ar") }
            )
        }

        SettingsSection(title = stringResource(R.string.settings_general)) {
            SettingsStaticRow(icon = Icons.Filled.Notifications, title = stringResource(R.string.settings_notifications))
            SettingsStaticRow(icon = Icons.Filled.HighQuality, title = stringResource(R.string.settings_playback_quality))
            SettingsStaticRow(icon = Icons.Filled.DeleteSweep, title = stringResource(R.string.settings_clear_cache))
            SettingsStaticRow(icon = Icons.Filled.Info, title = stringResource(R.string.settings_about))
        }

        Text(
            text = stringResource(R.string.settings_version),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
        )
    }
}

@Composable
private fun SettingsSection(title: String, content: @Composable () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text = title,
            style = MaterialTheme.typography.labelLarge,
            fontWeight = FontWeight.SemiBold,
            color = Accent
        )
        Surface(
            shape = RoundedCornerShape(16.dp),
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.04f)
        ) {
            Column(modifier = Modifier.padding(vertical = 4.dp)) {
                content()
            }
        }
    }
}

@Composable
private fun SettingsOptionRow(
    icon: ImageVector,
    title: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = if (selected) Accent else MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f),
            modifier = Modifier.size(22.dp)
        )
        Text(
            text = title,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier
                .padding(start = 16.dp)
                .weight(1f)
        )
        RadioButton(
            selected = selected,
            onClick = onClick,
            colors = RadioButtonDefaults.colors(
                selectedColor = Accent,
                unselectedColor = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.4f)
            )
        )
    }
}

@Composable
private fun SettingsStaticRow(icon: ImageVector, title: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f),
            modifier = Modifier.size(22.dp)
        )
        Text(
            text = title,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onBackground,
            modifier = Modifier.padding(start = 16.dp)
        )
    }
}
