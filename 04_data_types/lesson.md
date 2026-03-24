# 04 数据类型

## 学习目标

- 掌握向量、矩阵、列表、数据框、因子
- 理解类型转换与缺失值处理
- 能根据任务选择合适数据结构

## 核心讲解

- `vector`: 同质数据，运算高效
- `matrix`: 二维同质数据
- `list`: 可混合类型，适合复杂对象
- `data.frame/tibble`: 表格数据分析核心
- `factor`: 分类变量建模常用

## 课堂示例

```r
v <- c(1, 2, 3)
m <- matrix(1:6, nrow = 2)
lst <- list(name = "sample", values = v, mat = m)

df <- data.frame(
  id = 1:4,
  group = factor(c("A", "A", "B", "B")),
  score = c(90, 88, NA, 93)
)

str(df)
colMeans(df["score"], na.rm = TRUE)
```

## 练习任务

1. 基础练习：构造一个包含 10 名学生成绩的数据框，包含 `id`, `class`, `score`。
2. 进阶练习：将 `class` 转成因子并按班级计算均值，处理缺失值后再计算一次。

## 章末检查

- 我能解释 `numeric`、`character`、`factor` 差异
- 我能使用 `str()` 快速理解数据结构
