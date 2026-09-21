# Testing StudyForge from Windows

Windows can trigger the GitHub Actions build and download the Simulator artifact.

## Workflow
1. Push to `main` or start **Actions → iOS Build & Tests → Run workflow**.
2. Wait for the macOS jobs to finish.
3. Download **StudyForge-iOS-Simulator** from the run's Artifacts section.
4. The artifact includes `StudyForge-Simulator.app.zip` and `xcodebuild.log`.

## Limitation
Windows cannot run the iOS Simulator locally. The Simulator app requires macOS/Xcode.

A signed `.ipa` for a physical iPhone is a separate step requiring Apple signing credentials.
