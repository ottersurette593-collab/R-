# 03 VS Code 界面与工程化习惯

## 学习目标

- 熟悉 VS Code 常见面板和作用
- 掌握脚本、终端、输出和帮助系统
- 养成项目化开发习惯

## 核心讲解

- 典型面板：Explorer、Editor、Terminal、Run and Debug、Extensions
- 推荐工作流：
  - 每个主题一个 workspace
  - 代码和数据分目录
  - 结果输出到 `output/`

## 课堂示例

```r
# 工作目录与文件检查
getwd()
list.files()

# 建议目录结构
# project/
#   data/
#   scripts/
#   output/
```

## 练习任务

1. 基础练习：在 VS Code 中创建一个工作目录，建立 `data`, `scripts`, `output` 目录并保存为 workspace。
2. 进阶练习：在 VS Code 中完成“从读入数据到保存图像”的最短工作流并记录步骤。

## 章末检查

- 我能清晰说明 VS Code 主要面板的用途
- 我能在项目内稳定复现实验路径
