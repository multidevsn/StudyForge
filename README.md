# StudyForge iOS

StudyForge is an offline-first SwiftUI study cockpit with Today, Focus, Subjects, Progress and Settings.

## Features
- Native SwiftUI iPhone app
- Local Codable persistence
- Absolute-end-date focus timer
- Task and subject CRUD
- Weekly focus analytics
- Light/dark mode
- Accessibility labels
- Swift core unit tests
- GitHub Actions macOS build

## Bundle
`com.novix777.studyforge`

## Build
Open `StudyForge.xcodeproj` in Xcode on macOS and run the StudyForge scheme on an iOS Simulator.

## CI
`.github/workflows/ios-build.yml` runs core tests and builds an unsigned iOS Simulator app. The simulator artifact is published by GitHub Actions.

## Windows
See `WINDOWS-TESTING.md`.
