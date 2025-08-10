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
                VStack {
                    Spacer()
                    Text("Please select the video!!")
                        .font(FontConstants.MontserratFonts.medium(size: 17))
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    Spacer()
                }
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
        let asset = AVAsset(url: originalURL)
        
        Task.detached(priority: .userInitiated) {
            do {
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                guard let videoTrack = videoTracks.first else {
                    await MainActor.run {
                        self.toastText = "Failed to load video track"
                        self.showToast = true
                    }
                    return
                }
                
                let videoSize = try await videoTrack.load(.naturalSize)
                let frameRate = try await videoTrack.load(.nominalFrameRate)
                
                let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("reversedVideo.mp4")
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    try FileManager.default.removeItem(at: outputURL)
                }
                
                let reader = try AVAssetReader(asset: asset)
                let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ])
                reader.add(readerOutput)
                
                let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
                let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: videoSize.width,
                    AVVideoHeightKey: videoSize.height
                ])
                let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)
                writer.add(writerInput)
                
                reader.startReading()
                writer.startWriting()
                writer.startSession(atSourceTime: .zero)
                
                var sampleBuffers: [CMSampleBuffer] = []
                while let sample = readerOutput.copyNextSampleBuffer() {
                    sampleBuffers.append(sample)
                }
                
                var frameCount: Int64 = 0
                let frameDuration = CMTime(value: 1, timescale: Int32(frameRate))
                
                for sample in sampleBuffers.reversed() {
                    if let imageBuffer = CMSampleBufferGetImageBuffer(sample) {
                        while !writerInput.isReadyForMoreMediaData {
                            try await Task.sleep(nanoseconds: 10_000_000) // 10ms
                        }
                        let newTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                        adaptor.append(imageBuffer, withPresentationTime: newTime)
                        frameCount += 1
                    }
                }
                
                writerInput.markAsFinished()
                writer.finishWriting {
                    Task { @MainActor in
                        if writer.status == .completed {
                            self.convertedVideoURL = outputURL
                            self.toastText = "Video reversed successfully!"
                            self.showToast = true
                            
                            let newPlayer = AVPlayer(url: outputURL)
                            self.player = newPlayer
                            self.isPlaying = false
                            self.configurePlayer(newPlayer)
                            self.saveVideoToPhotoLibrary(url: outputURL)
                            PremiumManager.shared.markUsed()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.showToast = false
                            }
                        } else {
                            print("Error writing video: \(writer.error?.localizedDescription ?? "Unknown")")
                        }
                    }
                }
                
            } catch {
                print("Error reversing video: \(error.localizedDescription)")
            }
        }
    }
    
    func saveVideoToPhotoLibrary(url: URL) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Saved to Photos")
                } else {
                    print("Error saving video: \(error?.localizedDescription ?? "Unknown")")
                }
            }
        }
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
