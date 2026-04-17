# wrap-up

通用项目收尾 Claude skill：自动执行 git 提交、版本发布、文档扫描，按项目缓存 end actions，下次直接复用。

## 一句话安装

在 Claude Code 对话框粘贴：

```
请帮我安装 wrap-up skill：bash -c "$(curl -fsSL https://raw.githubusercontent.com/zhoushoujianwork/skill-wrap-up/main/install.sh)"
```

或直接在终端运行：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zhoushoujianwork/skill-wrap-up/main/install.sh)"
```

## 使用

在任意 git 项目的 Claude Code 会话中说：

```
收尾
```

或 `wrap-up` / `wrap up` / `做收尾` / `finish up`

## 功能

- 首次运行自动扫描项目特征（语言、VCS 平台、发布方式、文档文件）
- 按项目 remote URL 缓存 end actions，下次直接复用
- 内置 actions：`git-commit-push` / `version-release` / `update-changelog` / `check-readme` / `check-claude-md` / `run-tests`
- 支持自定义 action 扩展，编辑 `~/.claude/skills/wrap-up/cache/<slug>.md` 即可
- `wrap-up --refresh` 强制重新扫描项目特征

## 更新

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zhoushoujianwork/skill-wrap-up/main/install.sh)"
```
