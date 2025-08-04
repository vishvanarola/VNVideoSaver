//
//  VideoPlayerView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 04/08/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerVC = AVPlayerViewController()
        playerVC.showsPlaybackControls = true
        let player = AVPlayer(url: videoURL)
        playerVC.player = player
        player.play()
        return playerVC
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
