package com.shueibtech.iptvclone.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColors = lightColorScheme(
    primary   = Accent,
    background = White,
    surface   = White,
    onPrimary  = Black,
    onBackground = Black,
    onSurface  = Black
)

private val DarkColors = darkColorScheme(
    primary   = Accent,
    background = Black,
    surface   = Black,
    onPrimary  = Black,
    onBackground = White,
    onSurface  = White
)

@Composable
fun IptvCloneTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colors = if (darkTheme) DarkColors else LightColors
    MaterialTheme(
        colorScheme = colors,
        typography  = Typography,
        content     = content
    )
}
