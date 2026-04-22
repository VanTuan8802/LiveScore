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

    case today
    case competitions
    case favorites
    case myTeam

    var title: String {
        switch self {
        case .today:
            return String(localized: .today)
        case .competitions:
            return String(localized: .competitions)
        case .favorites:
            return String(localized: .favorites)
        case .myTeam:
            return String(localized: .myTeam)
        }
    }

    var iconNormal: Image {
        switch self {
        case .today:
            return Image("today_tab_normal")
        case .competitions:
            return Image("competitions_tab_normal")
        case .favorites:
            return Image("favorites_tab_normal")
        case .myTeam:
            return Image("my_team_tab_normal")
        }
    }

    var iconSelected: Image {
        switch self {
        case .today:
            return Image("today_tab_selected")
        case .competitions:
            return Image("competitions_tab_selected")
        case .favorites:
            return Image("favorites_tab_selected")
        case .myTeam:
            return Image("my_team_tab_selected")
        }
    }

}
