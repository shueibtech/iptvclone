#!/data/data/com.termux/files/usr/bin/bash
set -e

if [ ! -f "app/build.gradle.kts" ]; then
  echo "شغل السكربت من داخل مجلد iptvclone"
  exit 1
fi

PKG_DIR="app/src/main/java/com/shueibtech/iptvclone"

cat > "app/src/main/res/values/strings.xml" << 'EOF'
<resources>
    <string name="app_name">Iptv Clone</string>
    <string name="splash_made_by">Made by</string>
    <string name="splash_brand">ShueibTech</string>
    <string name="nav_home">Home</string>
    <string name="nav_reels">Reels</string>
    <string name="nav_settings">Settings</string>
    <string name="group_bein">beIN Sports</string>
    <string name="group_alkass">Alkass</string>
    <string name="group_alrabiaa">Al Rabia</string>
    <string name="group_themanyah">Thmanyah</string>
    <string name="channel_number">%1$s %2$d</string>
    <string name="tab_all">All</string>
    <string name="tab_favorites">Favorites</string>
    <string name="add_to_favorites">Add to Favorites</string>
    <string name="remove_from_favorites">Remove from Favorites</string>
    <string name="cancel">Cancel</string>
    <string name="favorites_empty">No favorites yet</string>
</resources>
EOF

cat > "app/src/main/res/values-ar/strings.xml" << 'EOF'
<resources>
    <string name="app_name">Iptv Clone</string>
    <string name="splash_made_by">صنع بواسطة</string>
    <string name="splash_brand">ShueibTech</string>
    <string name="nav_home">الرئيسية</string>
    <string name="nav_reels">ريلز</string>
    <string name="nav_settings">الإعدادات</string>
    <string name="group_bein">بي إن سبورت</string>
    <string name="group_alkass">الكأس</string>
    <string name="group_alrabiaa">الرابعة</string>
    <string name="group_themanyah">ثمانية</string>
    <string name="channel_number">%1$s %2$d</string>
    <string name="tab_all">الكل</string>
    <string name="tab_favorites">المفضلة</string>
    <string name="add_to_favorites">أضف إلى المفضلة</string>
    <string name="remove_from_favorites">إزالة من المفضلة</string>
    <string name="cancel">إلغاء</string>
    <string name="favorites_empty">لا توجد مفضلة بعد</string>
</resources>
EOF

cat > "$PKG_DIR/ui/MainScreen.kt" << 'EOF'
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
import androidx.compose.runtime.mutableStateListOf
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
    val favorites = remember { mutableStateListOf<String>() }

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
                NavDestination.Home -> HomeScreen(favorites = favorites)
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
EOF

cat > "$PKG_DIR/ui/screens/HomeScreen.kt" << 'EOF'
package com.shueibtech.iptvclone.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.shueibtech.iptvclone.R
import com.shueibtech.iptvclone.ui.theme.Accent
import com.shueibtech.iptvclone.ui.theme.Black

private data class ChannelGroup(
    val id: String,
    val titleRes: Int,
    val logoRes: Int,
    val channelCount: Int
)

private data class ChannelInfo(
    val groupId: String,
    val groupTitleRes: Int,
    val logoRes: Int,
    val index: Int
) {
    val key: String get() = "${groupId}_$index"
}

private enum class HomeTab { All, Favorites }

private val channelGroups = listOf(
    ChannelGroup("bein", R.string.group_bein, R.drawable.bein, 6),
    ChannelGroup("alkass", R.string.group_alkass, R.drawable.alkass, 5),
    ChannelGroup("alrabiaa", R.string.group_alrabiaa, R.drawable.alrabiaa, 4),
    ChannelGroup("themanyah", R.string.group_themanyah, R.drawable.themanyah, 3)
)

@Composable
fun HomeScreen(favorites: SnapshotStateList<String>) {
    var selectedTab by remember { mutableStateOf(HomeTab.All) }
    var selectedChannel by remember { mutableStateOf<ChannelInfo?>(null) }

    val visibleGroups = channelGroups.mapNotNull { group ->
        val indices = if (selectedTab == HomeTab.All) {
            (1..group.channelCount).toList()
        } else {
            (1..group.channelCount).filter { favorites.contains("${group.id}_$it") }
        }
        if (indices.isEmpty()) null else group to indices
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(top = 18.dp, bottom = 130.dp),
            verticalArrangement = Arrangement.spacedBy(28.dp)
        ) {
            item {
                Box(
                    modifier = Modifier.fillMaxWidth(),
                    contentAlignment = Alignment.Center
                ) {
                    HomeTabs(selected = selectedTab, onSelect = { selectedTab = it })
                }
            }
            if (visibleGroups.isEmpty()) {
                item { EmptyFavorites() }
            } else {
                items(visibleGroups) { (group, indices) ->
                    ChannelSection(
                        group = group,
                        indices = indices,
                        favorites = favorites,
                        onLongPress = { selectedChannel = it }
                    )
                }
            }
        }

        val channelForSheet = selectedChannel
        AnimatedVisibility(
            visible = selectedChannel != null,
            enter = fadeIn(tween(200)) + scaleIn(initialScale = 0.92f, animationSpec = tween(200)),
            exit = fadeOut(tween(150)) + scaleOut(targetScale = 0.92f, animationSpec = tween(150))
        ) {
            channelForSheet?.let { info ->
                FavoriteSheet(
                    channel = info,
                    isFavorite = favorites.contains(info.key),
                    onToggle = {
                        if (favorites.contains(info.key)) favorites.remove(info.key) else favorites.add(info.key)
                        selectedChannel = null
                    },
                    onDismiss = { selectedChannel = null }
                )
            }
        }
    }
}

@Composable
private fun HomeTabs(selected: HomeTab, onSelect: (HomeTab) -> Unit) {
    val indicatorOffset by animateDpAsState(
        targetValue = if (selected == HomeTab.All) 0.dp else 132.dp,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessLow),
        label = "tabIndicator"
    )

    Box(
        modifier = Modifier
            .height(46.dp)
            .clip(RoundedCornerShape(23.dp))
            .background(MaterialTheme.colorScheme.onBackground.copy(alpha = 0.06f))
            .padding(4.dp)
    ) {
        Box(
            modifier = Modifier
                .offset(x = indicatorOffset)
                .width(132.dp)
                .fillMaxHeight()
                .clip(RoundedCornerShape(19.dp))
                .background(Accent)
        )
        Row {
            HomeTab.entries.forEach { tab ->
                val isSelected = tab == selected
                Box(
                    modifier = Modifier
                        .width(132.dp)
                        .fillMaxHeight()
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null,
                            onClick = { onSelect(tab) }
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = stringResource(if (tab == HomeTab.All) R.string.tab_all else R.string.tab_favorites),
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = if (isSelected) Black else MaterialTheme.colorScheme.onBackground.copy(alpha = 0.55f)
                    )
                }
            }
        }
    }
}

@Composable
private fun EmptyFavorites() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 80.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = stringResource(R.string.favorites_empty),
            fontSize = 14.sp,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.4f)
        )
    }
}

@Composable
private fun ChannelSection(
    group: ChannelGroup,
    indices: List<Int>,
    favorites: SnapshotStateList<String>,
    onLongPress: (ChannelInfo) -> Unit
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        SectionHeader(group)
        Spacer(modifier = Modifier.height(14.dp))
        LazyRow(
            contentPadding = PaddingValues(horizontal = 22.dp),
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            items(indices) { index ->
                ChannelCard(
                    group = group,
                    index = index,
                    isFavorite = favorites.contains("${group.id}_$index"),
                    onLongPress = onLongPress
                )
            }
        }
    }
}

@Composable
private fun SectionHeader(group: ChannelGroup) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 22.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(
            painter = painterResource(id = group.logoRes),
            contentDescription = stringResource(group.titleRes),
            contentScale = ContentScale.Fit,
            modifier = Modifier.size(32.dp)
        )
        Spacer(modifier = Modifier.width(10.dp))
        Text(
            text = stringResource(group.titleRes),
            fontWeight = FontWeight.Bold,
            fontSize = 16.sp,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
private fun ChannelCard(
    group: ChannelGroup,
    index: Int,
    isFavorite: Boolean,
    onLongPress: (ChannelInfo) -> Unit
) {
    val groupTitle = stringResource(group.titleRes)

    Box(
        modifier = Modifier
            .width(108.dp)
            .height(124.dp)
    ) {
        Surface(
            modifier = Modifier
                .fillMaxSize()
                .combinedClickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = {},
                    onLongClick = {
                        onLongPress(ChannelInfo(group.id, group.titleRes, group.logoRes, index))
                    }
                ),
            shape = RoundedCornerShape(20.dp),
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.05f),
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.onBackground.copy(alpha = 0.08f))
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Surface(
                    modifier = Modifier.size(48.dp),
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.background
                ) {
                    Image(
                        painter = painterResource(id = group.logoRes),
                        contentDescription = null,
                        contentScale = ContentScale.Fit,
                        modifier = Modifier.padding(9.dp)
                    )
                }
                Spacer(modifier = Modifier.height(10.dp))
                Text(
                    text = stringResource(R.string.channel_number, groupTitle, index),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.8f),
                    maxLines = 1
                )
            }
        }

        if (isFavorite) {
            Icon(
                imageVector = Icons.Filled.Favorite,
                contentDescription = null,
                tint = Accent,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(8.dp)
                    .size(16.dp)
            )
        }
    }
}

@Composable
private fun FavoriteSheet(
    channel: ChannelInfo,
    isFavorite: Boolean,
    onToggle: () -> Unit,
    onDismiss: () -> Unit
) {
    val name = stringResource(R.string.channel_number, stringResource(channel.groupTitleRes), channel.index)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Black.copy(alpha = 0.6f))
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onDismiss
            ),
        contentAlignment = Alignment.Center
    ) {
        Surface(
            modifier = Modifier
                .padding(horizontal = 40.dp)
                .fillMaxWidth()
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = {}
                ),
            shape = RoundedCornerShape(28.dp),
            color = MaterialTheme.colorScheme.background,
            border = BorderStroke(1.dp, Accent.copy(alpha = 0.25f)),
            shadowElevation = 24.dp
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(28.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Image(
                    painter = painterResource(id = channel.logoRes),
                    contentDescription = null,
                    contentScale = ContentScale.Fit,
                    modifier = Modifier.size(64.dp)
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = name,
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp,
                    color = MaterialTheme.colorScheme.onBackground
                )
                Spacer(modifier = Modifier.height(22.dp))
                Surface(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null,
                            onClick = onToggle
                        ),
                    shape = RoundedCornerShape(18.dp),
                    color = Accent
                ) {
                    Text(
                        text = stringResource(
                            if (isFavorite) R.string.remove_from_favorites else R.string.add_to_favorites
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 14.dp),
                        textAlign = TextAlign.Center,
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp,
                        color = Black
                    )
                }
                Spacer(modifier = Modifier.height(10.dp))
                Text(
                    text = stringResource(R.string.cancel),
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null,
                            onClick = onDismiss
                        )
                        .padding(vertical = 10.dp),
                    textAlign = TextAlign.Center,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
                )
            }
        }
    }
}
EOF
