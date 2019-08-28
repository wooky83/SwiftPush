//
//  LocationDetailsViewController.swift
//  RocalPush
//
//  Created by wooky83 on 28/08/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

final class LocationDetailsViewController: UIViewController, NotificationScheduler {
    @IBOutlet private weak var radius: UITextField!
    @IBOutlet private weak var notificationTitle: UITextField!
    @IBOutlet private weak var badge: UITextField!
    @IBOutlet private weak var repeats: UISwitch!
    @IBOutlet private weak var notifyOnExit: UISwitch!
    @IBOutlet private weak var notifyOnEntry: UISwitch!
    @IBOutlet private weak var sound: UISwitch!
    
    private let numberFormatter = NumberFormatter()
    
    var coordinate: CLLocationCoordinate2D!
    
    @IBAction private func toggled() {
        view.endEditing(true)
    }
    
    @IBAction private func doneButtonTouched(_ sender: UIBarButtonItem) {
        guard let radiusStr = radius.toTrimmedString(), let distance = CLLocationDistance(radiusStr) else {
            UIAlertController.okWithMessage("Please specify radius.", presentingViewController: self)
            return
        }
        
        let region = CLCircularRegion(center: coordinate, radius: distance, identifier: UUID().uuidString)
        region.notifyOnExit = notifyOnExit.isOn
        region.notifyOnEntry = notifyOnEntry.isOn
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: repeats.isOn)
        scheduleNotification(trigger: trigger, titleTextField: notificationTitle, sound: sound.isOn, badge: badge.text)
    }
}

extension LocationDetailsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField !== notificationTitle, !string.isEmpty, let oldText = textField.text else { return true }
        
        let range = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: range, with: string)
        
        if textField === radius {
            guard let value = numberFormatter.number(from: newText), value.doubleValue > 0 else {
                return false
            }
        } else if textField === badge {
            guard let value = Int(newText), value >= 0 else {
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case radius:
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

