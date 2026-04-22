//
//  ContainerExtension.swift
//  LiveScore
//
//  Created by VanTuan8802 on 21/4/26.
//

import Foundation
import Foundation
import Factory

/// App manager
extension Container {
    var app: Factory<AppManager> {
        Factory(self) { @MainActor in
            AppManager()
        }.singleton
    }
}

/// Navigation
extension Container {
    var todayNavi: Factory<Navigation> {
        Factory(self) { @MainActor in
            Navigation()
        }.singleton
    }
    
    var statistics: Factory<Navigation> {
        Factory(self) { @MainActor in
            Navigation()
        }.singleton
    }
    
    var budget: Factory<Navigation> {
        Factory(self) { @MainActor in
            Navigation()
        }.singleton
    }
    
    var setting: Factory<Navigation> {
        Factory(self) { @MainActor in
            Navigation()
        }.singleton
    }
}

/// Tabbar
extension Container {
    var dataRefresh: Factory<DataFreshable> {
        Factory(self) { @MainActor in
            DataFreshable()
        }.singleton
    }
}
