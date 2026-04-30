//
//  LeagueChipSelector.swift
//  LiveScore
//

import SwiftUI

struct LeagueChipSelector: View {
    let leagues: [LeagueSection]
    @Binding var selectedLeagueId: Int?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ChipButton(title: "ALL", selected: selectedLeagueId == nil) {
                    selectedLeagueId = nil
                }
                ForEach(leagues) { league in
                    ChipButton(title: league.shortCode, selected: selectedLeagueId == league.id) {
                        selectedLeagueId = league.id
                    }
                }
            }
        }
    }
}

private struct ChipButton: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.semibold12)
                .foregroundColor(selected ? .white : .secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(selected ? Color("primary") : Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
    }
}

