import SwiftUI

@main
struct StudyForgeApp: App {
    @State private var store = StudyStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(store)
                .preferredColorScheme(nil)
        }
    }
}
