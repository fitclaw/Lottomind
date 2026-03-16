# Architecture

`LottoMind` is a monolithic iOS app with no private backend. The app handles local persistence, UI rendering, scoring logic, and direct communication with external AI providers.

## Core Layers

### App Layer

- `App/LottoMindApp.swift`
- Entry point, SwiftData container setup, and background-task registration

### Model Layer

- `Models/LotteryDraw.swift`
- `Models/Recommendation.swift`
- `Models/UserRecord.swift`

These models are persisted with SwiftData.

### Service Layer

- `Services/DataFetcher/AIAPIClient.swift`
- `Services/DataFetcher/AIDataFetcher.swift`
- `Services/DataFetcher/DataParser.swift`
- `Services/BackgroundTaskManager.swift`
- `Services/NotificationManager.swift`

Responsibilities include:

- Reading and saving the local API key
- Calling external AI-provider APIs
- Parsing responses into structured draw data
- Scheduling background refresh and local notifications

### Algorithm Layer

- `Services/AlgorithmEngine/*`

Current modules include:

- Hot-number avoidance
- Jackpot pressure
- Sequence decay
- Combo structure
- Anomaly detection
- Fusion scoring

### ViewModel Layer

- `ViewModels/*`

These classes adapt SwiftData and service results into UI-facing state.

### View Layer

- `Views/*`
- `Theme/*`

SwiftUI screens, shared UI components, and design tokens live here.

## Data Flow

1. The user saves an API key in Settings.
2. The dashboard or a background task triggers refresh.
3. `AIDataFetcher` calls an external provider through `AIAPIClient`.
4. `DataParser` converts the response into `LotteryDraw`.
5. The algorithm engine derives `Recommendation` objects from historical data.
6. SwiftData persists the results and ViewModels refresh the UI.

## Design Principles

- No real secrets committed to the repository
- No dependence on a private backend
- Local-first defaults
- Explicit limits on exaggerated prediction claims
- Clear separation between networking, scoring, and UI state
