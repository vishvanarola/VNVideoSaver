//
//  PhotosCollageView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 31/07/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct PhotosCollageView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showPhotoPicker = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImageData: Data?
    @State private var isShowingPhotoPreview = false
    @State private var showNoInternetAlert: Bool = false
    @Bindable var collage: Collage
    @Binding var isTabBarHidden: Bool
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Group {
            if isShowingPhotoPreview {
                fullPhotoView()
            } else {
                VStack {
                    headerView
                    collagePhohotView
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedItems,
            maxSelectionCount: 10,
            matching: .images
        )
        .onChange(of: selectedItems) { oldValue, newValue in
            Task {
                await handleImageSelection()
            }
        }
        .noInternetAlert(isPresented: $showNoInternetAlert)
    }
    
    var headerView: some View {
        HeaderView(
            leftButtonImageName: "ic_back",
            rightButtonImageName: "ic_white_plus",
            headerTitle: collage.name,
            leftButtonAction: {
                AdManager.shared.showInterstitialAd()
                isTabBarHidden = false
                navigationPath.removeLast()
            },
            rightButtonAction: {
                if ReachabilityManager.shared.isNetworkAvailable {
                    if PremiumManager.shared.hasUsed() && !PremiumManager.shared.isPremium {
                        AdManager.shared.showInterstitialAd()
                        isHideTabBackPremium = true
                        navigationPath.append(MyCollectionRoute.premium)
                    } else {
                        showPhotoPicker = true
                    }
                } else {
                    showNoInternetAlert = true
                }
            }
        )
    }
    
    var collagePhohotView: some View {
        Group {
            if collage.images.isEmpty {
                Spacer()
                Text("No photos added yet")
                    .font(FontConstants.MontserratFonts.medium(size: 17))
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(collage.images, id: \.id) { collageImage in
                            if let uiImage = UIImage(data: collageImage.data) {
                                Button {
                                    AdManager.shared.showInterstitialAd()
                                    selectedImageData = collageImage.data
                                    withAnimation {
                                        isShowingPhotoPreview = true
                                    }
                                } label: {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    func fullPhotoView() -> some View {
        Group {
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                if let data = selectedImageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                }
                
                Button {
                    AdManager.shared.showInterstitialAd()
                    withAnimation {
                        isShowingPhotoPreview = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                }
                .frame(width: 30, height: 30)
                .padding()
                .foregroundColor(.white)
                .padding(.top, 20)
            }
        }
    }
    
    func handleImageSelection() async {
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let image = CollageImage(data: data)
                image.collage = collage
                collage.images.append(image)
            }
        }
        do {
            PremiumManager.shared.markUsed()
            try modelContext.save()
        } catch {
            print("⚠️ Error saving images: \(error)")
        }
    }
}

#Preview {
    PhotosCollageView(collage: Collage(name: "Demo"), isTabBarHidden: .constant(true), navigationPath: .constant(NavigationPath()))
}
