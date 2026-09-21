import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "house.fill") }
            FocusView()
                .tabItem { Label("Focus", systemImage: "timer") }
            SubjectsView()
                .tabItem { Label("Subjects", systemImage: "books.vertical.fill") }
            ProgressViewScreen()
                .tabItem { Label("Progress", systemImage: "chart.line.uptrend.xyaxis") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(StudyForgeTheme.violet)
    }
}
