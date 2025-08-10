//
//  SettingsView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 31/07/25.
//

import SwiftUI

enum SettingsRoute: Hashable {
    case premium
}

enum SettingsTool: String {
    case share_app
    case rate_us
    case terms_conditions
    case privacy_policy
}

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @State private var navigationPath = NavigationPath()
    @State private var showNoInternetAlert: Bool = false
    @State private var isShowingShareSheet = false
    @Binding var selectedTab: CustomTab
    @Binding var isTabBarHidden: Bool
    @Binding var isHiddenBanner: Bool
    @ObservedObject var adManager = AdManager.shared
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                headerView
                if !PremiumManager.shared.isPremium {
                    premiumView
                }
                tools
                if let isShowNativeSettings = remoteConfigModel?.isShowNativeSettings, isShowNativeSettings == true && !PremiumManager.shared.isPremium {
                    nativeAdView
                }
                Spacer()
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .premium:
                    PremiumView(isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath, isHiddenBanner: $isHiddenBanner)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .noInternetAlert(isPresented: $showNoInternetAlert)
            .sheet(isPresented: $isShowingShareSheet) {
                if let appUrl = appLink {
                    ActivityView(activityItems: [appUrl])
                }
            }
        }
    }
    
    var headerView: some View {
        VStack {
            Spacer()
            HStack {
                Text("Settings")
                    .font(FontConstants.SyneFonts.semiBold(size: 23))
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .frame(height: UIScreen.main.bounds.height * 0.15)
        .padding(.horizontal, 20)
    }
    
    var premiumView: some View {
        Button {
            if ReachabilityManager.shared.isNetworkAvailable {
                AdManager.shared.showInterstitialAd()
                isHideTabBackPremium = false
                isTabBarHidden = true
                navigationPath.append(SettingsRoute.premium)
            } else {
                showNoInternetAlert = true
            }
        } label: {
            ZStack {
                HStack(spacing: 0) {
                    Image("ic_crown")
                    VStack(alignment: .leading, spacing: 9) {
                        Text("Get Premium")
                            .font(FontConstants.SyneFonts.medium(size: 22))
                            .foregroundStyle(Color.black)
                        Text("Get full access to all our features")
                            .font(FontConstants.SyneFonts.regular(size: 18))
                            .foregroundStyle(Color.black.opacity(0.7))
                    }
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 249/255, green: 160/255, blue: 56/255),
                            Color(red: 1.0, green: 223/255, blue: 107/255)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(30)
                .clipped()
            }
            .padding(.horizontal, 20)
        }
    }
    
    var tools: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                tool(image: "ic_share_app", tool: .share_app)
                tool(image: "ic_rate_us", tool: .rate_us)
            }
            HStack(spacing: 16) {
                tool(image: "ic_terms_conditions", tool: .terms_conditions)
                tool(image: "ic_privacy_policy", tool: .privacy_policy)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func tool(image: String, tool: SettingsTool) -> some View {
        Button {
            switch tool {
            case .share_app:
                isShowingShareSheet = true
            case .rate_us:
                if let url = appRateLink {
                    openUrls(url)
                }
            case .terms_conditions:
                if let url = termsCondition {
                    openUrls(url)
                }
            case .privacy_policy:
                if let url = privacyPolicy {
                    openUrls(url)
                }
            }
        } label: {
            Image(image)
        }
    }
    
    func openUrls(_ url: URL) {
        if ReachabilityManager.shared.isNetworkAvailable {
            openURL(url)
        } else {
            showNoInternetAlert = true
        }
    }
    
    var nativeAdView: some View {
        Group {
            GADNativeViewControllerWrapper()
                .padding(.horizontal, 20)
                .padding(.top)
        }
    }
}

#Preview {
    SettingsView(selectedTab: .constant(.settings), isTabBarHidden: .constant(false), isHiddenBanner: .constant(false))
}
