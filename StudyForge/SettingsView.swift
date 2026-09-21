import SwiftUI

struct SettingsView: View {
    @Environment(StudyStore.self) private var store
    @AppStorage("StudyForge.defaultMinutes") private var defaultMinutes = 25
    @AppStorage("StudyForge.notifications") private var notifications = true
    @State private var showingReset = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Focus") {
                    Stepper("Default: (defaultMinutes) minutes", value: $defaultMinutes, in: 5...120, step: 5)
                    Toggle("Completion notifications", isOn: $notifications)
                }
                Section("Data") {
                    Button("Reset local data", role: .destructive) { showingReset = true }
                }
                Section {
                    LabeledContent("StudyForge", value: "1.0")
                    Text("Your tasks, subjects, and focus history stay on this device.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Reset all local data?", isPresented: $showingReset) {
                Button("Reset", role: .destructive) { store.reset() }
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
}
