package com.shueibtech.iptvclone.ui.nav

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.PlayCircle
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.PlayCircleOutline
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.ui.graphics.vector.ImageVector
import com.shueibtech.iptvclone.R

enum class NavDestination(
    val labelRes: Int,
    val iconSelected: ImageVector,
    val iconUnselected: ImageVector
) {
    Home(R.string.nav_home, Icons.Filled.Home, Icons.Outlined.Home),
    Reels(R.string.nav_reels, Icons.Filled.PlayCircle, Icons.Outlined.PlayCircleOutline),
    Settings(R.string.nav_settings, Icons.Filled.Settings, Icons.Outlined.Settings)
}
