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
    <string name="home_subtitle">Live channels</string>
    <string name="channel_number">%1$s %2$d</string>
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
    <string name="home_subtitle">البث المباشر</string>
    <string name="channel_number">%1$s %2$d</string>
</resources>
EOF

cat > "$PKG_DIR/ui/screens/HomeScreen.kt" << 'EOF'
package com.shueibtech.iptvclone.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
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
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.shueibtech.iptvclone.R
import com.shueibtech.iptvclone.ui.theme.Accent

private data class ChannelGroup(
    val titleRes: Int,
    val logoRes: Int,
    val channelCount: Int
)

private val channelGroups = listOf(
    ChannelGroup(R.string.group_bein, R.drawable.bein, 6),
    ChannelGroup(R.string.group_alkass, R.drawable.alkass, 6),
    ChannelGroup(R.string.group_alrabiaa, R.drawable.alrabiaa, 4),
    ChannelGroup(R.string.group_themanyah, R.drawable.themanyah, 3)
)

@Composable
fun HomeScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(top = 28.dp, bottom = 130.dp),
            verticalArrangement = Arrangement.spacedBy(28.dp)
        ) {
            item {
                HomeHeader()
            }
            items(channelGroups) { group ->
                ChannelSection(group)
            }
        }
    }
}

@Composable
private fun HomeHeader() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 22.dp)
    ) {
        Text(
            text = stringResource(R.string.nav_home),
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.onBackground
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = stringResource(R.string.home_subtitle),
            fontSize = 13.sp,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
        )
    }
}

@Composable
private fun ChannelSection(group: ChannelGroup) {
    Column(modifier = Modifier.fillMaxWidth()) {
        SectionHeader(group)
        Spacer(modifier = Modifier.height(14.dp))
        LazyRow(
            contentPadding = PaddingValues(horizontal = 22.dp),
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            items(group.channelCount) { index ->
                ChannelCard(group = group, index = index + 1)
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
        Surface(
            modifier = Modifier.size(34.dp),
            shape = CircleShape,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.06f)
        ) {
            Image(
                painter = painterResource(id = group.logoRes),
                contentDescription = stringResource(group.titleRes),
                contentScale = ContentScale.Fit,
                modifier = Modifier.padding(6.dp)
            )
        }
        Spacer(modifier = Modifier.width(10.dp))
        Text(
            text = stringResource(group.titleRes),
            fontWeight = FontWeight.Bold,
            fontSize = 16.sp,
            color = MaterialTheme.colorScheme.onBackground
        )
        Spacer(modifier = Modifier.width(8.dp))
        Surface(
            shape = RoundedCornerShape(10.dp),
            color = Accent.copy(alpha = 0.14f)
        ) {
            Text(
                text = group.channelCount.toString(),
                modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                color = Accent
            )
        }
    }
}

@Composable
private fun ChannelCard(group: ChannelGroup, index: Int) {
    val groupTitle = stringResource(group.titleRes)

    Surface(
        modifier = Modifier
            .width(108.dp)
            .height(124.dp),
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
}
EOF

echo "تم. شغل: ./gradlew assembleDebug"
