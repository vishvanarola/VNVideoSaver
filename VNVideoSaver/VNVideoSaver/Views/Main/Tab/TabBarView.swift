//
//  TabBarView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 27/07/25.
//

import SwiftUI

enum CustomTab {
    case home, myCollection, settings
}

struct TabBarView: View {
    @ObservedObject var adManager = AdManager.shared
    @State private var selectedTab: CustomTab = .home
    @State private var isTabBarHidden: Bool = false
    @State private var isHiddenBanner: Bool = false
    
    var body: some View {
        VStack {
            Group {
                switch selectedTab {
                case .home:
                    NewHomeView(isTabBarHidden: $isTabBarHidden, isHiddenBanner: $isHiddenBanner)
                case .myCollection:
                    MyCollectionsView(selectedTab: $selectedTab, isTabBarHidden: $isTabBarHidden, isHiddenBanner: $isHiddenBanner)
                case .settings:
                    SettingsView(selectedTab: $selectedTab, isTabBarHidden: $isTabBarHidden, isHiddenBanner: $isHiddenBanner)
                }
            }
            VStack(spacing: 0) {
                if !isTabBarHidden {
                    HStack {
                        tabBarItem(tab: .home, icon: "ic_selected_home", deselectIcon: "ic_deselected_home", label: "Home")
                        Spacer()
                        tabBarItem(tab: .myCollection, icon: "ic_selected_collection", deselectIcon: "ic_deselected_collection", label: "My Files")
                        Spacer()
                        tabBarItem(tab: .settings, icon: "ic_selected_settings", deselectIcon: "ic_deselected_settings", label: "Lock")
                    }
                    .padding(.horizontal)
                    .background(
                        Color.white.opacity(0.05)
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
                    )
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                }
                if !isHiddenBanner && !PremiumManager.shared.isPremium && adManager.isBannerAdLoaded {
                    BannerAdView()
                        .frame(height: 70)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func tabBarItem(tab: CustomTab, icon: String, deselectIcon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        Image(isSelected ? icon : deselectIcon)
            .resizable()
            .frame(width: 30, height: 30)
            .frame(width: 70, height: 70)
            .onTapGesture {
                AdManager.shared.showInterstitialAd()
                withAnimation {
                    selectedTab = tab
                }
            }
    }
}

#Preview {
    TabBarView()
}
