//
//  MyCollectionsView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 31/07/25.
//

import SwiftUI
import SwiftData

enum MyCollectionRoute: Hashable {
    case photosCollage(Collage)
    case premium
}

struct MyCollectionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Collage.createdAt, order: .reverse) private var collages: [Collage]
    @State private var showCreateCollage = false
    @State private var collageToEdit: Collage? = nil
    @State private var navigationPath = NavigationPath()
    @State private var showNoInternetAlert: Bool = false
    @Binding var selectedTab: CustomTab
    @Binding var isTabBarHidden: Bool
    @Binding var isHiddenBanner: Bool
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                VStack {
                    headerView
                    listView
                }
                .ignoresSafeArea()
                .navigationBarBackButtonHidden(true)
                
                if showCreateCollage {
                    CreateCollageView(isPresented: $showCreateCollage, collageToEdit: collageToEdit, isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath)
                }
            }
            .navigationDestination(for: MyCollectionRoute.self) { route in
                switch route {
                case .photosCollage(let collage):
                    PhotosCollageView(collage: collage, isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath)
                case .premium:
                    PremiumView(isTabBarHidden: $isTabBarHidden, navigationPath: $navigationPath, isHiddenBanner: $isHiddenBanner)
                        .navigationBarBackButtonHidden(true)
                }
            }
            .noInternetAlert(isPresented: $showNoInternetAlert)
        }
    }
    
    var headerView: some View {
        VStack {
            Spacer()
            HStack {
                Text("My Collection")
                    .font(FontConstants.SyneFonts.semiBold(size: 23))
                    .foregroundStyle(Color.white)
                Spacer()
                Button {
                    if ReachabilityManager.shared.isNetworkAvailable {
                        AdManager.shared.showInterstitialAd()
                        withAnimation {
                            showCreateCollage = true
                            collageToEdit = nil
                        }
                    } else {
                        showNoInternetAlert = true
                    }
                } label: {
                    Image("ic_plus")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(height: UIScreen.main.bounds.height * 0.15)
        .padding(.horizontal, 20)
    }
    
    var listView: some View {
        Group {
            if collages.isEmpty {
                VStack {
                    Spacer()
                    emptyStateView
                    Spacer()
                }
            } else {
                List {
                    ForEach(collages) { collage in
                        ZStack {
                            Image("ic_collectionBack")
                                .resizable()
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                            HStack {
                                Image("ic_folder")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding(.leading)
                                Text(collage.name)
                                    .font(FontConstants.MontserratFonts.medium(size: 18))
                                    .foregroundStyle(Color.white)
                                    .lineLimit(2)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color(red: 26/255, green: 26/255, blue: 26/255).opacity(0.45))
                        .cornerRadius(15)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.bottom, 10)
                        .padding(.horizontal, 20)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                if ReachabilityManager.shared.isNetworkAvailable {
                                    AdManager.shared.showInterstitialAd()
                                    deleteCollage(collage)
                                } else {
                                    showNoInternetAlert = true
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.clear)
                            
                            Button {
                                if ReachabilityManager.shared.isNetworkAvailable {
                                    AdManager.shared.showInterstitialAd()
                                    collageToEdit = collage
                                    showCreateCollage = true
                                } else {
                                    showNoInternetAlert = true
                                }
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.clear)
                        }
                        .onTapGesture {
                            if ReachabilityManager.shared.isNetworkAvailable {
                                AdManager.shared.showInterstitialAd()
                                isTabBarHidden = true
                                navigationPath.append(MyCollectionRoute.photosCollage(collage))
                            } else {
                                showNoInternetAlert = true
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    func collectionView(_ name: String) -> some View {
        ZStack {
            Image("ic_collectionBack")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 70)
            HStack {
                Image("ic_folder")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.leading)
                Text(name)
                    .font(FontConstants.MontserratFonts.medium(size: 18))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(Color(red: 26/255, green: 26/255, blue: 26/255).opacity(0.45))
        .cornerRadius(15)
        .listRowSeparator(.hidden)
        .padding(.bottom, 10)
    }
    
    var emptyStateView: some View {
        VStack {
            Spacer()
            Image("ic_noData")
            Text("No Data Found")
                .font(FontConstants.MontserratFonts.medium(size: 20))
                .foregroundColor(.white.opacity(0.30))
            Spacer()
        }
        .padding(.bottom, 50)
    }
    
    private func deleteCollage(_ collage: Collage) {
        modelContext.delete(collage)
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete collage: \(error)")
        }
    }
}

#Preview {
    MyCollectionsView(selectedTab: .constant(.myCollection), isTabBarHidden: .constant(false), isHiddenBanner: .constant(false))
}
