//
//  TimeIntervalViewController.swift
//  RocalPush
//
//  Created by wooky83 on 28/08/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit
import UserNotifications

final class TimeIntervalViewController: UIViewController, NotificationScheduler {
    @IBOutlet private weak var seconds: UITextField!
    @IBOutlet private weak var notificationTitle: UITextField!
    @IBOutlet private weak var badge: UITextField!
    @IBOutlet private weak var repeats: UISwitch!
    @IBOutlet private weak var sound: UISwitch!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        seconds.becomeFirstResponder()
    }
    
    @IBAction private func toggled() {
        view.endEditing(true)
    }
    
    @IBAction private func doneButtonTouched() {
        guard let interval = seconds.toTimeInterval(minimum: 1) else {
            UIAlertController.okWithMessage("Please specify a positive number of seconds.", presentingViewController: self)
            return
        }
        if repeats.isOn && interval < 60 {
            repeats.isOn = false
            UIAlertController.okWithMessage("Time interval must be at least 60 if repeating.", presentingViewController: self)
            return
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats.isOn)
        scheduleNotification(trigger: trigger, titleTextField: notificationTitle, sound: sound.isOn, badge: badge.text)
    }
}

extension TimeIntervalViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField !== notificationTitle, !string.isEmpty, let oldText = textField.text else { return true }
        
        let range = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: range, with: string)
        
        guard let value = TimeInterval(newText), value >= 0 else {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case seconds:
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
