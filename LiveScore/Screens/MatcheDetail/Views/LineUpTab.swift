//
//  LineUpTab.swift
//  LiveScore
//
//  Created by VanTuan8802 on 30/4/26.
//

import SwiftUI

struct LineUpTab: View {
    let isLoading: Bool
    let errorMessage: String?
    let lineups: [AFFixtureLineup]
    @Binding var expandedLineupIDs: Set<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                ProgressView(String(localized: .loading_lineup))
            } else if let errorMessage {
                Text(errorMessage)
                    .font(.regular14)
                    .foregroundColor(.secondary)
            } else if lineups.isEmpty {
                Text(String(localized: .no_lineup_available))
                    .font(.regular14)
                    .foregroundColor(.secondary)
            } else {
                ForEach(lineups) { lineup in
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            toggleLineup(lineup.id)
                        } label: {
                            HStack(spacing: 8) {
                                RemoteImage(urlString: lineup.team.logo, size: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lineup.team.name)
                                        .font(.semibold20)
                                        .foregroundColor(.primary)
                                    Text(String(format: String(localized: .formation_format), lineup.formation ?? "-"))
                                        .font(.regular14)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: expandedLineupIDs.contains(lineup.id) ? "chevron.down" : "chevron.up")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)

                        if expandedLineupIDs.contains(lineup.id) {
                            Divider()
                            Text(String(localized: .starting_xi))
                                .font(.semibold16)
                                .foregroundColor(Color("primary"))

                            ForEach(lineup.startXI) { wrapper in
                                playerRow(wrapper)
                            }

                            if !lineup.substitutes.isEmpty {
                                Divider()
                                Text(String(localized: .substitutes))
                                    .font(.semibold16)
                                    .foregroundColor(Color("primary"))

                                ForEach(lineup.substitutes) { wrapper in
                                    playerRow(wrapper)
                                }
                            }
                        }
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
                }
            }
        }
    }

    private func playerRow(_ wrapper: AFLineupPlayerWrapper) -> some View {
        HStack {
            Text("\(wrapper.player.number ?? 0)")
                .font(.regular12)
                .foregroundColor(Color("primary"))
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color("primary").opacity(0.15)))

            Text(wrapper.player.name ?? "-")
                .font(.regular16)
            Spacer()
            Text(wrapper.player.pos ?? "")
                .font(.regular12)
                .foregroundColor(.secondary)
        }
    }

    private func toggleLineup(_ lineupID: Int) {
        if expandedLineupIDs.contains(lineupID) {
            expandedLineupIDs.remove(lineupID)
        } else {
            expandedLineupIDs.insert(lineupID)
        }
    }
}

#Preview {
    LineUpTab(
        isLoading: false,
        errorMessage: nil,
        lineups: [],
        expandedLineupIDs: .constant([])
    )
}
