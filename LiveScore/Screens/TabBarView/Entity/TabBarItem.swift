//
//  TabBarItem.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//



import Foundation
import SwiftUI

enum TabBarItem: Int, Identifiable, CaseIterable, Comparable {

    internal var id: Int { rawValue }

    static func < (lhs: TabBarItem, rhs: TabBarItem) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    case matches
    case competitions
    case favorites
    case setting

    var title: String {
        switch self {
        case .matches:
            return String(localized: .matches)
        case .competitions:
            return String(localized: .competitions)
        case .favorites:
            return String(localized: .favorites)
        case .setting:
            return String(localized: "setting")
        }
    }

    var iconNormal: Image {
        switch self {
        case .matches:
            return Image("matches_tab_normal")
        case .competitions:
            return Image("competitions_tab_normal")
        case .favorites:
            return Image("favorites_tab_normal")
        case .setting:
            return Image("setting_tab_normal")
        }
    }

    var iconSelected: Image {
        switch self {
        case .matches:
            return Image("matches_tab_selected")
        case .competitions:
            return Image("competitions_tab_selected")
        case .favorites:
            return Image("favorites_tab_selected")
        case .setting:
            return Image("setting_tab_selected")
        }
    }

}
