# Architecture

`LottoMind` 是一个单体 iOS App，没有自建后端。应用侧负责本地数据存储、界面渲染、算法评分和与外部 AI 服务商的直接通信。

## 核心层次

### App 层

- `App/LottoMindApp.swift`
- 负责 App 入口、SwiftData 容器注入和后台任务注册

### 数据模型层

- `Models/LotteryDraw.swift`
- `Models/Recommendation.swift`
- `Models/UserRecord.swift`

使用 SwiftData 持久化开奖数据、推荐结果和手动账本记录。

### 服务层

- `Services/DataFetcher/AIAPIClient.swift`
- `Services/DataFetcher/AIDataFetcher.swift`
- `Services/DataFetcher/DataParser.swift`
- `Services/BackgroundTaskManager.swift`
- `Services/NotificationManager.swift`

职责包括：

- 读取和保存本地 API Key
- 调用外部 AI 服务商接口
- 将响应解析为结构化开奖数据
- 调度后台刷新和本地通知

### 算法层

- `Services/AlgorithmEngine/*`

当前包含多个评分模块：

- 热号回避
- 奖池压力
- 序列衰减
- 组合结构
- 反常突变
- 融合评分

### 视图模型层

- `ViewModels/*`

负责把 SwiftData 与服务层结果整理为界面可消费状态。

### 视图层

- `Views/*`
- `Theme/*`

负责 SwiftUI 页面、组件和设计 token。

## 数据流

1. 用户在设置页保存自己的 AI API Key。
2. 仪表盘或后台任务触发数据刷新。
3. `AIDataFetcher` 通过 `AIAPIClient` 向所选服务商发起请求。
4. `DataParser` 将响应转成 `LotteryDraw`。
5. 算法引擎根据历史数据生成 `Recommendation`。
6. SwiftData 存储结果，ViewModel 重新加载并刷新 UI。

## 设计原则

- 不在仓库中存储任何真实密钥
- 不依赖私有后端
- 默认本地优先
- 对“预测”“必中”等夸大表述做显式限制
- 将网络获取、算法计算和界面状态解耦
