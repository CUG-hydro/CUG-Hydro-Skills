<h1>CUG-Hydro-Skills</h1>
> CUG-Hydro研究组LLM Skills

## 1 github-helper

- 学习单个文件，例如<https://github.com/jl-pkgs/StrategicRandomSearch.jl/blob/main/src/SRS.jl>

- 学习repo，借助`repomix`

    > 改工具可让LLM快速、完整的学会一个Github repo。

    在线copy配置命令，<https://repomix.com/>

    *格式*:
    ```bash
    npx repomix --remote 'https://github.com/{own}/{repo}' -o {repo}.md --style markdown --output-show-line-numbers --ignore '.github, .vscode, .gitignore'
    ```

    *示例*:    
    ```bash
    npx repomix --remote 'https://github.com/jl-pkgs/StrategicRandomSearch.jl' -o StrategicRandomSearch.md --style markdown --output-show-line-numbers --ignore '.github, .vscode, .gitignore'
    ```
    
    > 其他常用参数：`--no-file-summary`
    大型repo，优先下载zip；不要使用github
    
- github `gh`

    安装

npx repomix --remote 'https://github.com/Deltares/Wflow.jl' --style markdown --output-show-line-numbers --no-file-summary --ignore '.github'

