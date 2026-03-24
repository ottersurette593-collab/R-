# 08 仿真与绘图

## 学习目标

- 学会随机模拟与蒙特卡洛思路
- 使用 `ggplot2` 完成常见统计图
- 能输出高质量图表用于报告

## 核心讲解

- 随机数生成：`rnorm`, `runif`, `sample`
- 仿真流程：设定参数 -> 重复抽样 -> 汇总统计
- 绘图语法：数据层 + 几何层 + 美学映射

## 课堂示例

```r
library(ggplot2)

set.seed(42)
sim <- data.frame(x = rnorm(500, mean = 0, sd = 1))

p <- ggplot(sim, aes(x = x)) +
  geom_histogram(binwidth = 0.25, fill = "steelblue", color = "white") +
  theme_minimal() +
  labs(title = "Normal Simulation", x = "x", y = "count")

print(p)
```

## 练习任务

1. 基础练习：模拟 1000 次抛硬币，估计正面比例分布。
2. 进阶练习：对不同样本量（50/100/500）比较样本均值分布差异并绘图。

## 章末检查

- 我会设置随机种子确保可复现
- 我能独立完成至少 3 种基础图形
