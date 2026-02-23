#!/usr/bin/env bash
# repomix-gh - 极简版（支持缓存）
# ./repomix-gh.sh owner/repo [output.md] [--force] [--full]

REPO=$1
OUT=${2:-$(basename $REPO).md}
FORCE=$3
LEAN=${4:---lean}  # 默认 lean 模式

CACHE_DIR="$HOME/.cache/repomix-gh"
mkdir -p "$CACHE_DIR"

echo "📦 repomix-gh: $REPO"
echo "================================"

BR=$(gh api repos/$REPO -q .default_branch)
ZIP_FILE="$CACHE_DIR/${REPO/\//_}-$BR.zip"
EXTRACT_DIR="$CACHE_DIR/${REPO/\//_}-$BR"

# 检查缓存
if [[ -f "$ZIP_FILE" && -z "$FORCE" ]]; then
    echo "✓ 使用缓存: $ZIP_FILE"
    ls -lh "$ZIP_FILE"
else
    echo "⬇️  下载: $REPO@$BR"
    curl -L "https://github.com/$REPO/archive/refs/heads/$BR.zip" -o "$ZIP_FILE" \
      || gh api "repos/$REPO/zipball?ref=$BR" -o "$ZIP_FILE"
    ls -lh "$ZIP_FILE"
fi

# 解压（如果需要）
if [[ ! -d "$EXTRACT_DIR" ]]; then
    echo "📂 解压: $(basename $ZIP_FILE)"
    unzip -q -o "$ZIP_FILE" -d "$CACHE_DIR"
    EXTRACT_DIR=$(find "$CACHE_DIR" -maxdepth 1 -type d -name "${REPO##*/}-$BR" | head -1)
    if [[ -z "$EXTRACT_DIR" ]]; then
        EXTRACT_DIR=$(find "$CACHE_DIR" -maxdepth 1 -type d -name "*-${BR}*" | head -1)
    fi
    echo "✓ 解压到: $EXTRACT_DIR"
else
    echo "✓ 使用已解压目录: $EXTRACT_DIR"
fi

# 选择忽略模式
if [[ "$LEAN" == "--full" ]]; then
    IGNORE="--ignore .github,.git,.cursor,.vscode,assets,node_modules,dist,build,.next,coverage"
    echo "📦 Full 模式：包含所有文件"
else
    IGNORE="--ignore .github,.git,.cursor,.vscode,assets,node_modules,dist,build,.next,coverage,tests,docs/ja-JP,docs/zh-CN,docs/zh-TW,docs/es-ES"
    echo "🎯 Lean 模式：排除测试和多语言文档（默认）"
fi

# 生成文档
echo "📝 生成文档: $OUT"
echo "================================"
REPOMIX_OUTPUT=$(repomix "$EXTRACT_DIR" -o "$OUT" --style markdown --output-show-line-numbers --no-file-summary $IGNORE 2>&1)
echo "$REPOMIX_OUTPUT"

# 提取统计信息
TOTAL_TOKENS=$(echo "$REPOMIX_OUTPUT" | grep "Total Tokens:" | grep -oP '\d[\d,]+')
TOTAL_FILES=$(echo "$REPOMIX_OUTPUT" | grep "Total Files:" | grep -oP '\d[\d,]+')

# 文件类型统计（包含大小）
echo ""
echo "📊 文件类型统计 (Top 20):"
echo "================================"

# 统计每种类型的文件数和总大小
FILE_STATS=$(find "$EXTRACT_DIR" -type f \
  ! -path "*/.github/*" ! -path "*/.git/*" ! -path "*/.cursor/*" ! -path "*/.vscode/*" \
  ! -path "*/assets/*" ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/build/*" \
  ! -path "*/.next/*" ! -path "*/coverage/*" \
  $( [[ "$LEAN" != "--full" ]] && echo "! -path '*/tests/*' ! -path '*/docs/ja-JP/*' ! -path '*/docs/zh-CN/*' ! -path '*/docs/zh-TW/*' ! -path '*/docs/es-ES/*'" ) \
  -name "*.*" | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -20)

echo "$FILE_STATS" | while read count ext; do
  # 计算该类型的总大小
  size=$(find "$EXTRACT_DIR" -type f \
    ! -path "*/.github/*" ! -path "*/.git/*" ! -path "*/.cursor/*" ! -path "*/.vscode/*" \
    ! -path "*/assets/*" ! -path "*/node_modules/*" ! -path "*/dist/*" ! -path "*/build/*" \
    ! -path "*/.next/*" ! -path "*/coverage/*" \
    $( [[ "$LEAN" != "--full" ]] && echo "! -path '*/tests/*' ! -path '*/docs/ja-JP/*' ! -path '*/docs/zh-CN/*' ! -path '*/docs/zh-TW/*' ! -path '*/docs/es-ES/*'" ) \
    -name "*.$ext" -exec du -ch {} + 2>/dev/null | tail -1 | awk '{print $1}')
  printf "  .%-20s  %5d 个文件  %8s\n" "$ext" "$count" "$size"
done

# 添加元数据到输出文件
META_COMMENT=""
META_COMMENT+="<!-- Token 总数: $TOTAL_TOKENS -->"$'\n'
META_COMMENT+="<!-- 文件总数: $TOTAL_FILES -->"$'\n'
META_COMMENT+="<!-- 生成时间: $(date -u '+%Y-%m-%d %H:%M:%S UTC') -->"$'\n'
META_COMMENT+="<!-- 仓库: $REPO@$BR -->"$'\n'
META_COMMENT+="<!-- 模式: $LEAN -->"$'\n'

# 将元数据插入文件开头
TEMP_FILE=$(mktemp)
echo "$META_COMMENT" > "$TEMP_FILE"
cat "$OUT" >> "$TEMP_FILE"
mv "$TEMP_FILE" "$OUT"

echo ""
echo "================================"
echo "✓ 完成！输出文件:"
ls -lh "$OUT"
echo ""
echo "📈 总计: $TOTAL_TOKENS tokens, $TOTAL_FILES 个文件"
