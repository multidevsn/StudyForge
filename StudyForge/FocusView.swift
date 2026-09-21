import SwiftUI

struct FocusView: View {
    @Environment(StudyStore.self) private var store
    @State private var timer = TimerViewModel()
    @State private var selectedSubjectID: UUID?
    @State private var showCompletion = false
    @State private var presentedAsSheet: Bool

    init(presentedAsSheet: Bool = false) {
        _presentedAsSheet = State(initialValue: presentedAsSheet)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    subjectPicker
                    timerCard
                    presets
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Focus")
            .toolbar {
                if presentedAsSheet {
                    ToolbarItem(placement: .cancellationAction) { DismissButton() }
                }
            }
            .alert("Session complete", isPresented: $showCompletion) {
                Button("Done") { }
            } message: {
                Text("Nice work. Your focus time has been added to Progress.")
            }
            .onAppear {
                selectedSubjectID = selectedSubjectID ?? store.subjects.first?.id
                timer.subjectID = selectedSubjectID
                timer.refresh()
            }
            .onChange(of: timer.completionCount) { _, _ in
                guard let subjectID = timer.subjectID, let startedAt = timer.startedAt else { return }
                store.recordCompletedFocus(subjectID: subjectID, durationMinutes: timer.selectedMinutes, startedAt: startedAt)
                showCompletion = true
            }
        }
    }

    private var subjectPicker: some View {
        Picker("Subject", selection: $selectedSubjectID) {
            ForEach(store.subjects) { subject in
                Text(subject.name).tag(Optional(subject.id))
            }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedSubjectID) { _, newValue in
            timer.subjectID = newValue
        }
    }

    private var timerCard: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(StudyForgeTheme.violet.opacity(0.14), lineWidth: 20)
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(StudyForgeTheme.violet, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: timer.progress)

                VStack(spacing: 6) {
                    Text(timer.displayTime)
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text(timer.isRunning ? "In focus" : "Ready")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 270, height: 270)

            HStack(spacing: 12) {
                Button(timer.isRunning ? "Pause" : "Start") {
                    if timer.isRunning {
                        timer.pause()
                    } else {
                        timer.start()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(StudyForgeTheme.violet)
                .controlSize(.large)

                Button("Reset") { timer.stop() }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(timer.isRunning)
            }
        }
        .frostCard()
    }

    private var presets: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session length").font(.headline)
            HStack {
                ForEach([15, 25, 45, 60], id: .self) { minutes in
                    Button("(minutes)m") { timer.configure(minutes: minutes) }
                        .buttonStyle(.bordered)
                        .disabled(timer.isRunning)
                }
            }
        }
    }
}

private struct DismissButton: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View { Button("Done") { dismiss() } }
}
