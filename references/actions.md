# End Actions 参考

## 内置 Actions

### git-commit-push
调用 `pushgit` skill 执行标准提交推送流程（status → diff → stage → commit → push）。
若 pushgit skill 不可用，手动执行：
```bash
git status
git diff
git add <files>
git commit -m "<conventional commit message>"
git push
```

### version-release

#### 1. 推断版本规则

先读取远端已有 tag，推断项目的版本号规范：

```bash
git fetch --tags
git tag -l | sort -V | tail -20
```

| 检测到的 tag 格式 | 推断规则 |
|-----------------|---------|
| `v0.x.y`（如 v0.13.0） | minor=新功能，patch=修复，v1.0.0=首个稳定版 |
| `v1.x.y` / `v2.x.y` | 标准 semver：major.minor.patch |
| `x.y.z`（无 v 前缀） | 同 semver，不加 v 前缀 |
| `vYYYY.MM.DD` | 日期版本，递增日期或加 `.N` 后缀 |
| 无 tag | 使用标准方案（见下方） |

根据本次变更类型建议下一个版本号：
- 新功能（feat）→ minor +1，patch 归零
- Bug 修复（fix/perf）→ patch +1
- 破坏性变更（BREAKING CHANGE）→ major +1

**无 tag 时的标准方案**：从 `v0.1.0` 开始，遵循 `v0.x.y` 规则。

#### 2. 执行路径

根据项目发布方式选择：

| 发布方式 | 执行步骤 |
|---------|---------|
| `github-actions` | `git tag -a vX.Y.Z -m "<message>"` → `git push origin vX.Y.Z` |
| `goreleaser` | `git tag vX.Y.Z` → `git push origin vX.Y.Z` |
| `makefile` | `make release VERSION=X.Y.Z` 或 `make tag VERSION=X.Y.Z` |
| `npm` | `npm version patch/minor/major` → `npm publish` |
| `cargo` | `cargo publish` |
| `pypi` | `python -m build` → `twine upload dist/*` |
| `manual` | 提示用户手动操作，说明步骤 |

#### 3. 执行前检查

- 当前分支是否为主分支（main/master）
- 是否有未提交的变更（应先执行 git-commit-push）
- 展示推断的版本号，让用户确认或修改

### update-changelog
```bash
# 获取上次 tag 到 HEAD 的提交
git log <last-tag>..HEAD --oneline --no-merges
```
按 Conventional Commits 分类（feat/fix/perf/refactor/docs/chore），追加到 CHANGELOG.md 顶部。
若无 CHANGELOG.md，创建并使用 Keep a Changelog 格式。

格式模板：
```markdown
## [vX.Y.Z] - YYYY-MM-DD

### Features
- xxx (#PR)

### Bug Fixes
- xxx

### Performance
- xxx
```

### check-readme
扫描 README.md 中可能过时的内容：
- 版本号引用（`v0.x.y`、`@latest` 等）
- 安装命令中的版本号
- 功能列表是否与当前代码一致
- Badge 链接是否有效

发现问题时列出具体行号，询问用户是否更新。

### update-docs
扫描 `docs/` 目录（若存在），检查：
- API 文档是否与当前代码一致
- 配置项说明是否完整
- 示例代码是否可运行

### check-claude-md
检查 `CLAUDE.md`（若存在）是否需要更新：
- 新增的 CLI 命令或配置项
- 变更的工作流程
- 新的约束或规范

### run-tests
执行项目测试套件（快速验证）：

| 语言 | 命令 |
|-----|------|
| Go | `go test ./... -count=1 -timeout 60s` |
| Node | `npm test -- --run` 或 `npx vitest --run` |
| Python | `pytest -x -q` |
| Rust | `cargo test` |

测试失败时阻断后续 actions，提示用户修复。

### smoke-test
执行冒烟测试（若 Makefile 中有 `smoke-test` target）：
```bash
make smoke-test 2>/dev/null || echo "no smoke-test target"
```

---

## 自定义 Action 格式

在缓存文件的 `End Actions` 列表中添加：
```
N. custom-<name>: <一句话描述>，执行：<具体命令或步骤>
```

示例：
```
5. custom-notify: 发送 Slack 通知，执行：curl -X POST $SLACK_WEBHOOK -d '{"text":"deployed vX.Y.Z"}'
6. custom-deploy: 部署到 staging，执行：make deploy ENV=staging
```

Claude 会按描述和执行步骤处理自定义 action，支持 bash 命令、skill 调用、或自然语言描述的操作。

---

## Action 执行顺序建议

标准顺序（可在缓存中调整）：
1. `run-tests` — 先验证代码正确性
2. `git-commit-push` — 提交当前变更
3. `update-changelog` — 更新变更日志
4. `version-release` — 打 tag 发布
5. `check-readme` — 检查文档
6. `check-claude-md` — 检查项目指南
