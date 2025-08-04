//
//  VNVideoSaverApp.swift
//  VNVideoSaver
//
//  Created by vishva narola on 26/07/25.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct VNVideoSaverApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject var adManager = AdManager.shared
    
    init() {
        ReachabilityManager.shared.startMonitoring()
        
        FirebaseApp.configure()
        
        PremiumManager.shared.configureRevenueCat()
        
        AdServices().fetchNewRemoteAdsData { response in
            AdManager.shared.configureAds(response.canShowUMP ?? false)
            interstitialIntergap = response.intergap ?? 3
            remoteConfigAdShowCount = response.intergap ?? 3
            restoreShow = response.restoreShow ?? false
            if let appOpenAdUnitID = response.appOpen {
                AdManager.shared.appOpenAdUnitID = appOpenAdUnitID
                if !PremiumManager.shared.isPremium {
                    AdManager.shared.loadAppOpenAd(true)
                }
            }
            
            if let bannerAdUnitID = response.banner {
                AdManager.shared.bannerAdUnitID = bannerAdUnitID
            }
            
            if let interstitialAdUnitID = response.interstitial {
                AdManager.shared.interstitialAdUnitID = interstitialAdUnitID
                AdManager.shared.loadInterstitialAd()
            }
            
        } failure: { error in
            print("error remote config fetch: \(error)")
        }
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Collage.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .onAppear {
                    if !PremiumManager.shared.isPremium {
                        showAppOpenAd()
                        showBannerAd()
                    }
                }
                .onReceive(adManager.$isAppOpenAdReady) { isReady in
                    if isReady && !PremiumManager.shared.isPremium {
                        showAppOpenAd()
                        showBannerAd()
                    }
                }
                .onChange(of: scenePhase) { oldValue, newValue in
                    if newValue == .active && !PremiumManager.shared.isPremium {
                        showAppOpenAd()
                        showBannerAd()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    func showAppOpenAd() {
        AdManager.shared.showAppOpenAdIfAvailable()
    }
    
    func showBannerAd() {
        AdManager.shared.loadBannerAd()
    }
}
