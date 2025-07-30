//
//  ReachabilityManager.swift
//  VNVideoSaver
//
//  Created by vishva narola on 06/07/25.
//

import Foundation
import Reachability

class ReachabilityManager: NSObject {
    
    // Shared instance
    static let shared = ReachabilityManager()
    
    // Indicates whether network is currently available
    private(set) var isNetworkAvailable: Bool = false
    
    // Current network connection type
    private(set) var reachabilityStatus: Reachability.Connection = .unavailable
    
    // Reachability instance
    private let reachability: Reachability
    
    // Custom notification name to notify status changes
    static let networkStatusChangedNotification = Notification.Name("NetworkStatusChangedNotification")
    
    override private init() {
        do {
            reachability = try Reachability()
        } catch {
            fatalError("Unable to create Reachability instance: \(error)")
        }
        super.init()
    }
    
    // Called when reachability changes
    @objc private func reachabilityChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        
        reachabilityStatus = reachability.connection
        isNetworkAvailable = reachability.connection != .unavailable
        
        switch reachability.connection {
        case .wifi:
            debugPrint("Network reachable through WiFi")
        case .cellular:
            debugPrint("Network reachable through Cellular Data")
        case .unavailable:
            debugPrint("Network became unreachable")
        }
        
        // Notify listeners about the change
        NotificationCenter.default.post(name: ReachabilityManager.networkStatusChangedNotification, object: nil)
    }
    
    // Start monitoring
    func startMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do {
            try reachability.startNotifier()
            reachabilityChanged(notification: Notification(name: .reachabilityChanged, object: reachability))
        } catch {
            debugPrint("Could not start Reachability notifier: \(error)")
        }
    }
    
    // Stop monitoring
    func stopMonitoring() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
}
