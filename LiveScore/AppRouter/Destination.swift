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
    
    case matches
    case matcheDetail(match: AFFixtureResponse)
    case competitions
    case favorites
    case myTeam
}

extension Destination {
    var identifier: String {
        switch self {
        case .matches: return "matches"
        case .matcheDetail: return "matcheDetail"
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
        case .matches:
            MatchesView()
        case .matcheDetail(let match):
            MatcheDetailView(match: match)
        case .competitions:
            CompetitionsView()
        case .favorites:
            FavoritesView()
        case .myTeam:
            MyTeamView()
        }
    }
}
