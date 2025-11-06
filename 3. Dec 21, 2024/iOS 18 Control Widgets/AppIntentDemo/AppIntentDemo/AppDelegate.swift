//
//  AppDelegate.swift
//  AppIntentDemo
//
//  Created by Jay Kothadia on 15/12/24.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let shared = UIApplication.shared.delegate as! AppDelegate
    var window: UIWindow?
    var intentMessage: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard url.scheme == "myApp", url.host == "displayInput",
              let input = url.pathComponents.dropFirst().first else { return false }
        NotificationCenter.default.post(name: .didReceiveInput, object: input)
        return true
    }

}

