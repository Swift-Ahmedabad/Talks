//
//  SharedManager.swift
//  AppIntentDemo
//
//  Created by Jay Kothadia on 15/12/24.
//

import Foundation

class SharedManager {
    static let shared = SharedManager()
    private init() {}
    
    let userRunsKey = "appGroup_user_runs"
    let userWicketsKey = "appGroup_user_wickets"
    let pageToOpen = "appGroup_page_to_open"
    let timerIsRunningKey = "appGroup_timer_is_running"
}
