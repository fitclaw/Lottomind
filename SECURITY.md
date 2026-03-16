# Security Policy

## 支持范围 / Supported Scope

当前安全修复优先覆盖 `main` 分支的最新代码。
Security fixes are prioritized for the latest code on `main`.

## 报告方式 / How To Report

- 如果发现漏洞，请优先使用 GitHub 的私密漏洞报告能力。
- 如果仓库暂未开启私密报告，请先提交一个不含细节的占位 Issue，请求维护者建立私下沟通渠道。
- 不要在公开 Issue、PR、截图或日志中粘贴真实 API Key、Cookie、Token、设备标识或个人信息。
- If you discover a vulnerability, prefer GitHub private vulnerability reporting when available.
- If private reporting is not enabled, open a placeholder issue without exploit details and request a private channel.
- Never post real API keys, cookies, tokens, device identifiers, or personal data in public issues, PRs, screenshots, or logs.

## 报告内容建议 / What To Include

- 影响范围
- 复现步骤
- 触发条件
- 预期行为与实际行为
- 可能的修复方向
- Impacted scope
- Reproduction steps
- Trigger conditions
- Expected behavior vs actual behavior
- Possible remediation direction

## 响应原则 / Response Principles

- 会尽快确认问题是否成立，并评估是否需要临时缓解措施。
- 如果问题涉及已泄露的凭证，第一优先级是撤销和轮换凭证，而不是继续传播样本。
- 修复完成后，会在不暴露利用细节的前提下公开说明影响范围与升级建议。
- Reports are triaged as quickly as possible, including whether temporary mitigations are needed.
- If credentials are exposed, revocation and rotation come before any sample-sharing or reproduction work.
- After a fix, impact and upgrade guidance should be shared without exposing exploit details.
