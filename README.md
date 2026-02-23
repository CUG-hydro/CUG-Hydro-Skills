<h1>CUG-Hydro-Skills</h1>

> CUG-Hydro研究组：分享与开发 LLM Skills

- `claude-code`使用与配置教程：[](docs/ClaudeCode-llms.txt)

## Skills读取顺序  <!-- omit in toc -->

### 1 Claude <!-- omit in toc -->

```bash
~/.claude/skills/
.claude/skills/
```

```powershell
# 创建目录连接（不需要管理员权限）
mkdir .claude
mklink /J ".claude\skills" "%CD%\skills"
```
