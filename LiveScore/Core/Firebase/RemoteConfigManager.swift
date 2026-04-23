//
//  RemoteConfigManager.swift
//  LiveScore
//
//  Created by VanTuan8802 on 23/4/26.
//

import Foundation
import FirebaseCore
import FirebaseRemoteConfig

final class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    private let remoteConfig = RemoteConfig.remoteConfig()

    private init() {}

    func configure() {
        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            #if DEBUG
            print("[RemoteConfig] GoogleService-Info.plist not found. Skipping Firebase / Remote Config.")
            #endif
            return
        }

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3_600
        #endif
        remoteConfig.configSettings = settings

        let defaultAPIJSON = "{\"apiKey\":\"\"}" as NSString
        remoteConfig.setDefaults([FirebaseKey.apiConfig: defaultAPIJSON])

        Task { await fetchAndActivate() }
    }

    @discardableResult
    func fetchAndActivate() async -> Bool {
        guard FirebaseApp.app() != nil else { return false }
        do {
            _ = try await remoteConfig.fetchAndActivate()
            return true
        } catch {
            #if DEBUG
            print("[RemoteConfig] fetchAndActivate error: \(error.localizedDescription)")
            #endif
            return false
        }
    }

    /// Parses Remote Config `api_config` (JSON) and returns the `apiKey` field when non-empty.
    func apiKeyFromRemoteConfig() -> String? {
        guard FirebaseApp.app() != nil else { return nil }

        let json = remoteConfig.configValue(forKey: FirebaseKey.apiConfig).stringValue
        guard let data = json.data(using: .utf8), !data.isEmpty else { return nil }

        guard let payload = try? JSONDecoder().decode(APIConfigRemotePayload.self, from: data) else {
            return nil
        }
        let key = payload.apiKey?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let key, !key.isEmpty else { return nil }
        return key
    }
}

private struct APIConfigRemotePayload: Decodable {
    let apiKey: String?
}
