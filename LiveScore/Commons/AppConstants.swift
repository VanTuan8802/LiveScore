//
//  AppConstants.swift
//  LiveScore
//
//  Created by VanTuan8802 on 22/4/26.
//

import Foundation

struct AppConstants {
    static let baseURL = "https://v3.football.api-sports.io"

    /// Used when Remote Config is missing, invalid, or not yet loaded (`api_config` JSON).
    static let apiFootballKeyFallback = ""

    /// Prefer key from Firebase Remote Config parameter `api_config` → JSON `apiKey`, else local fallback.
    static var apiFootballKey: String {
        if let key = RemoteConfigManager.shared.apiKeyFromRemoteConfig() {
            return key
        }
        return apiFootballKeyFallback
    }
}
