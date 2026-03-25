---
title: "第00节：预备节（Git 与仓库）- 新手一次看懂版"
author: "HuangJIn"
date: "2026-03-25"
output:
  html_document:
    toc: true
    toc_depth: 3
    number_sections: true
    theme: flatly
    df_print: paged
---



# 学习目标

- 彻底理解 Git、仓库、远程仓库三者关系  
- 按步骤独立完成第一次提交和第一次推送  
- 看懂 `git status`，知道下一步该做什么  
- 遇到常见报错时能快速定位并修复  

# 1. 先用一句话理解 Git

你可以把 Git 理解成“代码的时间机器”：

1. 你每改一次代码，都可以打一个“快照”（commit）  
2. 快照有时间、有说明，可以回到任意历史点  
3. 把快照推到 GitHub，就等于有了云端备份和协作入口  

# 2. 三个核心名词（必须搞清）

## 2.1 工作区（Working Directory）

你平时编辑文件的地方，就是工作区。

## 2.2 本地仓库（Local Repository）

项目下的 `.git` 目录，保存版本历史。  
执行 `git init` 就会创建本地仓库。

## 2.3 远程仓库（Remote Repository）

GitHub 上的仓库地址（例如 `https://github.com/xxx/yyy.git`）。  
用来同步、备份、协作。

# 3. 先做环境检查（看见这些结果就算成功）


``` r
git_ver <- tryCatch(
  system2("git", "--version", stdout = TRUE, stderr = TRUE),
  error = function(e) paste("Git not found:", e$message)
)
git_ver
```

```
## [1] "git version 2.52.0.windows.1"
```

如果输出类似 `git version x.x.x`，说明 Git 安装正常。  
如果提示找不到命令，先安装 Git 再继续。

# 4. 第一次本地提交（一步一步）

这一节只做本地，不连接 GitHub。  
目标：完成 `init -> add -> commit -> log` 闭环。

## 4.1 演示脚本（自动跑一遍）


``` r
demo_repo <- file.path(tempdir(), "git_zero_to_one_demo")
if (!dir.exists(demo_repo)) dir.create(demo_repo, recursive = TRUE)

old_wd <- getwd()
setwd(demo_repo)

# Step 1: 初始化仓库
out_init <- system2("git", "init", stdout = TRUE, stderr = TRUE)

# Step 2: 准备一个文件
writeLines(c("# My First Repo", "", "Created in prep lesson."), "README.md")

# Step 3: 查看状态
out_status_1 <- system2("git", "status --short", stdout = TRUE, stderr = TRUE)

# Step 4: 加入暂存区
out_add <- system2("git", "add README.md", stdout = TRUE, stderr = TRUE)

# Step 5: 再看状态
out_status_2 <- system2("git", "status --short", stdout = TRUE, stderr = TRUE)

# Step 6: 提交
out_commit <- system2(
  "git",
  c(
    "-c", "user.name=demo-user",
    "-c", "user.email=demo-user@example.com",
    "commit", "-m", "feat: init demo repo"
  ),
  stdout = TRUE,
  stderr = TRUE
)

# Step 7: 查看日志
out_log <- system2("git", "log --oneline -1", stdout = TRUE, stderr = TRUE)

setwd(old_wd)

list(
  repo_path = demo_repo,
  init = out_init,
  status_before_add = out_status_1,
  status_after_add = out_status_2,
  commit = out_commit,
  latest_log = out_log
)
```

```
## $repo_path
## [1] "C:\\Users\\27743\\AppData\\Local\\Temp\\RtmpyOflSP/git_zero_to_one_demo"
## 
## $init
## [1] "Initialized empty Git repository in C:/Users/27743/AppData/Local/Temp/RtmpyOflSP/git_zero_to_one_demo/.git/"
## 
## $status_before_add
## [1] "?? README.md"
## 
## $status_after_add
## [1] "A  README.md"
## 
## $commit
## [1] "error: pathspec 'init' did not match any file(s) known to git"
## [2] "error: pathspec 'demo' did not match any file(s) known to git"
## [3] "error: pathspec 'repo' did not match any file(s) known to git"
## attr(,"status")
## [1] 1
## 
## $latest_log
## [1] "fatal: your current branch 'master' does not have any commits yet"
## attr(,"status")
## [1] 128
```

## 4.2 每一步“看到什么算正常”

1. `git init` 后看到 `Initialized empty Git repository`  
2. `git status --short` 看到 `?? README.md`（未跟踪）  
3. `git add README.md` 后再看状态，通常是 `A  README.md`（已暂存）  
4. `git commit` 成功后看到 `1 file changed` 之类输出  
5. `git log --oneline` 能看到你写的提交信息  

# 5. 连接 GitHub 并首次推送（真实项目用）

下面命令在你的项目根目录执行。

## 5.1 首次配置提交身份（只需一次）

```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

检查是否设置成功：

```bash
git config --global --get user.name
git config --global --get user.email
```

## 5.2 绑定远程仓库并推送

```bash
git remote add origin <你的仓库URL>
git branch -M main
git push -u origin main
```

### 成功标志

- 输出里出现 `new branch` 或 `up to date`
- 之后执行 `git status` 会看到本地分支跟踪远程分支

### 注意

- 如果 GitHub 要求登录，请按提示使用浏览器授权或 Token
- 一个仓库只需要 `remote add origin` 一次

# 6. 日常最常用 6 条命令（背下来）

```bash
git status
git add .
git commit -m "你的提交说明"
git pull --rebase
git push
git log --oneline --decorate -n 5
```

建议固定节奏：

1. 开始前 `git pull --rebase`  
2. 做完一个小目标就 `add + commit`  
3. 收尾前 `git push`  

# 7. `git status` 读图式讲解

你只要看两块信息：

1. `Changes not staged for commit`：改了但还没 `add`  
2. `Changes to be committed`：已经 `add`，下一步可 `commit`  

速记规则：

- 有改动先 `git status`
- 有“not staged”先 `git add`
- 有“to be committed”就 `git commit`

# 8. VS Code 中对应按钮怎么用

1. 左侧 Source Control 打开后，会列出变更文件  
2. 文件右侧 `+` 等价于 `git add`  
3. 顶部输入框写提交信息  
4. 点击 Commit 按钮  
5. 点击 Sync / Push 推送  

建议新手前 2 周“终端命令 + Source Control 面板”一起用，建立心智映射。

# 9. 新手最常见报错与修复

## 9.1 `Author identity unknown`

原因：没配置 `user.name/user.email`。  
修复：

```bash
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"
```

## 9.2 `failed to push some refs`

原因：远程有更新，本地没同步。  
修复：

```bash
git pull --rebase
git push
```

## 9.3 出现冲突标记 `<<<<<<<`

原因：同一位置被不同改动修改。  
修复流程：

1. 打开冲突文件，保留正确内容  
2. 删除冲突标记  
3. `git add <file>`  
4. `git rebase --continue`（rebase 场景）或 `git commit`（merge 场景）  

# 10. 一次完整上手清单（建议照抄练习）

```bash
mkdir git-practice
cd git-practice
git init
echo "# Git Practice" > README.md
git status
git add README.md
git commit -m "feat: first commit"
git log --oneline -1
```

然后再做一次修改并提交：

```bash
echo "second line" >> README.md
git status
git add README.md
git commit -m "docs: update README"
git log --oneline -2
```

# 11. 课堂练习

## 基础练习

1. 完成一次本地 `init -> add -> commit`。  
2. 截图保存 `git status`（提交前）和 `git log --oneline`（提交后）。  

## 进阶练习

1. 新建 GitHub 仓库并推送你的练习项目。  
2. 用 VS Code 再做一次修改并二次提交。  
3. 提交信息分别使用：  
   - `feat:` 新增内容  
   - `fix:` 修复问题  
   - `docs:` 文档更新  

# 12. 章末自检

- 我能解释工作区、本地仓库、远程仓库  
- 我能独立完成第一次提交和第一次推送  
- 我能根据 `git status` 决定下一步命令  
- 我知道三类常见报错的处理方式  

# 13. 下一节预告

下一节开始进入 R 本体：**R 语言介绍与第一段代码**。

