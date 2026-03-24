# 02 软件安装与配置（VS Code 版）

## 学习目标

- 正确安装 R 与 VS Code
- 完成 VS Code 的 R 开发环境配置
- 配置 CRAN 镜像与基础包
- 学会排查安装失败问题

## 核心讲解

- 安装顺序：R -> VS Code -> R 扩展 -> 常用包
- 常用包：`tidyverse`, `data.table`, `ggplot2`, `readr`, `bio3d`
- VS Code 推荐扩展：
  - `R`（REditorSupport）
  - `R Debugger`
  - `Code Runner`（可选）
- 建议设置：
  - 统一项目目录
  - 设置默认编码 UTF-8
  - 使用 VS Code 工作区（workspace）管理不同任务

## 课堂示例

```r
# 查看 R 版本与会话信息
R.version.string
sessionInfo()

# 安装并加载包
install.packages(c("tidyverse", "bio3d"))
library(tidyverse)
```

```json
// VS Code settings.json 示例（可按需添加）
{
  "files.encoding": "utf8",
  "r.bracketedPaste": true,
  "r.plot.useHttpgd": true,
  "r.sessionWatcher": true
}
```

## 练习任务

1. 基础练习：安装 `ggplot2` 并画一个散点图（数据可用 `mtcars`）。
2. 进阶练习：在 VS Code 中完成一次“脚本运行 -> 图表输出 -> 保存结果”流程，并写出 5 条你的环境配置规范（例如文件命名、目录结构、包版本记录）。

## 章末检查

- 我能独立完成包安装与加载
- 我知道如何通过 `sessionInfo()` 定位环境问题
- 我能在 VS Code 中运行 R 脚本并查看图形输出
