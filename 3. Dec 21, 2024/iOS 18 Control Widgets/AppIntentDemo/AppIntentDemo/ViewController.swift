//
//  ViewController.swift
//  AppIntentDemo
//
//  Created by Jay Kothadia on 15/12/24.
//

import UIKit
import WidgetKit

class ViewController: UIViewController {

    @IBOutlet weak var lblRuns: UILabel!
    @IBOutlet weak var lblWickets: UILabel!
    
    let appGroupUserDefaults = AppGroup(identifier: .controlCentre).userDefaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabel(_:)), name: .didReceiveInput, object: nil)
        
        lblRuns.text = "1000"
        lblWickets.text = "55"
        
        appGroupUserDefaults?.set("1000", forKey: SharedManager.shared.userRunsKey)
        appGroupUserDefaults?.set("55", forKey: SharedManager.shared.userWicketsKey)
        
        ControlCenter.shared.reloadAllControls()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let intentMessage = AppDelegate.shared.intentMessage {
                self.lblRuns.text = intentMessage
            }
        }
    }
    
    @objc func updateLabel(_ notification: Notification) {
        if let input = notification.object as? String {
            self.lblRuns.text = input
        }
    }
}

extension Notification.Name {
    static let didReceiveInput = Notification.Name("didReceiveInput")
}
