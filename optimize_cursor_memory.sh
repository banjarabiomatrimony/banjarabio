#!/bin/bash

# Cursor Memory Optimization Script
# Run this script to aggressively reduce memory usage

echo "🔧 Starting Cursor Memory Optimization..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Kill Dart Analysis Server processes
echo -e "${YELLOW}1. Killing Dart Analysis Server processes...${NC}"
pkill -f "dart.*analysis_server" 2>/dev/null && echo -e "${GREEN}✓ Killed Dart Analysis Server${NC}" || echo "No Dart Analysis Server running"

# 2. Kill Gradle daemons
echo -e "${YELLOW}2. Stopping Gradle daemons...${NC}"
cd "$(dirname "$0")/android" 2>/dev/null
if [ -f "gradlew" ]; then
    ./gradlew --stop 2>/dev/null && echo -e "${GREEN}✓ Stopped Gradle daemons${NC}" || echo "Gradle not running"
else
    echo "Gradle wrapper not found, skipping..."
fi
cd - > /dev/null

# 3. Kill Java processes related to Gradle
echo -e "${YELLOW}3. Killing Java/Gradle processes...${NC}"
pkill -f "java.*gradle" 2>/dev/null && echo -e "${GREEN}✓ Killed Gradle Java processes${NC}" || echo "No Gradle Java processes running"

# 4. Clean Flutter build cache
echo -e "${YELLOW}4. Cleaning Flutter build cache...${NC}"
cd "$(dirname "$0")"
flutter clean > /dev/null 2>&1 && echo -e "${GREEN}✓ Cleaned Flutter build${NC}" || echo "Flutter clean failed or not needed"

# 5. Clean Dart tool cache
echo -e "${YELLOW}5. Cleaning Dart tool cache...${NC}"
rm -rf .dart_tool/package_config.json 2>/dev/null
rm -rf .dart_tool/flutter_build 2>/dev/null
echo -e "${GREEN}✓ Cleaned Dart tool cache${NC}"

# 6. Clean Gradle cache (optional - uncomment if needed)
# echo -e "${YELLOW}6. Cleaning Gradle cache...${NC}"
# rm -rf android/.gradle/caches 2>/dev/null
# echo -e "${GREEN}✓ Cleaned Gradle cache${NC}"

# 7. Remove IntelliJ/Android Studio files (they cause indexing)
echo -e "${YELLOW}7. Removing IntelliJ/Android Studio files...${NC}"
rm -rf .idea 2>/dev/null && echo -e "${GREEN}✓ Removed .idea folder${NC}" || echo ".idea folder not found"
find . -name "*.iml" -type f -delete 2>/dev/null && echo -e "${GREEN}✓ Removed .iml files${NC}" || echo "No .iml files found"

# 8. Clean build directories
echo -e "${YELLOW}8. Cleaning build directories...${NC}"
rm -rf build/app/tmp 2>/dev/null
rm -rf android/app/build 2>/dev/null
rm -rf android/build 2>/dev/null
echo -e "${GREEN}✓ Cleaned build directories${NC}"

# 9. Clear Cursor cache (macOS)
echo -e "${YELLOW}9. Clearing Cursor cache...${NC}"
CURSOR_CACHE="$HOME/Library/Application Support/Cursor/Cache"
CURSOR_CACHED_DATA="$HOME/Library/Application Support/Cursor/CachedData"
CURSOR_LOGS="$HOME/Library/Application Support/Cursor/logs"

if [ -d "$CURSOR_CACHE" ]; then
    rm -rf "$CURSOR_CACHE"/* 2>/dev/null && echo -e "${GREEN}✓ Cleared Cursor cache${NC}" || echo "Could not clear cache"
fi

if [ -d "$CURSOR_CACHED_DATA" ]; then
    rm -rf "$CURSOR_CACHED_DATA"/* 2>/dev/null && echo -e "${GREEN}✓ Cleared Cursor cached data${NC}" || echo "Could not clear cached data"
fi

if [ -d "$CURSOR_LOGS" ]; then
    find "$CURSOR_LOGS" -name "*.log" -mtime +7 -delete 2>/dev/null && echo -e "${GREEN}✓ Cleaned old logs${NC}" || echo "Could not clean logs"
fi

# 10. Clear Dart Server cache
echo -e "${YELLOW}10. Clearing Dart Server cache...${NC}"
DART_SERVER="$HOME/.dartServer"
if [ -d "$DART_SERVER" ]; then
    rm -rf "$DART_SERVER"/* 2>/dev/null && echo -e "${GREEN}✓ Cleared Dart Server cache${NC}" || echo "Could not clear Dart Server cache"
fi

echo ""
echo -e "${GREEN}✅ Memory optimization complete!${NC}"
echo ""
echo "📊 Next steps:"
echo "1. Restart Cursor completely (Cmd+Q, then reopen)"
echo "2. Open Command Palette (Cmd+Shift+P) and run: 'Dart: Restart Analysis Server'"
echo "3. Check Activity Monitor to verify memory usage has decreased"
echo ""
echo "💡 Expected memory usage: 2-5GB (down from 30GB)"
