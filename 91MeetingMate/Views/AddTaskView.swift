//
//  AddTaskView.swift
//  91MeetingMate
//
//  Sheet to add a new task to a meeting.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: MeetingViewModel
    let meetingId: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var assignee = ""
    @State private var deadline = Date()
    @State private var notes = ""
    @State private var repeatInterval: TaskRepeatInterval = .none

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
                .listRowBackground(Color.white)
            }
            .navigationTitle("Add task")
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
                        let task = TaskItem(
                            title: t,
                            assignee: assignee.isEmpty ? "Unassigned" : assignee,
                            deadline: deadline,
                            status: .notStarted,
                            notes: notes.isEmpty ? nil : notes,
                            meetingId: meetingId,
                            repeatInterval: repeatInterval
                        )
                        viewModel.addTask(to: meetingId, task: task)
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
