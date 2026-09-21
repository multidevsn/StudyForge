import SwiftUI
import Charts

struct ProgressViewScreen: View {
    @Environment(StudyStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    summary
                    weeklyChart
                    breakdown
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Progress")
        }
    }

    private var summary: some View {
        HStack(spacing: 12) {
            MetricCard(title: "This week", value: "(store.weeklyMetrics().reduce(0) { $0 + $1.minutes })m", icon: "chart.line.uptrend.xyaxis")
            MetricCard(title: "Streak", value: "(store.streak)d", icon: "flame.fill")
        }
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Focus minutes").font(.headline)
            Chart(store.weeklyMetrics()) { metric in
                BarMark(
                    x: .value("Day", metric.date, unit: .day),
                    y: .value("Minutes", metric.minutes)
                )
                .foregroundStyle(StudyForgeTheme.violet.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .frame(height: 220)
            .chartYAxis { AxisMarks(position: .leading) }
            .chartXAxis { AxisMarks(values: .stride(by: .day)) { value in AxisValueLabel(format: .dateTime.weekday(.narrow)) } }
        }
        .frostCard()
    }

    private var breakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By subject").font(.headline)
            ForEach(store.subjectMetrics(), id: .0.id) { pair in
                let subject = pair.0
                let minutes = pair.1
                HStack {
                    Image(systemName: subject.symbol).foregroundStyle(StudyForgeTheme.violet)
                    Text(subject.name)
                    Spacer()
                    Text("(minutes)m").monospacedDigit().foregroundStyle(.secondary)
                }
            }
        }
        .frostCard()
    }
}
