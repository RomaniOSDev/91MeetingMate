//
//  MeetingPickerView.swift
//  91MeetingMate
//
//  Sheet to select a meeting for adding a task.
//

import SwiftUI

struct MeetingPickerView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @Binding var selectedMeetingForTask: MeetingIDWrapper?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                
                if viewModel.meetings.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.meetingAccent)
                        Text("No meetings")
                            .font(.title3)
                            .foregroundStyle(Color.meetingDeep)
                        Text("Create a meeting first to add tasks")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(viewModel.sortedMeetings) { meeting in
                            Button {
                                selectedMeetingForTask = MeetingIDWrapper(id: meeting.id)
                                dismiss()
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(meeting.title)
                                            .font(.headline)
                                            .foregroundStyle(Color.black)
                                        Text(meeting.date, style: .date)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.meetingAccent)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Select Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.meetingDeep)
                }
            }
        }
    }
}
