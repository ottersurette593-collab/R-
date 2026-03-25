# 00 预备节：Git 与仓库（新手一步一步版）

## 学习目标

- 看懂 Git 基本概念：工作区、本地仓库、远程仓库
- 独立完成第一次提交与第一次推送
- 能根据 `git status` 判断下一步命令
- 能处理常见报错（身份未配置、推送失败、冲突）

## 一句话理解

Git 是“代码的时间机器”：  
你每次提交（commit）都会留下一个可回溯的历史快照。

## 新手最小闭环（先只做本地）

```bash
git init
git status
git add README.md
git commit -m "feat: first commit"
git log --oneline -1
```

成功标志：

1. `git init` 后看到 `Initialized empty Git repository`
2. `git status --short` 看到 `??`（未跟踪）或 `A`（已暂存）
3. `git log --oneline` 能看到你刚写的提交信息

## 连接 GitHub 并推送

```bash
git remote add origin <repo_url>
git branch -M main
git push -u origin main
```

## 每天固定流程（建议照做）

1. 开始前：`git pull --rebase`
2. 做完一个小目标：`git add .` + `git commit -m "..."`
3. 收尾前：`git push`

## VS Code 对应操作

1. Source Control 中查看改动
2. 点击 `+` 暂存文件（等价于 `git add`）
3. 填写提交信息并 Commit
4. Sync/Push 同步远程

## 常见报错

1. `Author identity unknown`  
   修复：配置用户名和邮箱
   ```bash
   git config --global user.name "your-name"
   git config --global user.email "you@example.com"
   ```
2. `failed to push some refs`  
   修复：先拉取再推送
   ```bash
   git pull --rebase
   git push
   ```
3. 冲突标记 `<<<<<<<`  
   修复：手动改冲突文件 -> `git add` -> `git rebase --continue` 或 `git commit`

## 章末检查

- 我能解释 Git 与 GitHub 的关系
- 我能独立完成一次完整提交和推送
- 我能读懂 `git status` 并知道下一步操作
