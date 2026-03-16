# Contributing

感谢你愿意为 `LottoMind` 做贡献。

## 先看这些

- 阅读 [README.md](/Users/vtx/Dev/LettoMind/README.md) 了解项目定位与限制
- 阅读 [docs/DEVELOPMENT.md](/Users/vtx/Dev/LettoMind/docs/DEVELOPMENT.md) 完成本地开发环境
- 阅读 [docs/RESPONSIBLE_USE.md](/Users/vtx/Dev/LettoMind/docs/RESPONSIBLE_USE.md) 确认合规边界

## 适合贡献的方向

- 修复崩溃、布局错误、无障碍问题和数据解析问题
- 改进测试覆盖率、工程脚本和文档质量
- 提升本地数据管理、错误提示和网络健壮性
- 把实验性功能明确标注为实验性，而不是包装成“预测能力”

## 不接受的内容

- 真实 API Key、测试账号、设备标识或任何个人隐私数据
- 夸大收益、诱导购彩或规避监管的描述
- 未解释来源的二进制产物、构建缓存或大文件

## 工作流建议

1. 从最新 `main` 创建分支。
2. 用小而清晰的提交完成改动。
3. 在提交前至少完成一次本地构建。
4. 如果改动影响行为、文档或隐私说明，请一并更新相应文件。

## 提交规范

推荐使用 Conventional Commits：

```text
feat(scope): short summary
fix(scope): short summary
docs(scope): short summary
refactor(scope): short summary
test(scope): short summary
chore(scope): short summary
```

## Pull Request 清单

- 改动范围明确，标题清晰
- 本地构建通过
- 新增行为有对应测试或验证说明
- 文档与界面文案保持一致
- 没有引入敏感信息或私有凭证

## 文档语言

仓库目前以中文为主，允许中英混写；新增文档请优先保证清晰、准确和可维护。
