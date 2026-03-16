# Development

## 环境要求

- macOS
- Xcode 16 或更高版本
- iOS 17+ Simulator 或真机

## 本地运行

1. 打开 `Lottomind/Lottomind.xcodeproj`。
2. 选择 `Lottomind` Scheme。
3. 如果在真机上运行，给 App Target 配置你自己的 Development Team。
4. 运行 App。

## 命令行验证

构建：

```bash
xcodebuild build \
  -project Lottomind/Lottomind.xcodeproj \
  -scheme Lottomind \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

测试：

```bash
xcodebuild test \
  -project Lottomind/Lottomind.xcodeproj \
  -scheme Lottomind \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

如果本机没有该模拟器，请替换成任意可用的 iOS 17+ iPhone 模拟器。

## 联网功能说明

- 项目没有官方数据源 SDK。
- 开奖数据同步依赖外部 AI 服务商的联网能力与响应格式。
- 没有 API Key 时，核心界面仍可浏览本地内容和示例数据，但无法拉取最新开奖。

## 提交前检查

- 本地构建通过
- 默认共享 Scheme 的单元测试通过
- 没有提交个人 API Key、日志快照或截图中的隐私数据
- 文档与界面行为一致

## 已知工程约束

- 背景刷新是 best-effort 行为，不能保证严格在固定时间触发
- 当前项目仍是实验性质，界面与算法会继续迭代
- 如果你修改了 Target、资源分组或测试目标，请同步更新 Xcode 工程配置
- `LottomindUITests` 目标目前保留为手动验证入口，不纳入默认共享 Scheme
