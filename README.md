# LottoMind

`LottoMind` 是一个面向 iOS 17+ 的彩票历史数据分析实验项目，提供开奖抓取、统计分析、历史回测、冷热号探索和本地购彩账本能力。

这个仓库现在已经整理为可公开发布的开源项目：

- 使用 `MIT` 许可证
- 不包含仓库级 API Key、密码或个人联系信息
- 默认仅在本地保存用户数据与 API Key
- 不包含代购彩票能力，也不隶属于任何官方彩票发行机构

## 功能概览

- 首页仪表盘：展示最新开奖、推荐号码和奖池压力指数
- 分析页：展示多模块评分、说明文案和推荐详情
- 探索页：查看冷热号、热力图和时间范围变化
- 回测页：查看历史命中率和策略表现
- 账本页：记录手动录入的购彩成本与开奖结果
- 设置页：配置默认彩种、通知、本地数据清理与 AI API Key

## 技术栈

- SwiftUI
- SwiftData
- BackgroundTasks
- UserNotifications
- XCTest / Testing

## 数据与隐私

- 本项目不自带后端，也不通过自建服务器转发请求。
- 用户输入的 API Key 默认只保存在本机 Keychain。
- 当你主动执行联网同步时，请求会直接发送到你选择的 AI 服务商接口。
- 开奖数据抓取依赖外部 AI 服务和公开网络搜索能力，结果可能存在延迟或误差。

更多说明见 [docs/RESPONSIBLE_USE.md](/Users/vtx/Dev/LettoMind/docs/RESPONSIBLE_USE.md)。

## 快速开始

1. 使用 Xcode 16 或更新版本打开 [Lottomind/Lottomind.xcodeproj](/Users/vtx/Dev/LettoMind/Lottomind/Lottomind.xcodeproj)。
2. 选择 iOS 17+ 模拟器，或在真机上为 App Target 配置你自己的 Development Team。
3. 运行 App。
4. 如需联网拉取开奖信息，在“设置”页填入你自己的 AI API Key。

## 测试

在命令行中可以使用：

```bash
xcodebuild test \
  -project Lottomind/Lottomind.xcodeproj \
  -scheme Lottomind \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

如果本机没有 `iPhone 16` 模拟器，请替换为任意可用的 iOS 17+ iPhone 模拟器。

默认共享 Scheme 当前只包含稳定的单元测试。`LottomindUITests` 目标仍保留在项目中，适合在本地 Xcode 会话里按需运行和继续完善。

## 项目结构

```text
Lottomind/
  Lottomind/            # App 源码、资源、SwiftData 模型
  LottomindTests/       # 单元测试
  LottomindUITests/     # UI 测试
  docs/                 # 面向开源协作者的文档
```

## 协作

- 贡献指南： [CONTRIBUTING.md](/Users/vtx/Dev/LettoMind/CONTRIBUTING.md)
- 安全策略： [SECURITY.md](/Users/vtx/Dev/LettoMind/SECURITY.md)
- 行为准则： [CODE_OF_CONDUCT.md](/Users/vtx/Dev/LettoMind/CODE_OF_CONDUCT.md)
- 变更记录： [CHANGELOG.md](/Users/vtx/Dev/LettoMind/CHANGELOG.md)
- 架构说明： [docs/ARCHITECTURE.md](/Users/vtx/Dev/LettoMind/docs/ARCHITECTURE.md)
- 开发说明： [docs/DEVELOPMENT.md](/Users/vtx/Dev/LettoMind/docs/DEVELOPMENT.md)

## 已知限制

- 当前版本仍依赖通用 AI 接口抓取开奖数据，并非官方数据源 SDK。
- 背景刷新受 iOS 系统调度策略影响，不能保证严格准时。
- 推荐结果只用于历史统计分析和界面演示，不应被视为收益承诺或预测服务。
