//
//  SaveTemplateNameView.swift
//  91MeetingMate
//
//  Simple sheet to enter template name when saving from meeting detail.
//

import SwiftUI

struct SaveTemplateNameView: View {
    @ObservedObject var viewModel: MeetingViewModel
    let meeting: Meeting
    @Binding var templateName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                Form {
                    Section {
                        TextField("Template name", text: $templateName)
                            .tint(Color.meetingAccent)
                    } header: {
                        Text("Template name").foregroundStyle(Color.meetingDeep)
                    } footer: {
                        Text("This will save the meeting structure (participants, agenda, reminder) as a reusable template.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.white)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Save as template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        templateName = ""
                        dismiss()
                    }
                    .foregroundStyle(Color.meetingDeep)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let name = templateName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty {
                            viewModel.saveAsTemplate(meeting, name: name)
                            templateName = ""
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(templateName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.meetingAccent, in: Capsule())
                }
            }
        }
    }
}
