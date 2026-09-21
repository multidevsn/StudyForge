import Foundation
import Observation

@MainActor
@Observable
final class StudyStore {
    private(set) var subjects: [Subject] = []
    private(set) var tasks: [StudyTask] = []
    private(set) var sessions: [FocusSession] = []

    private let storageKey = "StudyForge.snapshot.v1"
    private let calendar = Calendar.current

    init(loadSeed: Bool = true) {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let snapshot = try? JSONDecoder().decode(StudySnapshot.self, from: data) {
            subjects = snapshot.subjects
            tasks = snapshot.tasks
            sessions = snapshot.sessions
        } else if loadSeed {
            seed()
        }
    }

    var todayTasks: [StudyTask] {
        tasks.filter { calendar.isDateInToday($0.dueDate) }.sorted { a, b in
            if a.isCompleted != b.isCompleted { return !a.isCompleted && b.isCompleted }
            if a.priority != b.priority { return a.priority.rank > b.priority.rank }
            return a.dueDate < b.dueDate
        }
    }

    var completedTasksCount: Int { tasks.filter(\.isCompleted).count }

    var focusMinutesToday: Int {
        sessions.filter { calendar.isDateInToday($0.startedAt) && $0.completed }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    var streak: Int {
        var count = 0
        var cursor = calendar.startOfDay(for: Date())
        while hasActivity(on: cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    func subject(for id: UUID) -> Subject? { subjects.first { $0.id == id } }

    func addTask(title: String, subjectID: UUID, priority: StudyTask.Priority, dueDate: Date) {
        let task = StudyTask(id: UUID(), title: title.trimmingCharacters(in: .whitespacesAndNewlines), subjectID: subjectID, dueDate: dueDate, isCompleted: false, priority: priority)
        guard !task.title.isEmpty else { return }
        tasks.append(task)
        persist()
    }

    func toggleTask(_ id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
        persist()
    }

    func deleteTask(_ id: UUID) {
        tasks.removeAll { $0.id == id }
        persist()
    }

    func addSubject(name: String, symbol: String, accentHex: String = "#7C5CFC") {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        subjects.append(Subject(id: UUID(), name: trimmed, symbol: symbol, accentHex: accentHex, colorSeed: subjects.count))
        persist()
    }

    func deleteSubject(_ id: UUID) {
        guard subjects.count > 1 else { return }
        subjects.removeAll { $0.id == id }
        tasks.removeAll { $0.subjectID == id }
        sessions.removeAll { $0.subjectID == id }
        persist()
    }

    func recordCompletedFocus(subjectID: UUID, durationMinutes: Int, startedAt: Date) {
        guard durationMinutes > 0 else { return }
        sessions.append(FocusSession(id: UUID(), subjectID: subjectID, startedAt: startedAt, durationMinutes: durationMinutes, completed: true))
        persist()
    }

    func weeklyMetrics() -> [DailyMetric] {
        let start = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            let minutes = sessions.filter { calendar.isDate($0.startedAt, inSameDayAs: day) && $0.completed }
                .reduce(0) { $0 + $1.durationMinutes }
            return DailyMetric(id: day, date: day, minutes: minutes)
        }
    }

    func subjectMetrics() -> [(Subject, Int)] {
        subjects.map { subject in
            let minutes = sessions.filter { $0.subjectID == subject.id && $0.completed }
                .reduce(0) { $0 + $1.durationMinutes }
            return (subject, minutes)
        }.sorted { $0.1 > $1.1 }
    }

    func reset() {
        subjects = []
        tasks = []
        sessions = []
        UserDefaults.standard.removeObject(forKey: storageKey)
        seed()
    }

    private func hasActivity(on day: Date) -> Bool {
        let didTask = tasks.contains { $0.isCompleted && calendar.isDate($0.dueDate, inSameDayAs: day) }
        let didFocus = sessions.contains { $0.completed && calendar.isDate($0.startedAt, inSameDayAs: day) }
        return didTask || didFocus
    }

    private func persist() {
        let snapshot = StudySnapshot(subjects: subjects, tasks: tasks, sessions: sessions)
        if let data = try? JSONEncoder().encode(snapshot) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func seed() {
        subjects = [
            Subject(id: UUID(), name: "Mathematics", symbol: "function", accentHex: "#7C5CFC", colorSeed: 0),
            Subject(id: UUID(), name: "Physics", symbol: "atom", accentHex: "#22C55E", colorSeed: 1),
            Subject(id: UUID(), name: "Computer Science", symbol: "terminal", accentHex: "#F59E0B", colorSeed: 2)
        ]
        let today = calendar.startOfDay(for: Date())
        tasks = [
            StudyTask(id: UUID(), title: "Finish limits exercise set", subjectID: subjects[0].id, dueDate: today, isCompleted: false, priority: .high),
            StudyTask(id: UUID(), title: "Review kinematics formulas", subjectID: subjects[1].id, dueDate: today, isCompleted: false, priority: .normal),
            StudyTask(id: UUID(), title: "Practice arrays in C", subjectID: subjects[2].id, dueDate: today, isCompleted: true, priority: .normal)
        ]
        sessions = []
        persist()
    }
}

private extension StudyTask.Priority {
    var rank: Int {
        switch self { case .low: 0; case .normal: 1; case .high: 2 }
    }
}
