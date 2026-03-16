# Development

## Requirements

- macOS
- Xcode 16 or newer
- An iOS 17+ simulator or device

## Run Locally

1. Open `Lottomind/Lottomind.xcodeproj`.
2. Select the `Lottomind` scheme.
3. If you build for a device, configure your own Development Team.
4. Run the app.

## Command-Line Checks

Build:

```bash
xcodebuild build \
  -project Lottomind/Lottomind.xcodeproj \
  -scheme Lottomind \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

Test:

```bash
xcodebuild test \
  -project Lottomind/Lottomind.xcodeproj \
  -scheme Lottomind \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

If that simulator is not available, replace it with any local iOS 17+ iPhone simulator.

## Network-Dependent Features

- The project does not use an official draw-data SDK.
- Draw sync depends on external AI providers and response formatting.
- Without an API key, the app can still present local content and static UI flows, but it cannot fetch fresh draw data.

## Before You Submit

- Local build passes
- The default shared scheme tests pass
- No API keys, logs, or screenshots with personal data are committed
- Docs and UI copy match the current behavior

## Current Constraints

- Background refresh is best-effort, not guaranteed to run at an exact time
- The project remains experimental and will continue to evolve
- `LottomindUITests` is currently kept as a manual validation target rather than part of the default shared scheme
