//
//  OnboardingView.swift
//  91MeetingMate
//
//  Onboarding screens for first-time users.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to MeetingMate",
            description: "Organize your meetings, track tasks, and never miss an important discussion.",
            icon: "doc.text.fill",
            gradientColors: [Color.meetingAccent, Color.meetingDeep]
        ),
        OnboardingPage(
            title: "Stay Organized",
            description: "Create meeting templates, set reminders, and keep track of all your participants and decisions.",
            icon: "calendar.badge.checkmark",
            gradientColors: [Color.meetingAccent, Color.meetingDeep]
        )
    ]
    
    var body: some View {
        ZStack {
            // Solid background
            Color.meetingBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom section
                VStack(spacing: 20) {
                    // Page indicators (only 2)
                    HStack(spacing: 12) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(
                                    currentPage == index ?
                                    LinearGradient(
                                        colors: [Color.meetingAccent, Color.meetingDeep],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [Color.meetingAccent.opacity(0.3), Color.meetingAccent.opacity(0.1)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: currentPage == index ? 32 : 12, height: 12)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.top, 30)
                    
                    // Action button
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        HStack {
                            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingDeep],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .shadow(color: Color.meetingAccent.opacity(0.5), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                }
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.white)
                        .shadow(color: Color.meetingDeep.opacity(0.1), radius: 20, x: 0, y: -5)
                )
            }
        }
    }
    
    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 50) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradientColors.map { $0.opacity(0.25) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(color: page.gradientColors[0].opacity(0.5), radius: 40, x: 0, y: 20)
                    .blur(radius: 20)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.gradientColors.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                    .shadow(color: page.gradientColors[0].opacity(0.4), radius: 30, x: 0, y: 15)
                
                Image(systemName: page.icon)
                    .font(.system(size: 90))
                    .foregroundStyle(
                        LinearGradient(
                            colors: page.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.top, 80)
            
            // Text content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.meetingDeep, Color.meetingAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 50)
                    .lineSpacing(4)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation {
            isPresented = false
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let gradientColors: [Color]
}
