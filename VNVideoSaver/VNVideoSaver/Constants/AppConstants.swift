//
//  AppConstants.swift
//  VNVideoSaver
//
//  Created by vishva narola on 19/06/25.
//

import SwiftUI
import Photos

let homeAppName = "MegaGrab"
let splashAppName = "MegaGrab"
let remoteConfigAdFetchKey = "VideoSaver"
var interstitialIntergap: Int = 3
var isHideTabBackPremium: Bool = true
var appComesFirst = true
var remoteConfigModel: RemoteAdsModel?

let redThemeColor = Color(red: 229/255, green: 32/255, blue: 32/255) //#E52020
let pinkThemeColor = Color(red: 1.0, green: 101/255, blue: 101/255) //#FF6565
let textGrayColor = Color(red: 153/255, green: 153/255, blue: 153/255) //#999999
let pinkOpacityColor = Color(red: 242/255, green: 84/255, blue: 91/255) //#F2545B
let pinkGradientColor = Color(red: 1.0, green: 65/255, blue: 101/255) //#FF4165
let backgroundGrayColor = Color(red: 217/255, green: 217/255, blue: 217/255) //#D9D9D9

let appLink = URL(string: "https://apps.apple.com/us/app/video-saver-2025/id6749473138")
let appRateLink = URL(string: "https://apps.apple.com/us/app/video-downloader-form-insta/id6749473138?action=write-review")
let termsCondition = URL(string: "https://sahilnarola22.blogspot.com/2025/08/terms-condition.html")
let EULA = URL(string: "https://sahilnarola22.blogspot.com/2025/08/eula.html")
let privacyPolicy = URL(string: "https://sahilnarola22.blogspot.com/2025/08/privacy-policy_1.html")

var videosArray: [VideosArrayData] = [
    VideosArrayData(title: "Big Buck Bunny", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg", size: "428 KB"),
    VideosArrayData(title: "Elephant Dream", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg", size: "428 KB"),
    VideosArrayData(title: "For Bigger Blazes", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg", size: "428 KB"),
    VideosArrayData(title: "For Bigger Escape", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg", size: "428 KB"),
    VideosArrayData(title: "For Bigger Fun", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg", size: "428 KB"),
    VideosArrayData(title: "For Bigger Joyrides", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg", size: "428 KB"),
    VideosArrayData(title: "For Bigger Meltdowns", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg", size: "428 KB"),
    VideosArrayData(title: "Sintel", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg", size: "428 KB"),
    VideosArrayData(title: "Subaru Outback On Street And Dirt", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg", size: "428 KB"),
    VideosArrayData(title: "Tears of Steel", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg", size: "428 KB"),
    VideosArrayData(title: "Volkswagen GTI Review", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/VolkswagenGTIReview.jpg", size: "428 KB"),
    VideosArrayData(title: "We Are Going On Bullrun", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WeAreGoingOnBullrun.jpg", size: "428 KB"),
    VideosArrayData(title: "What care can you get for a grand?", videoUrl: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", videoThumb: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WhatCarCanYouGetForAGrand.jpg", size: "428 KB")
]
var randomVideosGlob = [RandomVideoItem]()
