//
//  SlowmotionVideoView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 28/07/25.
//

import SwiftUI
import PhotosUI
import AVKit
import AVFoundation

enum SlowmotionType {
    case slow025x
    case slow075x
    case slow2x
}

struct SlowmotionVideoView: View {
    @State private var isVideoPicked = false
    @State private var showVideoPicker = false
    @State private var pickedVideoURL: URL? = nil
    @State private var player: AVPlayer? = nil
    @State private var convertedVideoURL: URL? = nil
    @State private var isPlaying = false
    @State private var showToast = false
    @State private var toastText = "Video converted successfully"
    @State private var showNoInternetAlert: Bool = false
    @State private var slowmotionType: SlowmotionType = .slow025x
    @Binding var isTabBarHidden: Bool
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                videoView
                Spacer()
                slowmotionButton
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
                    self.slowmotionVideo(originalURL: url, type: slowmotionType)
                } else {
                    toastText = "Please select the Video first!"
                    showToast = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.showToast = false
                    }
                }
            }
        }
        .noInternetAlert(isPresented: $showNoInternetAlert)
        .ignoresSafeArea(.all, edges: .top)
    }
    
    var headerView: some View {
        HeaderView(
            leftButtonImageName: "ic_back",
            rightButtonImageName: "ic_plus",
            headerTitle: "Slowmotion",
            leftButtonAction: {
                isTabBarHidden = false
                navigationPath.removeLast()
            }, rightButtonAction: {
                showVideoPicker = true
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
                            switch self.slowmotionType {
                            case .slow025x:
                                player.playImmediately(atRate: 0.25)
                            case .slow075x:
                                player.playImmediately(atRate: 0.75)
                            case .slow2x:
                                player.playImmediately(atRate: 2.0)
                            }
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
    
    var slowmotionButton: some View {
        HStack(spacing: 10) {
            slowButton(text: "0.25X", type: .slow025x)
            slowButton(text: "0.75X", type: .slow075x)
            slowButton(text: "2X", type: .slow2x)
        }
        .frame(maxWidth: .infinity)
    }
    
    func slowButton(text: String, type: SlowmotionType) -> some View {
        Button {
            slowmotionType = type
            if let url = self.pickedVideoURL {
                self.slowmotionVideo(originalURL: url, type: type)
            }
        } label: {
            Text(text)
                .font(FontConstants.MontserratFonts.medium(size: 18))
                .foregroundStyle(slowmotionType == type ? .white : .white.opacity(0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    if slowmotionType == type {
                        LinearGradient(
                            gradient: Gradient(colors: [redThemeColor, pinkGradientColor]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        textGrayColor.opacity(0.2)
                    }
                }
                .cornerRadius(10)
        }
    }
    
    var outputButton: some View {
        ThemeButtonView(buttonTitle: "Save Video") {
            if let url = pickedVideoURL {
                if ReachabilityManager.shared.isNetworkAvailable {
                    AdManager.shared.showInterstitialAd()
                    self.saveSlowMotionVideo(originalURL: url, type: slowmotionType)
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
    
    func slowmotionVideo(originalURL: URL, type: SlowmotionType) {
        let asset = AVAsset(url: originalURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer(playerItem: playerItem)
        self.player = player
        self.isVideoPicked = true
        self.isPlaying = true
        switch type {
        case .slow025x:
            player.playImmediately(atRate: 0.25)
        case .slow075x:
            player.playImmediately(atRate: 0.75)
        case .slow2x:
            player.playImmediately(atRate: 2.0)
        }
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
    
    func saveSlowMotionVideo(originalURL: URL, type: SlowmotionType) {
        print("type save video = \(type)")
        let asset = AVAsset(url: originalURL)
        let composition = AVMutableComposition()
        
        Task {
            do {
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                guard let videoTrack = videoTracks.first else {
                    self.toastText = "Failed to load video track"
                    self.showToast = true
                    return
                }
                
                let videoCompositionTrack = composition.addMutableTrack(
                    withMediaType: .video,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                )
                
                let scaleFactor: Float64
                switch type {
                case .slow025x:
                    scaleFactor = 1.0 / 0.25
                case .slow075x:
                    scaleFactor = 1.0 / 0.75
                case .slow2x:
                    scaleFactor = 1.0 / 2.0
                }
                
                let duration = try await asset.load(.duration)
                
                let timeRange = CMTimeRange(start: .zero, duration: duration)
                
                
                try videoCompositionTrack?.insertTimeRange(
                    timeRange,
                    of: videoTrack,
                    at: .zero
                )
                
                videoCompositionTrack?.scaleTimeRange(
                    timeRange,
                    toDuration: CMTimeMultiplyByFloat64(duration, multiplier: scaleFactor)
                )
                
                // Also handle audio
                //                if let audioTrack = asset.tracks(withMediaType: .audio).first {
                //                    let audioCompositionTrack = composition.addMutableTrack(
                //                        withMediaType: .audio,
                //                        preferredTrackID: kCMPersistentTrackID_Invalid
                //                    )
                //                    try audioCompositionTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)
                //                    audioCompositionTrack?.scaleTimeRange(
                //                        timeRange,
                //                        toDuration: CMTimeMultiplyByFloat64(duration, multiplier: scaleFactor)
                //                    )
                //                }
                
                let audioTracks = try await asset.loadTracks(withMediaType: .audio)
                guard let audioTrack = audioTracks.first else {
                    print("No audio track found")
                    return
                }
                
                let audioCompositionTrack = composition.addMutableTrack(
                    withMediaType: .audio,
                    preferredTrackID: kCMPersistentTrackID_Invalid
                )
                try audioCompositionTrack?.insertTimeRange(timeRange, of: audioTrack, at: .zero)
                audioCompositionTrack?.scaleTimeRange(
                    timeRange,
                    toDuration: CMTimeMultiplyByFloat64(duration, multiplier: scaleFactor)
                )
                
                // Export
                guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
                    self.toastText = "Export session creation failed"
                    self.showToast = true
                    return
                }
                
                let outputURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("slowmotion_\(Int(Date().timeIntervalSince1970)).mp4")
                exportSession.outputURL = outputURL
                exportSession.outputFileType = .mp4
                exportSession.shouldOptimizeForNetworkUse = true
                exportSession.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
                
                exportSession.exportAsynchronously {
                    DispatchQueue.main.async {
                        switch exportSession.status {
                        case .completed:
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                            }) { success, error in
                                DispatchQueue.main.async {
                                    if success {
                                        self.toastText = "Video saved to Photos"
                                    } else {
                                        self.toastText = "Saving failed: \(error?.localizedDescription ?? "unknown error")"
                                    }
                                    self.showToast = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        self.showToast = false
                                    }
                                }
                            }
                            
                        case .failed, .cancelled:
                            self.toastText = "Export failed: \(exportSession.error?.localizedDescription ?? "unknown error")"
                            self.showToast = true
                            
                        default:
                            break
                        }
                    }
                }
                
            } catch {
                self.toastText = "Error during export: \(error.localizedDescription)"
                self.showToast = true
            }
        }
    }
}

#Preview {
    SlowmotionVideoView(isTabBarHidden: .constant(true), navigationPath: .constant(NavigationPath()))
}
