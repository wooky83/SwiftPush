//
//  SegueHandlerType.swift
//  RocalPush
//
//  Created by wooky83 on 28/08/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit

/**
 * A protocol that represents a segue identifier in the storyboard.  Every view controller that
 * inherits this protocol should define the `SegueIdentifier` enum to be of type `String`, and
 * there should be a case name that **exactly** matches what is in the storyboard.
 *
 * ```swift
 * class SomeViewController : UIViewController, SegueHandlerType {
 *   enum SegueIdentifier : String {
 *     case ShowSomething, ReturnHome
 *   }
 *
 *   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 *     guard let ident = segueIdentifier(forSegue: segue) else { return }
 *
 *     switch ident {
 *     case .ShowSomething: ...
 *     case .ReturnHome: ...
 *     }
 *   }
 *
 *   @IBAction private someAction() {
 *     ...
 *     performSegue(withIdentifier: .ShowSomething, sender: self)
 *   }
 * }
 */

@available(iOS 9.0, OSX 10.10, *)
protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

@available(iOS 9.0, OSX 10.10, *)
extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
    func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    func segueIdentifier(forSegue segue: UIStoryboardSegue) -> SegueIdentifier? {
        // It's quite possible to have no identifier.
        guard let identifier = segue.identifier else { return nil }
        
        return SegueIdentifier(rawValue: identifier)
    }
    
    func shouldPerformSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) -> Bool {
        return shouldPerformSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
}
