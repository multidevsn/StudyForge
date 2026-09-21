import Foundation

struct Subject: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var symbol: String
    var accentHex: String
    var colorSeed: Int
}

struct StudyTask: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var subjectID: UUID
    var dueDate: Date
    var isCompleted: Bool
    var priority: Priority

    enum Priority: String, Codable, CaseIterable, Identifiable {
        case low, normal, high
        var id: String { rawValue }
        var label: String {
            switch self { case .low: "Low"; case .normal: "Normal"; case .high: "High" }
        }
    }
}

struct FocusSession: Identifiable, Codable, Hashable {
    var id: UUID
    var subjectID: UUID
    var startedAt: Date
    var durationMinutes: Int
    var completed: Bool
}

struct StudySnapshot: Codable {
    var subjects: [Subject]
    var tasks: [StudyTask]
    var sessions: [FocusSession]
}

struct DailyMetric: Identifiable, Hashable {
    let id: Date
    let date: Date
    let minutes: Int
}
