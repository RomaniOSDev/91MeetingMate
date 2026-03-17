//
//  TemplatesView.swift
//  91MeetingMate
//
//  View for managing meeting templates: list, create from meeting, use template.
//

import SwiftUI

struct TemplatesView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @State private var showSaveTemplate = false
    @State private var showUseTemplate = false
    @State private var selectedTemplate: MeetingTemplate?
    @State private var templateName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                if viewModel.templates.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.templates) { template in
                            templateRow(template)
                                .listRowBackground(Color.white)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTemplate(template)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.meetingBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showUseTemplate = true
                        } label: {
                            Label("Use template", systemImage: "doc.on.doc")
                        }
                        Button {
                            showSaveTemplate = true
                        } label: {
                            Label("Save current as template", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.meetingAccent)
                    }
                }
            }
            .sheet(isPresented: $showUseTemplate) {
                UseTemplateView(viewModel: viewModel)
            }
            .sheet(isPresented: $showSaveTemplate) {
                SaveTemplateView(viewModel: viewModel, templateName: $templateName)
            }
        }
    }

    private func templateRow(_ template: MeetingTemplate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.meetingAccent.opacity(0.2), Color.meetingAccent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "doc.on.doc.fill")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: Color.meetingAccent.opacity(0.3), radius: 6, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.black)
                    Text(template.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack(spacing: 12) {
                Label("\(template.participants.count)", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundStyle(Color.meetingAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.meetingAccent.opacity(0.1))
                    )
                Label("\(template.agenda.count)", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(Color.meetingAccent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.meetingAccent.opacity(0.1))
                    )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.1), radius: 10, x: 0, y: 5)
                .shadow(color: Color.meetingDeep.opacity(0.05), radius: 3, x: 0, y: 1)
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
        .onTapGesture {
            selectedTemplate = template
            showUseTemplate = true
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.meetingAccent)
            Text("No templates")
                .font(.title3)
                .foregroundStyle(Color.meetingAccent)
            Text("Save a meeting as template to reuse it")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct UseTemplateView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                Form {
                    Section {
                        DatePicker("Meeting date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .tint(Color.meetingAccent)
                    } header: {
                        Text("Select template").foregroundStyle(Color.meetingDeep)
                    }
                    .listRowBackground(Color.white)
                    
                    Section {
                        ForEach(viewModel.templates) { template in
                            Button {
                                viewModel.createMeetingFromTemplate(template, date: selectedDate)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundStyle(Color.black)
                                    Text(template.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .listRowBackground(Color.white)
                        }
                    } header: {
                        Text("Templates").foregroundStyle(Color.meetingDeep)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Use template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.meetingDeep)
                }
            }
        }
    }
}

struct SaveTemplateView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @Binding var templateName: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMeeting: Meeting?

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
                    }
                    .listRowBackground(Color.white)
                    
                    Section {
                        ForEach(viewModel.sortedMeetings) { meeting in
                            Button {
                                selectedMeeting = meeting
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(meeting.title)
                                            .font(.headline)
                                            .foregroundStyle(Color.black)
                                        Text(meeting.date, style: .date)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if selectedMeeting?.id == meeting.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.meetingAccent)
                                    }
                                }
                            }
                            .listRowBackground(Color.white)
                        }
                    } header: {
                        Text("Select meeting").foregroundStyle(Color.meetingDeep)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Save as template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.meetingDeep)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let meeting = selectedMeeting, !templateName.isEmpty {
                            viewModel.saveAsTemplate(meeting, name: templateName)
                            templateName = ""
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(templateName.isEmpty || selectedMeeting == nil ? Color.gray : Color.meetingAccent, in: Capsule())
                }
            }
        }
    }
}
