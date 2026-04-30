//
//  AppManager.swift
//  LiveScore
//
//  Created by VanTuan8802 on 21/4/26.
//


import Foundation
import Combine

@MainActor
class AppManager: ObservableObject {
    /// Tabbar
    @Published var isShowTabbar: Bool = true
    @Published var activeTab: TabBarItem = .matches

    /// Navi
    @Published var navi: Navigation = Navigation()

    /// State
    @Published var isInBackground: Bool = false
}
