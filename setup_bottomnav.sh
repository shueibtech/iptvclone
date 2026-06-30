#!/data/data/com.termux/files/usr/bin/bash
set -e

if [ ! -f "app/build.gradle.kts" ]; then
  echo "شغل السكربت من داخل مجلد iptvclone (نفس مكان app و gradle.properties)"
  exit 1
fi

PKG_DIR="app/src/main/java/com/shueibtech/iptvclone"
NAV_DIR="$PKG_DIR/ui/nav"
SCREENS_DIR="$PKG_DIR/ui/screens"

mkdir -p "$NAV_DIR"
mkdir -p "$SCREENS_DIR"

cat > "gradle/libs.versions.toml" << 'EOF'
[versions]
agp = "8.5.0"
kotlin = "2.0.0"
coreKtx = "1.13.1"
lifecycleRuntimeKtx = "2.8.3"
activityCompose = "1.9.0"
appcompat = "1.7.0"
composeBom = "2024.06.00"

[libraries]
androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "coreKtx" }
androidx-lifecycle-runtime-ktx = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycleRuntimeKtx" }
androidx-activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activityCompose" }
androidx-compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "composeBom" }
androidx-ui = { group = "androidx.compose.ui", name = "ui" }
androidx-ui-graphics = { group = "androidx.compose.ui", name = "ui-graphics" }
androidx-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
androidx-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
androidx-material3 = { group = "androidx.compose.material3", name = "material3" }
androidx-material-icons-extended = { group = "androidx.compose.material", name = "material-icons-extended" }
androidx-appcompat = { group = "androidx.appcompat", name = "appcompat", version.ref = "appcompat" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
kotlin-compose = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
EOF

cat > "app/build.gradle.kts" << 'EOF'
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "com.shueibtech.iptvclone"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.shueibtech.iptvclone"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.material.icons.extended)
    implementation(libs.androidx.appcompat)
    debugImplementation(libs.androidx.ui.tooling)
}
EOF

cat > "app/src/main/res/values/strings.xml" << 'EOF'
<resources>
    <string name="app_name">Iptv Clone</string>
    <string name="splash_made_by">Made by</string>
    <string name="splash_brand">ShueibTech</string>
    <string name="nav_home">Home</string>
    <string name="nav_reels">Reels</string>
    <string name="nav_settings">Settings</string>
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
</resources>
EOF

cat > "$PKG_DIR/ui/theme/Color.kt" << 'EOF'
package com.shueibtech.iptvclone.ui.theme

import androidx.compose.ui.graphics.Color

val Accent      = Color(0xFF19F793)
val White       = Color(0xFFFFFFFF)
val Black       = Color(0xFF000000)
val NavBarLight = Color(0xFFF4F4F4)
val NavBarDark  = Color(0xFF121212)
EOF

cat > "$NAV_DIR/NavDestination.kt" << 'EOF'
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
EOF

cat > "$NAV_DIR/BottomNavBar.kt" << 'EOF'
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
EOF

cat > "$SCREENS_DIR/HomeScreen.kt" << 'EOF'
package com.shueibtech.iptvclone.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.shueibtech.iptvclone.R

@Composable
fun HomeScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = stringResource(R.string.nav_home),
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}
EOF

cat > "$SCREENS_DIR/ReelsScreen.kt" << 'EOF'
package com.shueibtech.iptvclone.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.shueibtech.iptvclone.R

@Composable
fun ReelsScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = stringResource(R.string.nav_reels),
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}
EOF

cat > "$SCREENS_DIR/SettingsScreen.kt" << 'EOF'
package com.shueibtech.iptvclone.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import com.shueibtech.iptvclone.R

@Composable
fun SettingsScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = stringResource(R.string.nav_settings),
            style = MaterialTheme.typography.titleLarge,
            color = MaterialTheme.colorScheme.onBackground
        )
    }
}
EOF

cat > "$PKG_DIR/MainActivity.kt" << 'EOF'
package com.shueibtech.iptvclone

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.shueibtech.iptvclone.ui.MainScreen
import com.shueibtech.iptvclone.ui.theme.Accent
import com.shueibtech.iptvclone.ui.theme.IptvCloneTheme
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        WindowCompat.setDecorFitsSystemWindows(window, false)
        val controller = WindowInsetsControllerCompat(window, window.decorView)
        controller.hide(WindowInsetsCompat.Type.systemBars())
        controller.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE

        setContent {
            IptvCloneTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    var showSplash by remember { mutableStateOf(true) }
                    if (showSplash) {
                        SplashScreen(onFinished = { showSplash = false })
                    } else {
                        MainScreen()
                    }
                }
            }
        }
    }
}

@Composable
fun SplashScreen(onFinished: () -> Unit) {
    var visible by remember { mutableStateOf(false) }
    var exiting by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        visible = true
        delay(2200)
        exiting = true
        delay(450)
        onFinished()
    }

    val scale by animateFloatAsState(
        targetValue = if (visible && !exiting) 1f else 0.85f,
        animationSpec = if (exiting) {
            tween(450, easing = FastOutSlowInEasing)
        } else {
            spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessLow)
        },
        label = "splashScale"
    )
    val alpha by animateFloatAsState(
        targetValue = if (visible && !exiting) 1f else 0f,
        animationSpec = tween(if (exiting) 450 else 600),
        label = "splashAlpha"
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        Image(
            painter = painterResource(id = R.drawable.ic_splash),
            contentDescription = null,
            modifier = Modifier
                .align(Alignment.Center)
                .size(132.dp)
                .graphicsLayer {
                    scaleX = scale
                    scaleY = scale
                    this.alpha = alpha
                }
        )

        Row(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 56.dp)
                .graphicsLayer { this.alpha = alpha }
        ) {
            Text(
                text = stringResource(R.string.splash_made_by) + " ",
                color = MaterialTheme.colorScheme.onBackground,
                fontWeight = FontWeight.Medium
            )
            Text(
                text = stringResource(R.string.splash_brand),
                color = Accent,
                fontWeight = FontWeight.Bold
            )
        }
    }
}
EOF

echo "تم. شغل: ./gradlew assembleDebug"
