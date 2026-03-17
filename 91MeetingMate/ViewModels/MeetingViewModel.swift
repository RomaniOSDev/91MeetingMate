//
//  MeetingViewModel.swift
//  91MeetingMate
//
//  MVVM ViewModel: meetings CRUD, persistence, statistics.
//

import Foundation
import Combine

final class MeetingViewModel: ObservableObject {
    @Published var meetings: [Meeting] = []
    @Published var templates: [MeetingTemplate] = []
    @Published var searchText: String = ""

    private let storageKey = "meetingMate_meetings"
    private let templatesKey = "meetingMate_templates"
    private let notificationService = NotificationService.shared

    init() {
        loadFromUserDefaults()
        loadTemplatesFromUserDefaults()
        notificationService.requestAuthorization()
        notificationService.updateNotifications(for: meetings)
        checkRecurringTasks()
    }

    // MARK: - CRUD

    func addMeeting(_ meeting: Meeting) {
        meetings.append(meeting)
        saveToUserDefaults()
        notificationService.scheduleNotification(for: meeting)
    }

    func updateMeeting(_ meeting: Meeting) {
        guard let i = meetings.firstIndex(where: { $0.id == meeting.id }) else { return }
        meetings[i] = meeting
        saveToUserDefaults()
        notificationService.scheduleNotification(for: meeting)
    }

    func deleteMeeting(_ meeting: Meeting) {
        notificationService.removeNotification(for: meeting.id)
        meetings.removeAll { $0.id == meeting.id }
        saveToUserDefaults()
    }

    func toggleFavorite(_ meeting: Meeting) {
        guard var m = meetings.first(where: { $0.id == meeting.id }) else { return }
        m.isFavorite.toggle()
        updateMeeting(m)
    }

    // MARK: - Meeting content updates

    func updateAgendaItem(meetingId: UUID, item: AgendaItem) {
        guard var meeting = meetings.first(where: { $0.id == meetingId }) else { return }
        if let i = meeting.agenda.firstIndex(where: { $0.id == item.id }) {
            meeting.agenda[i] = item
        }
        updateMeeting(meeting)
    }

    func toggleAgendaItemCompleted(meetingId: UUID, itemId: UUID) {
        guard var meeting = meetings.first(where: { $0.id == meetingId }),
              let i = meeting.agenda.firstIndex(where: { $0.id == itemId }) else { return }
        meeting.agenda[i].isCompleted.toggle()
        updateMeeting(meeting)
    }

    func addDecision(meetingId: UUID, text: String) {
        guard var meeting = meetings.first(where: { $0.id == meetingId }) else { return }
        meeting.decisions.append(text)
        updateMeeting(meeting)
    }

    func removeDecision(meetingId: UUID, at index: Int) {
        guard var meeting = meetings.first(where: { $0.id == meetingId }),
              meeting.decisions.indices.contains(index) else { return }
        meeting.decisions.remove(at: index)
        updateMeeting(meeting)
    }

    func updateTask(meetingId: UUID, task: TaskItem) {
        guard var meeting = meetings.first(where: { $0.id == meetingId }) else { return }
        if let i = meeting.tasks.firstIndex(where: { $0.id == task.id }) {
            let oldTask = meeting.tasks[i]
            meeting.tasks[i] = task
            
            // If task was completed and has repeat interval, create next occurrence
            if oldTask.status != .completed && task.status == .completed && task.repeatInterval != .none {
                let nextDeadline = task.repeatInterval.nextDate(from: task.deadline)
                let nextTask = TaskItem(
                    title: task.title,
                    assignee: task.assignee,
                    deadline: nextDeadline,
                    status: .notStarted,
                    notes: task.notes,
                    meetingId: meetingId,
                    repeatInterval: task.repeatInterval,
                    parentTaskId: task.id
                )
                meeting.tasks.append(nextTask)
            }
        }
        updateMeeting(meeting)
    }

    func addTask(to meetingId: UUID, task: TaskItem) {
        guard var meeting = meetings.first(where: { $0.id == meetingId }) else { return }
        var t = task
        t.meetingId = meetingId
        meeting.tasks.append(t)
        updateMeeting(meeting)
    }

    func deleteTask(meetingId: UUID, taskId: UUID) {
        guard var meeting = meetings.first(where: { $0.id == meetingId }) else { return }
        meeting.tasks.removeAll { $0.id == taskId }
        updateMeeting(meeting)
    }

    // MARK: - Sorted lists

    var sortedMeetings: [Meeting] {
        meetings.sorted { $0.date > $1.date }
    }

    var filteredMeetings: [Meeting] {
        if searchText.isEmpty {
            return sortedMeetings
        }
        let query = searchText.lowercased()
        return sortedMeetings.filter { meeting in
            meeting.title.lowercased().contains(query) ||
            meeting.location?.lowercased().contains(query) ?? false ||
            meeting.participants.contains { $0.name.lowercased().contains(query) } ||
            meeting.notes.lowercased().contains(query) ||
            meeting.agenda.contains { $0.topic.lowercased().contains(query) }
        }
    }

    var favoriteMeetings: [Meeting] {
        meetings.filter(\.isFavorite)
    }

    // MARK: - All tasks (for Tasks tab)

    var allTasks: [TaskItem] {
        meetings.flatMap { m in
            m.tasks.map { t in
                var task = t
                if task.meetingId == nil { task.meetingId = m.id }
                return task
            }
        }
    }

    func meeting(for task: TaskItem) -> Meeting? {
        guard let mid = task.meetingId else { return nil }
        return meetings.first { $0.id == mid }
    }

    var overdueTasks: [TaskItem] {
        allTasks.filter(\.isOverdue)
    }

    // MARK: - Statistics

    var totalMeetingsCount: Int { meetings.count }
    var completedTasksCount: Int { allTasks.filter { $0.status == .completed }.count }
    var activeTasksCount: Int { allTasks.filter { $0.status != .completed }.count }
    var uniqueParticipantsCount: Int {
        Set(meetings.flatMap { $0.participants.map(\.id) }).count
    }

    /// Meetings per weekday for chart (0 = Sunday, 1 = Monday, ...)
    var meetingsByWeekday: [Int: Int] {
        var result: [Int: Int] = (0..<7).reduce(into: [:]) { $0[$1] = 0 }
        let cal = Calendar.current
        for m in meetings {
            let w = cal.component(.weekday, from: m.date) - 1
            result[w, default: 0] += 1
        }
        return result
    }

    /// Task counts by status for pie chart
    var taskCountByStatus: [TaskStatus: Int] {
        var result: [TaskStatus: Int] = [:]
        for status in TaskStatus.allCases {
            result[status] = allTasks.filter { $0.status == status }.count
        }
        return result
    }

    // MARK: - Templates

    func addTemplate(_ template: MeetingTemplate) {
        templates.append(template)
        saveTemplatesToUserDefaults()
    }

    func deleteTemplate(_ template: MeetingTemplate) {
        templates.removeAll { $0.id == template.id }
        saveTemplatesToUserDefaults()
    }

    func createMeetingFromTemplate(_ template: MeetingTemplate, date: Date) {
        let meeting = template.toMeeting(date: date)
        addMeeting(meeting)
    }

    func saveAsTemplate(_ meeting: Meeting, name: String) {
        let template = MeetingTemplate(
            name: name,
            title: meeting.title,
            location: meeting.location,
            participants: meeting.participants,
            agenda: meeting.agenda,
            reminderInterval: meeting.reminderInterval
        )
        addTemplate(template)
    }

    // MARK: - Participant Statistics

    var participantStatistics: [(participant: Participant, meetingCount: Int)] {
        var stats: [UUID: (participant: Participant, meetingCount: Int)] = [:]
        
        for meeting in meetings {
            for participant in meeting.participants {
                if let existing = stats[participant.id] {
                    stats[participant.id] = (participant: existing.participant, meetingCount: existing.meetingCount + 1)
                } else {
                    stats[participant.id] = (participant: participant, meetingCount: 1)
                }
            }
        }
        
        return stats.values.sorted { $0.meetingCount > $1.meetingCount }
    }

    var topParticipants: [(participant: Participant, meetingCount: Int)] {
        Array(participantStatistics.prefix(10))
    }

    // MARK: - Calendar View

    func meetingsForWeek(containing date: Date) -> [Date: [Meeting]] {
        let cal = Calendar.current
        guard let weekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return [:]
        }
        
        var result: [Date: [Meeting]] = [:]
        for dayOffset in 0..<7 {
            guard let day = cal.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            let dayStart = cal.startOfDay(for: day)
            let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!
            
            let dayMeetings = meetings.filter { meeting in
                meeting.date >= dayStart && meeting.date < dayEnd
            }
            
            if !dayMeetings.isEmpty {
                result[dayStart] = dayMeetings.sorted { $0.date < $1.date }
            }
        }
        
        return result
    }

    func meetingsForDay(_ date: Date) -> [Meeting] {
        let cal = Calendar.current
        let dayStart = cal.startOfDay(for: date)
        let dayEnd = cal.date(byAdding: .day, value: 1, to: dayStart)!
        
        return meetings.filter { meeting in
            meeting.date >= dayStart && meeting.date < dayEnd
        }.sorted { $0.date < $1.date }
    }

    // MARK: - Recurring Tasks

    func checkRecurringTasks() {
        // Check all completed tasks with repeat interval and create next occurrence if needed
        for meeting in meetings {
            for task in meeting.tasks where task.status == .completed && task.repeatInterval != .none {
                // Check if next occurrence already exists
                let hasNextOccurrence = meeting.tasks.contains { $0.parentTaskId == task.id }
                if !hasNextOccurrence {
                    let nextDeadline = task.repeatInterval.nextDate(from: task.deadline)
                    if nextDeadline > Date() {
                        var updatedMeeting = meeting
                        let nextTask = TaskItem(
                            title: task.title,
                            assignee: task.assignee,
                            deadline: nextDeadline,
                            status: .notStarted,
                            notes: task.notes,
                            meetingId: meeting.id,
                            repeatInterval: task.repeatInterval,
                            parentTaskId: task.id
                        )
                        updatedMeeting.tasks.append(nextTask)
                        updateMeeting(updatedMeeting)
                    }
                }
            }
        }
    }

    // MARK: - Persistence

    func saveToUserDefaults() {
        guard let data = try? JSONEncoder().encode(meetings) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Meeting].self, from: data) else {
            meetings = []
            return
        }
        meetings = decoded
        // Update notifications after loading
        notificationService.updateNotifications(for: meetings)
    }

    func saveTemplatesToUserDefaults() {
        guard let data = try? JSONEncoder().encode(templates) else { return }
        UserDefaults.standard.set(data, forKey: templatesKey)
    }

    func loadTemplatesFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: templatesKey),
              let decoded = try? JSONDecoder().decode([MeetingTemplate].self, from: data) else {
            templates = []
            return
        }
        templates = decoded
    }
}
