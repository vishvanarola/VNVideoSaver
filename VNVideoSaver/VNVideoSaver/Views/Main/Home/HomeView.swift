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
                    if !randomVideos.isEmpty {
                        videoListView
                        Spacer()
                    }
                    tools
                    Spacer()
                }
                .ignoresSafeArea()
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
                    PremiumView(isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath, isHiddenBanner: $isHiddenBanner)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    
    var headerView: some View {
        VStack {
            Spacer()
            HStack {
                Text(homeAppName)
                    .font(FontConstants.SyneFonts.semiBold(size: 23))
                    .foregroundStyle(Color.white)
                    .overlay(
                        LinearGradient(
                            colors: [redThemeColor, pinkGradientColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .mask(
                        Text(homeAppName)
                            .font(FontConstants.SyneFonts.semiBold(size: 23))
                    )
                Spacer()
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
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 70, height: 30)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(height: UIScreen.main.bounds.height * 0.15)
        .padding(.horizontal, 20)
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
        .padding(.horizontal, 20)
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
        .padding(.horizontal, 20)
    }
    
    var videoListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    Color.clear
                        .frame(height: 1)
                        .background(
                            GeometryReader { geo -> Color in
                                DispatchQueue.main.async {
                                    isUserAtTop = geo.frame(in: .named("scroll")).minY >= -10
                                }
                                return Color.clear
                            }
                        )
                        .id("top")
                    
                    ForEach(randomVideos) { item in
                        VideoThumbnailView(videoData: item.data)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
                .padding(.bottom, 5)
            }
            .coordinateSpace(name: "scroll")
            .onChange(of: randomVideos) { _, _ in
                if !isUserAtTop {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    var tools: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                tool(image: "ic_compress_video", destination: .compress)
                tool(image: "ic_reverse_video", destination: .reverse)
            }
            HStack(spacing: 16) {
                tool(image: "ic_slowmotion_video", destination: .slowmotion)
                tool(image: "ic_get_hashtag", destination: .hashtag)
            }
        }
        .padding(.top, 20)
    }
    
    func tool(image: String, destination: HomeDestination) -> some View {
        Button {
            isTabBarHidden = true
            navigationPath.append(destination)
        } label: {
            Image(image)
                .resizable()
                .frame(width: (UIScreen.main.bounds.width - 56) / 2, height: (UIScreen.main.bounds.width - 56) / 2.5, alignment: .leading)
        }
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

struct VideoThumbnailView: View {
    @State var videoData: VideosArrayData?
    @State private var isPresentingPlayer = false
    @State private var showNoInternetAlert: Bool = false
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.black.opacity(0.1))
                AsyncImage(url: URL(string: videoData?.videoThumb ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 60, height: 60)
                .cornerRadius(10)
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(videoData?.title ?? "Video Name")
                    .font(FontConstants.MontserratFonts.semiBold(size: 15))
                    .lineLimit(2)
                    .foregroundStyle(Color.primary)
                Text(videoData?.size ?? "--")
                    .font(FontConstants.MontserratFonts.medium(size: 14))
                    .foregroundStyle(textGrayColor)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(10)
        .background(textGrayColor.opacity(0.2))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 0)
        .onTapGesture {
            if ReachabilityManager.shared.isNetworkAvailable {
                isPresentingPlayer = true
            } else {
                showNoInternetAlert = true
            }
        }
        .sheet(isPresented: $isPresentingPlayer) {
            if let urlString = videoData?.videoUrl, let url = URL(string: urlString) {
                VideoPlayerView(videoURL: url)
            } else {
                Text("Invalid video URL")
            }
        }
        .noInternetAlert(isPresented: $showNoInternetAlert)
    }
}

#Preview {
    HomeView(isTabBarHidden: .constant(false), isHiddenBanner: .constant(false))
}
