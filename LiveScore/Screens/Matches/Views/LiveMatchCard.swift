//
//  LiveMatchCard.swift
//  LiveScore
//

import SwiftUI

struct LiveMatchCard: View {
    let match: AFFixtureResponse

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("primary").opacity(0.85), Color.blue.opacity(0.75)],
                startPoint: .leading,
                endPoint: .trailing
            )

            VStack(spacing: 10) {
                Text(match.league.name)
                    .font(.semibold14)
                    .foregroundColor(.white.opacity(0.92))

                HStack(spacing: 12) {
                    RemoteImage(urlString: match.teams.home.logo, size: 64)
                    Text(scoreText)
                        .font(.semibold30)
                        .foregroundColor(.white)
                    RemoteImage(urlString: match.teams.away.logo, size: 64)
                }

                Text("\(match.teams.home.name) vs \(match.teams.away.name)")
                    .font(.semibold16)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var scoreText: String {
        let home = match.goals.home ?? 0
        let away = match.goals.away ?? 0
        return "\(home) : \(away)"
    }
}

