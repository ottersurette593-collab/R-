# 07 回归与分类（完善版）

## 学习目标

- 理解监督学习流程：拆分、训练、预测、评估
- 掌握线性回归与逻辑回归的基础用法
- 会解释 RMSE、R2、Accuracy、Recall、AUC 等指标
- 能初步判断模型是否过拟合

## 核心讲解

- 回归：`lm()`，预测连续值
- 分类：`glm(..., family = binomial)`，预测类别概率
- 评估：训练集/测试集分离，避免“只会背题”的模型
- 指标：
  - 回归：`RMSE`, `MAE`, `R2`
  - 分类：混淆矩阵、`Accuracy`, `Precision`, `Recall`, `F1`, `AUC`

## AUC 定义公式与结果判定

定义（秩统计写法）：

`AUC = (sum(r_i, y_i=1) - n_+*(n_+ + 1)/2) / (n_+*n_-)`

其中 `r_i` 是预测分数秩，`n_+`/`n_-` 是正负样本数量。

结果判定（经验）：

1. `AUC = 0.5`：接近随机
2. `0.5 < AUC < 0.7`：较弱
3. `0.7 <= AUC < 0.8`：可接受
4. `0.8 <= AUC < 0.9`：较好
5. `AUC >= 0.9`：优秀
6. `AUC < 0.5`：模型方向可能反了或存在异常

## 课堂示例

```r
# 线性回归
fit_lm <- lm(mpg ~ wt + hp + cyl, data = mtcars)
summary(fit_lm)

# 逻辑回归（setosa 二分类）
df <- iris
df$target <- ifelse(df$Species == "setosa", 1, 0)
fit_glm <- glm(target ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
               data = df, family = binomial)
summary(fit_glm)
```

## 常见坑提醒

1. 只看训练集指标通常不可靠，必须看测试集表现。
2. 分类模型输出默认是概率，不是最终类别，需要设阈值。
3. 准确率高不代表模型好，类别不平衡时要重点看召回率和 AUC。

## 练习任务

1. 基础练习：用 `mtcars` 做线性回归并计算测试集 RMSE。
2. 基础练习：用 `iris` 完成 `setosa` 二分类并计算准确率。
3. 进阶练习：比较两组特征组合，分析测试集指标差异。
4. 进阶练习：实现一个二分类评估函数，输出混淆矩阵与核心指标。

## 章末检查

- 我能解释回归和分类的输入输出差异
- 我会用 `lm` 与 `glm` 搭建基础模型
- 我能阅读并解释核心评估指标
