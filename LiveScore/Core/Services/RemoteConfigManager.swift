//
//  RemoteConfigManager.swift
//  LiveScore
//

import Foundation
import FirebaseCore
import FirebaseRemoteConfig

final class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    private var remoteConfig: RemoteConfig?
    private var isConfigured: Bool = false

    private init() {}

    func configure() {
        if isConfigured { return }

        guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
            #if DEBUG
            print("[RemoteConfig] GoogleService-Info.plist not found. Skipping Firebase / Remote Config.")
            #endif
            return
        }

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        isConfigured = true

        if remoteConfig == nil {
            remoteConfig = RemoteConfig.remoteConfig()
        }

        guard let remoteConfig else { return }

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
        guard isConfigured, let remoteConfig else { return false }
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

    func apiKeyFromRemoteConfig() -> String? {
        guard isConfigured, let remoteConfig else { return nil }

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

