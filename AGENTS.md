# Linux 编程哲学

## 核心原则

### 1. Do one thing well
每个工具只做一件事，并把它做好。

### 2. Everything is a file
一切皆文件，统一接口。

### 3. Small is beautiful
小即是美，简洁 > 复杂。

### 4. Composition over complexity
组合优于复杂，管道串联。

## 编码规范

### 极简主义

```bash
# ✅ 好：简洁直接
curl -L "$URL" -o "$TMP/file" && unzip -q "$TMP/file"

# ❌ 坏：冗余啰嗦
if curl --location --request GET "$URL" --output "$TMP/file"; then
    if unzip -quiet "$TMP/file"; then
        echo "Success!"
    else
        echo "Failed to unzip"
    fi
else
    echo "Failed to download"
fi
```

**实战案例：GitHub 仓库打包**
```bash
# ✅ 10 行搞定（repomix-gh.sh）
REPO=$1; TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT
BR=$(gh api repos/$REPO -q .default_branch)
curl -L "https://github.com/$REPO/archive/refs/heads/$BR.zip" -o $TMP/r.zip
unzip -q $TMP/r.zip -d $TMP
repomix "$TMP"/*/ -o "$OUT" --style markdown --no-file-summary -i .github,.git

# ❌ 过度工程：60+ 行，大量 if-else、进度输出、错误检查
```

### 失败即终止

```bash
# ✅ 好：set -e 自动处理错误
set -e
curl -L "$URL" | tar xz

# ❌ 坏：手动检查每个错误
if ! curl -L "$URL" -o file; then
    echo "Error!"
    exit 1
fi
```

### 默认输出到 stdout

```bash
# ✅ 好：输出到 stdout，可组合
process_data | grep pattern | sort

# ❌ 坏：直接写文件
process_data -o output.txt
```

### 无静默失败

```bash
# ✅ 好：让错误自然传播
cmd1 | cmd2 | cmd3

# ❌ 坏：吞噬错误
cmd1 || true  # 除非有明确理由
```

### 使用标准工具

```bash
# ✅ 好：标准 POSIX 工具
tmp=$(mktemp -d)
trap "rm -rf $tmp" EXIT

# ❌ 坏：依赖特定实现
tmp=/tmp/temp-$$
# 忘记清理...
```

### 管道优先

```bash
# ✅ 好：管道组合
grep pattern file | sort | uniq

# ❌ 坏：临时文件
grep pattern file > /tmp/a
sort /tmp/a > /tmp/b
uniq /tmp/b
```

## 实战示例

### ❌ 过度工程
```bash
#!/usr/bin/env bash
# 下载并处理文件 - 啰嗦版

DOWNLOAD_URL="$1"
OUTPUT_FILE="$2"
TEMP_DIR=$(mktemp -d)

# 下载文件
echo "开始下载..."
if curl -L "$DOWNLOAD_URL" -o "$TEMP_DIR/file.zip"; then
    echo "下载成功"

    # 解压文件
    echo "开始解压..."
    if unzip -q "$TEMP_DIR/file.zip" -d "$TEMP_DIR"; then
        echo "解压成功"

        # 处理文件
        echo "开始处理..."
        if process "$TEMP_DIR" > "$OUTPUT_FILE"; then
            echo "处理成功！"
        else
            echo "处理失败" >&2
            exit 1
        fi
    else
        echo "解压失败" >&2
        exit 1
    fi
else
    echo "下载失败" >&2
    exit 1
fi

rm -rf "$TEMP_DIR"
```

### ✅ 极简风格
```bash
#!/usr/bin/env bash
# 下载并处理文件

U=$1
O=$2
T=$(mktemp -d)
trap "rm -rf $T" EXIT

curl -L "$U" -o "$T/f.zip" \
  && unzip -q "$T/f.zip" -d "$T" \
  && process "$T" > "$O"
```

## 检查清单

编写代码时问自己：

1. **能否删减？** - 去掉不必要的变量、注释、抽象
2. **能否组合？** - 用管道代替临时文件
3. **能否简化？** - 用标准工具替代自定义逻辑
4. **是否失败即终止？** - set -e, 让错误自然传播
5. **是否可组合？** - 输出到 stdout 而非硬编码文件

## 参考资料

- [The Art of Unix Programming](http://www.catb.org/~esr/writings/taoup/)
- [Unix Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy)
- [12 Factor App](https://12factor.net/)
