//
//  HeaderView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 28/07/25.
//

import SwiftUI

struct HeaderView: View {
    let leftButtonImageName: String
    let rightButtonImageName: String?
    let headerTitle: String
    let leftButtonAction: () -> Void
    let rightButtonAction: (() -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button {
                    leftButtonAction()
                } label: {
                    Image(leftButtonImageName)
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                }
                Spacer()
                if (rightButtonImageName == nil) {
                    Spacer()
                }
                Text(headerTitle)
                    .font(FontConstants.SyneFonts.semiBold(size: 23))
                    .foregroundStyle(Color.white)
                Spacer()
                if let rightImage = rightButtonImageName {
                    Button {
                        rightButtonAction?()
                    } label: {
                        Image(rightImage)
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                    }
                } else {
                    Spacer()
                    Spacer()
                }
            }
            .padding(.bottom, 20)
        }
        .frame(height: UIScreen.main.bounds.height * 0.15)
    }
}

#Preview {
    HeaderView(
        leftButtonImageName: "ic_back",
        rightButtonImageName: nil,
        headerTitle: "Text Repeater",
        leftButtonAction: {
            print("Back button tapped")
        },
        rightButtonAction: nil
    )
}
