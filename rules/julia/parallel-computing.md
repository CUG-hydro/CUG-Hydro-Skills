# Julia 并行计算规则

## 多线程安全

### 避免竞态条件

```julia
# BAD: 竞态条件
shared = 0
@threads for i in 1:n
    shared += expensive_computation(i)
end

# GOOD: 使用局部累加
results = zeros(nthreads())
@threads :static for i in 1:n
    tid = threadid()
    results[tid] += expensive_computation(i)
end
total = sum(results)

# 或更好的方式
using Threads
@threads for i in 1:n
    local_result = expensive_computation(i)
    # 使用锁或原子操作更新共享状态
end
```

### 原子操作

```julia
using Base.Threads

# 原子计数器
counter = Atomic{Int64}(0)
@threads for i in 1:1000
    atomic_add!(counter, 1)
end
```

## 进程并行

### 使用 Distributed

```julia
using Distributed
addprocs(4)

# @distributed 用于归约
result = @distributed (+) for i in 1:n
    expensive_computation(i)
end

# pmap 用于负载均衡
results = pmap(expensive_computation, 1:n)
```

## GPU 计算

```julia
using CUDA

# 确保数据在GPU上
gpu_array = cu(cpu_array)

# 内核函数
function gpu_kernel!(y, x)
    i = threadIdx().x + (blockIdx().x - 1) * blockDim().x
    if i <= length(x)
        y[i] = sin(x[i])
    end
    return nothing
end

# 调用
@cuda threads=256 blocks=ceil(Int, n/256) gpu_kernel!(y, x)
```

## 性能优化

### 避免分配

```julia
# BAD: 每次迭代分配
@threads for i in 1:n
    temp = similar(array)  # 分配
    temp .= array .+ i
    results[i] = sum(temp)
end

# GOOD: 预分配
temp = similar(array)
@threads for i in 1:n
    temp .= array .+ i
    results[i] = sum(temp)
end
```

### 内存对齐

```julia
# 使用 StaticArrays 小数组
using StaticArrays

function process_point(p::SVector{3,Float64})
    # 栈分配，无需GC
    norm(p)
end
```
