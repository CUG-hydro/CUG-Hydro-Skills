# 可复现性规则

所有科研代码和数据分析必须满足可复现性要求。

## 环境管理

### Julia
- 使用 `Project.toml` 和 `Manifest.toml` 锁定依赖版本
- 在README中说明Julia版本要求
- 使用 `DrWatson.jl` 管理项目结构

### Python
- 使用 `requirements.txt` 或 `environment.yml`
- 明确Python版本
- 考虑使用 `pipenv` 或 `poetry`

### R
- 使用 `renv` 管理依赖
- 记录R版本
- 使用 `sessionInfo()` 输出环境信息

## 数据管理

- 原始数据永不修改，使用脚本处理
- 数据文件使用版本控制或DOI引用
- 提供数据字典说明变量含义
- 敏感数据使用 `.gitignore` 排除

## 代码组织

```
project/
├── README.md           # 项目说明和复现步骤
├── Project.toml        # Julia环境
├── scripts/            # 分析脚本
├── src/                # 可复用代码模块
├── data/
│   ├── raw/            # 原始数据（只读）
│   ├── processed/      # 处理后数据
│   └── README.md       # 数据来源说明
├── results/            # 输出结果
└── figures/            # 图表输出
```

## 随机性控制

- 所有随机过程必须设置种子
- Julia: `Random.seed!(42)`
- Python: `np.random.seed(42)` 或 `random.seed(42)`
- R: `set.seed(42)`

## 文档要求

- 每个脚本头部说明目的、输入、输出
- 关键参数在配置文件或脚本开头明确定义
- 提供运行示例
