package com.shueibtech.iptvclone.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.isSystemInDarkTheme
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
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Icon
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
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
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
import com.shueibtech.iptvclone.ui.theme.White

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
    var contextChannel by remember { mutableStateOf<ChannelInfo?>(null) }

    LaunchedEffect(selectedChannel) {
        if (selectedChannel != null) contextChannel = selectedChannel
    }

    val visibleGroups = channelGroups.mapNotNull { group ->
        val indices = if (selectedTab == HomeTab.All) {
            (1..group.channelCount).toList()
        } else {
            (1..group.channelCount).filter { favorites.contains("${group.id}_$it") }
        }
        if (indices.isEmpty()) null else group to indices
    }

    val backgroundBlur by animateDpAsState(
        targetValue = if (selectedChannel != null) 22.dp else 0.dp,
        animationSpec = tween(280),
        label = "backgroundBlur"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        // الصفحة الأساسية: تابات ثابتة فوق + شبكة القنوات. تتشوش لما تفتح قائمة المفضلة
        Column(
            modifier = Modifier
                .fillMaxSize()
                .blur(backgroundBlur)
        ) {
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

        // طبقة التعتيم تطلع فوق المحتوى المشوش، تقفل القائمة لو ضغط برّا الكارد
        AnimatedVisibility(
            visible = selectedChannel != null,
            enter = fadeIn(tween(240)),
            exit = fadeOut(tween(220)),
            modifier = Modifier.fillMaxSize()
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Black.copy(alpha = 0.62f))
                    .clickable(
                        interactionSource = remember { MutableInteractionSource() },
                        indication = null,
                        onClick = { selectedChannel = null }
                    )
            )
        }

        // كارد القناة المكبّر + زر المفضلة، يطلع بنص الشاشة بعيد عن شريط التنقل تحت
        AnimatedVisibility(
            visible = selectedChannel != null,
            enter = fadeIn(tween(220)) + scaleIn(
                initialScale = 0.82f,
                animationSpec = spring(
                    dampingRatio = Spring.DampingRatioMediumBouncy,
                    stiffness = Spring.StiffnessLow
                )
            ),
            exit = fadeOut(tween(160)) + scaleOut(targetScale = 0.82f, animationSpec = tween(160)),
            modifier = Modifier.align(Alignment.Center)
        ) {
            contextChannel?.let { info ->
                ChannelContextCard(
                    channel = info,
                    isFavorite = favorites.contains(info.key),
                    onToggle = {
                        if (favorites.contains(info.key)) favorites.remove(info.key) else favorites.add(info.key)
                        selectedChannel = null
                    }
                )
            }
        }
    }
}

@Composable
private fun HomeTabsRow(selected: HomeTab, onSelect: (HomeTab) -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 14.dp)
            .padding(top = 6.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally)
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
    val dark = isSystemInDarkTheme()
    val logoBg = if (dark) Black else White

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Surface(
            shape = RoundedCornerShape(7.dp),
            color = logoBg,
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
    val dark = isSystemInDarkTheme()
    val cardBg = if (dark) Black else White
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
                .background(cardBg)
                .border(
                    width = 1.dp,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.08f),
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
private fun ChannelContextCard(
    channel: ChannelInfo,
    isFavorite: Boolean,
    onToggle: () -> Unit
) {
    val dark = isSystemInDarkTheme()
    val logoBg = if (dark) Black else White
    val name = stringResource(R.string.channel_number, stringResource(channel.groupTitleRes), channel.index)

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = {}
            )
    ) {
        Surface(
            shape = RoundedCornerShape(28.dp),
            color = logoBg,
            shadowElevation = 30.dp,
            border = BorderStroke(1.dp, Accent.copy(alpha = 0.22f)),
            modifier = Modifier.size(168.dp)
        ) {
            Image(
                painter = painterResource(id = channel.logoRes),
                contentDescription = null,
                contentScale = ContentScale.Fit,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(28.dp)
            )
        }

        Spacer(modifier = Modifier.height(18.dp))

        Text(
            text = name,
            fontWeight = FontWeight.Bold,
            fontSize = 17.sp,
            color = White
        )

        Spacer(modifier = Modifier.height(20.dp))

        Surface(
            shape = RoundedCornerShape(50),
            color = Accent,
            modifier = Modifier
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onToggle
                )
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(horizontal = 26.dp, vertical = 14.dp)
            ) {
                Icon(
                    imageVector = if (isFavorite) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                    contentDescription = null,
                    tint = Black,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = stringResource(
                        if (isFavorite) R.string.remove_from_favorites else R.string.add_to_favorites
                    ),
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = Black
                )
            }
        }
    }
}
