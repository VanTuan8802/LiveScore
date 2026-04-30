//
//  CompactMatchRow.swift
//  LiveScore
//

import SwiftUI

struct CompactMatchRow: View {
    let match: AFFixtureResponse

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            RemoteImage(urlString: match.teams.home.logo, size: 36)

            VStack(spacing: 2) {
                Text("\(match.teams.home.name) vs. \(match.teams.away.name)")
                    .font(.semibold14)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                Text(resultOrTimeText)
                    .font(hasScore ? .semibold14 : .regular12)
                    .foregroundColor(hasScore ? Color("primary") : .secondary)
                if let venue = match.fixture.venue?.name, !venue.isEmpty {
                    Text(venue)
                        .font(.regular12)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)

            RemoteImage(urlString: match.teams.away.logo, size: 36)
        }
    }

    private var kickoffText: String {
        Self.timeFormatter.string(from: match.fixture.date)
    }

    private var hasScore: Bool {
        match.goals.home != nil && match.goals.away != nil
    }

    private var resultOrTimeText: String {
        if let home = match.goals.home, let away = match.goals.away {
            return "\(home) - \(away)"
        }
        return kickoffText
    }

    private static let timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()
}

