#!/usr/bin/env bash
# repomix-gh - GitHub 仓库打包工具
# 用法: ./repomix-gh.sh owner/repo [output.md] [--force] [--full] [--ignore ...]

REPO="" OUT="" FORCE="" LEAN="--lean" IGNORE_EXTRA=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)  FORCE=1; shift ;;
        --full)   LEAN="--full"; shift ;;
        --ignore) IGNORE_EXTRA="$2"; shift 2 ;;
        -*)       echo "未知选项: $1"; exit 1 ;;
        *)        [[ -z "$REPO" ]] && REPO="$1" || OUT="$1"; shift ;;
    esac
done
OUT=${OUT:-$(basename $REPO).md}

# === 缓存与下载 ===
CACHE_DIR="$HOME/.cache/repomix-gh"
mkdir -p "$CACHE_DIR"
echo "📦 repomix-gh: $REPO"
echo "================================"

BR=$(gh api repos/$REPO -q .default_branch)
ZIP_FILE="$CACHE_DIR/${REPO/\//_}-$BR.zip"
EXTRACT_DIR="$CACHE_DIR/${REPO/\//_}-$BR"

if [[ -f "$ZIP_FILE" && -z "$FORCE" ]]; then
    echo "✓ 使用缓存: $ZIP_FILE"
    ls -lh "$ZIP_FILE"
else
    echo "⬇️  下载: $REPO@$BR"
    URL="https://github.com/$REPO/archive/refs/heads/$BR.zip"
    curl -L "$URL" -o "$ZIP_FILE" || \
        gh api "repos/$REPO/zipball?ref=$BR" -o "$ZIP_FILE"
    ls -lh "$ZIP_FILE"
fi

# === 解压 ===
if [[ -d "$EXTRACT_DIR" ]]; then
    echo "✓ 使用已解压目录: $EXTRACT_DIR"
else
    echo "📂 解压: $(basename $ZIP_FILE)"
    unzip -q -o "$ZIP_FILE" -d "$CACHE_DIR"
    EXTRACT_DIR=$(find "$CACHE_DIR" -maxdepth 1 -type d \
        -name "${REPO##*/}-$BR" | head -1)
    [[ -z "$EXTRACT_DIR" ]] && \
        EXTRACT_DIR=$(find "$CACHE_DIR" -maxdepth 1 -type d \
            -name "*-${BR}*" | head -1)
    echo "✓ 解压到: $EXTRACT_DIR"
fi

# === 忽略模式 ===
BASE=".github,.git,.cursor,.vscode"
BASE+=",assets,node_modules,dist,build,.next,coverage"
[[ "$LEAN" != "--full" ]] && \
    BASE+=",tests,docs/ja-JP,docs/zh-CN,docs/zh-TW,docs/es-ES"
[[ "$LEAN" == "--full" ]] && echo "📦 Full 模式" || echo "🎯 Lean 模式"
[[ -n "$IGNORE_EXTRA" ]] && BASE+=",$IGNORE_EXTRA" && \
    echo "🚫 额外忽略: $IGNORE_EXTRA"

# === 生成文档 ===
echo "📝 生成文档: $OUT"
echo "================================"
OUT_CMD=$(repomix "$EXTRACT_DIR" -o "$OUT" --style markdown \
    --output-show-line-numbers --no-file-summary --ignore "$BASE" 2>&1)
echo "$OUT_CMD"

TOKENS=$(echo "$OUT_CMD" | grep "Total Tokens:" | grep -oP '\d[\d,]+')
FILES=$(echo "$OUT_CMD" | grep "Total Files:" | grep -oP '\d[\d,]+')

# === 文件类型统计 ===
echo ""
echo "📊 文件类型统计 (Top 20):"
echo "================================"
EXCLUDE="! -path */.github/* ! -path */.git/* ! -path */.cursor/*"
EXCLUDE+=" ! -path */.vscode/* ! -path */assets/* ! -path */node_modules/*"
EXCLUDE+=" ! -path */dist/* ! -path */build/* ! -path */.next/*"
EXCLUDE+=" ! -path */coverage/*"
[[ "$LEAN" != "--full" ]] && EXCLUDE+=" ! -path */tests/*"
[[ "$LEAN" != "--full" ]] && EXCLUDE+=" ! -path */docs/ja-JP/*"
[[ "$LEAN" != "--full" ]] && EXCLUDE+=" ! -path */docs/zh-CN/*"
[[ "$LEAN" != "--full" ]] && EXCLUDE+=" ! -path */docs/zh-TW/*"
[[ "$LEAN" != "--full" ]] && EXCLUDE+=" ! -path */docs/es-ES/*"

eval find "$EXTRACT_DIR" -type f $EXCLUDE -name '"*.*"' | sed 's/.*\.//' \
    | sort | uniq -c | sort -rn | head -20 | while read c e; do
    s=$(eval find "$EXTRACT_DIR" -type f $EXCLUDE -name '"*.$e"' \
        -exec du -ch {} + 2>/dev/null | tail -1 | cut -f1)
    printf "  .%-20s  %5d 个文件  %8s\n" "$e" "$c" "$s"
done

# === 添加元数据 ===
META="<!-- Token 总数: $TOKENS -->
<!-- 文件总数: $FILES -->
<!-- 生成时间: $(date -u '+%Y-%m-%d %H:%M:%S UTC') -->
<!-- 仓库: $REPO@$BR -->
<!-- 模式: $LEAN -->
"
[[ -n "$IGNORE_EXTRA" ]] && META="<!-- 额外忽略: $IGNORE_EXTRA -->
$META"
{ echo -n "$META"; cat "$OUT"; } > "$OUT.tmp" && mv "$OUT.tmp" "$OUT"

echo ""
echo "================================"
echo "✓ 完成！输出文件:"
ls -lh "$OUT"
echo ""
echo "📈 总计: $TOKENS tokens, $FILES 个文件"
