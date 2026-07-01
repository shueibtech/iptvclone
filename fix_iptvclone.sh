#!/data/data/com.termux/files/usr/bin/bash
set -e

if [ ! -f "app/build.gradle.kts" ]; then
  echo "❌ شغّل السكربت من داخل مجلد المشروع (فيه app/build.gradle.kts)"
  exit 1
fi

MAIN_SCREEN=$(find app/src/main/java -name "MainScreen.kt" | head -1)
REELS_FILE=$(find app/src/main/java -name "ReelsScreen.kt" | head -1)

[ -z "$MAIN_SCREEN" ] && { echo "❌ ما لقيت MainScreen.kt"; exit 1; }
[ -z "$REELS_FILE" ] && { echo "❌ ما لقيت ReelsScreen.kt"; exit 1; }

echo "📄 MainScreen : $MAIN_SCREEN"
echo "📄 ReelsScreen: $REELS_FILE"

mkdir -p .fix_backup
cp "$MAIN_SCREEN" ".fix_backup/MainScreen.kt.bak"
cp "$REELS_FILE"  ".fix_backup/ReelsScreen.kt.bak"
cp gradlew         ".fix_backup/gradlew.bak" 2>/dev/null || true

insert_after_package() {
  local file="$1" line="$2"
  grep -qF "$line" "$file" && return 0
  local pkgline
  pkgline=$(grep -n '^package ' "$file" | head -1 | cut -d: -f1)
  awk -v ln="$pkgline" -v imp="$line" 'NR==ln{print; print imp; next} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  echo "➕ $line"
}

# 1) تصحيح سطر package في ReelsScreen.kt (كان تالف/مدمج مع imports)
REELS_PKG=$(dirname "$REELS_FILE" | sed 's#app/src/main/java/##; s#/#.#g')
EXPECTED="package $REELS_PKG"
if [ "$(head -1 "$REELS_FILE")" != "$EXPECTED" ]; then
  sed -i "1s#.*#$EXPECTED#" "$REELS_FILE"
  echo "🔧 صلّحت package في ReelsScreen.kt -> $REELS_PKG"
else
  echo "✅ package في ReelsScreen.kt سليم"
fi

# 2) التأكد من import الريلز في MainScreen.kt
insert_after_package "$MAIN_SCREEN" "import ${REELS_PKG}.ReelsScreen"

# 3) إضافة import R (لازم عشان نمرر الفيديو)
ROOT_PKG=$(grep -m1 'namespace' app/build.gradle.kts | sed -E 's/.*"([^"]+)".*/\1/')
[ -z "$ROOT_PKG" ] && ROOT_PKG=$(grep -m1 'applicationId' app/build.gradle.kts | sed -E 's/.*"([^"]+)".*/\1/')
insert_after_package "$MAIN_SCREEN" "import ${ROOT_PKG}.R"

# 4) تمرير فيديو افتراضي حقيقي من res/raw بدل الاستدعاء الفاضي
RAW_FILE=$(find app/src/main/res/raw -type f 2>/dev/null | head -1)
if [ -n "$RAW_FILE" ]; then
  RAW_VIDEO=$(basename "$RAW_FILE" | sed 's/\.[^.]*$//')
  if grep -q 'ReelsScreen()' "$MAIN_SCREEN"; then
    sed -i "s/ReelsScreen()/ReelsScreen(videoRawResId = R.raw.${RAW_VIDEO})/" "$MAIN_SCREEN"
    echo "🔧 ReelsScreen(videoRawResId = R.raw.${RAW_VIDEO})"
  fi
else
  echo "⚠️  ما فيه أي فيديو داخل res/raw — لازم تضيف واحد يدويًا"
fi

# 5) استرجاع gradlew الأصلي لو كان تالف (سكربتك الحالي مجرد 27 بايت وهمي)
GRADLE_VER=$(sed -n 's#.*gradle-\([0-9.]*\)-bin\.zip#\1#p' gradle/wrapper/gradle-wrapper.properties)
[ -z "$GRADLE_VER" ] && GRADLE_VER="8.7"
GRADLEW_SIZE=$(wc -c < gradlew 2>/dev/null || echo 0)

if [ "$GRADLEW_SIZE" -lt 1000 ] || ! grep -q "APP_HOME" gradlew 2>/dev/null; then
  echo "🔧 gradlew تالف (حجمه $GRADLEW_SIZE بايت فقط) — أرجّع الأصلي v$GRADLE_VER"
  curl -fsSL -o gradlew "https://raw.githubusercontent.com/gradle/gradle/v${GRADLE_VER}.0/gradlew"
  chmod +x gradlew
else
  echo "✅ gradlew سليم"
fi

if [ ! -s "gradle/wrapper/gradle-wrapper.jar" ]; then
  echo "🔧 gradle-wrapper.jar مفقود — أحمّله"
  curl -fsSL -o gradle/wrapper/gradle-wrapper.jar "https://raw.githubusercontent.com/gradle/gradle/v${GRADLE_VER}.0/gradle/wrapper/gradle-wrapper.jar"
else
  echo "✅ gradle-wrapper.jar موجود"
fi

echo ""
echo "===== فحص أخير ====="
echo "-- ReelsScreen.kt سطر 1:"
head -1 "$REELS_FILE"
echo "-- استدعاء الريلز في MainScreen.kt:"
grep -n "ReelsScreen(" "$MAIN_SCREEN"
echo "-- حجم gradlew:"
wc -c gradlew
echo "-- gradle-wrapper.jar:"
ls -la gradle/wrapper/gradle-wrapper.jar

git add -A
git commit -m "fix: package الريلز + gradlew الأصلي + ربط فيديو افتراضي" || echo "ما فيه تغييرات جديدة للـ commit"
git push

echo ""
echo "✅ خلصنا. راقب GitHub Actions."
