//
//  GetHashtagView.swift
//  VNVideoSaver
//
//  Created by vishva narola on 28/07/25.
//

import SwiftUI

struct Hashtags: Hashable {
    var title: String
    var description: String
}

struct GetHashtagView: View {
    @State private var hashtags: [Hashtags] = [
        Hashtags(title: "Love", description: "#Love #InLove #LoveStory #Romance #TrueLove #LoveWins #LoveAlways #LoveIsInTheAir #LoveLife #LoveYouMore #CoupleGoals #ForeverLove #SelfLove #LoveQuotes #LoveYou"),
        Hashtags(title: "Attitude", description: "#Attitude #PositiveAttitude #MindsetMatters #AttitudeIsEverything #AttitudeAdjustment #GrowthMindset #Confidence #InnerStrength #BeYou #LifeGoals #DriveMotivation"),
        Hashtags(title: "Nature", description: "#NatureLovers #NaturePhotography #ExploreNature #NatureBokeh #NatureLife #WildlifeWitness #NatureAddict #NatureWalking #NatureIsBeautiful #NatureInspiration #LoveNature"),
        Hashtags(title: "Beach", description: "#BeachLife #BeachVibes #BeachDay #BeachLovers #BeachBum #BeachSand #BeachFun #BeachPhotography #BeachSunset #BeachAdventure #BeachChilling #BeachGoals #BeachStyle"),
        Hashtags(title: "Bike", description: "#BikeLife #BikeAdventures #CycleMore #Biker #BikeLove #BikeCommunity #BikeToWork #BikingTips #BikeFit #BikeJourney #MountainBiking #RoadCycling #BicycleLifestyle"),
        Hashtags(title: "Night", description: "#NightVibes #NightLife #NightSky #NightPhotography #NightOwls #NighttimeAdventures #ChasingStars #CityAtNight #Nocturnal #StarryNight #NightLights #Moonlit #LateNightThoughts"),
        Hashtags(title: "Mountain", description: "#MountainAdventure #MountainEscape #MountainViews #ExploreMountains #MountainVibes #AdventureOnTheMountain #MountainGoals #MountainLife #NatureInTheMountains #HikingMountains"),
        Hashtags(title: "Road Trip", description: "#RoadTrip #AdventureTime #TravelGoals #Wanderlust #ExploreMore #RoadTripVibes #ScenicDrive #NatureLovers #TravelAdventures #RoadTripFun #JourneyOn #TravelBuddies #RoadTrip2025"),
        Hashtags(title: "Fitness", description: "#FitnessGoals #Workout #GymLife #HealthyLifestyle #FitFam #FitInspiration #GetFit #FitnessJourney #TrainingHard #LiveFit #FitForLife #FitnessMotivation #StrengthTraining #FitBody #Cardio #FitnessCommunity"),
        Hashtags(title: "Inspiration", description: "#Inspiration #Inspire #Motivation #PositiveVibes #Mindset #Empowerment #SuccessMindset #DreamBig #GoalSetting #PersonalGrowth #LiveInspired #FindYourPassion #InspirationDaily"),
        Hashtags(title: "Hair", description: "#Hair #HairCare #Hairstylist #HealthyHair #HairGoals #HairTutorial #HairInspiration #Hairstyle #HairSalon #HairTrend #HairTransformation #HairLove #HairTalk #CurlyHair"),
        Hashtags(title: "Family", description: "#FamilyLove #FamilyTime #FamilyFun #FamilyFirst #FamilyMoments #FamilyGoals #FamilyLife #FamilyVibes #FamilyBonding #FamiliesLaughTogether #FamilyAdventures #FamilyTies #FamilyForever"),
        Hashtags(title: "Photographer", description: "#PhotoGrapher #Photography #CameraGear #CaptureTheMoment #InstaPhoto #CreativePhotographer #NaturePhotography #PortraitPhotography #TravelPhotos #Wanderlust #VisualStorytelling"),
        Hashtags(title: "Couple", description: "#CoupleGoals #Love #RomanticCouple #CoupleVibes #TogetherForever #CoupleLife #RelationshipGoals #CoupleLove #InLove #Happiness #CoupleTherapy #CoupleAdventures #CoupleStyle #BondingTime"),
        Hashtags(title: "Wedding", description: "#wedding #weddingday #weddingseason #weddinginspiration #weddingvibes #weddingplanning #weddingphotography #weddingdress #weddingceremony #weddingreception #weddingdetails #weddingmessage"),
        Hashtags(title: "Food", description: "#FoodLovers #Foodie #DeliciousFood #YummyEats #FoodPhotography #FoodPorn #InstaFood #TastyTreats #HomemadeFood #Food vid #FoodInspiration #FoodCulture #CulinaryDelights #HealthyEating"),
        Hashtags(title: "Anniversary", description: "#Anniversary #AnniversaryCelebration #LoveAnniversary #HappyAnniversary #AnniversaryLove #MilestoneAnniversary #CoupleGoals #AnniversaryVibes #RelationshipAnniversary #AnniversaryParty #CelebratingLove #ForeverTogether #AnniversaryWishes #TogetherForever"),
        Hashtags(title: "Friends", description: "#friends #friendship #bff #goodtimes #squadgoals #memorymaking #funwithfriends #friendshipgoals #besties #laughter #together #socialize #friendshipmatters #qualitytime #adventureswithfriends #friendshipforall"),
        Hashtags(title: "Party", description: "#Party #BirthdayParty #PartyVibes #PartyTime #PartyMood #PartyPlanning #EpicParty #PartyGoals #EventPlanning #PartyDecor #Celebration #FunParty #NightOut #MakeMemories #DanceParty #PartyScenes"),
        Hashtags(title: "Fashion", description: "#fashion #fashionstyle #fashiontrends #fashioninspo #fashionblogger #fashionphotography #ootd #styleinspiration #fashionista #lookbook #mensfashion #womenswear #streetstyle #fashiondesign #personalstyle")
    ]
    @State private var showNoInternetAlert: Bool = false
    @State private var shareText: String = ""
    @State private var isSharing: Bool = false
    @State private var showToast = false
    @Binding var isTabBarHidden: Bool
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                ScrollView {
                    tagsListView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            if showToast {
                VStack {
                    Spacer()
                    Text("Copied")
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
        .ignoresSafeArea(.all, edges: .top)
        .sheet(isPresented: $isSharing) {
            ActivityView(activityItems: [shareText])
        }
        .noInternetAlert(isPresented: $showNoInternetAlert)
    }
    
    var headerView: some View {
        HeaderView(
            leftButtonImageName: "ic_back",
            rightButtonImageName: "",
            headerTitle: "Hashtag",
            leftButtonAction: {
                isTabBarHidden = false
                navigationPath.removeLast()
            }, rightButtonAction: nil
        )
        .padding(.horizontal, 20)
    }
    
    var tagsListView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(hashtags, id: \.self) { hashtag in
                hashtagView(hashtag)
            }
        }
        .padding(.vertical, 30)
    }
    
    func hashtagView(_ hashtag: Hashtags) -> some View {
        VStack(spacing: 14) {
            HStack {
                Text(hashtag.title)
                    .font(FontConstants.MontserratFonts.bold(size: 20))
                    .overlay(
                        LinearGradient(
                            colors: [redThemeColor, pinkGradientColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .mask(
                        Text(hashtag.title)
                            .font(FontConstants.MontserratFonts.bold(size: 20))
                    )
                Spacer()
                HStack(spacing: 10) {
                    Button {
                        if PremiumManager.shared.isPremium || !PremiumManager.shared.hasUsed() {
                            PremiumManager.shared.markUsed()
                            UIPasteboard.general.string = hashtag.description
                            showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.showToast = false
                            }
                        } else {
                            navigationPath.append(HomeDestination.premium)
                        }
                    } label: {
                        Image("ic_white_copy")
                    }
                    Button {
                        shareText(hashtag.description)
                    } label: {
                        Image("ic_white_share")
                    }
                }
            }
            HStack {
                Text(hashtag.description)
                    .font(FontConstants.SyneFonts.regular(size: 15))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                Spacer()
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.10))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    private func shareText(_ text: String) {
        shareText = text
        isSharing = true
    }
}

#Preview {
    GetHashtagView(isTabBarHidden: .constant(true), navigationPath: .constant(NavigationPath()))
}
