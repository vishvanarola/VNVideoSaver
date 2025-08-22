//
//  NewHomeView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 20/08/25.
//

import SwiftUI

struct NewHomeView: View {
    @StateObject private var videoManager = VideoLibraryManager()
    @State private var navigationPath = NavigationPath()
    @State private var showNoInternetAlert: Bool = false
    @Binding var isTabBarHidden: Bool
    @Binding var isHiddenBanner: Bool
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                headerView
                ScrollView {
                    tools
                    videoListView
                }
                Spacer()
            }
            .ignoresSafeArea()
            .onAppear {
                videoManager.fetchVideos()
                if appComesFirst && !PremiumManager.shared.isPremium {
                    appComesFirst = false
                    isHideTabBackPremium = false
                    isTabBarHidden = true
                    navigationPath.append(HomeDestination.premium)
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
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 70, height: 30)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .frame(height: UIScreen.main.bounds.height * 0.15)
        .padding(.horizontal, 20)
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
        .padding(.top, 10)
    }
    
    func tool(image: String, destination: HomeDestination) -> some View {
        Button {
            isTabBarHidden = true
            AdManager.shared.showInterstitialAd()
            navigationPath.append(destination)
        } label: {
            Image(image)
                .resizable()
                .frame(width: (UIScreen.main.bounds.width - 56) / 2, height: (UIScreen.main.bounds.width - 56) / 2.5, alignment: .leading)
        }
    }
    
    var videoListView: some View {
        VStack {
            HStack {
                Text("Videos")
                    .font(FontConstants.MontserratFonts.bold(size: 20))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Spacer()
            }
            .padding(.horizontal, 20)
            if videoManager.videos.count <= 0 {
                VStack {
                    Spacer()
                    emptyStateView
                    Spacer()
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(videoManager.videos, id: \.self) { video in
                        VideoThumbnailViewNewHome(videoData: video)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
    }
    
    var emptyStateView: some View {
        VStack {
            Spacer()
            Image("ic_noData")
            Text("No Data Found")
                .font(FontConstants.MontserratFonts.medium(size: 20))
                .foregroundColor(.white.opacity(0.30))
            Spacer()
        }
        .padding(.bottom, 50)
    }
}

struct VideoThumbnailViewNewHome: View {
    @State var videoData: VideosArrayData?
    @State private var isPresentingPlayer = false
    @State private var showNoInternetAlert: Bool = false
    
    var body: some View {
        ZStack {
            Image("ic_collectionBack")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 80)
            HStack {
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
                Text(videoData?.title ?? "Video Name")
                    .font(FontConstants.MontserratFonts.medium(size: 18))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                Spacer()
            }
            .padding()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color(red: 26/255, green: 26/255, blue: 26/255).opacity(0.45))
        .cornerRadius(15)
        .padding(.bottom, 10)
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
    NewHomeView(isTabBarHidden: .constant(false), isHiddenBanner: .constant(false))
}
