//
//  AdServices.swift
//  VNVideoSaver
//
//  Created by vishva narola on 01/07/25.
//

import FirebaseRemoteConfig

class AdServices {
    func fetchNewRemoteAdsData(success: @escaping (RemoteAdsModel) -> Void, failure: @escaping (String) -> Void) {
        var remoteConfig: RemoteConfig!
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.fetch() { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                remoteConfig.activate() { (status,error) in
                    do {
                        let obj = remoteConfig.configValue(forKey: remoteConfigAdFetchKey).jsonValue
                        print("Config fetched!",obj as Any)
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: obj as Any, options: [])
                        do {
                            let jsonDecoder = JSONDecoder()
                            let responseModel = try jsonDecoder.decode(RemoteAdsModel.self, from: jsonData)
                            success(responseModel)
                            
                        } catch let error {
                            print(error)
                            failure("Something went wrong")
                        }
                    } catch {
                        print(error)
                        failure("Something went wrong")
                    }
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
                failure(error?.localizedDescription ?? "No error available.")
            }
        }
    }
}
