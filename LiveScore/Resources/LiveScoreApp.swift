//
//  LiveScoreApp.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//

import SwiftUI

@main
struct LiveScoreApp: App {
    init() {
        RemoteConfigManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContainerView()
        }
    }
}
