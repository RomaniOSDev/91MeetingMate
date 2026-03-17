//
//  ParticipantStatsView.swift
//  91MeetingMate
//
//  Statistics view showing top participants and their meeting counts.
//

import SwiftUI

struct ParticipantStatsView: View {
    @ObservedObject var viewModel: MeetingViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Participants")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.meetingDeep)
                        
                        if viewModel.participantStatistics.isEmpty {
                            emptyState
                        } else {
                            topParticipantsSection
                            allParticipantsSection
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.meetingBackground, for: .navigationBar)
        }
    }

    private var topParticipantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top participants")
                .font(.headline)
                .foregroundStyle(Color.meetingDeep)
            
            let top = viewModel.topParticipants
            let maxCount = top.first?.meetingCount ?? 1
            
            VStack(spacing: 12) {
                ForEach(Array(top.enumerated()), id: \.element.participant.id) { index, item in
                    participantRow(item.participant, count: item.meetingCount, maxCount: maxCount, rank: index + 1)
                }
            }
        }
    }

    private var allParticipantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All participants")
                .font(.headline)
                .foregroundStyle(Color.meetingDeep)
            
            let stats = viewModel.participantStatistics
            let maxCount = stats.first?.meetingCount ?? 1
            
            VStack(spacing: 8) {
                ForEach(stats, id: \.participant.id) { item in
                    participantRow(item.participant, count: item.meetingCount, maxCount: maxCount, rank: nil)
                }
            }
        }
    }

    private func participantRow(_ participant: Participant, count: Int, maxCount: Int, rank: Int?) -> some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.meetingAccent.opacity(0.3), Color.meetingAccent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
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
                    .frame(width: 50, height: 50)
                Text(participant.initials)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.meetingDeep)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(participant.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.black)
                    if let rank = rank {
                        Text("#\(rank)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                LinearGradient(
                                    colors: [Color.meetingAccent, Color.meetingDeep],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: Capsule()
                            )
                            .shadow(color: Color.meetingAccent.opacity(0.4), radius: 4, x: 0, y: 2)
                    }
                }
                if let role = participant.role, !role.isEmpty {
                    Text(role)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.meetingDeep, Color.meetingAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Text("meeting\(count == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(Color.meetingAccent)
            }
            
            // Progress bar
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.meetingAccent.opacity(0.15))
                    .frame(height: 6)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [Color.meetingAccent, Color.meetingDeep],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(count) / CGFloat(maxCount), height: 6)
                            .shadow(color: Color.meetingAccent.opacity(0.5), radius: 4, x: 0, y: 2)
                    }
            }
            .frame(width: 70, height: 6)
        }
        .padding(16)
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
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.meetingAccent)
            Text("No participants")
                .font(.title3)
                .foregroundStyle(Color.meetingDeep)
            Text("Add participants to meetings to see statistics")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
