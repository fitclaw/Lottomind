# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- MIT license, public README, security policy, code of conduct and maintainer-facing docs
- GitHub issue templates and PR template for open-source collaboration
- Reconstructed Xcode project metadata so the repository can be opened and built directly

### Changed

- Replaced private bundle-style identifiers with neutral open-source identifiers
- Rewrote privacy and responsible-use copy to match the app's actual network and storage behavior
- Refocused contributing guidance on public collaboration instead of internal workflow notes

### Removed

- Internal planning, AI workflow and development-log documents that were not suitable for public release
- Personal signature lines from template-generated test files

## [1.0.0] - 2026-03-04

### Added

- Initial SwiftUI iOS app with dashboard, analysis, explore, backtest, ledger and settings flows
- SwiftData-backed local storage for draws, recommendations and user ledger records
- Multi-provider AI API integration for fetching lottery draw information
- Algorithm modules for hot/cold analysis, jackpot pressure, sequence decay, combo structure and anomaly detection
