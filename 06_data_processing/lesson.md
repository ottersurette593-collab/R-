# 06 数据处理

## 学习目标

- 掌握读写数据、清洗、变换与汇总
- 学会 `dplyr` 核心动词
- 构建可复用的数据处理管道

## 核心讲解

- 读入：`readr::read_csv()`
- 清洗：缺失值、重复值、类型矫正
- 变换：`mutate`, `case_when`
- 汇总：`group_by`, `summarise`
- 合并：`left_join`, `inner_join`

## 课堂示例

```r
library(dplyr)

result <- mtcars %>%
  mutate(cyl = as.factor(cyl)) %>%
  group_by(cyl) %>%
  summarise(
    n = n(),
    avg_mpg = mean(mpg),
    avg_hp = mean(hp),
    .groups = "drop"
  )

result
```

## 练习任务

1. 基础练习：对 `iris` 按 `Species` 计算每列均值。
2. 进阶练习：构造两个表并用 `left_join` 合并，检查合并后缺失值来源。

## 章末检查

- 我能独立写出 5 步以内的数据清洗流水线
- 我能解释“宽表”和“长表”转换场景
