//
//  VideoLibraryManager.swift
//  VNVideoSaver
//
//  Created by vishva narola on 20/08/25.
//

import Photos
import UIKit

class VideoLibraryManager: ObservableObject {
    @Published var videos: [VideosArrayData] = []
    
    func fetchVideos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let assets = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                
                var tempVideos: [VideosArrayData] = []
                assets.enumerateObjects { asset, _, _ in
                    let options = PHVideoRequestOptions()
                    options.version = .original
                    
                    // Get video URL
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                        if let urlAsset = avAsset as? AVURLAsset {
                            let videoURL = urlAsset.url
                            
                            // Get thumbnail
                            let imageManager = PHImageManager.default()
                            let requestOptions = PHImageRequestOptions()
                            requestOptions.isSynchronous = true
                            requestOptions.deliveryMode = .highQualityFormat
                            
                            var thumbnailURL = ""
                            imageManager.requestImage(for: asset,
                                                      targetSize: CGSize(width: 200, height: 200),
                                                      contentMode: .aspectFill,
                                                      options: requestOptions) { image, _ in
                                if let data = image?.jpegData(compressionQuality: 0.7) {
                                    // Save thumbnail temporarily
                                    let tempPath = NSTemporaryDirectory() + "\(UUID().uuidString).jpg"
                                    let tempURL = URL(fileURLWithPath: tempPath)
                                    try? data.write(to: tempURL)
                                    thumbnailURL = tempURL.absoluteString
                                }
                            }
                            
                            // File size
                            let sizeString = ByteCountFormatter.string(fromByteCount: Int64(asset.pixelWidth * asset.pixelHeight), countStyle: .file)
                            
                            let videoData = VideosArrayData(
                                title: asset.creationDate?.formatted(date: .abbreviated, time: .shortened) ?? "Video",
                                videoUrl: videoURL.absoluteString,
                                videoThumb: thumbnailURL,
                                size: sizeString
                            )
                            DispatchQueue.main.async {
                                tempVideos.append(videoData)
                                self.videos = tempVideos
                            }
                        }
                    }
                }
            }
        }
    }
}
