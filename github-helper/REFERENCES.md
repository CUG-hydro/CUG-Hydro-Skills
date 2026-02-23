# GitHub File Access - 参考资源

## 官方文档

- [GitHub REST API 官方文档](https://docs.github.com/en/rest)
- [GitHub Contents API](https://docs.github.com/en/rest/repos/contents)
- [GitHub CLI (gh) 手册](https://cli.github.com/manual/)

## 命令行工具

| 工具 | 描述 | 适用场景 |
|------|------|---------|
| **wget** | 专为下载设计 | 下载文件，支持断点续传 |
| **curl** | 多协议传输工具 | 下载文件、API 调用 |
| **gh** | GitHub 官方 CLI | GitHub 操作，已认证用户 |

## 工具安装

### wget
```bash
# Debian/Ubuntu
sudo apt install wget

# macOS (使用 Homebrew)
brew install wget

# Windows (使用 Scoop)
scoop install wget
```

### curl
```bash
# curl 通常已预装在 Linux/macOS/Windows 10+
# 如需安装：
# Debian/Ubuntu
sudo apt install curl

# macOS
brew install curl
```

### GitHub CLI (gh)
```bash
# Debian/Ubuntu
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# macOS
brew install gh

# Windows
winget install --id GitHub.cli
```

## API 端点参考

| 端点 | 描述 | 示例 |
|------|------|------|
| `/repos/{owner}/{repo}/contents/{path}` | 获取文件/目录内容 | `https://api.github.com/repos/jl-pkgs/StrategicRandomSearch.jl/contents/src` |
| `/repos/{owner}/{repo}/readme` | 获取 README | `https://api.github.com/repos/jl-pkgs/StrategicRandomSearch.jl/readme` |
| `/repos/{owner}/{repo}` | 获取仓库信息 | `https://api.github.com/repos/jl-pkgs/StrategicRandomSearch.jl` |

## 速率限制

| 方法 | 限制 |
|------|------|
| wget/curl (raw URL) | 无严格限制 |
| GitHub API | 未认证：60次/小时，已认证：5000次/小时 |
| GitHub CLI | 已认证用户遵循 API 限制 |

## 认证（可选）

对于私有仓库或提高 API 限制，可使用 Personal Access Token：

1. 访问 GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. 生成新 token
3. 使用方法：
```bash
# API 调用
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user

# gh CLI
gh auth login
```

## 示例仓库

- [StrategicRandomSearch.jl](https://github.com/jl-pkgs/StrategicRandomSearch.jl) - Julia 优化库
- [CUG-Hydro-Skills](https://github.com/cug-hydro/CUG-Hydro-Skills) - 本项目
