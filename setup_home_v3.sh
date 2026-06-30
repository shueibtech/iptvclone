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
    <string name="home_title">Live Channels</string>
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
    <string name="home_title">البث المباشر</string>
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

cat > "$PKG_DIR/ui/screens/HomeScreen.kt" << 'EOF'
package com.shueibtech.iptvclone.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshots.SnapshotStateList
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.graphicsLayer
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
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
    var sheetChannel by remember { mutableStateOf<ChannelInfo?>(null) }

    LaunchedEffect(selectedChannel) {
        if (selectedChannel != null) sheetChannel = selectedChannel
    }

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
        Column(modifier = Modifier.fillMaxSize()) {
            HomeHeader()
            HomeTabsRow(selected = selectedTab, onSelect = { selectedTab = it })

            Box(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
            ) {
                if (visibleGroups.isEmpty()) {
                    EmptyFavorites()
                } else {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(top = 6.dp, bottom = 130.dp),
                        verticalArrangement = Arrangement.spacedBy(30.dp)
                    ) {
                        items(visibleGroups, key = { it.first.id }) { (group, indices) ->
                            ChannelSection(
                                group = group,
                                indices = indices,
                                favorites = favorites,
                                onLongPress = { selectedChannel = it }
                            )
                        }
                    }
                }
            }
        }

        AnimatedVisibility(
            visible = selectedChannel != null,
            enter = fadeIn(tween(200)),
            exit = fadeOut(tween(200)),
            modifier = Modifier.fillMaxSize()
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Black.copy(alpha = 0.55f))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = { selectedChannel = null }
                    )
            )
        }

        AnimatedVisibility(
            visible = selectedChannel != null,
            enter = slideInVertically(
                initialOffsetY = { it },
                animationSpec = spring(
                    dampingRatio = Spring.DampingRatioLowBouncy,
                    stiffness = Spring.StiffnessMedium
                )
            ) + fadeIn(tween(150)),
            exit = slideOutVertically(
                targetOffsetY = { it },
                animationSpec = tween(220)
            ) + fadeOut(tween(150)),
            modifier = Modifier.align(Alignment.BottomCenter)
        ) {
            sheetChannel?.let { info ->
                FavoriteSheetContent(
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
private fun HomeHeader() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 22.dp, vertical = 16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = stringResource(R.string.home_title),
            fontSize = 22.sp,
            fontWeight = FontWeight.ExtraBold,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}

@Composable
private fun HomeTabsRow(selected: HomeTab, onSelect: (HomeTab) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        HomeTab.entries.forEach { tab ->
            val isSelected = tab == selected
            val bgColor by animateColorAsState(
                targetValue = if (isSelected) Accent else MaterialTheme.colorScheme.onBackground.copy(alpha = 0.07f),
                animationSpec = tween(220),
                label = "chipBg"
            )
            val textColor by animateColorAsState(
                targetValue = if (isSelected) Black else MaterialTheme.colorScheme.onBackground.copy(alpha = 0.7f),
                animationSpec = tween(220),
                label = "chipText"
            )
            Surface(
                shape = RoundedCornerShape(50),
                color = bgColor,
                modifier = Modifier
                    .clip(RoundedCornerShape(50))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = { onSelect(tab) }
                    )
            ) {
                Text(
                    text = stringResource(if (tab == HomeTab.All) R.string.tab_all else R.string.tab_favorites),
                    fontSize = 12.5.sp,
                    fontWeight = FontWeight.SemiBold,
                    color = textColor,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 7.dp)
                )
            }
        }
    }
}

@Composable
private fun EmptyFavorites() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(top = 90.dp),
        contentAlignment = Alignment.TopCenter
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Icon(
                imageVector = Icons.Outlined.FavoriteBorder,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.25f),
                modifier = Modifier.size(40.dp)
            )
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = stringResource(R.string.favorites_empty),
                fontSize = 14.sp,
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.4f)
            )
        }
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
        Spacer(modifier = Modifier.height(12.dp))
        LazyRow(
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            items(indices, key = { "${group.id}_$it" }) { index ->
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
            .padding(horizontal = 20.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Surface(
            shape = RoundedCornerShape(7.dp),
            color = Color.White,
            modifier = Modifier.size(26.dp)
        ) {
            Image(
                painter = painterResource(id = group.logoRes),
                contentDescription = stringResource(group.titleRes),
                contentScale = ContentScale.Fit,
                modifier = Modifier.padding(4.dp)
            )
        }
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
    val interactionSource = remember { MutableInteractionSource() }
    val pressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (pressed) 0.94f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "cardScale"
    )

    Column(
        modifier = Modifier
            .width(116.dp)
            .graphicsLayer {
                scaleX = scale
                scaleY = scale
            }
            .combinedClickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = {},
                onLongClick = {
                    onLongPress(ChannelInfo(group.id, group.titleRes, group.logoRes, index))
                }
            )
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(1f)
                .clip(RoundedCornerShape(10.dp))
                .background(Color.White)
                .border(
                    width = 1.dp,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.06f),
                    shape = RoundedCornerShape(10.dp)
                )
        ) {
            Image(
                painter = painterResource(id = group.logoRes),
                contentDescription = null,
                contentScale = ContentScale.Fit,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(14.dp)
            )
            if (isFavorite) {
                Surface(
                    shape = CircleShape,
                    color = Black.copy(alpha = 0.55f),
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(6.dp)
                        .size(22.dp)
                ) {
                    Icon(
                        imageVector = Icons.Filled.Favorite,
                        contentDescription = null,
                        tint = Accent,
                        modifier = Modifier.padding(4.dp)
                    )
                }
            }
        }
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = stringResource(R.string.channel_number, groupTitle, index),
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.85f),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

@Composable
private fun FavoriteSheetContent(
    channel: ChannelInfo,
    isFavorite: Boolean,
    onToggle: () -> Unit,
    onDismiss: () -> Unit
) {
    val name = stringResource(R.string.channel_number, stringResource(channel.groupTitleRes), channel.index)

    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = {}
            ),
        shape = RoundedCornerShape(topStart = 26.dp, topEnd = 26.dp),
        color = MaterialTheme.colorScheme.background,
        shadowElevation = 20.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 28.dp)
        ) {
            Box(
                modifier = Modifier
                    .padding(top = 12.dp)
                    .align(Alignment.CenterHorizontally)
                    .width(36.dp)
                    .height(4.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .background(MaterialTheme.colorScheme.onBackground.copy(alpha = 0.2f))
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(start = 20.dp, end = 12.dp, top = 18.dp, bottom = 14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = Color.White,
                    modifier = Modifier.size(46.dp)
                ) {
                    Image(
                        painter = painterResource(id = channel.logoRes),
                        contentDescription = null,
                        contentScale = ContentScale.Fit,
                        modifier = Modifier.padding(8.dp)
                    )
                }
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    text = name,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 15.sp,
                    color = MaterialTheme.colorScheme.onBackground,
                    modifier = Modifier.weight(1f)
                )
                IconButton(onClick = onDismiss) {
                    Icon(
                        imageVector = Icons.Filled.Close,
                        contentDescription = stringResource(R.string.cancel),
                        tint = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
                    )
                }
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.06f))

            Spacer(modifier = Modifier.height(4.dp))

            SheetActionRow(
                icon = if (isFavorite) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                iconTint = if (isFavorite) Accent else MaterialTheme.colorScheme.onBackground.copy(alpha = 0.8f),
                label = stringResource(
                    if (isFavorite) R.string.remove_from_favorites else R.string.add_to_favorites
                ),
                onClick = onToggle
            )
        }
    }
}

@Composable
private fun SheetActionRow(
    icon: ImageVector,
    iconTint: Color,
    label: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick
            )
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = iconTint,
            modifier = Modifier.size(22.dp)
        )
        Spacer(modifier = Modifier.width(16.dp))
        Text(
            text = label,
            fontSize = 14.5.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}
EOF

echo "تم تحديث الواجهة الرئيسية بتصميم جديد على غرار سبوتفاي ✅"
