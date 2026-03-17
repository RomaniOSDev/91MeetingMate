//
//  MeetingsListView.swift
//  91MeetingMate
//
//  Main list of meetings with cards, sorting, add button.
//

import SwiftUI

struct MeetingsListView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @State private var showAddMeeting = false
    @State private var selectedMeeting: Meeting?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                listContent
            }
            .navigationTitle("MeetingMate")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.meetingBackground, for: .navigationBar)
            .searchable(text: $viewModel.searchText, prompt: "Search meetings...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddMeeting = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.meetingAccent)
                    }
                }
            }
            .sheet(isPresented: $showAddMeeting) {
                EditMeetingView(viewModel: viewModel, meeting: nil)
            }
            .navigationDestination(item: $selectedMeeting) { meeting in
                MeetingDetailView(viewModel: viewModel, meeting: meeting)
            }
        }
    }

    private var listContent: some View {
        Group {
            if viewModel.filteredMeetings.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(viewModel.filteredMeetings) { meeting in
                        meetingRow(meeting)
                            .listRowBackground(Color.white)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .onTapGesture {
                                selectedMeeting = meeting
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleFavorite(meeting)
                                } label: {
                                    Label("Favorite", systemImage: meeting.isFavorite ? "star.fill" : "star")
                                }
                                .tint(Color.meetingAccent)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteMeeting(meeting)
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
    }

    private func meetingRow(_ meeting: Meeting) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(meeting.date, style: .date)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.meetingDeep, Color.meetingAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                if meeting.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingAccent.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            Text(meeting.title)
                .font(.headline)
                .foregroundStyle(Color.black)
            HStack(spacing: 12) {
                if let loc = meeting.location, !loc.isEmpty {
                    Label(loc, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundStyle(Color.meetingAccent)
                }
                Label("\(meeting.participants.count)", systemImage: "person.2.fill")
                    .font(.caption)
                    .foregroundStyle(Color.meetingAccent)
                Label("\(meeting.tasks.count)", systemImage: "checklist")
                    .font(.caption)
                    .foregroundStyle(Color.meetingAccent)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.meetingDeep.opacity(0.1), radius: 8, x: 0, y: 4)
                .shadow(color: Color.meetingDeep.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.meetingAccent.opacity(0.3), Color.meetingDeep.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.meetingAccent.opacity(0.2), Color.meetingAccent.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.meetingAccent.opacity(0.3), radius: 10, x: 0, y: 5)
                Image(systemName: viewModel.searchText.isEmpty ? "doc.text.magnifyingglass" : "magnifyingglass")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.meetingAccent, Color.meetingDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            Text(viewModel.searchText.isEmpty ? "Your protocols" : "No results")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.meetingDeep, Color.meetingAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text(viewModel.searchText.isEmpty ? "Tap + to create your first meeting" : "Try a different search term")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
