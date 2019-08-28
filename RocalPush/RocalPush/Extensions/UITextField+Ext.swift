//
//  UITextField+Ext.swift
//  RocalPush
//
//  Created by wooky83 on 28/08/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit

extension UITextField {
    func toInt(minimum: Int = 0, maximum: Int? = nil) -> Int? {
        guard let value = toTrimmedString(), let ret = Int(value), ret >= minimum else {
            return nil
        }
        
        if let maximum = maximum, ret > maximum {
            return nil
        }
        
        return ret
    }
    
    func toTimeInterval(minimum: TimeInterval = 0) -> TimeInterval? {
        guard let value = toTrimmedString(), let ret = TimeInterval(value), ret >= minimum else {
            return nil
        }
        
        return ret
    }
    
    func toTrimmedString() -> String? {
        let ws = CharacterSet.whitespacesAndNewlines
        guard let trimmed = text?.trimmingCharacters(in: ws), !trimmed.isEmpty else {
            return nil
        }
        
        return trimmed
    }
}
