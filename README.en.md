<p align="center">
  <a href="./README.md"><strong>简体中文</strong></a> · <a href="./README.en.md"><strong>English</strong></a>
</p>

<p align="center">
  <img src="docs/assets/github-banner.svg" alt="LottoMind banner" width="100%" />
</p>

<p align="center">
  <a href="https://github.com/fitclaw/Lottomind/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/fitclaw/Lottomind/ci.yml?branch=main&label=CI&style=for-the-badge" alt="CI" /></a>
  <a href="https://github.com/fitclaw/Lottomind/blob/main/LICENSE"><img src="https://img.shields.io/github/license/fitclaw/Lottomind?style=for-the-badge" alt="License" /></a>
  <img src="https://img.shields.io/badge/iOS-17%2B-0A84FF?style=for-the-badge" alt="iOS 17+" />
  <img src="https://img.shields.io/badge/Swift-5-orange?style=for-the-badge" alt="Swift 5" />
</p>

# LottoMind

`LottoMind` is a local-first iOS 17+ experimental app for lottery history analysis, including draw fetching, statistical scoring, backtesting, heatmaps, and a personal ledger.

## Repository Positioning

- Released under the `MIT` license
- No repository-level API keys, passwords, or personal contact details
- API keys and app data are stored locally by default
- No ticket purchasing or brokerage features
- Friendly to both Chinese-speaking and English-speaking contributors

## Features

- Dashboard for latest draw, recommendations, and jackpot pressure
- Analysis view for module scores and explanations
- Explore view for hot/cold numbers and heatmaps
- Backtest view for historical performance
- Ledger view for manually tracked purchases and results
- Settings for lottery type, notifications, local data reset, and AI API key management

## Highlights

- Local-first architecture without a private backend
- Multi-module scoring engine for pattern analysis
- Open-source ready repository setup with CI, issue templates, PR template, and support docs
- Public-release friendly cleanup of secrets, personal identifiers, and internal-only process documents

## Stack

- SwiftUI
- SwiftData
- BackgroundTasks
- UserNotifications
- XCTest / Testing

## Data And Privacy

- This project does not ship with a private backend.
- User-provided API keys are stored locally in Keychain by default.
- When sync is triggered, requests go directly to the selected AI provider.
- Draw fetching depends on external AI providers and public web results, so delays and inaccuracies are possible.

See [Responsible Use](./docs/RESPONSIBLE_USE.en.md) for more context.

## Quick Start

1. Open `Lottomind/Lottomind.xcodeproj` with Xcode 16 or later.
2. Pick an iOS 17+ simulator, or configure your own Development Team for device builds.
3. Run the app.
4. Add your own AI API key in Settings if you want live data sync.

## Test

```bash
xcodebuild test \
  -project Lottomind/Lottomind.xcodeproj \
  -scheme Lottomind \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

If `iPhone 16` is not available locally, replace it with any available iOS 17+ iPhone simulator.

The default shared scheme currently includes the stable unit-test target only. `LottomindUITests` remains in the project for manual Xcode sessions and future refinement.

## Quick Links

- 中文说明: [README.md](./README.md)
- Architecture: [docs/ARCHITECTURE.en.md](./docs/ARCHITECTURE.en.md)
- Development: [docs/DEVELOPMENT.en.md](./docs/DEVELOPMENT.en.md)
- Responsible Use: [docs/RESPONSIBLE_USE.en.md](./docs/RESPONSIBLE_USE.en.md)
- Support: [SUPPORT.md](./SUPPORT.md)
- Contributing: [CONTRIBUTING.md](./CONTRIBUTING.md)
- Security: [SECURITY.md](./SECURITY.md)
- Code of Conduct: [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)
- Changelog: [CHANGELOG.md](./CHANGELOG.md)

## Collaboration Notes

- Issues and PRs are welcome in either Chinese or English
- Mixed-language docs are acceptable if they stay clear and maintainable
- Please use the provided templates when reporting bugs, asking questions, or discussing security-sensitive topics

## Known Limits

- The current version still relies on general AI APIs instead of an official draw-data SDK
- Background refresh is best-effort and not guaranteed at an exact time
- Recommendations are for historical analysis and UI experimentation only, not guaranteed outcomes or financial advice
