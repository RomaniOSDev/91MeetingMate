//
//  MeetingDetailView.swift
//  91MeetingMate
//
//  Meeting detail: header, participants, agenda, decisions, tasks, actions.
//

import SwiftUI

struct MeetingDetailView: View {
    @ObservedObject var viewModel: MeetingViewModel
    let meeting: Meeting
    @State private var showEdit = false
    @State private var showAddDecision = false
    @State private var newDecisionText = ""
    @State private var showAddTask = false
    @State private var showSaveTemplate = false
    @State private var templateName = ""

    private var currentMeeting: Meeting {
        viewModel.meetings.first(where: { $0.id == meeting.id }) ?? meeting
    }

    var body: some View {
        ZStack {
            Color.meetingBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    participantsSection
                    agendaSection
                    decisionsSection
                    tasksSection
                }
                .padding()
            }
            .sheet(isPresented: $showEdit) {
                EditMeetingView(viewModel: viewModel, meeting: currentMeeting)
            }
            .sheet(isPresented: $showAddDecision) {
                addDecisionSheet
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel, meetingId: currentMeeting.id)
            }
            .sheet(isPresented: $showSaveTemplate) {
                SaveTemplateNameView(viewModel: viewModel, meeting: currentMeeting, templateName: $templateName)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showEdit = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button {
                            showSaveTemplate = true
                        } label: {
                            Label("Save as template", systemImage: "doc.on.doc")
                        }
                        Button {
                            viewModel.toggleFavorite(currentMeeting)
                        } label: {
                            Label(currentMeeting.isFavorite ? "Remove favorite" : "Add to favorites", systemImage: currentMeeting.isFavorite ? "star.fill" : "star")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(Color.meetingAccent)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(currentMeeting.date, style: .date)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingDeep, Color.meetingAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text(currentMeeting.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.black, Color.meetingDeep],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            HStack(spacing: 16) {
                if let loc = currentMeeting.location, !loc.isEmpty {
                    Label(loc, systemImage: "location.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.meetingAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.meetingAccent.opacity(0.1))
                                .shadow(color: Color.meetingAccent.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                }
                if currentMeeting.reminderInterval != .none {
                    Label("Reminder: \(currentMeeting.reminderInterval.rawValue) before", systemImage: "bell.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.meetingAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.meetingAccent.opacity(0.2), Color.meetingAccent.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color.meetingAccent.opacity(0.3), radius: 4, x: 0, y: 2)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.1), radius: 12, x: 0, y: 6)
                .shadow(color: Color.meetingDeep.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Participants")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingDeep, Color.meetingAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(currentMeeting.participants) { p in
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.meetingAccent.opacity(0.3), Color.meetingAccent.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 56, height: 56)
                                    .shadow(color: Color.meetingAccent.opacity(0.4), radius: 8, x: 0, y: 4)
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.meetingAccent, Color.meetingAccent.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 56, height: 56)
                                Text(p.initials)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.meetingDeep)
                            }
                            Text(p.name)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }

    private var agendaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            agendaHeader
            agendaProgressBar
            agendaItemsList
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }
    
    private var agendaHeader: some View {
        HStack {
            Text("Agenda")
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
            Text("\(Int(currentMeeting.agendaProgress * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(Color.meetingAccent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.meetingAccent.opacity(0.15))
                )
        }
    }
    
    private var agendaProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.meetingAccent.opacity(0.15))
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Color.meetingAccent, Color.meetingDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geometry.size.width * CGFloat(currentMeeting.agendaProgress),
                        height: 8
                    )
                    .shadow(color: Color.meetingAccent.opacity(0.5), radius: 4, x: 0, y: 2)
            }
        }
        .frame(height: 8)
    }
    
    private var agendaItemsList: some View {
        ForEach(currentMeeting.agenda) { item in
            agendaItemRow(item)
        }
    }
    
    private func agendaItemRow(_ item: AgendaItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            agendaItemCheckbox(item)
            agendaItemContent(item)
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
    
    private func agendaItemCheckbox(_ item: AgendaItem) -> some View {
        Button {
            viewModel.toggleAgendaItemCompleted(meetingId: currentMeeting.id, itemId: item.id)
        } label: {
            ZStack {
                Circle()
                    .fill(item.isCompleted ? Color.meetingAccent.opacity(0.2) : Color.clear)
                    .frame(width: 28, height: 28)
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(checkboxGradient(for: item))
            }
        }
    }
    
    private func checkboxGradient(for item: AgendaItem) -> LinearGradient {
        if item.isCompleted {
            return LinearGradient(
                colors: [Color.meetingAccent, Color.meetingDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.meetingAccent.opacity(0.5), Color.meetingAccent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func agendaItemContent(_ item: AgendaItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.topic)
                .strikethrough(item.isCompleted)
                .foregroundStyle(item.isCompleted ? Color.secondary : Color.black)
                .fontWeight(item.isCompleted ? .regular : .medium)
            if let d = item.duration, d > 0 {
                Text("\(d) min")
                    .font(.caption)
                    .foregroundStyle(Color.meetingAccent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.meetingAccent.opacity(0.1))
                    )
            }
        }
    }

    private var decisionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Decisions")
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
                Button {
                    showAddDecision = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color.meetingAccent, Color.meetingDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .shadow(color: Color.meetingAccent.opacity(0.4), radius: 6, x: 0, y: 3)
                }
            }
            ForEach(Array(currentMeeting.decisions.enumerated()), id: \.offset) { index, text in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.meetingAccent.opacity(0.2), Color.meetingAccent.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.meetingAccent, Color.meetingDeep],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    Text(text)
                        .foregroundStyle(Color.black)
                        .fontWeight(.medium)
                    Spacer()
                    Button {
                        viewModel.removeDecision(meetingId: currentMeeting.id, at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.meetingDeep.opacity(0.06), radius: 6, x: 0, y: 3)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tasks")
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
                Button {
                    showAddTask = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add task")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color.meetingAccent, Color.meetingDeep],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .shadow(color: Color.meetingAccent.opacity(0.4), radius: 6, x: 0, y: 3)
                }
            }
            ForEach(currentMeeting.tasks) { task in
                TaskRowView(viewModel: viewModel, meetingId: currentMeeting.id, task: task)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.08), radius: 10, x: 0, y: 4)
        )
    }

    private var addDecisionSheet: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                VStack(spacing: 16) {
                    TextField("Decision text", text: $newDecisionText, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                        .tint(Color.meetingAccent)
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add decision")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newDecisionText = ""
                        showAddDecision = false
                    }
                    .foregroundStyle(Color.meetingDeep)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let t = newDecisionText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !t.isEmpty {
                            viewModel.addDecision(meetingId: currentMeeting.id, text: t)
                        }
                        newDecisionText = ""
                        showAddDecision = false
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

// MARK: - Task row (used in detail and in TasksView)

struct TaskRowView: View {
    @ObservedObject var viewModel: MeetingViewModel
    let meetingId: UUID
    let task: TaskItem
    @State private var showEditTask = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                var t = task
                t.status = task.status == .completed ? .notStarted : .completed
                viewModel.updateTask(meetingId: meetingId, task: t)
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            task.status == .completed ?
                            LinearGradient(
                                colors: [Color.meetingAccent.opacity(0.3), Color.meetingAccent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.meetingAccent.opacity(0.1), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .shadow(color: task.status == .completed ? Color.meetingAccent.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                    Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(
                            task.status == .completed ?
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color.meetingAccent.opacity(0.6), Color.meetingAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                HStack(spacing: 8) {
                    Label(task.assignee, systemImage: "person")
                        .font(.caption)
                        .foregroundStyle(Color.meetingAccent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.meetingAccent.opacity(0.1))
                        )
                    Text(task.deadline, style: .date)
                        .font(.caption)
                        .foregroundStyle(task.isOverdue ? .red : Color.meetingAccent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(task.isOverdue ? Color.red.opacity(0.1) : Color.meetingAccent.opacity(0.1))
                        )
                    if task.repeatInterval != .none {
                        Label(task.repeatInterval.rawValue, systemImage: "repeat")
                            .font(.caption2)
                            .foregroundStyle(Color.meetingAccent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.meetingAccent.opacity(0.15), Color.meetingAccent.opacity(0.1)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }
                Text(task.status.rawValue)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(statusBackground(task.status), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(task.status == .notStarted ? Color.meetingAccent : .clear, lineWidth: 1.5)
                    )
                    .foregroundStyle(statusTextColor(task.status))
                    .shadow(color: task.status == .completed || task.status == .blocked ? Color.meetingAccent.opacity(0.3) : Color.clear, radius: 3, x: 0, y: 2)
            }
            Spacer()
            Button {
                showEditTask = true
            } label: {
                Image(systemName: "pencil")
                    .font(.subheadline)
                    .foregroundStyle(Color.meetingAccent)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(Color.meetingAccent.opacity(0.1))
                    )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.08), radius: 8, x: 0, y: 4)
                .shadow(color: Color.meetingDeep.opacity(0.04), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        colors: [Color.meetingAccent.opacity(0.2), Color.meetingDeep.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .sheet(isPresented: $showEditTask) {
            EditTaskView(viewModel: viewModel, meetingId: meetingId, task: task)
        }
    }

    private func statusBackground(_ status: TaskStatus) -> Color {
        switch status {
        case .notStarted: return Color.clear
        case .inProgress: return Color.meetingAccent.opacity(0.2)
        case .completed: return Color.meetingAccent
        case .blocked: return Color.meetingDeep
        }
    }

    private func statusTextColor(_ status: TaskStatus) -> Color {
        switch status {
        case .notStarted: return Color.meetingAccent
        case .inProgress: return Color.meetingDeep
        case .completed, .blocked: return .white
        }
    }
}
