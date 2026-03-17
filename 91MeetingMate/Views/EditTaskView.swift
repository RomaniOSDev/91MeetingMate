//
//  EditTaskView.swift
//  91MeetingMate
//
//  Sheet to edit task: title, assignee, deadline, status.
//

import SwiftUI

struct EditTaskView: View {
    @ObservedObject var viewModel: MeetingViewModel
    let meetingId: UUID
    let task: TaskItem
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var assignee: String
    @State private var deadline: Date
    @State private var status: TaskStatus
    @State private var notes: String
    @State private var repeatInterval: TaskRepeatInterval

    init(viewModel: MeetingViewModel, meetingId: UUID, task: TaskItem) {
        self.viewModel = viewModel
        self.meetingId = meetingId
        self.task = task
        _title = State(initialValue: task.title)
        _assignee = State(initialValue: task.assignee)
        _deadline = State(initialValue: task.deadline)
        _status = State(initialValue: task.status)
        _notes = State(initialValue: task.notes ?? "")
        _repeatInterval = State(initialValue: task.repeatInterval)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                Form {
                    TextField("Task title", text: $title)
                        .tint(Color.meetingAccent)
                    TextField("Assignee", text: $assignee)
                        .tint(Color.meetingAccent)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                        .tint(Color.meetingAccent)
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .tint(Color.meetingAccent)
                    Picker("Repeat", selection: $repeatInterval) {
                        ForEach(TaskRepeatInterval.allCases, id: \.self) { interval in
                            Text(interval.rawValue).tag(interval)
                        }
                    }
                    .tint(Color.meetingAccent)
                    if repeatInterval != .none {
                        Text("Task will be recreated automatically when completed")
                            .font(.caption)
                            .foregroundStyle(Color.meetingAccent)
                            .listRowBackground(Color.white)
                    }
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                        .tint(Color.meetingAccent)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.meetingDeep)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !t.isEmpty else { return }
                        var updated = task
                        updated.title = t
                        updated.assignee = assignee.isEmpty ? "Unassigned" : assignee
                        updated.deadline = deadline
                        updated.status = status
                        updated.notes = notes.isEmpty ? nil : notes
                        updated.repeatInterval = repeatInterval
                        viewModel.updateTask(meetingId: meetingId, task: updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.meetingAccent, in: Capsule())
                }
            }
        }
    }
}
