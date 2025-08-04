//
//  PremiumView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 28/07/25.
//

import SwiftUI
import RevenueCat

struct PremiumView: View {
    @ObservedObject private var premiumManager = PremiumManager.shared
    @Environment(\.openURL) var openURL
    @State private var selectedPlanIndex = 0
    @State private var isPurchasing = false
    @State private var activeAlert: PremiumAlertType?
    @Binding var isTabBarHidden: Bool
    @Binding var navigationPath: NavigationPath
    @Binding var isHiddenBanner: Bool
    
    var body: some View {
        ZStack {
            backgroundView.ignoresSafeArea()
            
            VStack(spacing: 0) {
                restoreView
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 30) {
                            headerView
                            featuresView
                            subscriptionPlansView
                            Color.clear.frame(height: 1).id("BOTTOM")
                        }
                        .padding(.top, 10)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            withAnimation(.easeOut(duration: 2)) {
                                proxy.scrollTo("BOTTOM", anchor: .bottom)
                            }
                        }
                    }
                }
                
                VStack(spacing: 16) {
                    getAllAccessButton
                    footerView
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            isHiddenBanner = true
            if premiumManager.products.isEmpty {
                premiumManager.fetchProducts()
            }
        }
        .onDisappear {
            isHiddenBanner = false
        }
        .alert(item: $activeAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK")) {
                    if case .success = alert {
                        isTabBarHidden = isHideTabBackPremium
                        navigationPath.removeLast()
                    } else if case .restore = alert {
                        isTabBarHidden = isHideTabBackPremium
                        navigationPath.removeLast()
                    }
                }
            )
        }
    }
    
    var backgroundView: some View {
        ZStack(alignment: .top) {
            Image("ic_premium_header")
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black.opacity(0.9), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var restoreView: some View {
        HStack {
            if restoreShow {
                Button {
                    premiumManager.restorePurchases { success, error in
                        DispatchQueue.main.async {
                            if success {
                                premiumManager.checkPremiumStatus()
                                activeAlert = .restore("Enjoy app without ads!")
                            } else {
                                activeAlert = .error(error ?? "Restore failed.")
                            }
                        }
                    }
                } label: {
                    Text("Restore")
                        .font(FontConstants.SyneFonts.medium(size: 20))
                        .foregroundStyle(textGrayColor)
                }
            }
            Spacer()
            Button {
                AdManager.shared.showInterstitialAd()
                isTabBarHidden = isHideTabBackPremium
                navigationPath.removeLast()
            } label: {
                Image("ic_close")
                    .resizable()
                    .scaledToFit()
            }
            .frame(width: 30, height: 30)
        }
        .padding(.top)
    }
    
    var headerView: some View {
        VStack(spacing: 10) {
            Text("Unlock Premium")
                .font(FontConstants.SyneFonts.semiBold(size: 35))
                .overlay(
                    LinearGradient(colors: [redThemeColor, pinkGradientColor],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .mask(
                    Text("Unlock Premium")
                        .font(FontConstants.SyneFonts.semiBold(size: 35))
                )
            
            Text("access now")
                .font(FontConstants.SyneFonts.semiBold(size: 25))
                .foregroundStyle(.white)
        }
    }
    
    var featuresView: some View {
        VStack(spacing: 16) {
            featureView(text: "HD Quality")
            featureView(text: "Ads Free 100%")
            featureView(text: "Unlimited all Access")
            featureView(text: "Find Trending Hashtag")
            featureView(text: "High Speed Connectivity")
        }
    }
    
    func featureView(text: String) -> some View {
        HStack(spacing: 15) {
            Image("ic_square_check")
            Text(text)
                .font(FontConstants.SyneFonts.medium(size: 20))
            Spacer()
        }
    }
    
    var subscriptionPlansView: some View {
        VStack(spacing: 10) {
            ForEach(Array(premiumManager.products.enumerated()), id: \.element.productIdentifier) { index, product in
                Button {
                    AdManager.shared.showInterstitialAd()
                    selectedPlanIndex = index
                } label: {
                    SubscriptionPlanCell(
                        product: product,
                        isSelected: selectedPlanIndex == index
                    )
                }
                .padding(.horizontal, 1)
            }
        }
    }
    
    var getAllAccessButton: some View {
        Button {
            guard premiumManager.products.indices.contains(selectedPlanIndex) else { return }
            let product = premiumManager.products[selectedPlanIndex]
            
            isPurchasing = true
            premiumManager.purchase(product: product) { success, error in
                DispatchQueue.main.async {
                    isPurchasing = false
                    if success {
                        premiumManager.checkPremiumStatus()
                        activeAlert = .success("Enjoy app without ads!")
                    } else {
                        activeAlert = .error(error ?? "Purchase failed.")
                    }
                }
            }
        } label: {
            Text("Get All Access")
                .font(FontConstants.SyneFonts.semiBold(size: 20))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [redThemeColor, pinkGradientColor]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
        }
        .disabled(isPurchasing || premiumManager.isLoadingProducts)
    }
    
    var footerView: some View {
        HStack(spacing: 0) {
            Button {
                if let url = privacyPolicy {
                    openURL(url)
                }
            } label: { Text("▪︎  Privacy & Policy") }
            Spacer()
            Button {
                if let url = termsCondition {
                    openURL(url)
                }
            } label: { Text("▪︎  Terms & Condition") }
            Spacer()
            Button {
                if let url = EULA {
                    openURL(url)
                }
            } label: { Text("▪︎  EULA") }
        }
        .font(FontConstants.SyneFonts.light(size: 14))
        .foregroundStyle(.white)
    }
}

struct SubscriptionPlanCell: View {
    let product: StoreProduct
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("\(product.localizedPriceString)/ \(product.sk2Product?.description ?? "")")
                    .font(FontConstants.MontserratFonts.semiBold(size: 20))
                    .foregroundStyle(.white)
                Text(product.localizedTitle)
                    .font(isSelected ?
                          FontConstants.MontserratFonts.semiBold(size: 17) :
                            FontConstants.MontserratFonts.medium(size: 17))
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            if isSelected {
                Image("ic_circle_fill")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            isSelected ?
            AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [redThemeColor, pinkGradientColor]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            ) :
                AnyView(Color(red: 26/255, green: 26/255, blue: 26/255).opacity(0.45))
        )
        .cornerRadius(20)
        .overlay(
            Group {
                if !isSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.5), .black],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            }
        )
    }
}

#Preview {
    PremiumView(isTabBarHidden: .constant(true), navigationPath: .constant(NavigationPath()), isHiddenBanner: .constant(true))
}
