# 06 数据处理（完善版）

## 学习目标

- 掌握读入、清洗、变换、汇总、输出的完整流程
- 熟练使用 `dplyr` 和 `tidyr` 核心语法
- 理解 `left_join` 与 `inner_join` 的结果差异
- 能把清洗步骤封装成可复用函数

## 核心讲解

- 读入：`readr::read_csv()`
- 检查：`glimpse()`, `summary()`, 缺失值与重复值统计
- 清洗：`distinct()`, 缺失值填补, 类型转换
- 变换：`mutate()`, `case_when()`
- 汇总：`group_by()`, `summarise()`
- 合并：`left_join()`, `inner_join()`
- 转换：`pivot_wider()`, `pivot_longer()`

## 课堂示例

```r
library(dplyr)
library(tidyr)

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

## 常见坑提醒

1. `left_join` 后出现 `NA` 往往是右表缺少匹配键，不一定是错误。
2. 缺失值处理要先定策略（删除/填补），再做汇总，避免结果偏差。
3. 宽表和长表用途不同，分析建模通常优先长表。

## 练习任务

1. 基础练习：对 `iris` 按 `Species` 计算每列均值。
2. 进阶练习：构造两张表并分别用 `left_join` 与 `inner_join` 合并，解释结果差异。
3. 进阶练习：把一个长表转宽表再转回长表，检查数据是否一致。

## 章末检查

- 我能独立写出 5 步以内的数据清洗流水线
- 我能解释“宽表”和“长表”的使用场景
- 我能定位 join 后 `NA` 的来源
