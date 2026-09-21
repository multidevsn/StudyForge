import XCTest
@testable import StudyForge

@MainActor
final class StudyForgeCoreTests: XCTestCase {
    func testTaskCRUDAndCompletion() {
        let store = StudyStore(loadSeed: false)
        store.addSubject(name: "Math", symbol: "function")
        let subjectID = try! XCTUnwrap(store.subjects.first?.id)
        store.addTask(title: "Limits", subjectID: subjectID, priority: .high, dueDate: Date())
        XCTAssertEqual(store.tasks.count, 1)
        let id = try! XCTUnwrap(store.tasks.first?.id)
        XCTAssertFalse(store.tasks[0].isCompleted)
        store.toggleTask(id)
        XCTAssertTrue(store.tasks[0].isCompleted)
        store.deleteTask(id)
        XCTAssertTrue(store.tasks.isEmpty)
    }

    func testProgressAggregation() {
        let store = StudyStore(loadSeed: false)
        store.addSubject(name: "Physics", symbol: "atom")
        let subjectID = try! XCTUnwrap(store.subjects.first?.id)
        store.recordCompletedFocus(subjectID: subjectID, durationMinutes: 25, startedAt: Date())
        store.recordCompletedFocus(subjectID: subjectID, durationMinutes: 45, startedAt: Date())
        XCTAssertEqual(store.focusMinutesToday, 70)
        XCTAssertEqual(store.subjectMetrics().first?.1, 70)
    }

    func testWeeklyMetricsHasSevenDays() {
        let store = StudyStore(loadSeed: false)
        XCTAssertEqual(store.weeklyMetrics().count, 7)
    }
}
