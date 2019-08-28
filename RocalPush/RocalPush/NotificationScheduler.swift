//
//  NotificationScheduler.swift
//  RocalPush
//
//  Created by wooky83 on 28/08/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit
import UserNotifications

protocol NotificationScheduler {
    func scheduleNotification(trigger: UNNotificationTrigger, titleTextField: UITextField, sound: Bool, badge: String?)
}

extension NotificationScheduler where Self: UIViewController {
    func scheduleNotification(trigger: UNNotificationTrigger, titleTextField: UITextField, sound: Bool, badge: String?) {
        guard let title = titleTextField.toTrimmedString() else {
            UIAlertController.okWithMessage("Please specify a title.", presentingViewController: self)
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        if sound {
            content.sound = UNNotificationSound.default
        }
        if let badge = badge, let number = Int(badge) {
            content.badge = NSNumber(value: number)
        }
        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    let message = "Failed to schedule notification. \(error.localizedDescription)"
                    UIAlertController.okWithMessage(message, presentingViewController: self)
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        }
    }
}

