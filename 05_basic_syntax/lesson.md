# 05 基本语法（完善版）

## 学习目标

- 掌握变量、函数、条件和循环的基本写法
- 理解 `if` 与 `ifelse` 的使用边界
- 学会用向量化和 `apply` 家族提升效率
- 能写出带输入检查的可复用函数

## 核心讲解

- 条件语句：`if/else`, `ifelse`, `switch`
- 循环语句：`for`, `while`, `repeat`, `break`, `next`
- 函数设计：参数、默认值、返回值、输入校验
- 性能思维：循环预分配、向量化、`apply/lapply/sapply`

## 课堂示例

```r
score_to_grade <- function(score) {
  ifelse(score >= 90, "A",
         ifelse(score >= 80, "B",
                ifelse(score >= 70, "C", "D")))
}

scores <- c(95, 88, 72, 64)
score_to_grade(scores)

safe_mean <- function(x, na.rm = TRUE) {
  if (!is.numeric(x)) stop("x must be numeric")
  if (all(is.na(x))) return(NA_real_)
  mean(x, na.rm = na.rm)
}

safe_mean(c(1, 2, 3, NA))
```

## 常见坑提醒

1. `if` 条件必须是单个逻辑值，向量判断请用 `ifelse`。
2. `for` 循环尽量先预分配结果向量，避免在循环里不断扩容。
3. 除零可能得到 `Inf/NaN`，需要在函数中显式处理。

## 练习任务

1. 基础练习：写函数 `z_score(x)` 返回标准化向量。
2. 基础练习：写函数 `safe_mean(x)`，当全为 `NA` 返回 `NA`。
3. 进阶练习：用 `for` 与向量化分别实现平方运算并比较耗时。
4. 进阶练习：用 `apply` 计算矩阵行和、列均值。

## 章末检查

- 我会写带默认参数和输入检查的函数
- 我知道如何选择 `if`、`ifelse`、`switch`
- 我能用 `apply/lapply/sapply` 处理批量任务
