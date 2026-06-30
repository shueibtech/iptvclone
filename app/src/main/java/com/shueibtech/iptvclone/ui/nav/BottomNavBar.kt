package com.shueibtech.iptvclone.ui.nav

import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.shueibtech.iptvclone.ui.theme.Accent
import com.shueibtech.iptvclone.ui.theme.NavBarDark
import com.shueibtech.iptvclone.ui.theme.NavBarLight

@Composable
fun AppBottomNavBar(
    selected: NavDestination,
    onSelect: (NavDestination) -> Unit,
    modifier: Modifier = Modifier
) {
    val dark = isSystemInDarkTheme()
    val barColor = if (dark) NavBarDark else NavBarLight
    val borderColor = Accent.copy(alpha = if (dark) 0.18f else 0.12f)

    Surface(
        modifier = modifier
            .padding(horizontal = 28.dp, vertical = 18.dp)
            .height(68.dp)
            .fillMaxWidth(),
        shape = RoundedCornerShape(34.dp),
        color = barColor,
        shadowElevation = 14.dp,
        border = BorderStroke(1.dp, borderColor)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            NavDestination.entries.forEach { destination ->
                NavBarItem(
                    destination = destination,
                    isSelected = destination == selected,
                    onClick = { onSelect(destination) }
                )
            }
        }
    }
}

@Composable
private fun NavBarItem(
    destination: NavDestination,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val iconTint = if (isSelected) Accent else MaterialTheme.colorScheme.onBackground.copy(alpha = 0.45f)
    val pillColor = if (isSelected) Accent.copy(alpha = 0.16f) else Color.Transparent

    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .height(48.dp)
            .clip(RoundedCornerShape(24.dp))
            .background(pillColor)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick
            )
            .animateContentSize(
                animationSpec = spring(
                    dampingRatio = Spring.DampingRatioMediumBouncy,
                    stiffness = Spring.StiffnessLow
                )
            )
            .padding(horizontal = if (isSelected) 16.dp else 14.dp, vertical = 12.dp)
    ) {
        Icon(
            imageVector = if (isSelected) destination.iconSelected else destination.iconUnselected,
            contentDescription = stringResource(destination.labelRes),
            tint = iconTint,
            modifier = Modifier.size(23.dp)
        )
        if (isSelected) {
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = stringResource(destination.labelRes),
                color = Accent,
                fontWeight = FontWeight.Bold,
                fontSize = 13.sp
            )
        }
    }
}
