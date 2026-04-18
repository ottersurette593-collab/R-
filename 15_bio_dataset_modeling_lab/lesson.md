---
title: "第15节：生物数据建模综合实验（预处理-相关性-回归-分类-检验）"
author: "HuangJIn"
date: "2026-04-18"
output:
  html_document:
    toc: true
    toc_depth: 3
    number_sections: true
    theme: flatly
---

# 学习目标

- 使用真实生物医学数据完成一次端到端统计建模实验
- 掌握数据预处理、相关性分析、回归与分类的统一流程
- 比较线性回归、多项式回归、全连接神经网络在回归任务上的差异
- 通过假设检验与区间估计形成可解释的统计结论

# 1. 数据集与任务定义

本节使用 `survival` 包中的 `lung` 数据集（晚期肺癌临床数据）。  
我们定义两个核心任务：

1. 回归任务：预测生存时间 `time`（连续变量）
2. 分类任务：预测是否发生死亡事件 `dead`（0/1）

## 1.1 研究背景与数据结构（详细）

- 研究背景：`lung` 数据来自晚期肺癌患者临床随访，包含人口学信息、功能状态评分、体重变化与生存结局。  
- 样本单位：单个患者。  
- 响应变量（回归）：`time`，单位为天。  
- 响应变量（分类）：`dead`，由 `status` 映射得到（死亡=1，其他=0）。  
- 主要解释变量：`age`、`sex`、`ph.ecog`（ECOG 体能状态）、`ph.karno`（Karnofsky 评分）、`wt.loss`（体重变化）。  
- 研究目标：在同一数据集上比较“解释性模型”和“灵活预测模型”的表现差异，并形成可解释的统计结论。

## 1.2 本节任务清单（可报告版本）

1. 数据预处理：缺失处理、变量编码、训练/测试划分、标准化。  
2. 相关性分析：连续变量之间相关方向与显著性。  
3. 回归建模：线性回归、多项式回归、全连接神经网络，对 `time` 做预测并比较误差。  
4. 分类建模：逻辑回归、全连接神经网络，对 `dead` 做概率预测并比较分类指标。  
5. 统计推断：完成组间假设检验并报告区间估计。  
6. 结论整合：给出“何时优先解释、何时优先预测”的方法建议。


``` r
set.seed(20260412)
library(survival)
library(nnet)

data(lung, package = "survival")
```

```
## Warning in data(lung, package = "survival"): data set 'lung' not found
```

``` r
raw <- lung[, c("time", "status", "age", "sex", "ph.ecog", "ph.karno", "wt.loss")]
raw$dead <- ifelse(raw$status == 2, 1, 0)
raw$sex <- factor(raw$sex, levels = c(1, 2), labels = c("male", "female"))

str(raw)
```

```
## 'data.frame':	228 obs. of  8 variables:
##  $ time    : num  306 455 1010 210 883 ...
##  $ status  : num  2 2 1 2 2 1 2 2 2 2 ...
##  $ age     : num  74 68 56 57 60 74 68 71 53 61 ...
##  $ sex     : Factor w/ 2 levels "male","female": 1 1 1 1 1 1 2 2 1 1 ...
##  $ ph.ecog : num  1 0 0 1 0 1 2 2 1 2 ...
##  $ ph.karno: num  90 90 90 90 100 50 70 60 70 70 ...
##  $ wt.loss : num  NA 15 15 11 0 0 10 1 16 34 ...
##  $ dead    : num  1 1 0 1 1 0 1 1 1 1 ...
```

``` r
summary(raw)
```

```
##       time            status           age            sex         ph.ecog      
##  Min.   :   5.0   Min.   :1.000   Min.   :39.00   male  :138   Min.   :0.0000  
##  1st Qu.: 166.8   1st Qu.:1.000   1st Qu.:56.00   female: 90   1st Qu.:0.0000  
##  Median : 255.5   Median :2.000   Median :63.00                Median :1.0000  
##  Mean   : 305.2   Mean   :1.724   Mean   :62.45                Mean   :0.9515  
##  3rd Qu.: 396.5   3rd Qu.:2.000   3rd Qu.:69.00                3rd Qu.:1.0000  
##  Max.   :1022.0   Max.   :2.000   Max.   :82.00                Max.   :3.0000  
##                                                                NA's   :1       
##     ph.karno         wt.loss             dead       
##  Min.   : 50.00   Min.   :-24.000   Min.   :0.0000  
##  1st Qu.: 75.00   1st Qu.:  0.000   1st Qu.:0.0000  
##  Median : 80.00   Median :  7.000   Median :1.0000  
##  Mean   : 81.94   Mean   :  9.832   Mean   :0.7237  
##  3rd Qu.: 90.00   3rd Qu.: 15.750   3rd Qu.:1.0000  
##  Max.   :100.00   Max.   : 68.000   Max.   :1.0000  
##  NA's   :1        NA's   :14
```

# 2. 数据预处理

问题描述：原始临床数据常见缺失与异构编码问题，若不统一处理会造成模型偏差或训练失败。本节目标是构建可复现、可直接用于建模的数据版本。

## 2.1 缺失值与变量处理

设原始特征向量为 \(x=(x_1,\dots,x_p)\)，中位数填补可写为：
\[
\tilde x_j=
\begin{cases}
\text{median}(x_j), & x_j\text{ 缺失}\\
x_j, & \text{否则}
\end{cases}
\]

标准化（用于神经网络）定义为：
\[
z_j = \frac{x_j-\mu_j}{s_j},
\]
其中 \(\mu_j\) 与 \(s_j\) 仅在训练集上估计。


``` r
df <- raw

# 删除关键变量缺失
n_before <- nrow(df)
df <- df[!is.na(df$time) & !is.na(df$dead), ]

# 中位数填补
num_impute <- c("age", "ph.ecog", "ph.karno", "wt.loss")
for (col in num_impute) {
  med <- median(df[[col]], na.rm = TRUE)
  df[[col]][is.na(df[[col]])] <- med
}

n_after <- nrow(df)
missing_after <- colSums(is.na(df))

list(n_before = n_before, n_after = n_after, missing_after = missing_after)
```

```
## $n_before
## [1] 228
## 
## $n_after
## [1] 228
## 
## $missing_after
##     time   status      age      sex  ph.ecog ph.karno  wt.loss     dead 
##        0        0        0        0        0        0        0        0
```

## 2.2 训练集/测试集划分


``` r
set.seed(20260412)
idx <- sample(seq_len(nrow(df)), size = round(0.7 * nrow(df)))
train <- df[idx, ]
test <- df[-idx, ]

c(train_n = nrow(train), test_n = nrow(test))
```

```
## train_n  test_n 
##     160      68
```

# 3. 相关性分析

问题描述：在进入多模型实验前，先回答“哪些变量与生存时间线性相关、方向如何、显著性如何”，用于辅助特征理解与模型解释。

Pearson 相关系数定义为：
\[
r_{XY}=\frac{\sum_{i=1}^n (x_i-\bar x)(y_i-\bar y)}
{\sqrt{\sum_{i=1}^n (x_i-\bar x)^2}\sqrt{\sum_{i=1}^n (y_i-\bar y)^2}}.
\]


``` r
num_vars <- df[, c("time", "age", "ph.ecog", "ph.karno", "wt.loss", "dead")]
cor_mat <- round(cor(num_vars, method = "pearson"), 3)
cor_mat
```

```
##            time    age ph.ecog ph.karno wt.loss   dead
## time      1.000 -0.078  -0.201    0.133   0.017 -0.171
## age      -0.078  1.000   0.193   -0.203   0.038  0.150
## ph.ecog  -0.201  0.193   1.000   -0.799   0.176  0.233
## ph.karno  0.133 -0.203  -0.799    1.000  -0.168 -0.183
## wt.loss   0.017  0.038   0.176   -0.168   1.000  0.028
## dead     -0.171  0.150   0.233   -0.183   0.028  1.000
```


``` r
cor_age <- cor.test(df$time, df$age)
cor_ecog <- cor.test(df$time, df$ph.ecog)
cor_karno <- cor.test(df$time, df$ph.karno)
cor_wt <- cor.test(df$time, df$wt.loss)

data.frame(
  feature = c("age", "ph.ecog", "ph.karno", "wt.loss"),
  r = round(c(cor_age$estimate, cor_ecog$estimate, cor_karno$estimate, cor_wt$estimate), 3),
  p_value = signif(c(cor_age$p.value, cor_ecog$p.value, cor_karno$p.value, cor_wt$p.value), 4)
)
```

```
##    feature      r  p_value
## 1      age -0.078 0.240500
## 2  ph.ecog -0.201 0.002341
## 3 ph.karno  0.133 0.044090
## 4  wt.loss  0.017 0.792800
```

# 4. 回归实验（线性 / 多项式 / 全连接神经网络）

问题描述（回归任务）：

- 研究问题：能否根据基线临床特征预测患者生存时间 `time`？  
- 评价重点：预测误差（RMSE/MAE）与拟合解释程度（R2）。  
- 比较目标：  
  1. 线性回归：高可解释性基线；  
  2. 多项式回归：引入有限非线性；  
  3. 全连接神经网络：高表达能力但可解释性较弱。  
- 判定原则：以测试集 RMSE 为主指标，MAE/R2 为辅助。

## 4.1 模型公式推导

线性回归模型：
\[
y_i=\beta_0+\sum_{j=1}^p\beta_j x_{ij}+\varepsilon_i,
\quad \hat\beta=\arg\min_\beta \sum_{i=1}^n (y_i-\hat y_i)^2.
\]

多项式回归（以二次项为例）：
\[
y_i=\beta_0+\beta_1x_i+\beta_2x_i^2+\cdots+\varepsilon_i.
\]

全连接神经网络（单隐层）可写为：
\[
\hat y = W_2\,\sigma(W_1x+b_1)+b_2,
\]
其中 \(\sigma(\cdot)\) 为激活函数，参数通过最小化损失函数（如 MSE）迭代学习。

## 4.2 回归建模与评估


``` r
# 线性回归
lm_fit <- lm(time ~ age + sex + ph.ecog + ph.karno + wt.loss, data = train)
pred_lm <- predict(lm_fit, newdata = test)

# 多项式回归
poly_fit <- lm(
  time ~ poly(age, 2, raw = TRUE) + poly(wt.loss, 2, raw = TRUE) + sex + ph.ecog + ph.karno,
  data = train
)
pred_poly <- predict(poly_fit, newdata = test)

# 全连接神经网络回归
x_train <- model.matrix(~ age + sex + ph.ecog + ph.karno + wt.loss, data = train)[, -1]
x_test <- model.matrix(~ age + sex + ph.ecog + ph.karno + wt.loss, data = test)[, -1]

x_train_sc <- scale(x_train)
x_test_sc <- scale(x_test, center = attr(x_train_sc, "scaled:center"), scale = attr(x_train_sc, "scaled:scale"))

y_train <- train$time
y_mean <- mean(y_train)
y_sd <- sd(y_train)
y_train_sc <- (y_train - y_mean) / y_sd

set.seed(20260412)
nn_reg <- nnet(
  x = x_train_sc,
  y = y_train_sc,
  size = 6,
  linout = TRUE,
  decay = 0.01,
  maxit = 1000,
  trace = FALSE
)

pred_nn_sc <- predict(nn_reg, x_test_sc)
pred_nn <- as.numeric(pred_nn_sc) * y_sd + y_mean

metric_reg <- function(y_true, y_pred) {
  rmse <- sqrt(mean((y_true - y_pred)^2))
  mae <- mean(abs(y_true - y_pred))
  r2 <- 1 - sum((y_true - y_pred)^2) / sum((y_true - mean(y_true))^2)
  c(RMSE = rmse, MAE = mae, R2 = r2)
}

reg_cmp <- rbind(
  linear = metric_reg(test$time, pred_lm),
  polynomial = metric_reg(test$time, pred_poly),
  neural_net = metric_reg(test$time, pred_nn)
)
round(reg_cmp, 4)
```

```
##                RMSE      MAE      R2
## linear     178.6600 144.4135 -0.0082
## polynomial 195.4176 156.3399 -0.2062
## neural_net 258.7875 200.4487 -1.1153
```

## 4.3 回归结果分析

- 在线性可解释性方面，线性模型参数最直观；多项式模型可刻画非线性；神经网络灵活但可解释性较弱。  
- 本次实验中，回归测试集指标如下（自动读取）：
  - 线性回归：RMSE=178.66，MAE=144.41，R2=-0.008
  - 多项式回归：RMSE=195.42，MAE=156.34，R2=-0.206
  - 全连接神经网络：RMSE=258.79，MAE=200.45，R2=-1.115

结论：就本数据和当前参数设置而言，linear 在 RMSE 上表现最好。

# 5. 分类实验（逻辑回归 vs 全连接神经网络）

问题描述（分类任务）：

- 研究问题：基于同一组临床特征，预测患者是否发生死亡事件（`dead`）。  
- 输出形式：事件概率 \\(\\hat p\\) 与二分类标签。  
- 比较指标：Accuracy、Precision、Recall、F1、AUC。  
- 判定原则：以 AUC 作为主要比较指标，Accuracy/F1 作为辅助。

## 5.1 分类模型公式

逻辑回归：
\[
\text{logit}(P(Y=1\mid x))=\beta_0+\sum_{j=1}^p\beta_jx_j.
\]

全连接神经网络分类（单隐层）可写为：
\[
\hat p=\sigma\left(W_2\,\sigma(W_1x+b_1)+b_2\right),
\]
其中输出 \(\hat p\in(0,1)\) 解释为事件概率。

## 5.2 分类建模与评估


``` r
calc_auc <- function(y_true, y_prob) {
  ranks <- rank(y_prob, ties.method = "average")
  n_pos <- sum(y_true == 1)
  n_neg <- sum(y_true == 0)
  if (n_pos == 0 || n_neg == 0) return(NA_real_)
  (sum(ranks[y_true == 1]) - n_pos * (n_pos + 1) / 2) / (n_pos * n_neg)
}

metric_cls <- function(y_true, y_prob, cutoff = 0.5) {
  y_pred <- ifelse(y_prob >= cutoff, 1, 0)
  tp <- sum(y_true == 1 & y_pred == 1)
  tn <- sum(y_true == 0 & y_pred == 0)
  fp <- sum(y_true == 0 & y_pred == 1)
  fn <- sum(y_true == 1 & y_pred == 0)

  acc <- (tp + tn) / length(y_true)
  prec <- ifelse(tp + fp == 0, NA_real_, tp / (tp + fp))
  rec <- ifelse(tp + fn == 0, NA_real_, tp / (tp + fn))
  f1 <- ifelse(is.na(prec) || is.na(rec) || (prec + rec) == 0, NA_real_, 2 * prec * rec / (prec + rec))
  auc <- calc_auc(y_true, y_prob)

  c(Accuracy = acc, Precision = prec, Recall = rec, F1 = f1, AUC = auc)
}

# 逻辑回归
logit_fit <- glm(dead ~ age + sex + ph.ecog + ph.karno + wt.loss, data = train, family = binomial())
prob_logit <- predict(logit_fit, newdata = test, type = "response")

# 全连接神经网络分类
train_cls <- train
train_cls$dead_f <- factor(train_cls$dead, levels = c(0, 1), labels = c("alive", "dead"))

set.seed(20260412)
nn_cls <- nnet(
  dead_f ~ age + sex + ph.ecog + ph.karno + wt.loss,
  data = train_cls,
  size = 5,
  decay = 0.01,
  maxit = 1000,
  trace = FALSE
)

prob_nn_mat <- predict(nn_cls, newdata = test, type = "raw")
if (is.matrix(prob_nn_mat)) {
  if ("dead" %in% colnames(prob_nn_mat)) {
    prob_nn <- prob_nn_mat[, "dead"]
  } else {
    prob_nn <- prob_nn_mat[, ncol(prob_nn_mat)]
  }
} else {
  prob_nn <- as.numeric(prob_nn_mat)
}

cls_cmp <- rbind(
  logistic = metric_cls(test$dead, prob_logit),
  neural_net = metric_cls(test$dead, prob_nn)
)
round(cls_cmp, 4)
```

```
##            Accuracy Precision Recall     F1    AUC
## logistic     0.7647    0.7656   0.98 0.8596 0.5400
## neural_net   0.6324    0.7273   0.80 0.7619 0.4644
```

## 5.3 分类结果分析

- 逻辑回归可解释性强（系数可转化为 OR）；神经网络对复杂非线性关系更敏感。  
- 本次实验中：
  - Logistic：Accuracy=0.765，AUC=0.54
  - Neural Net：Accuracy=0.632，AUC=0.464

在当前划分下，logistic 在 AUC 上更优。

# 6. 假设检验

问题描述：在模型比较之外，需要回答临床上常见的“组间差异是否显著”问题。本节以性别分组为例，分别检验生存时间均值差异与死亡率差异。

## 6.1 生存时间按性别分组比较（Welch t 检验）

检验问题：男性与女性生存时间均值是否存在差异？
\[
H_0:\mu_{male}=\mu_{female},\quad H_1:\mu_{male}\neq\mu_{female}.
\]


``` r
t_sex <- t.test(time ~ sex, data = df, var.equal = FALSE)
t_sex
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  time by sex
## t = -1.9843, df = 196.51, p-value = 0.04861
## alternative hypothesis: true difference in means between group male and group female is not equal to 0
## 95 percent confidence interval:
##  -111.1266705   -0.3428947
## sample estimates:
##   mean in group male mean in group female 
##             283.2319             338.9667
```

## 6.2 死亡率按性别比较（两比例检验）

\[
H_0:p_{male}=p_{female},\quad H_1:p_{male}\neq p_{female}.
\]


``` r
male_dead <- sum(df$dead[df$sex == "male"])
female_dead <- sum(df$dead[df$sex == "female"])
male_n <- sum(df$sex == "male")
female_n <- sum(df$sex == "female")

prop_sex <- prop.test(x = c(male_dead, female_dead), n = c(male_n, female_n), correct = FALSE)
prop_sex
```

```
## 
## 	2-sample test for equality of proportions without continuity correction
## 
## data:  c(male_dead, female_dead) out of c(male_n, female_n)
## X-squared = 13.511, df = 1, p-value = 0.0002371
## alternative hypothesis: two.sided
## 95 percent confidence interval:
##  0.1019165 0.3434942
## sample estimates:
##    prop 1    prop 2 
## 0.8115942 0.5888889
```

## 6.3 检验结果分析

- 性别生存时间均值检验 p 值：0.04861。  
- 性别死亡率差异检验 p 值：2.371 &times; 10<sup>-4</sup>。  
- 在 \(\alpha=0.05\) 下，
  - 生存时间均值差异：显著
  - 死亡率差异：显著

# 7. 区间估计

问题描述：除显著性检验外，还需报告参数估计的不确定性范围，以支持医学解释与决策沟通。

## 7.1 均值区间（t 区间）

对于总体均值 \(\mu\)，
\[
\bar X \pm t_{1-\alpha/2,n-1}\frac{S}{\sqrt n}.
\]

## 7.2 比例区间

大样本下比例 \(p\) 可用近似区间
\[
\hat p \pm z_{1-\alpha/2}\sqrt{\frac{\hat p(1-\hat p)}{n}}.
\]


``` r
mean_ci <- t.test(df$time)$conf.int
dead_ci <- binom.test(sum(df$dead), nrow(df))$conf.int

interval_summary <- data.frame(
  metric = c("mean_time", "dead_rate"),
  estimate = c(mean(df$time), mean(df$dead)),
  ci_low = c(mean_ci[1], dead_ci[1]),
  ci_high = c(mean_ci[2], dead_ci[2])
)
interval_summary$estimate <- round(interval_summary$estimate, 4)
interval_summary$ci_low <- round(interval_summary$ci_low, 4)
interval_summary$ci_high <- round(interval_summary$ci_high, 4)
interval_summary
```

```
##      metric estimate   ci_low  ci_high
## 1 mean_time 305.2325 277.7437 332.7212
## 2 dead_rate   0.7237   0.6608   0.7807
```

区间估计解读：

- 生存时间均值点估计：305.23，95%CI=[277.74, 332.72]
- 死亡率点估计：0.724，95%CI=[0.661, 0.781]

# 8. 总结：三类回归 + 两类分类的优劣

## 8.1 回归模型比较（本实验）

1. 线性回归：解释性强、实现简单，对线性关系友好。
2. 多项式回归：在保持较好解释性的同时捕获部分非线性。
3. 全连接神经网络：表达能力强，但参数多、可解释性弱、对预处理敏感。

## 8.2 分类模型比较（本实验）

1. 逻辑回归：参数可解释（OR），适合临床结论表达。
2. 全连接神经网络：在复杂边界下可能表现更好，但不易解释。

## 8.3 方法选择建议

- 若目标是“解释机制”：优先线性/逻辑回归。
- 若目标是“预测精度”且样本量足够：可尝试神经网络并做验证。
- 在生物统计场景中，建议“可解释模型 + 高性能模型”并行报告。

# 章末检查

- 我能从同一数据集中同时构建回归与分类任务
- 我能写出线性、多项式、神经网络、逻辑回归的核心公式
- 我能完成检验、区间估计并给出结果解释
- 我能比较模型优劣并说明选择依据
