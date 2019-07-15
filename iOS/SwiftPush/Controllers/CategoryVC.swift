//
//  CategoryVC.swift
//  SwiftPush
//
//  Created by wooky83 on 15/07/2019.
//  Copyright © 2019 wooky. All rights reserved.
//

import UIKit

class CategoryVC: UIViewController {

    @IBOutlet private weak var accepted: UILabel!
    @IBOutlet private weak var rejected: UILabel!
    
    private var numAccepted = 0 {
        didSet {
            self.accepted.text = "\(numAccepted)"
        }
    }
    
    private var numRejected = 0 {
        didSet {
            self.rejected.text = "\(numRejected)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Notification.Name.acceptButton.onPost { [weak self] _ in
            self?.numAccepted += 1
        }
        Notification.Name.rejectButton.onPost { [weak self] _ in
            self?.numRejected += 1
        }
    }

}
