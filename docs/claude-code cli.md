## LLM配置 <!-- omit in toc -->

```powershell
# code $PROFILE
# 需要在环境变量中先配置好环境变量KEY
$env:KEY_KIMI = "sk-kimi-9goqabHfwEQl42q6jrxZpQE22rp-***"
$env:KEY_ZAI = "0693adac93994a26a78009a48aa01248-***"

function kimi-claude {
    $env:ANTHROPIC_AUTH_TOKEN=$env:KEY_KIMI
    $env:ANTHROPIC_BASE_URL="https://api.kimi.com/coding"
    $env:DISABLE_TELEMETRY=1
    claude @Args
} 

function zai-claude {
    $env:ANTHROPIC_AUTH_TOKEN=$env:KEY_ZAI
    $env:ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
    # $env:ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-5"
    $env:ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7"
    $env:ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5"
    
    claude @Args
} 

function min-claude {
    $env:ANTHROPIC_AUTH_TOKEN=$env:KEY_MINIMAX
    $env:ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic"
    # $env:ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-5"
    $env:ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M2.5-highspeed"
    $env:ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M2.5"
    
    claude @Args
}

```
