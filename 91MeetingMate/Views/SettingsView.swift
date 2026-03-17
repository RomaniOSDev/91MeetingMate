//
//  SettingsView.swift
//  91MeetingMate
//
//  Settings screen with Rate Us, Privacy, Terms.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @ObservedObject var viewModel: MeetingViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.meetingBackground.ignoresSafeArea()
                
                List {
                    appInfoSection
                    actionsSection
                    legalSection
                    dataSection
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.meetingBackground, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.meetingAccent)
                }
            }
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        Section {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.meetingAccent.opacity(0.4), radius: 12, x: 0, y: 6)
                    Image(systemName: "doc.text.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("MeetingMate")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.meetingDeep)
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.white)
        } header: {
            Text("App").foregroundStyle(Color.meetingDeep)
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        Section {
            settingsRow(
                icon: "star.fill",
                title: "Rate Us",
                iconColor: Color.meetingAccent
            ) {
                rateApp()
            }
            
            settingsRow(
                icon: "square.and.arrow.up",
                title: "Share App",
                iconColor: Color.meetingAccent
            ) {
                shareApp()
            }
        } header: {
            Text("Actions").foregroundStyle(Color.meetingDeep)
        }
        .listRowBackground(Color.white)
    }
    
    // MARK: - Legal Section
    
    private var legalSection: some View {
        Section {
            settingsRow(
                icon: "lock.shield.fill",
                title: "Privacy Policy",
                iconColor: Color.meetingDeep
            ) {
                openPrivacyPolicy()
            }
            
            settingsRow(
                icon: "doc.text.fill",
                title: "Terms of Service",
                iconColor: Color.meetingDeep
            ) {
                openTermsOfService()
            }
        } header: {
            Text("Legal").foregroundStyle(Color.meetingDeep)
        }
        .listRowBackground(Color.white)
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Meetings")
                        .font(.subheadline)
                        .foregroundStyle(Color.meetingDeep)
                    Text("\(viewModel.totalMeetingsCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.meetingAccent, Color.meetingDeep],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                Spacer()
            }
            .padding(.vertical, 8)
            
            Button(role: .destructive) {
                // Clear all data action
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Clear All Data")
                }
                .foregroundStyle(.red)
            }
        } header: {
            Text("Data").foregroundStyle(Color.meetingDeep)
        } footer: {
            Text("All data is stored locally on your device.")
                .font(.caption)
        }
        .listRowBackground(Color.white)
    }
    
    // MARK: - Settings Row
    
    private func settingsRow(
        icon: String,
        title: String,
        iconColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [iconColor.opacity(0.2), iconColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [iconColor, iconColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(Color.meetingDeep)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Actions
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func shareApp() {
        let text = "Check out MeetingMate - the best app for managing your meetings!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/725f5962-df67-4bcf-895d-4596c82b8085") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://www.termsfeed.com/live/51453c62-ac26-4e10-8027-78c9de683678") {
            UIApplication.shared.open(url)
        }
    }
}
