//
//  HomeView.swift
//  91MeetingMate
//
//  Beautiful home dashboard with upcoming meetings, quick stats, and actions.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @State private var showAddMeeting = false
    @State private var showSettings = false
    @State private var selectedMeeting: Meeting?

    private var upcomingMeetings: [Meeting] {
        viewModel.meetings
            .filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
            .prefix(5)
            .map { $0 }
    }

    private var todayMeetings: [Meeting] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        return viewModel.meetings.filter { meeting in
            meeting.date >= today && meeting.date < tomorrow
        }.sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.meetingBackground,
                        Color.meetingBackground.opacity(0.5),
                        Color.meetingAccent.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        quickStatsSection
                        todaySection
                        upcomingSection
                        quickActionsSection
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.meetingAccent, Color.meetingDeep],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showAddMeeting) {
                EditMeetingView(viewModel: viewModel, meeting: nil)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
            .navigationDestination(item: $selectedMeeting) { meeting in
                MeetingDetailView(viewModel: viewModel, meeting: meeting)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.meetingDeep, Color.meetingAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Welcome back!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    showAddMeeting = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.meetingAccent, Color.meetingDeep],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.meetingAccent.opacity(0.5), radius: 12, x: 0, y: 6)
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.1), radius: 16, x: 0, y: 8)
                .shadow(color: Color.meetingDeep.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Color.meetingAccent.opacity(0.3), Color.meetingDeep.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingDeep, Color.meetingAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            HStack(spacing: 12) {
                quickStatCard(
                    title: "Today",
                    value: "\(todayMeetings.count)",
                    icon: "calendar",
                    color: Color.meetingAccent
                )
                quickStatCard(
                    title: "Upcoming",
                    value: "\(upcomingMeetings.count)",
                    icon: "clock",
                    color: Color.meetingDeep
                )
                quickStatCard(
                    title: "Tasks",
                    value: "\(viewModel.activeTasksCount)",
                    icon: "checklist",
                    color: Color.meetingAccent
                )
            }
        }
    }

    private func quickStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingDeep, color],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.08), radius: 10, x: 0, y: 5)
                .shadow(color: Color.meetingDeep.opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.2), Color.meetingDeep.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.meetingDeep, Color.meetingAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                if !todayMeetings.isEmpty {
                    Text("\(todayMeetings.count) meeting\(todayMeetings.count == 1 ? "" : "s")")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
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
            }

            if todayMeetings.isEmpty {
                emptyTodayState
            } else {
                ForEach(todayMeetings) { meeting in
                    meetingCard(meeting, isToday: true)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.1), radius: 16, x: 0, y: 8)
                .shadow(color: Color.meetingDeep.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
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

    private var emptyTodayState: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingAccent.opacity(0.6), Color.meetingAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("No meetings scheduled for today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }

    // MARK: - Upcoming Section

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Upcoming")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.meetingDeep, Color.meetingAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                if !upcomingMeetings.isEmpty {
                    NavigationLink {
                        MeetingsListView(viewModel: viewModel)
                    } label: {
                        Text("View all")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.meetingAccent)
                    }
                }
            }

            if upcomingMeetings.isEmpty {
                emptyUpcomingState
            } else {
                ForEach(upcomingMeetings.prefix(3)) { meeting in
                    meetingCard(meeting, isToday: false)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.1), radius: 16, x: 0, y: 8)
                .shadow(color: Color.meetingDeep.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
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

    private var emptyUpcomingState: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar.badge.clock")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingAccent.opacity(0.6), Color.meetingAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("No upcoming meetings")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }

    // MARK: - Meeting Card

    private func meetingCard(_ meeting: Meeting, isToday: Bool) -> some View {
        Button {
            selectedMeeting = meeting
        } label: {
            HStack(spacing: 14) {
                // Time indicator
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
                    if !isToday {
                        Text(meeting.date, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 65)
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.meetingAccent.opacity(0.15), Color.meetingAccent.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text(meeting.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.black)
                        .lineLimit(2)

                    HStack(spacing: 10) {
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
                
                if meeting.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingAccent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.meetingDeep.opacity(0.08), radius: 8, x: 0, y: 4)
                    .shadow(color: Color.meetingDeep.opacity(0.04), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.meetingAccent.opacity(0.3), Color.meetingAccent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingDeep, Color.meetingAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            HStack(spacing: 12) {
                quickActionButton(
                    title: "Calendar",
                    icon: "calendar",
                    destination: AnyView(CalendarWeekView(viewModel: viewModel))
                )
                quickActionButton(
                    title: "Templates",
                    icon: "doc.on.doc",
                    destination: AnyView(TemplatesView(viewModel: viewModel))
                )
                quickActionButton(
                    title: "Analytics",
                    icon: "chart.bar",
                    destination: AnyView(MeetingStatsView(viewModel: viewModel))
                )
            }
        }
    }

    private func quickActionButton(title: String, icon: String, destination: AnyView) -> some View {
        NavigationLink {
            destination
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.meetingAccent.opacity(0.2), Color.meetingAccent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: Color.meetingAccent.opacity(0.3), radius: 8, x: 0, y: 4)
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
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.meetingDeep)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.meetingDeep.opacity(0.08), radius: 10, x: 0, y: 5)
                    .shadow(color: Color.meetingDeep.opacity(0.04), radius: 3, x: 0, y: 1)
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
}
