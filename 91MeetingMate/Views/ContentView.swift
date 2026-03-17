//
//  ContentView.swift
//  91MeetingMate
//
//  Root SwiftUI view: TabView (Meetings, Tasks, Analytics).
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MeetingViewModel()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        ZStack {
            TabView {
                HomeView(viewModel: viewModel)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                MeetingsListView(viewModel: viewModel)
                    .tabItem {
                        Label("Meetings", systemImage: "doc.text")
                    }
                CalendarWeekView(viewModel: viewModel)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                TasksView(viewModel: viewModel)
                    .tabItem {
                        Label("Tasks", systemImage: "checklist")
                    }
                MeetingStatsView(viewModel: viewModel)
                    .tabItem {
                        Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                    }
            }
            .tint(Color.meetingAccent)
            .preferredColorScheme(.light)
            
            if showOnboarding {
                OnboardingView(isPresented: $showOnboarding)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }
}

#Preview {
    ContentView()
}
