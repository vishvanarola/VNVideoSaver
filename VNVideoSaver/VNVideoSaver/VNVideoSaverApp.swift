//
//  VNVideoSaverApp.swift
//  VNVideoSaver
//
//  Created by vishva narola on 26/07/25.
//

import SwiftUI

@main
struct VNVideoSaverApp: App {
    
    init() {
        ReachabilityManager.shared.startMonitoring()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
