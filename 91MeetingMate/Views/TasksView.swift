//
//  TasksView.swift
//  91MeetingMate
//
//  Tab: all tasks with filters (All / Mine / Overdue).
//

import SwiftUI

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case mine = "Mine"
    case overdue = "Overdue"
}

struct TasksView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @State private var filter: TaskFilter = .all
    @State private var selectedMeeting: Meeting?
    @State private var selectedMeetingForTask: MeetingIDWrapper?
    @State private var showMeetingPicker = false

    private var filteredTasks: [TaskItem] {
        switch filter {
        case .all: return viewModel.allTasks.sorted { $0.deadline < $1.deadline }
        case .mine: return viewModel.allTasks.sorted { $0.deadline < $1.deadline }
        case .overdue: return viewModel.overdueTasks.sorted { $0.deadline < $1.deadline }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Filter", selection: $filter) {
                        ForEach(TaskFilter.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .tint(Color.meetingAccent)
                    listContent
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.meetingBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if viewModel.meetings.isEmpty {
                            // If no meetings, show message or create meeting first
                        } else {
                            showMeetingPicker = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.meetingAccent)
                    }
                }
            }
            .sheet(item: $selectedMeetingForTask) { wrapper in
                AddTaskView(viewModel: viewModel, meetingId: wrapper.id)
            }
            .sheet(isPresented: $showMeetingPicker) {
                MeetingPickerView(
                    viewModel: viewModel,
                    selectedMeetingForTask: $selectedMeetingForTask
                )
            }
            .navigationDestination(item: $selectedMeeting) { meeting in
                MeetingDetailView(viewModel: viewModel, meeting: meeting)
            }
        }
    }

    private var listContent: some View {
        Group {
            if filteredTasks.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(filteredTasks) { task in
                        if let meeting = viewModel.meeting(for: task) {
                            let meetingId = task.meetingId ?? meeting.id
                            TaskRowView(viewModel: viewModel, meetingId: meetingId, task: task)
                                .listRowBackground(Color.meetingBackground)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .onTapGesture {
                                    selectedMeeting = meeting
                                }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 48))
                .foregroundStyle(Color.meetingAccent)
            Text("No tasks")
                .font(.title3)
                .foregroundStyle(Color.meetingDeep)
            Text(filter == .overdue ? "No overdue tasks" : "Add tasks in meeting details")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
