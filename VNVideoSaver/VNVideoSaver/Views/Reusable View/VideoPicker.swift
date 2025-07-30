//
//  VideoPicker.swift
//  VNVideoSaver
//
//  Created by vishva narola on 26/06/25.
//

import SwiftUI
import PhotosUI

struct VideoPicker: UIViewControllerRepresentable {
    var didPickVideo: (URL?) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didPickVideo: didPickVideo)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var didPickVideo: (URL?) -> Void
        
        init(didPickVideo: @escaping (URL?) -> Void) {
            self.didPickVideo = didPickVideo
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let itemProvider = results.first?.itemProvider,
                  itemProvider.hasItemConformingToTypeIdentifier("public.movie") else {
                didPickVideo(nil)
                return
            }
            
            itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, error in
                guard let url = url else {
                    self.didPickVideo(nil)
                    return
                }
                
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                try? FileManager.default.copyItem(at: url, to: tempURL)
                self.didPickVideo(tempURL)
            }
        }
    }
}
