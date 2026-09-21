import SwiftUI

struct AddTaskSheet: View {
    @Environment(StudyStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var priority: StudyTask.Priority = .normal
    @State private var dueDate = Date()
    @State private var subjectID: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Task") {
                    TextField("What needs to get done?", text: $title)
                    Picker("Priority", selection: $priority) {
                        ForEach(StudyTask.Priority.allCases) { Text($0.label).tag($0) }
                    }
                    DatePicker("Due", selection: $dueDate, displayedComponents: [.date])
                }
                Section("Subject") {
                    Picker("Subject", selection: $subjectID) {
                        Text("Choose subject").tag(UUID?.none)
                        ForEach(store.subjects) { subject in
                            Label(subject.name, systemImage: subject.symbol).tag(Optional(subject.id))
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let firstSubject = store.subjects.first else { return }
                        store.addTask(title: title, subjectID: subjectID ?? firstSubject.id, priority: priority, dueDate: dueDate)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || store.subjects.isEmpty)
                }
            }
            .onAppear { subjectID = store.subjects.first?.id }
        }
    }
}
