//
//  LottieView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 27/07/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .playOnce
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: animationName)
        
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
