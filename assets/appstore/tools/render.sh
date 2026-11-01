#!/usr/bin/env bash
# 把截图排版模板渲染成 App Store 尺寸（横屏 2752×2064）。
# 用法：./render.sh <lang: zh|en> <slide: 1-5> <输出路径>
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LANG_CODE="${1:?zh|en}"
SLIDE="${2:?1-5}"
OUT="${3:?output.png}"
if [ "$LANG_CODE" = "zh" ]; then
  TEMPLATE="screenshots-landscape.html"
else
  TEMPLATE="screenshots-landscape-en.html"
fi
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 --window-size=2752,2064 \
  --virtual-time-budget=5000 --user-data-dir=/tmp/chrome-nook \
  --screenshot="$OUT" "file://$ROOT/$TEMPLATE#$SLIDE"
