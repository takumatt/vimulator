# Vimulator Project Instructions

## README

Update README.md whenever features are added, changed, or removed.

- New feature → add to the Features table or Customization section
- Option / property change → update the relevant code example
- Removal / breaking change → remove or correct the description

Verify README is up to date before committing.

## Commits

- Commit frequently
- Commit messages in English
- Never commit `xcuserdata/`, `*.xcuserstate`, or `.DS_Store`

## Testing

Run tests on the iOS simulator via xcodebuild (not `swift test` — UIKit requires the simulator):

```sh
xcodebuild test \
  -scheme Vimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

- Performance baselines are in `measure {}` blocks — compare before/after when changing scanner or overlay code
- Tests use plain `UIView` with explicit accessibility traits instead of `UIButton`, because `UIButton.isAccessibilityElement` returns false outside a window in iOS 26

## Code style

- 2-space indentation
- All code guarded by `#if targetEnvironment(simulator)`
