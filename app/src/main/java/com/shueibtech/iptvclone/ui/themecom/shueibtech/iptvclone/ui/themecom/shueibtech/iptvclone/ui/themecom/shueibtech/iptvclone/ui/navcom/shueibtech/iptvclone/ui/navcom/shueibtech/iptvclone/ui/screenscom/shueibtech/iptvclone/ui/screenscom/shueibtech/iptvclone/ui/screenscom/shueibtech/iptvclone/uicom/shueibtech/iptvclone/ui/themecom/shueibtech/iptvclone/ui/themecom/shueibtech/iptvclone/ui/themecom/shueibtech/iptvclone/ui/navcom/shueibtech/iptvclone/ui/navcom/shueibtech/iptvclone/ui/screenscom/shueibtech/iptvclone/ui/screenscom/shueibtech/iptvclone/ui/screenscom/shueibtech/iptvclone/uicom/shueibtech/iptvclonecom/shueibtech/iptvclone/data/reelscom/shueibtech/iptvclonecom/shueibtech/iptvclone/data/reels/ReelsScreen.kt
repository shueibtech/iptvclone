package com.shueibtech.iptvclone.ui.themecom.shueibtech.iptvclone.ui.themecom.shueibtech.iptvclone.ui.themecom.shueibtech.iptvclone.ui.navcom.shueibtech.iptvclone.ui.navcom.shueibtech.iptvclone.ui.screenscom.shueibtech.iptvclone.ui.screenscom.shueibtech.iptvclone.ui.screenscom.shueibtech.iptvclone.uicom.shueibtech.iptvclone.ui.themecom.shueibtech.iptvclone.ui.themecom.shueibtech.iptvclone.ui.themecom.shueibtech.iptvclone.ui.navcom.shueibtech.iptvclone.ui.navcom.shueibtech.iptvclone.ui.screenscom.shueibtech.iptvclone.ui.screenscom.shueibtech.iptvclone.ui.screenscom.shueibtech.iptvclone.uicom.shueibtech.iptvclonecom.shueibtech.iptvclone.data.reelscom.shueibtech.iptvclonecom.shueibtech.iptvclone.data.reels

import android.net.Uri
import android.view.ViewGroup
import androidx.annotation.OptIn
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.AspectRatioFrameLayout
import androidx.media3.ui.PlayerView
import kotlinx.coroutines.delay
import java.util.Locale

@OptIn(UnstableApi::class)
@Composable
fun ReelsScreen(
    videoRawResId: Int,
    title: String = "هدف رونالدو كأس العالم",
    likeCount: Int = 1266,
    shareCount: Int = 736,
    downloadCount: Int = 1634,
) {
    val context = LocalContext.current
    var liked by remember { mutableStateOf(false) }
    var likes by remember { mutableStateOf(likeCount) }

    val exoPlayer = remember {
        ExoPlayer.Builder(context).build().apply {
            val uri = Uri.parse("android.resource://${context.packageName}/$videoRawResId")
            setMediaItem(MediaItem.fromUri(uri))
            repeatMode = Player.REPEAT_MODE_ONE
            playWhenReady = true
            prepare()
        }
    }

    var duration by remember { mutableStateOf(0L) }
    var position by remember { mutableStateOf(0L) }
    var isDragging by remember { mutableStateOf(false) }

    LaunchedEffect(exoPlayer) {
        while (true) {
            if (!isDragging) {
                duration = exoPlayer.duration.coerceAtLeast(0L)
                position = exoPlayer.currentPosition.coerceAtLeast(0L)
            }
            delay(200)
        }
    }

    DisposableEffect(Unit) {
        onDispose { exoPlayer.release() }
    }

    Box(modifier = Modifier.fillMaxSize().background(Color.Black)) {
        AndroidView(
            factory = {
                PlayerView(context).apply {
                    player = exoPlayer
                    useController = false
                    layoutParams = ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    )
                    resizeMode = AspectRatioFrameLayout.RESIZE_MODE_ZOOM
                }
            },
            modifier = Modifier.fillMaxSize()
        )

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(220.dp)
                .align(Alignment.BottomCenter)
                .background(
                    Brush.verticalGradient(
                        colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.75f))
                    )
                )
        )

        Column(
            modifier = Modifier
                .align(Alignment.CenterEnd)
                .padding(end = 12.dp, bottom = 90.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(22.dp)
        ) {
            ReelActionButton(
                icon = if (liked) Icons.Filled.Favorite else Icons.Filled.FavoriteBorder,
                tint = if (liked) Color(0xFFFF3040) else Color.White,
                count = likes,
                onClick = {
                    liked = !liked
                    likes += if (liked) 1 else -1
                }
            )
            ReelActionButton(
                icon = Icons.Filled.Share,
                tint = Color.White,
                count = shareCount,
                onClick = { }
            )
            ReelActionButton(
                icon = Icons.Filled.Download,
                tint = Color.White,
                count = downloadCount,
                onClick = { }
            )
        }

        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .fillMaxWidth()
                .padding(start = 16.dp, end = 64.dp, bottom = 18.dp)
        ) {
            Text(
                text = title,
                color = Color.White,
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(modifier = Modifier.height(14.dp))
            ReelsProgressBar(
                progress = if (duration > 0) position.toFloat() / duration.toFloat() else 0f,
                onSeek = { frac ->
                    isDragging = true
                    val target = (frac * duration).toLong()
                    exoPlayer.seekTo(target)
                    position = target
                },
                onSeekFinished = { isDragging = false }
            )
        }
    }
}

@Composable
private fun ReelActionButton(icon: ImageVector, tint: Color, count: Int, onClick: () -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.pointerInput(Unit) { detectTapGestures(onTap = { onClick() }) }
    ) {
        Box(
            modifier = Modifier
                .size(46.dp)
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = icon, contentDescription = null, tint = tint, modifier = Modifier.size(26.dp))
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(text = formatCount(count), color = Color.White, fontSize = 12.sp, fontWeight = FontWeight.Medium)
    }
}

private fun formatCount(count: Int): String = when {
    count >= 1_000_000 -> String.format(Locale.US, "%.1fM", count / 1_000_000f)
    count >= 1_000 -> String.format(Locale.US, "%.1fK", count / 1_000f)
    else -> count.toString()
}

@Composable
private fun ReelsProgressBar(progress: Float, onSeek: (Float) -> Unit, onSeekFinished: () -> Unit) {
    var barWidthPx by remember { mutableStateOf(0f) }
    val clamped = progress.coerceIn(0f, 1f)

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(20.dp)
            .onGloballyPositioned { barWidthPx = it.size.width.toFloat() }
            .pointerInput(Unit) {
                detectTapGestures { offset ->
                    if (barWidthPx > 0) onSeek((offset.x / barWidthPx).coerceIn(0f, 1f))
                }
            }
            .pointerInput(Unit) {
                detectHorizontalDragGestures(
                    onDragStart = { offset -> if (barWidthPx > 0) onSeek((offset.x / barWidthPx).coerceIn(0f, 1f)) },
                    onHorizontalDrag = { change, _ -> if (barWidthPx > 0) onSeek((change.position.x / barWidthPx).coerceIn(0f, 1f)) },
                    onDragEnd = { onSeekFinished() }
                )
            },
        contentAlignment = Alignment.CenterStart
    ) {
        Box(
            modifier = Modifier.fillMaxWidth().height(4.dp).clip(RoundedCornerShape(50))
                .background(Color.White.copy(alpha = 0.25f))
        )
        Box(
            modifier = Modifier.fillMaxWidth(clamped).height(4.dp).clip(RoundedCornerShape(50))
                .background(Brush.horizontalGradient(listOf(Color(0xFFFF5F6D), Color(0xFFFFC371))))
        )
        Box(
            modifier = Modifier
                .graphicsLayer { translationX = (barWidthPx * clamped) - 6.dp.toPx() }
                .shadow(3.dp, CircleShape, clip = false)
                .size(12.dp)
                .clip(CircleShape)
                .background(Color.White)
        )
    }
}
