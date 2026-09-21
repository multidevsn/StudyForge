import SwiftUI

struct SubjectsView: View {
    @Environment(StudyStore.self) private var store
    @State private var showAdd = false
    @State private var subjectToDelete: Subject?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.subjects) { subject in
                    NavigationLink {
                        SubjectDetailView(subject: subject)
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: subject.symbol)
                                .frame(width: 40, height: 40)
                                .background(StudyForgeTheme.violet.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(subject.name).font(.headline)
                                let count = store.tasks.filter { $0.subjectID == subject.id && $0.isCompleted }.count
                                Text("(count) completed tasks").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .swipeActions {
                        Button(role: .destructive) { subjectToDelete = subject } label: { Label("Delete", systemImage: "trash") }
                    }
                }
            }
            .navigationTitle("Subjects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add subject")
                }
            }
            .sheet(isPresented: $showAdd) { AddSubjectSheet() }
            .confirmationDialog("Delete subject?", item: $subjectToDelete) { subject in
                Button("Delete", role: .destructive) { store.deleteSubject(subject.id) }
            } message: { subject in
                Text("Tasks and focus sessions for (subject.name) will also be removed.")
            }
        }
    }
}

struct SubjectDetailView: View {
    @Environment(StudyStore.self) private var store
    let subject: Subject

    var body: some View {
        List {
            Section("Focus") {
                let minutes = store.sessions.filter { $0.subjectID == subject.id && $0.completed }.reduce(0) { $0 + $1.durationMinutes }
                LabeledContent("Minutes", value: "(minutes)")
            }
            Section("Tasks") {
                let items = store.tasks.filter { $0.subjectID == subject.id }
                ForEach(items) { task in TaskRow(task: task) }
            }
        }
        .navigationTitle(subject.name)
    }
}

struct AddSubjectSheet: View {
    @Environment(StudyStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var symbol = "book"

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("SF Symbol", text: $symbol)
            }
            .navigationTitle("New Subject")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { store.addSubject(name: name, symbol: symbol); dismiss() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
