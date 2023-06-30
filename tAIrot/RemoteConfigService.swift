//
//  RemoteConfigService.swift
//  The Seer
//
//  Created by Brandon Ramírez Casazza on 20/06/23.
//

import Foundation
import FirebaseRemoteConfig

class RemoteConfigService {
    let remoteConfig: RemoteConfig

    static let shared = RemoteConfigService()

    private init() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }

    func fetchRemoteConfig() {
        remoteConfig.fetchAndActivate { status, error in
            if let error = error {
                print("Error fetching remote config: \(error)")
            }
            print("Remote config fetched!")
        }
    }

    func getString(for key: String) -> String {
        return remoteConfig.configValue(forKey: key).stringValue ?? ""
    }
}

