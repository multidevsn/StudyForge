import SwiftUI

struct TodayView: View {
    @Environment(StudyStore.self) private var store
    @State private var showingAddTask = false
    @State private var showingFocus = false

    private var dateTitle: String {
        Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    metrics
                    focusCTA
                    tasksSection
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Today")
            .sheet(isPresented: $showingAddTask) { AddTaskSheet() }
            .sheet(isPresented: $showingFocus) { FocusView(presentedAsSheet: true) }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("StudyForge")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(StudyForgeTheme.violet)
            Text("Build momentum, not pressure.")
                .font(.largeTitle.weight(.bold))
            Text(dateTitle)
                .foregroundStyle(.secondary)
        }
    }

    private var metrics: some View {
        HStack(spacing: 12) {
            MetricCard(title: "Focus", value: "(store.focusMinutesToday)m", icon: "bolt.fill")
            MetricCard(title: "Streak", value: "(store.streak)d", icon: "flame.fill")
            MetricCard(title: "Done", value: "(store.completedTasksCount)", icon: "checkmark.circle.fill")
        }
    }

    private var focusCTA: some View {
        Button {
            showingFocus = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Deep focus").font(.headline)
                    Text("A focused session. One subject. No noise.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "play.fill")
                    .font(.headline)
                    .frame(width: 48, height: 48)
                    .background(StudyForgeTheme.violet, in: Circle())
                    .foregroundStyle(.white)
            }
            .frostCard()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start a focus session")
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today’s tasks").font(.title3.weight(.bold))
                Spacer()
                Button { showingAddTask = true } label: { Image(systemName: "plus") }
                    .buttonStyle(.borderedProminent)
                    .tint(StudyForgeTheme.violet)
                    .accessibilityLabel("Add task")
            }
            if store.todayTasks.isEmpty {
                ContentUnavailableView("You’re clear", systemImage: "checkmark.circle", description: Text("No tasks due today."))
                    .frame(maxWidth: .infinity)
                    .frostCard()
            } else {
                ForEach(store.todayTasks) { task in
                    TaskRow(task: task)
                }
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(StudyForgeTheme.violet)
            Text(value).font(.title2.weight(.bold).monospacedDigit())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frostCard()
    }
}

struct TaskRow: View {
    @Environment(StudyStore.self) private var store
    let task: StudyTask

    var body: some View {
        Button { store.toggleTask(task.id) } label: {
            HStack(spacing: 12) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    if let subject = store.subject(for: task.subjectID) {
                        Text(subject.name).font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if task.priority == .high {
                    Image(systemName: "flag.fill").foregroundStyle(.orange)
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.isCompleted ? "Completed (task.title)" : "Mark (task.title) complete")
    }
}
