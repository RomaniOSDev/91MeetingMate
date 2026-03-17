//
//  MeetingStatsView.swift
//  91MeetingMate
//
//  Tab: analytics — KPI cards, meetings by weekday, task status pie.
//

import SwiftUI

struct MeetingStatsView: View {
    @ObservedObject var viewModel: MeetingViewModel

    private let weekdayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private var maxMeetings: Int {
        viewModel.meetingsByWeekday.values.max() ?? 1
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Analytics")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.meetingDeep)
                        kpiSection
                        meetingsByWeekdaySection
                        taskStatusSection
                        NavigationLink {
                            ParticipantStatsView(viewModel: viewModel)
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.meetingAccent.opacity(0.2), Color.meetingAccent.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "person.2.fill")
                                        .font(.title3)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color.meetingAccent, Color.meetingDeep],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Participants")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.meetingDeep)
                                    Text("View participant statistics")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color.meetingAccent)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.meetingDeep.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.meetingAccent.opacity(0.2), Color.meetingDeep.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.meetingBackground, for: .navigationBar)
        }
    }

    private var kpiSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .foregroundStyle(Color.meetingDeep)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                kpiCard(title: "Total meetings", value: "\(viewModel.totalMeetingsCount)", icon: "doc.text")
                kpiCard(title: "Completed tasks", value: "\(viewModel.completedTasksCount)", icon: "checkmark.circle")
                kpiCard(title: "Active tasks", value: "\(viewModel.activeTasksCount)", icon: "list.bullet")
                kpiCard(title: "Participants", value: "\(viewModel.uniqueParticipantsCount)", icon: "person.2")
            }
        }
    }

    private func kpiCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.meetingAccent.opacity(0.2), Color.meetingAccent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.meetingAccent.opacity(0.3), radius: 6, x: 0, y: 3)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.meetingAccent, Color.meetingDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingDeep, Color.meetingAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.meetingAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.1), radius: 10, x: 0, y: 5)
                .shadow(color: Color.meetingDeep.opacity(0.05), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.meetingAccent.opacity(0.2), Color.meetingDeep.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var meetingsByWeekdaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Meetings by day")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingDeep, Color.meetingAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(0..<7, id: \.self) { day in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color.meetingAccent, Color.meetingDeep],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: barHeight(day: day))
                            .shadow(color: Color.meetingAccent.opacity(0.4), radius: 6, x: 0, y: 3)
                        Text(weekdayLabels[day])
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.meetingDeep)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.meetingDeep.opacity(0.08), radius: 10, x: 0, y: 4)
            )
            .frame(height: 140)
        }
    }

    private func barHeight(day: Int) -> CGFloat {
        let count = viewModel.meetingsByWeekday[day] ?? 0
        guard maxMeetings > 0 else { return 4 }
        return max(4, CGFloat(count) / CGFloat(maxMeetings) * 80)
    }

    private var taskStatusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tasks by status")
                .font(.headline)
                .foregroundStyle(Color.meetingDeep)
            let total = viewModel.allTasks.count
            if total == 0 {
                Text("No tasks yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                TaskStatusPieChart(viewModel: viewModel)
                    .frame(height: 180)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        let count = viewModel.taskCountByStatus[status] ?? 0
                        HStack {
                            Circle()
                                .fill(statusColor(status))
                                .frame(width: 10, height: 10)
                            Text(status.rawValue)
                                .font(.caption)
                                .foregroundStyle(Color.meetingDeep)
                            Spacer()
                            Text("\(count)")
                                .font(.caption)
                                .foregroundStyle(Color.meetingAccent)
                        }
                    }
                }
            }
        }
    }

    private func statusColor(_ status: TaskStatus) -> Color {
        switch status {
        case .notStarted: return Color.meetingAccent.opacity(0.5)
        case .inProgress: return Color.meetingAccent
        case .completed: return Color.meetingAccent
        case .blocked: return Color.meetingDeep
        }
    }
}

// MARK: - Simple pie chart using Path

struct TaskStatusPieChart: View {
    @ObservedObject var viewModel: MeetingViewModel

    var body: some View {
        let total = viewModel.allTasks.count
        guard total > 0 else {
            return AnyView(EmptyView())
        }
        let statuses = TaskStatus.allCases
        let counts = statuses.map { viewModel.taskCountByStatus[$0] ?? 0 }
        let colors: [Color] = [
            Color.meetingAccent.opacity(0.6),
            Color.meetingAccent,
            Color.meetingDeep.opacity(0.8),
            Color.meetingDeep
        ]
        
        // Calculate pie slices data
        var slices: [(startAngle: Double, endAngle: Double, color: Color)] = []
        var currentAngle: Double = -90
        for (i, count) in counts.enumerated() where count > 0 {
            let ratio = Double(count) / Double(total)
            let endAngle = currentAngle + ratio * 360
            slices.append((startAngle: currentAngle, endAngle: endAngle, color: colors[i % colors.count]))
            currentAngle = endAngle
        }
        
        return AnyView(
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                ZStack {
                    ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                        PieSlice(startAngle: .degrees(slice.startAngle), endAngle: .degrees(slice.endAngle))
                            .fill(slice.color)
                    }
                }
                .frame(width: size, height: size)
                .position(center)
            }
        )
    }
}

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}
