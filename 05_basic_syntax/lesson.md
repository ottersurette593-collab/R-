# 05 基本语法

## 学习目标

- 掌握变量、函数、条件与循环
- 学会向量化思维替代低效循环
- 能写出可复用的自定义函数

## 核心讲解

- 条件：`if`, `ifelse`, `switch`
- 循环：`for`, `while`, `repeat`
- 函数：参数、返回值、默认值
- 向量化与 `apply` 家族

## 课堂示例

```r
score_to_grade <- function(score) {
  ifelse(score >= 90, "A",
         ifelse(score >= 80, "B",
                ifelse(score >= 70, "C", "D")))
}

scores <- c(95, 88, 72, 64)
score_to_grade(scores)

# 向量化汇总
mat <- matrix(1:9, nrow = 3)
apply(mat, 1, sum)
```

## 练习任务

1. 基础练习：写函数 `z_score(x)` 返回标准化后的向量。
2. 进阶练习：写函数 `safe_mean(x)`，当全部为 `NA` 时返回 `NA`，否则返回均值。

## 章末检查

- 我会写带默认参数的函数
- 我知道何时用 `apply/lapply/sapply`
