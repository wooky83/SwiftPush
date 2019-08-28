//
//  ViewController.swift
//  RocalPush
//
//  Created by wooky83 on 28/08/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

final class ViewController: UITableViewController, SegueHandlerType {
    @IBOutlet private weak var addButton: UIBarButtonItem!
    @IBOutlet private weak var refreshButton: UIBarButtonItem!
    
    enum SegueIdentifier : String {
        case timed, calendar, location
    }
    
    private let center = UNUserNotificationCenter.current()
    private var pending: [UNNotificationRequest] = []
    private var delivered: [UNNotification] = []
    
    private lazy var measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .medium
        formatter.unitOptions = .naturalScale
        return formatter
    }()
    
    private lazy var dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        return formatter
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func refreshNotificationList() {
        center.getPendingNotificationRequests() { [weak self] requests in
            guard let self = self else { return }
            self.pending = requests
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        center.getDeliveredNotifications() { [weak self] requests in
            guard let self = self else { return }
            self.delivered = requests
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard let self = self else { return }
            if granted {
                self.refreshNotificationList()
                self.center.delegate = self
            }
            self.addButton.isEnabled = granted
            self.refreshButton.isEnabled = granted
        }
    }
    
    private func configure(cell: UITableViewCell, with trigger: UNNotificationTrigger?, and content: UNNotificationContent?) {
        guard let content = content, trigger != nil else {
            cell.textLabel?.text = "None"
            cell.detailTextLabel?.text = ""
            return
        }
        
        if let trigger = trigger as? UNCalendarNotificationTrigger {
            cell.textLabel?.text = "Calendar - \(content.title)"
            
            let prefix = trigger.repeats ? "Every " : ""
            let when = Calendar.current.date(from: trigger.dateComponents)!
            cell.detailTextLabel?.text = prefix + dateFormatter.string(from: when)
        } else if let trigger = trigger as? UNTimeIntervalNotificationTrigger {
            cell.textLabel?.text = "Interval - \(content.title)"
            
            let prefix = trigger.repeats ? "Every " : ""
            cell.detailTextLabel?.text = prefix + dateComponentsFormatter.string(from: trigger.timeInterval)!
        } else if let trigger = trigger as? UNLocationNotificationTrigger {
            cell.textLabel?.text = "Location - \(content.title)"
            
            let region = trigger.region as! CLCircularRegion
            
            let measurement = Measurement(value: region.radius, unit: UnitLength.meters)
            let radius = measurementFormatter.string(from: measurement)
            
            cell.detailTextLabel?.text = "ɸ \(region.center.latitude), λ \(region.center.longitude), radius \(radius)"
        }
    }
    
    @IBAction private func addButtonPressed() {
        let timed = UIAlertAction(title: "Timed", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.performSegue(withIdentifier: .timed, sender: nil)
        }
        
        let calendar = UIAlertAction(title: "Calendar", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.performSegue(withIdentifier: .calendar, sender: nil)
        }
        
        let location = UIAlertAction(title: "Location", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.performSegue(withIdentifier: .location, sender: nil)
        }
        
        let alert = UIAlertController(title: "Type of trigger", message: "Please select the type of local notification you'd like to create.", preferredStyle: .actionSheet)
        alert.addAction(timed)
        alert.addAction(calendar)
        alert.addAction(location)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func refreshButtonPressed() {
        refreshNotificationList()
    }
}

// MARK: - UITableViewDataSource
extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0, !pending.isEmpty {
            return pending.count
        } else if section == 1, !delivered.isEmpty {
            return delivered.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "normal", for: indexPath)
        
        if indexPath.section == 0, !pending.isEmpty {
            configure(cell: cell, with: pending[indexPath.row].trigger, and: pending[indexPath.row].content)
        } else if indexPath.section == 1, !delivered.isEmpty {
            configure(cell: cell, with: delivered[indexPath.row].request.trigger, and: delivered[indexPath.row].request.content)
        } else {
            configure(cell: cell, with: nil, and: nil)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        if indexPath.section == 0 {
            guard !pending.isEmpty else { return }
            
            let request = pending[indexPath.row]
            center.removePendingNotificationRequests(withIdentifiers: [request.identifier])
        } else {
            guard !delivered.isEmpty else { return }
            
            let request = delivered[indexPath.row].request
            center.removeDeliveredNotifications(withIdentifiers: [request.identifier])
        }
        
        refreshNotificationList()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Pending" : "Delivered"
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension ViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        refreshNotificationList()
        
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            addButtonPressed()
        }
    }
}
