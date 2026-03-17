//
//  MeetingModels.swift
//  91MeetingMate
//
//  Data models for meetings, participants, agenda, tasks.
//

import Foundation

// MARK: - Participant

struct Participant: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var email: String?
    var role: String?

    init(id: UUID = UUID(), name: String, email: String? = nil, role: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
    }

    var initials: String {
        name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }
}

// MARK: - Agenda Item

struct AgendaItem: Identifiable, Codable, Hashable {
    let id: UUID
    var topic: String
    var duration: Int? // minutes
    var notes: String
    var isCompleted: Bool

    init(id: UUID = UUID(), topic: String, duration: Int? = nil, notes: String = "", isCompleted: Bool = false) {
        self.id = id
        self.topic = topic
        self.duration = duration
        self.notes = notes
        self.isCompleted = isCompleted
    }
}

// MARK: - Reminder Interval

enum ReminderInterval: String, CaseIterable, Codable, Hashable {
    case none = "None"
    case fiveMinutes = "5 minutes"
    case fifteenMinutes = "15 minutes"
    case thirtyMinutes = "30 minutes"
    case oneHour = "1 hour"
    case oneDay = "1 day"
    
    var minutesBefore: Int? {
        switch self {
        case .none: return nil
        case .fiveMinutes: return 5
        case .fifteenMinutes: return 15
        case .thirtyMinutes: return 30
        case .oneHour: return 60
        case .oneDay: return 24 * 60
        }
    }
}

// MARK: - Task Repeat Interval

enum TaskRepeatInterval: String, CaseIterable, Codable, Hashable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    func nextDate(from date: Date) -> Date {
        let cal = Calendar.current
        switch self {
        case .none: return date
        case .daily: return cal.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly: return cal.date(byAdding: .day, value: 7, to: date) ?? date
        case .monthly: return cal.date(byAdding: .month, value: 1, to: date) ?? date
        }
    }
}

// MARK: - Task Status

enum TaskStatus: String, CaseIterable, Codable, Hashable {
    case notStarted = "Not started"
    case inProgress = "In progress"
    case completed = "Completed"
    case blocked = "Blocked"
}

// MARK: - Task Item

struct TaskItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var assignee: String
    var deadline: Date
    var status: TaskStatus
    var notes: String?
    var meetingId: UUID?
    var repeatInterval: TaskRepeatInterval
    var parentTaskId: UUID? // For recurring tasks

    init(id: UUID = UUID(), title: String, assignee: String, deadline: Date, status: TaskStatus = .notStarted, notes: String? = nil, meetingId: UUID? = nil, repeatInterval: TaskRepeatInterval = .none, parentTaskId: UUID? = nil) {
        self.id = id
        self.title = title
        self.assignee = assignee
        self.deadline = deadline
        self.status = status
        self.notes = notes
        self.meetingId = meetingId
        self.repeatInterval = repeatInterval
        self.parentTaskId = parentTaskId
    }

    var isOverdue: Bool {
        status != .completed && deadline < Date()
    }
}

// MARK: - Meeting

struct Meeting: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var location: String?
    var participants: [Participant]
    var agenda: [AgendaItem]
    var decisions: [String]
    var tasks: [TaskItem]
    var notes: String
    var isFavorite: Bool
    var reminderInterval: ReminderInterval
    let creationDate: Date

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        location: String? = nil,
        participants: [Participant] = [],
        agenda: [AgendaItem] = [],
        decisions: [String] = [],
        tasks: [TaskItem] = [],
        notes: String = "",
        isFavorite: Bool = false,
        reminderInterval: ReminderInterval = .none,
        creationDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.location = location
        self.participants = participants
        self.agenda = agenda
        self.decisions = decisions
        self.tasks = tasks
        self.notes = notes
        self.isFavorite = isFavorite
        self.reminderInterval = reminderInterval
        self.creationDate = creationDate
    }

    var agendaProgress: Double {
        guard !agenda.isEmpty else { return 0 }
        let completed = agenda.filter(\.isCompleted).count
        return Double(completed) / Double(agenda.count)
    }
}

// MARK: - Meeting Template

struct MeetingTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var title: String
    var location: String?
    var participants: [Participant]
    var agenda: [AgendaItem]
    var reminderInterval: ReminderInterval
    let creationDate: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        title: String,
        location: String? = nil,
        participants: [Participant] = [],
        agenda: [AgendaItem] = [],
        reminderInterval: ReminderInterval = .none,
        creationDate: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.title = title
        self.location = location
        self.participants = participants
        self.agenda = agenda
        self.reminderInterval = reminderInterval
        self.creationDate = creationDate
    }
    
    func toMeeting(date: Date) -> Meeting {
        Meeting(
            title: title,
            date: date,
            location: location,
            participants: participants,
            agenda: agenda.map { AgendaItem(topic: $0.topic, duration: $0.duration, notes: $0.notes, isCompleted: false) },
            decisions: [],
            tasks: [],
            notes: "",
            reminderInterval: reminderInterval
        )
    }
}
