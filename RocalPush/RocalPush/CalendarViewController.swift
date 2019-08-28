//
//  CalendarViewController.swift
//  RocalPush
//
//  Created by wooky83 on 28/08/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit
import UserNotifications

final class CalendarViewController: UIViewController, NotificationScheduler {
    @IBOutlet private weak var hour: UITextField!
    @IBOutlet private weak var minute: UITextField!
    @IBOutlet private weak var second: UITextField!
    @IBOutlet private weak var notificationTitle: UITextField!
    @IBOutlet private weak var badge: UITextField!
    @IBOutlet private weak var repeats: UISwitch!
    @IBOutlet private weak var sound: UISwitch!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hour.becomeFirstResponder()
    }
    
    @IBAction private func toggled() {
        view.endEditing(true)
    }
    
    @IBAction private func doneButtonTouched() {
        var components = DateComponents()
        components.second = second.toInt(minimum: 1, maximum: 59)
        components.minute = minute.toInt(minimum: 1, maximum: 59)
        components.hour = hour.toInt(minimum: 1, maximum: 23)
        
        if components.second == nil && components.minute == nil && components.hour == nil {
            UIAlertController.okWithMessage("Please specify hour, minute and/or second.", presentingViewController: self)
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats.isOn)
        scheduleNotification(trigger: trigger, titleTextField: notificationTitle, sound: sound.isOn, badge: badge.text)
    }
}


extension CalendarViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField !== notificationTitle, !string.isEmpty, let oldText = textField.text else { return true }
        
        let range = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: range, with: string)
        
        let min = textField === badge ? 0 : -1
        guard let value = Int(newText), value > min else {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case hour:
            minute.becomeFirstResponder()
        case minute:
            second.becomeFirstResponder()
        case second:
            notificationTitle.becomeFirstResponder()
        case notificationTitle:
            badge.becomeFirstResponder()
        case badge:
            textField.resignFirstResponder()
        default:
            break
        }
        
        return false
    }
}

