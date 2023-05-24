//
//  NotificationManager.swift
//  Public-Transport-Tracking
//
//  Created by Mihnea on 5/16/23.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    public func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public func nextStartNotification(line : String, capat: String, time : String, repeats: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.date(from: time)
        
        let dateInfo = Calendar.current.dateComponents([.hour, .minute], from: date ?? Date())
        
        let content = UNMutableNotificationContent()
        content.title = "Linia \(line) a pornit"
        content.body = "Vehiculul și-a început cursa de \(time) din \(capat) "
        content.sound = UNNotificationSound.default
        content.interruptionLevel = .timeSensitive

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: repeats)
        let request = UNNotificationRequest(identifier: time, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
