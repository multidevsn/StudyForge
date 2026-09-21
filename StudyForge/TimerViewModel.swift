import Foundation
import Observation

@MainActor
@Observable
final class TimerViewModel {
    private(set) var remainingSeconds: Int
    private(set) var isRunning = false
    private(set) var startedAt: Date?
    private(set) var endDate: Date?
    private(set) var completionCount = 0

    let defaultMinutes: Int
    var selectedMinutes: Int
    var subjectID: UUID?

    private var ticker: Task<Void, Never>?

    init(defaultMinutes: Int = 25) {
        self.defaultMinutes = max(1, defaultMinutes)
        self.selectedMinutes = max(1, defaultMinutes)
        self.remainingSeconds = max(1, defaultMinutes) * 60
    }

    var progress: Double {
        let total = max(1, selectedMinutes * 60)
        return 1 - Double(remainingSeconds) / Double(total)
    }

    var displayTime: String {
        String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
    }

    func start() {
        guard !isRunning else { return }
        if remainingSeconds <= 0 || remainingSeconds == selectedMinutes * 60 {
            startedAt = Date()
            endDate = Date().addingTimeInterval(TimeInterval(selectedMinutes * 60))
        } else {
            endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        }
        isRunning = true
        refresh()
        ticker?.cancel()
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { break }
                await MainActor.run { self?.refresh() }
            }
        }
    }

    func pause() {
        refresh()
        isRunning = false
        endDate = nil
        ticker?.cancel()
        ticker = nil
    }

    func stop() {
        isRunning = false
        endDate = nil
        startedAt = nil
        ticker?.cancel()
        ticker = nil
        remainingSeconds = selectedMinutes * 60
    }

    func refresh() {
        guard isRunning, let endDate else { return }
        remainingSeconds = max(0, Int(ceil(endDate.timeIntervalSinceNow)))
        if remainingSeconds == 0 {
            isRunning = false
            ticker?.cancel()
            ticker = nil
            completionCount += 1
        }
    }

    func configure(minutes: Int) {
        guard !isRunning else { return }
        selectedMinutes = max(1, minutes)
        remainingSeconds = selectedMinutes * 60
        startedAt = nil
        endDate = nil
    }

    deinit { ticker?.cancel() }
}
