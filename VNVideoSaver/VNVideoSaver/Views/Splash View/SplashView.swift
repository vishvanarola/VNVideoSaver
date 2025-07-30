//
//  SplashView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 27/07/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            TabBarView()
        } else {
            VStack(spacing: 40) {
                Spacer()
                Image("ic_appicon")
                    .resizable()
                    .frame(width: 130, height: 130)
                
                Text(splashAppName)
                    .font(FontConstants.SyneFonts.semiBold(size: 30))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                LottieView(animationName: "Loader", loopMode: .loop)
                    .frame(width: 100, height: 100)
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.7, execute: {
                    isActive = true
                })
            }
        }
    }
}

#Preview {
    SplashView()
}
