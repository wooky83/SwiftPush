//
//  Notification.swift
//  SwiftPush
//
//  Created by wooky83 on 15/07/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let acceptButton = Notification.Name("acceptTapped")
    static let rejectButton = Notification.Name("rejectTapped")
    
    func post(center: NotificationCenter = NotificationCenter.default, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        center.post(name: self, object: object, userInfo: userInfo)
    }
    
    @discardableResult
    func onPost(center: NotificationCenter = NotificationCenter.default, object: Any? = nil, queue: OperationQueue? = nil, using: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return center.addObserver(forName: self, object: object, queue: queue, using: using)
    }
    
}
