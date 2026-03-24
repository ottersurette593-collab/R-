# 07 回归与分类

## 学习目标

- 理解监督学习基本流程
- 会做线性回归与逻辑回归
- 能解释核心评价指标

## 核心讲解

- 线性回归：`lm()`，指标看 `R-squared`, `p-value`
- 逻辑回归：`glm(..., family = binomial)`
- 训练/测试划分与过拟合概念

## 课堂示例

```r
# 线性回归
fit_lm <- lm(mpg ~ wt + hp, data = mtcars)
summary(fit_lm)

# 二分类示例（是否自动挡）
mtcars$am <- as.factor(mtcars$am)
fit_glm <- glm(am ~ wt + hp + mpg, data = mtcars, family = binomial)
summary(fit_glm)
```

## 练习任务

1. 基础练习：用 `iris` 完成一个二分类逻辑回归（例如 `Species == setosa`）。
2. 进阶练习：比较两种不同特征组合的模型表现并解释差异。

## 章末检查

- 我能说清回归和分类的输入输出差异
- 我能解释系数方向与业务含义
