//
//  CalendarWeekView.swift
//  91MeetingMate
//
//  Weekly calendar view showing meetings grouped by day.
//

import SwiftUI

struct CalendarWeekView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @State private var currentWeek = Date()
    @State private var selectedMeeting: Meeting?

    private var weekMeetings: [Date: [Meeting]] {
        viewModel.meetingsForWeek(containing: currentWeek)
    }

    private var weekDays: [Date] {
        let cal = Calendar.current
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentWeek)) else {
            return []
        }
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: weekStart) }
    }

    private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {
                        weekHeader
                        weekDaysList
                    }
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.meetingBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button {
                            currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeek) ?? currentWeek
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color.meetingAccent)
                        }
                        Button {
                            currentWeek = Date()
                        } label: {
                            Text("Today")
                                .font(.caption)
                                .foregroundStyle(Color.meetingAccent)
                        }
                        Button {
                            currentWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? currentWeek
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.meetingAccent)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedMeeting) { meeting in
                MeetingDetailView(viewModel: viewModel, meeting: meeting)
            }
        }
    }

    private var weekHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, date in
                VStack(spacing: 6) {
                    Text(dayLabels[index])
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.meetingDeep.opacity(0.7))
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            isToday(date) ?
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.meetingDeep, Color.meetingDeep.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isToday(date) ?
                    LinearGradient(
                        colors: [Color.meetingAccent.opacity(0.15), Color.meetingAccent.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color.white, Color.meetingBackground],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Rectangle()
                        .fill(isToday(date) ? Color.meetingAccent.opacity(0.3) : Color.clear)
                        .frame(height: 3),
                    alignment: .bottom
                )
            }
        }
        .background(Color.white)
        .shadow(color: Color.meetingDeep.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    private var weekDaysList: some View {
        VStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                daySection(date: date)
            }
        }
    }

    private func daySection(date: Date) -> some View {
        let meetings = weekMeetings[Calendar.current.startOfDay(for: date)] ?? []
        let isToday = isToday(date)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(date, style: .date)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        isToday ?
                        LinearGradient(
                            colors: [Color.meetingAccent, Color.meetingDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.meetingDeep, Color.meetingDeep.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                Text("\(meetings.count) meeting\(meetings.count == 1 ? "" : "s")")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: [Color.meetingAccent, Color.meetingDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .shadow(color: Color.meetingAccent.opacity(0.4), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            if meetings.isEmpty {
                Text("No meetings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            } else {
                ForEach(meetings) { meeting in
                    meetingCard(meeting)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.bottom, 8)
    }

    private func meetingCard(_ meeting: Meeting) -> some View {
        Button {
            selectedMeeting = meeting
        } label: {
            HStack(alignment: .top, spacing: 14) {
                VStack(spacing: 4) {
                    Text(meeting.date, style: .time)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(meeting.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 65)
                .padding(.vertical, 8)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.meetingAccent.opacity(0.15), Color.meetingAccent.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(meeting.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.black)
                    if let loc = meeting.location, !loc.isEmpty {
                        Label(loc, systemImage: "location.fill")
                            .font(.caption)
                            .foregroundStyle(Color.meetingAccent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.meetingAccent.opacity(0.1))
                            )
                    }
                    HStack(spacing: 8) {
                        Label("\(meeting.participants.count)", systemImage: "person.2.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.meetingAccent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.meetingAccent.opacity(0.1))
                            )
                        Label("\(meeting.tasks.count)", systemImage: "checklist")
                            .font(.caption2)
                            .foregroundStyle(Color.meetingAccent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.meetingAccent.opacity(0.1))
                            )
                    }
                }
                Spacer()
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.meetingDeep.opacity(0.1), radius: 10, x: 0, y: 5)
                    .shadow(color: Color.meetingDeep.opacity(0.05), radius: 3, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: [Color.meetingAccent.opacity(0.4), Color.meetingAccent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
