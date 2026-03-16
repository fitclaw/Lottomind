# Contributing

感谢你愿意为 `LottoMind` 做贡献。
Thanks for considering a contribution to `LottoMind`.

## 语言与沟通 / Language And Communication

- Issue 和 PR 可以使用中文或英文。
- You can open issues and pull requests in either Chinese or English.
- 新增文档允许中英混写，但请优先保证清晰、准确和可维护。
- Mixed-language documentation is acceptable when it stays clear and maintainable.

## 先看这些 / Read These First

- 阅读 [README.md](./README.md) 了解项目定位与限制
- 阅读 [docs/DEVELOPMENT.md](./docs/DEVELOPMENT.md) 完成本地开发环境
- 阅读 [docs/RESPONSIBLE_USE.md](./docs/RESPONSIBLE_USE.md) 确认合规边界
- Read [README.en.md](./README.en.md) for the English overview
- Read [docs/DEVELOPMENT.en.md](./docs/DEVELOPMENT.en.md) for local setup in English
- Read [docs/RESPONSIBLE_USE.en.md](./docs/RESPONSIBLE_USE.en.md) for the English responsible-use summary

## 适合贡献的方向 / Good Contribution Areas

- 修复崩溃、布局错误、无障碍问题和数据解析问题
- 改进测试覆盖率、工程脚本和文档质量
- 提升本地数据管理、错误提示和网络健壮性
- 把实验性功能明确标注为实验性，而不是包装成“预测能力”
- Fix crashes, layout issues, accessibility problems, and parsing defects
- Improve test coverage, tooling, and documentation quality
- Strengthen local data handling, error reporting, and network resilience
- Label experimental behavior honestly instead of presenting it as prediction capability

## 不接受的内容 / Not Accepted

- 真实 API Key、测试账号、设备标识或任何个人隐私数据
- 夸大收益、诱导购彩或规避监管的描述
- 未解释来源的二进制产物、构建缓存或大文件
- Real API keys, private test accounts, device identifiers, or personal data
- Misleading gambling claims, exaggerated outcomes, or compliance-avoidance language
- Unexplained binaries, build artifacts, or oversized generated files

## 工作流建议 / Suggested Workflow

1. 从最新 `main` 创建分支。
2. 用小而清晰的提交完成改动。
3. 在提交前至少完成一次本地构建。
4. 如果改动影响行为、文档或隐私说明，请一并更新相应文件。
5. Create your branch from the latest `main`.
6. Keep commits small and well-scoped.
7. Run at least one local build before submission.
8. Update docs and privacy-facing copy whenever behavior changes.

## 提交规范 / Commit Style

推荐使用 Conventional Commits：

```text
feat(scope): short summary
fix(scope): short summary
docs(scope): short summary
refactor(scope): short summary
test(scope): short summary
chore(scope): short summary
```

## Pull Request 清单 / PR Checklist

- 改动范围明确，标题清晰
- 本地构建通过
- 新增行为有对应测试或验证说明
- 文档与界面文案保持一致
- 没有引入敏感信息或私有凭证
- Scope is clear and title is specific
- Local build succeeds
- New behavior has tests or verification notes
- Docs and UI copy stay in sync
- No secrets or sensitive data were introduced
