//
//  AdManager.swift
//  VNVideoSaver
//
//  Created by vishva narola on 01/07/25.
//

import GoogleMobileAds
import AppTrackingTransparency
import UserMessagingPlatform
import AdSupport

class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    
    // MARK: App Open Ad Properties
    var appOpenAd: AppOpenAd?
    var appOpenAdUnitID: String = ""
    @Published var isAppOpenAdReady = false
    
    // MARK: Banner Ad Properties
    var bannerView: BannerView?
    var bannerAdUnitID: String = ""
    @Published var isBannerAdLoaded: Bool = false
    
    // MARK: Interstitial Ad Properties
    var interstitialAd: InterstitialAd?
    var interstitialAdUnitID: String = ""
    
    // MARK: App Open Ad Methods
    func loadAppOpenAd(_ isShowAd: Bool) {
        if !PremiumManager.shared.isPremium {
            guard !appOpenAdUnitID.isEmpty else {
                print("App Open Ad unit ID is empty.")
                return
            }
            
            AppOpenAd.load(with: appOpenAdUnitID, request: Request()) { [weak self] ad, error in
                if let error = error {
                    print("Failed to load App Open Ad: \(error.localizedDescription)")
                    self?.isAppOpenAdReady = false
                    return
                }
                
                self?.appOpenAd = ad
                self?.appOpenAd?.fullScreenContentDelegate = self
                if isShowAd {
                    self?.isAppOpenAdReady = true
                }
                print("App Open Ad loaded successfully.")
            }
        }
    }
    
    func showAppOpenAdIfAvailable() {
        if !PremiumManager.shared.isPremium {
            if let ad = appOpenAd {
                ad.present(from: UIApplication.shared.rootVC)
                isAppOpenAdReady = false
                loadAppOpenAd(false)
            } else {
                print("App Open Ad not ready. Triggering load.")
                loadAppOpenAd(false)
            }
        }
    }
    
    // MARK: Banner Ad Methods
    func loadBannerAd(adSize: AdSize = AdSizeBanner) {
        if !PremiumManager.shared.isPremium {
            guard !bannerAdUnitID.isEmpty else {
                print("Banner Ad unit ID is empty.")
                return
            }
            bannerView = BannerView(adSize: adSize)
            bannerView?.adUnitID = bannerAdUnitID
            bannerView?.rootViewController = UIApplication.shared.rootVC
            bannerView?.load(Request())
            print("Banner Ad loading...")
            bannerView?.delegate = self
        }
    }
    
    // MARK: Interstitial Ad Methods
    func loadInterstitialAd() {
        if !PremiumManager.shared.isPremium {
            guard !interstitialAdUnitID.isEmpty else {
                print("Interstitial Ad unit ID is empty.")
                return
            }
            
            InterstitialAd.load(with: interstitialAdUnitID, request: Request()) { [weak self] ad, error in
                if let error = error {
                    print("Failed to load Interstitial Ad: \(error.localizedDescription)")
                    self?.interstitialAd = nil
                    return
                }
                
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                print("Interstitial Ad loaded successfully.")
            }
        }
    }
    
    func showInterstitialAd() {
        if !PremiumManager.shared.isPremium {
            if interstitialIntergap == remoteConfigModel?.intergap ?? 3 {
                if let interstitialAd = interstitialAd {
                    interstitialAd.present(from: UIApplication.shared.rootVC)
                    interstitialIntergap -= 1
                    loadInterstitialAd()
                    loadBannerAd()
                } else {
                    print("Interstitial Ad is not ready. Loading a new one.")
                    loadInterstitialAd()
                }
            } else {
                interstitialIntergap = interstitialIntergap <= 0 ? remoteConfigModel?.intergap ?? 3 : interstitialIntergap-1
            }
        }
    }
    
    func configureAds(_ canShowUMP: Bool) {
        if canShowUMP {
            requestConsentIfNeeded()
        } else {
            requestTrackingPermission()
        }
    }
    
    func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("Authorized")
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    print("Denied")
                case .notDetermined:
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }
    
    private func requestConsentIfNeeded() {
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false
        
        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { error in
            if let error = error {
                print("Consent Request Error: \(error.localizedDescription)")
                return
            }
            
            switch ConsentInformation.shared.formStatus {
            case .available:
                ConsentForm.load { form, loadError in
                    if let loadError = loadError {
                        print("Consent Form Load Error: \(loadError.localizedDescription)")
                        return
                    }
                    
                    form?.present(from: UIApplication.shared.rootVC) { dismissError in
                        if let dismissError = dismissError {
                            print("Consent Form Dismiss Error: \(dismissError.localizedDescription)")
                        }
                    }
                }
            case .unavailable:
                print("case not available")
            case .unknown:
                print("case unknown")
            @unknown default:
                break
            }
        }
    }
}

// MARK: - FullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("App Open Ad dismissed. Loading next one.")
        if appOpenAd == nil {
            print("app open ad is nil and load again")
            loadAppOpenAd(false)
        }
        if interstitialAd == nil {
            print("interstitial ad is nil and load again")
            loadInterstitialAd()
        }
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        
        if appOpenAd == nil {
            print("app open ad is nil and load again")
            loadAppOpenAd(false)
        }
        if interstitialAd == nil {
            print("interstitial ad is nil and load again")
            loadInterstitialAd()
        }
    }
}

// MARK: - BannerViewDelegate
extension AdManager: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("Banner Ad loaded successfully.")
        isBannerAdLoaded = true
    }
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner Ad failed to load: \(error.localizedDescription)")
        isBannerAdLoaded = false
    }
}

//MARK: - Application Root View
extension UIApplication {
    var rootVC: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first(where: { $0.isKeyWindow })?.rootViewController
    }
}
