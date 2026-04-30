//
//  LeagueHeaderView.swift
//  LiveScore
//

import SwiftUI

struct LeagueHeaderView: View {
    let section: LeagueSection

    var body: some View {
        HStack(spacing: 10) {
            RemoteImage(urlString: section.logo, size: 32)
            Text(section.name)
                .font(.semibold16)
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color("primary").opacity(0.12))
    }
}

