//
//  NoInternetAlertModifier.swift
//  VNVideoSaver
//
//  Created by vishva narola on 05/07/25.
//

import SwiftUI

struct NoInternetAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let dismissAction: (() -> Void)?
    
    init(isPresented: Binding<Bool>, dismissAction: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self.dismissAction = dismissAction
    }
    
    func body(content: Content) -> some View {
        content
            .alert("No Internet Connection", isPresented: $isPresented) {
                Button("OK", role: .cancel) {
                    dismissAction?()
                }
            } message: {
                Text("Please check your internet connection and try again. This feature requires an internet connection to work properly.")
            }
    }
}

extension View {
    func noInternetAlert(isPresented: Binding<Bool>) -> some View {
        self.modifier(NoInternetAlertModifier(isPresented: isPresented))
    }
}
