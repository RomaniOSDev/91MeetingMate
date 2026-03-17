//
//  NotificationService.swift
//  91MeetingMate
//
//  Service for managing local notifications for meeting reminders.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    // MARK: - Request Authorization
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    // MARK: - Schedule Notification
    
    func scheduleNotification(for meeting: Meeting) {
        guard let minutes = meeting.reminderInterval.minutesBefore,
              minutes > 0 else {
            // Remove notification if reminder is disabled
            removeNotification(for: meeting.id)
            return
        }
        
        let reminderDate = meeting.date.addingTimeInterval(-Double(minutes * 60))
        
        // Don't schedule if reminder time is in the past
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Meeting Reminder"
        content.body = "\(meeting.title) starts in \(meeting.reminderInterval.rawValue)"
        content.sound = .default
        content.userInfo = ["meetingId": meeting.id.uuidString]
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: meeting.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // MARK: - Remove Notification
    
    func removeNotification(for meetingId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [meetingId.uuidString])
    }
    
    // MARK: - Update All Notifications
    
    func updateNotifications(for meetings: [Meeting]) {
        // Remove all existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule new ones
        for meeting in meetings {
            scheduleNotification(for: meeting)
        }
    }
}
