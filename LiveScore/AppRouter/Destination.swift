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
    case leagues
    case leagueDetail(leagueId: Int, leagueName: String)
    case favorites
    case addFavoriteTeam
    case setting
}

extension Destination {
    var identifier: String {
        switch self {
        case .matches: return "matches"
        case .matcheDetail: return "matcheDetail"
        case .leagues: return "leagues"
        case .leagueDetail(let leagueId, _): return "leagueDetail_\(leagueId)"
        case .favorites: return "favorites"
        case .addFavoriteTeam: return "addFavoriteTeam"
        case .setting: return "setting"
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
        case .leagues:
            LeaguesView()
        case .leagueDetail(let leagueId, let leagueName):
            LeagueDetailView(leagueId: leagueId, leagueName: leagueName)
        case .favorites:
            FavoritesView()
        case .addFavoriteTeam:
            AddFavoriteTeamView()
        case .setting:
            MyTeamView()
        }
    }
}
