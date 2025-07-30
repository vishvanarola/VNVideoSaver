//
//  HomeView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 27/07/25.
//

import SwiftUI

enum HomeDestination: Hashable {
    case compress
    case reverse
    case slowmotion
    case hashtag
    case premium
}

struct VideosArrayData: Hashable {
    var title: String
    var videoUrl: String
    var videoThumb: String
    var size: String
}

struct RandomVideoItem: Identifiable, Hashable {
    let id = UUID()
    let data: VideosArrayData
}

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showNoInternetAlert: Bool = false
    @State private var enterTextInput: String = ""
    @State private var isFindTapped: Bool = false
    @State private var showToast = false
    @State private var toastText: String = "Copied"
    @State private var isUserAtTop: Bool = true
    @State private var randomVideos = [RandomVideoItem]()
    @Binding var isTabBarHidden: Bool
    @Binding var isHiddenBanner: Bool
    @Namespace private var topID
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                VStack {
                    headerView
                    textFieldView
                    findButton
                    tools
                    Spacer()
                }
                .padding(.horizontal, 20)
                if showToast {
                    VStack {
                        Spacer()
                        Text(toastText)
                            .font(FontConstants.MontserratFonts.medium(size: 17))
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .compress:
                    CompressVideoView(isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath)
                        .navigationBarBackButtonHidden(true)
                case .reverse:
                    ReverseVideoView(isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath)
                        .navigationBarBackButtonHidden(true)
                case .slowmotion:
                    SlowmotionVideoView(isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath)
                        .navigationBarBackButtonHidden(true)
                case .hashtag:
                    GetHashtagView(isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath)
                        .navigationBarBackButtonHidden(true)
                case .premium:
                    PremiumView()
                }
            }
        }
    }
    
    var headerView: some View {
        HStack {
            Text(homeAppName)
                .font(FontConstants.SyneFonts.semiBold(size: 23))
                .foregroundStyle(Color.white)
            Spacer()
            if !PremiumManager.shared.isPremium {
                Button {
                    if ReachabilityManager.shared.isNetworkAvailable {
                        isHideTabBackPremium = false
                        isTabBarHidden = true
                        navigationPath.append(HomeDestination.premium)
                    } else {
                        showNoInternetAlert = true
                    }
                } label: {
                    Image("ic_pro")
                }
            } else {
                Spacer()
                Spacer()
            }
        }
        .padding(.bottom, 20)
    }
    
    var textFieldView: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 20) {
                TextField("", text: $enterTextInput, prompt: Text("Type or Past URl ")
                    .font(FontConstants.MontserratFonts.medium(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                )
                .font(FontConstants.MontserratFonts.semiBold(size: 16))
                .keyboardType(.URL)
                .cornerRadius(20)
                .shadow(radius: 3)
                Button {
                    if !enterTextInput.isEmpty {
                        toastText = "Copied"
                        UIPasteboard.general.string = enterTextInput
                        showToasts()
                    }
                } label: {
                    Image("ic_copy")
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 50)
            .background(textGrayColor.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.white, .clear]),
                            startPoint: .init(x: 0.5, y: -10),
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .cornerRadius(20)
            if !PremiumManager.shared.isPremium {
                Image("ic_text_pro")
                    .padding(.top, -10)
                    .padding(.trailing, 70)
            }
        }
    }
    
    var findButton: some View {
        Button {
            if self.isValidURLRegex(enterTextInput) {
                if PremiumManager.shared.isPremium {
                    if let random = videosArray.randomElement() {
                        isFindTapped = true
                        let newItem = RandomVideoItem(data: random)
                        randomVideosGlob.insert(newItem, at: 0)
                        randomVideos.insert(newItem, at: 0)
                        if randomVideos.count > 50 {
                            randomVideos.removeLast()
                        }
                    }
                } else {
                    isHideTabBackPremium = false
                    isTabBarHidden = true
                    navigationPath.append(HomeDestination.premium)
                }
            } else {
                toastText = "Plase enter a valid URL"
                showToasts()
            }
        } label: {
            Text("Find your Video")
                .font(FontConstants.MontserratFonts.medium(size: 18))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: [redThemeColor, pinkGradientColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
        .cornerRadius(30)
        .padding(.top)
    }
    
    var tools: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image("ic_compress_video")
                    .resizable()
                    .frame(width: (UIScreen.main.bounds.width - 56) / 2, height: (UIScreen.main.bounds.width - 56) / 2.5, alignment: .leading)
                    .onTapGesture {
                        isTabBarHidden = true
                        navigationPath.append(HomeDestination.compress)
                    }
                Image("ic_reverse_video")
                    .resizable()
                    .frame(width: (UIScreen.main.bounds.width - 56) / 2, height: (UIScreen.main.bounds.width - 56) / 2.5, alignment: .leading)
                    .onTapGesture {
                        isTabBarHidden = true
                        navigationPath.append(HomeDestination.reverse)
                    }
            }
            HStack(spacing: 16) {
                Image("ic_slowmotion_video")
                    .resizable()
                    .frame(width: (UIScreen.main.bounds.width - 56) / 2, height: (UIScreen.main.bounds.width - 56) / 2.5, alignment: .leading)
                    .onTapGesture {
                        isTabBarHidden = true
                        navigationPath.append(HomeDestination.slowmotion)
                    }
                Image("ic_get_hashtag")
                    .resizable()
                    .frame(width: (UIScreen.main.bounds.width - 56) / 2, height: (UIScreen.main.bounds.width - 56) / 2.5, alignment: .leading)
                    .onTapGesture {
                        isTabBarHidden = true
                        navigationPath.append(HomeDestination.hashtag)
                    }
            }
        }
        .padding(.top, 20)
    }
    
    func tool(image: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(image)
                    .resizable()
                    .frame(width: 40, height: 40)
                Spacer()
                Image("ic_tools")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
            Text(text)
                .font(FontConstants.MontserratFonts.regular(size: 14))
                .foregroundColor(.white)
        }
        .padding()
        .frame(width: (UIScreen.main.bounds.width - 56) / 2, height: (UIScreen.main.bounds.width - 56) / 2.5, alignment: .leading)
        .background(textGrayColor.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .clear]),
                        startPoint: .init(x: 0.5, y: -10),
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
        )
        .cornerRadius(30)
    }
    
    func showToasts() {
        withAnimation {
            showToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showToast = false
            }
        }
    }
    
    func isValidURLRegex(_ urlString: String) -> Bool {
        let pattern = #"^(http|https)://([\w-]+(\.[\w-]+)+)([/#?]?.*)$"#
        return urlString.range(of: pattern, options: .regularExpression) != nil
    }
}

#Preview {
    HomeView(isTabBarHidden: .constant(false), isHiddenBanner: .constant(false))
}
