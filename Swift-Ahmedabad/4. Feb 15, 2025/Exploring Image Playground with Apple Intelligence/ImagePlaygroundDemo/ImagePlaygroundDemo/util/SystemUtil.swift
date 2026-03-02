//
//  SystemUtil.swift
//  ImagePlaygroundDemo
//
//  Created by Rahul Chandnani on 15/02/25.
//

import Foundation
import UIKit

class SystemUtil {
    
    static func getViewController (storyboardIdentifier: String!, controllerIdentifier: String!) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: nil)
        let notificationVC = storyboard.instantiateViewController(withIdentifier: controllerIdentifier)
        return notificationVC
    }
    
    static func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

}
