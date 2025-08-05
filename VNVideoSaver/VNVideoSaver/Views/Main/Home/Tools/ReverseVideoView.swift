//
//  ReverseVideoView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 28/07/25.
//

import SwiftUI
import PhotosUI
import AVKit
import AVFoundation

struct ReverseVideoView: View {
    @State private var isVideoPicked = false
    @State private var showVideoPicker = false
    @State private var pickedVideoURL: URL? = nil
    @State private var player: AVPlayer? = nil
    @State private var convertedVideoURL: URL? = nil
    @State private var isPlaying = false
    @State private var showToast = false
    @State private var toastText = "Video converted successfully"
    @State private var showNoInternetAlert: Bool = false
    @Binding var isTabBarHidden: Bool
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                videoView
                Spacer()
                outputButton
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
                        .padding(.bottom, 50)
                }
            }
        }
        .animation(.easeInOut, value: showToast)
        .sheet(isPresented: $showVideoPicker) {
            VideoPicker { url in
                self.pickedVideoURL = url
                if let url = url {
                    let newPlayer = AVPlayer(url: url)
                    self.player = newPlayer
                    self.isVideoPicked = true
                    self.isPlaying = false
                    self.configurePlayer(newPlayer)
                }
            }
        }
        .noInternetAlert(isPresented: $showNoInternetAlert)
        .ignoresSafeArea(.all, edges: .top)
    }
    
    var headerView: some View {
        HeaderView(
            leftButtonImageName: "ic_back",
            rightButtonImageName: isVideoPicked ? "ic_share" : "ic_white_plus",
            headerTitle: "Reverse",
            leftButtonAction: {
                isTabBarHidden = false
                AdManager.shared.showInterstitialAd()
                navigationPath.removeLast()
            }, rightButtonAction: {
                if isVideoPicked, let convertedURL = convertedVideoURL {
                    shareVideo(url: convertedURL)
                } else {
                    showVideoPicker = true
                }
            }
        )
    }
    
    var videoView: some View {
        Group {
            if let player = player {
                ZStack {
                    VideoPlayer(player: player)
                        .cornerRadius(12)
                        .padding(.vertical, 20)
                        .onAppear {
                            player.pause()
                            isPlaying = false
                            
                            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                                player.seek(to: .zero) { _ in
                                    isPlaying = false
                                }
                            }
                        }
                        .onDisappear {
                            player.pause()
                            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                        }
                    Button {
                        AdManager.shared.showInterstitialAd()
                        if isPlaying {
                            player.pause()
                        } else {
                            player.play()
                        }
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(redThemeColor.opacity(0.5))
                            .shadow(radius: 10)
                    }
                }
            } else {
                Rectangle()
                    .fill(backgroundGrayColor)
                    .cornerRadius(10)
                    .padding(.vertical, 20)
            }
        }
    }
    
    var outputButton: some View {
        ThemeButtonView(buttonTitle: "Reverse Now") {
            if let url = pickedVideoURL {
                if ReachabilityManager.shared.isNetworkAvailable {
                    if PremiumManager.shared.isPremium || !PremiumManager.shared.hasUsed() {
                        AdManager.shared.showInterstitialAd()
                        reverseVideo(originalURL: url)
                    } else {
                        navigationPath.append(HomeDestination.premium)
                    }
                } else {
                    showNoInternetAlert = true
                }
            } else {
                toastText = "Please select the Video first!"
                showToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showToast = false
                }
            }
        }
        .padding(.bottom)
    }
    
    func reverseVideo(originalURL: URL) {
        PremiumManager.shared.markUsed()
    }
    
    func shareVideo(url: URL) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        rootVC.present(vc, animated: true)
    }
    
    func configurePlayer(_ player: AVPlayer) {
        player.pause()
        isPlaying = false
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero) { _ in
                isPlaying = false
            }
        }
    }
}

#Preview {
    ReverseVideoView(isTabBarHidden: .constant(true), navigationPath: .constant(NavigationPath()))
}
