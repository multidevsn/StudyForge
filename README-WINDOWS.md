# StudyForge depuis Windows

GitHub Actions utilise un runner macOS pour compiler l'app iOS Simulator.

1. Lance **Actions → iOS Build & Tests → Run workflow** ou pousse sur `main`.
2. Ouvre une exécution terminée.
3. Télécharge l'artefact **StudyForge-iOS-Simulator**.
4. L'artefact contient `StudyForge-Simulator.app.zip` et `xcodebuild.log`.

Windows peut déclencher la CI et télécharger le build, mais l'iOS Simulator nécessite macOS + Xcode.

Un `.ipa` pour un vrai iPhone nécessite une signature Apple et n'est pas généré par cette CI non signée.
