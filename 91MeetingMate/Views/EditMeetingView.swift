//
//  EditMeetingView.swift
//  91MeetingMate
//
//  Create or edit meeting: title, date, location, participants, agenda, notes.
//

import SwiftUI

struct EditMeetingView: View {
    @ObservedObject var viewModel: MeetingViewModel
    let meeting: Meeting?
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var location: String = ""
    @State private var participants: [Participant] = []
    @State private var agenda: [AgendaItem] = []
    @State private var notes: String = ""
    @State private var reminderInterval: ReminderInterval = .none

    private var isEditing: Bool { meeting != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                Form {
                    basicSection
                    reminderSection
                    participantsSection
                    agendaSection
                    notesSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(isEditing ? "Edit meeting" : "New meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.meetingBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.meetingDeep)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.meetingAccent, in: Capsule())
                }
            }
            .onAppear { loadMeeting() }
        }
    }

    private var basicSection: some View {
        Section {
            TextField("Meeting title", text: $title)
                .tint(Color.meetingAccent)
            DatePicker("Date and time", selection: $date)
                .tint(Color.meetingAccent)
            TextField("Location or link", text: $location)
                .tint(Color.meetingAccent)
        } header: {
            Text("Basic info").foregroundStyle(Color.meetingDeep)
        }
        .listRowBackground(Color.white)
    }

    private var reminderSection: some View {
        Section {
            Picker("Reminder", selection: $reminderInterval) {
                ForEach(ReminderInterval.allCases, id: \.self) { interval in
                    Text(interval.rawValue).tag(interval)
                }
            }
            .tint(Color.meetingAccent)
            if reminderInterval != .none, let minutes = reminderInterval.minutesBefore {
                Text("You'll be notified \(minutes) minutes before the meeting")
                    .font(.caption)
                    .foregroundStyle(Color.meetingAccent)
            }
        } header: {
            Text("Reminder").foregroundStyle(Color.meetingDeep)
        }
        .listRowBackground(Color.white)
    }

    private var participantsSection: some View {
        Section {
            ForEach(participants) { p in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Name", text: bindingParticipantName(for: p))
                            .foregroundStyle(Color.black)
                        TextField("Role (optional)", text: bindingParticipantRole(for: p))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        participants.removeAll { $0.id == p.id }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.meetingAccent)
                    }
                }
                .listRowBackground(Color.white)
            }
            Button {
                participants.append(Participant(name: "New participant"))
            } label: {
                Label("Add participant", systemImage: "person.badge.plus")
                    .foregroundStyle(Color.meetingAccent)
            }
            .listRowBackground(Color.white)
        } header: {
            Text("Participants").foregroundStyle(Color.meetingDeep)
        }
    }

    private var agendaSection: some View {
        Section {
            ForEach(agenda) { item in
                HStack {
                    Button {
                        if let i = agenda.firstIndex(where: { $0.id == item.id }) {
                            agenda[i].isCompleted.toggle()
                        }
                    } label: {
                        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(Color.meetingAccent)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        TextField("Topic", text: bindingAgendaTopic(for: item))
                            .foregroundStyle(Color.black)
                        HStack(spacing: 4) {
                            Text("Duration (min):").font(.caption).foregroundStyle(Color.meetingAccent)
                            TextField("0", text: bindingAgendaDurationText(for: item))
                                .keyboardType(.numberPad)
                                .frame(width: 40)
                                .font(.caption)
                                .foregroundStyle(Color.meetingAccent)
                        }
                    }
                    Button {
                        agenda.removeAll { $0.id == item.id }
                    } label: {
                        Image(systemName: "trash").foregroundStyle(Color.meetingAccent)
                    }
                }
                .listRowBackground(Color.white)
            }
            Button {
                agenda.append(AgendaItem(topic: "New item", duration: nil, notes: ""))
            } label: {
                Label("Add agenda item", systemImage: "plus.circle")
                    .foregroundStyle(Color.meetingAccent)
            }
            .listRowBackground(Color.white)
        } header: {
            Text("Agenda").foregroundStyle(Color.meetingDeep)
        }
    }

    private var notesSection: some View {
        Section {
            TextField("General notes", text: $notes, axis: .vertical)
                .lineLimit(4...8)
                .tint(Color.meetingAccent)
                .listRowBackground(Color.white)
        } header: {
            Text("Notes").foregroundStyle(Color.meetingDeep)
        }
    }

    private func bindingParticipantName(for p: Participant) -> Binding<String> {
        Binding(
            get: { participants.first(where: { $0.id == p.id })?.name ?? "" },
            set: { new in
                if let i = participants.firstIndex(where: { $0.id == p.id }) {
                    participants[i].name = new
                }
            }
        )
    }

    private func bindingParticipantRole(for p: Participant) -> Binding<String> {
        Binding(
            get: { participants.first(where: { $0.id == p.id })?.role ?? "" },
            set: { new in
                if let i = participants.firstIndex(where: { $0.id == p.id }) {
                    participants[i].role = new.isEmpty ? nil : new
                }
            }
        )
    }

    private func bindingAgendaTopic(for item: AgendaItem) -> Binding<String> {
        Binding(
            get: { agenda.first(where: { $0.id == item.id })?.topic ?? "" },
            set: { new in
                if let i = agenda.firstIndex(where: { $0.id == item.id }) {
                    agenda[i].topic = new
                }
            }
        )
    }

    private func bindingAgendaDurationText(for item: AgendaItem) -> Binding<String> {
        Binding(
            get: {
                guard let i = agenda.firstIndex(where: { $0.id == item.id }),
                      let d = agenda[i].duration else { return "" }
                return d > 0 ? "\(d)" : ""
            },
            set: { new in
                guard let i = agenda.firstIndex(where: { $0.id == item.id }) else { return }
                agenda[i].duration = Int(new).flatMap { $0 > 0 ? $0 : nil }
            }
        )
    }

    private func loadMeeting() {
        guard let m = meeting else {
            title = ""
            date = Date()
            location = ""
            participants = []
            agenda = []
            notes = ""
            reminderInterval = .none
            return
        }
        title = m.title
        date = m.date
        location = m.location ?? ""
        participants = m.participants
        agenda = m.agenda
        notes = m.notes
        reminderInterval = m.reminderInterval
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        if let existing = meeting {
            var updated = existing
            updated.title = trimmedTitle
            updated.date = date
            updated.location = location.isEmpty ? nil : location
            updated.participants = participants
            updated.agenda = agenda
            updated.notes = notes
            updated.reminderInterval = reminderInterval
            // Keep existing decisions and tasks (edited on detail screen)
            viewModel.updateMeeting(updated)
        } else {
            let newMeeting = Meeting(
                title: trimmedTitle,
                date: date,
                location: location.isEmpty ? nil : location,
                participants: participants,
                agenda: agenda,
                decisions: [],
                tasks: [],
                notes: notes,
                reminderInterval: reminderInterval
            )
            viewModel.addMeeting(newMeeting)
        }
    }
}
