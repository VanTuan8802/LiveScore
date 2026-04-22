//
//  Destination.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//


import SwiftUI

enum Destination: Equatable {
    static func == (lhs: Destination, rhs: Destination) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
    
    case today
    case competitions
    case favorites
    case myTeam
}

extension Destination {
    var identifier: String {
        switch self {
        case .today: return "today"
        case .competitions: return "competitions"
        case .favorites: return "favorites"
        case .myTeam: return "myTeam"
        }
    }
}

extension Navigation {
    @ViewBuilder
    internal func screen(for destinationWrapper: DestinationWrapper) -> some View {
        switch destinationWrapper.destination {
        case .today:
            TodayView()
        case .competitions:
            CompetitionsView()
        case .favorites:
            FavoritesView()
        case .myTeam:
            MyTeamView()
        }
    }
}
