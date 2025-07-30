//
//  ThemeButtonView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 28/07/25.
//

import SwiftUI

struct ThemeButtonView: View {
    let buttonTitle: String
    let buttonAction: () -> Void
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            Text(buttonTitle)
                .font(FontConstants.SyneFonts.semiBold(size: 20))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [redThemeColor, pinkGradientColor]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(15)
        }
    }
}

#Preview {
    ThemeButtonView(buttonTitle: "Button", buttonAction: {})
}
