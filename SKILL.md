---
name: wrap-up
description: 通用项目收尾技能。触发条件：用户说 "wrap-up"、"收尾"、"wrap up"、"做收尾"、"结束工作"、"finish up"、"收个尾"。执行 git 提交推送、版本发布、文档扫描更新等 end actions。按项目路径缓存项目特征，下次自动复用已知行为，支持持续扩展新 action 类型。
---

# wrap-up — 项目收尾流水线

## 流程

### Step 1 — 加载项目缓存

计算当前项目的 slug：
```bash
git remote get-url origin 2>/dev/null || pwd
```
slug 规则：取 remote URL 的 `host/owner/repo` 部分，替换 `/` 为 `-`，去掉 `.git` 后缀。
例：`github.com/user/repo` → `github.com-user-repo`

读取缓存文件：`~/.claude/skills/wrap-up/cache/<slug>.md`

- **有缓存**：展示已知 end actions 列表，询问用户是否直接执行或调整
- **无缓存**：进入 Step 2 扫描项目特征

### Step 2 — 扫描项目特征（首次或 `--refresh`）

并行检测以下特征：

| 检测项 | 检测方式 |
|--------|---------|
| 语言/框架 | `go.mod` / `package.json` / `requirements.txt` / `Cargo.toml` / `pom.xml` |
| VCS 平台 | git remote URL 域名（github/gitlab/gitea/bitbucket） |
| 发布方式 | `.github/workflows/release.yml` / `Makefile` / `goreleaser.yml` / `package.json scripts.release` |
| 文档文件 | `CHANGELOG.md` / `README.md` / `CLAUDE.md` / `docs/` |
| 版本文件 | `version.go` / `package.json version` / `pyproject.toml` / `Cargo.toml version` |
| 最近 tag | `git describe --tags --abbrev=0` |

### Step 3 — 确认 End Actions

展示检测到的 actions 列表（带序号），用户可：
- 直接确认全部执行
- 跳过某些 action（输入序号）
- 添加临时 action

### Step 4 — 执行 End Actions

按顺序执行，每个 action 完成后打印状态。详见 [actions.md](references/actions.md)，包含：
- 所有内置 action 的执行逻辑（git-commit-push / version-release / update-changelog / check-readme / check-claude-md / run-tests 等）
- 自定义 action 格式
- Action 执行顺序建议

### Step 5 — 更新缓存

将本次执行结果写入 `~/.claude/skills/wrap-up/cache/<slug>.md`。
若缓存已存在，合并更新（保留用户手动添加的自定义 actions）。

---

## 缓存文件格式

路径：`~/.claude/skills/wrap-up/cache/<slug>.md`

```markdown
---
project_url: https://github.com/user/repo
project_path: /Users/xxx/github/repo
last_updated: 2026-04-17
---

## 项目特征
- lang: go
- vcs: github
- release: github-actions (release.yml)
- docs: [README.md, CHANGELOG.md, CLAUDE.md]
- version_file: version.go

## End Actions
按顺序执行：
1. git-commit-push: 使用 pushgit skill
2. version-release: git tag + push（触发 GitHub Actions release.yml）
3. update-changelog: 扫描 git log 更新 CHANGELOG.md
4. check-readme: 检查 README 版本号引用是否需要更新

## 备注
- 版本号格式：v0.x.y（minor=新功能，patch=修复）
- CHANGELOG 格式：Keep a Changelog
- 发布前需确认 CI 通过
```

---

## 扩展新 Action

两种方式：

1. **临时**：执行时在 Step 3 输入新 action 描述，本次执行后自动写入缓存
2. **永久**：直接编辑缓存文件的 `End Actions` 列表，下次自动执行

内置 action 类型详见 [actions.md](references/actions.md)。
自定义 action 格式：`N. custom-<name>: <描述>，执行：<具体命令或步骤>`

---

## 硬性规则

- 执行 `version-release` 前必须确认当前分支是主分支且 CI 通过
- 不自动 force push，不自动删除 tag
- 缓存文件只追加/更新，不删除用户手动添加的 actions
- 若用户说 `wrap-up --refresh`，强制重新扫描项目特征并更新缓存
