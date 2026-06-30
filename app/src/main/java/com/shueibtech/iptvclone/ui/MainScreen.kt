package com.shueibtech.iptvclone.ui

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.shueibtech.iptvclone.ui.nav.AppBottomNavBar
import com.shueibtech.iptvclone.ui.nav.NavDestination
import com.shueibtech.iptvclone.ui.screens.HomeScreen
import com.shueibtech.iptvclone.ui.screens.ReelsScreen
import com.shueibtech.iptvclone.ui.screens.SettingsScreen

@Composable
fun MainScreen() {
    var selected by remember { mutableStateOf(NavDestination.Home) }

    Box(modifier = Modifier.fillMaxSize()) {
        AnimatedContent(
            targetState = selected,
            transitionSpec = {
                fadeIn(tween(220)) togetherWith fadeOut(tween(160))
            },
            label = "screenTransition",
            modifier = Modifier.fillMaxSize()
        ) { destination ->
            when (destination) {
                NavDestination.Home -> HomeScreen()
                NavDestination.Reels -> ReelsScreen()
                NavDestination.Settings -> SettingsScreen()
            }
        }

        AppBottomNavBar(
            selected = selected,
            onSelect = { selected = it },
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}
