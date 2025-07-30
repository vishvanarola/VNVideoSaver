//
//  BannerAdRepresentableView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 27/07/25.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = AdManager.shared.bannerAdUnitID
        bannerView.rootViewController = UIApplication.shared.rootVC
        bannerView.load(Request())
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        
    }
}
