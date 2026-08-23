//
//  FavoritesView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//

import SwiftUI
import Factory

struct FavoritesView: View {
    @InjectedObject(\.favoritesStore) private var store: FavoritesStore
    @InjectedObject(\.app) private var app: AppManager

    var body: some View {
        Group {
            if store.teams.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(store.teams) { team in
                            teamRow(team)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.98, blue: 0.95))
        .safeAreaInset(edge: .top, spacing: 0) {
            HeaderView(
                title: String(localized: .favorites),
                rightAction: { app.navi.push(.addFavoriteTeam) },
                rightActionSystemImage: "plus"
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "star.slash")
                .font(.system(size: 44, weight: .regular))
                .foregroundColor(.gray.opacity(0.5))
            Text(String(localized: .noFavoriteTeams))
                .font(.regular16)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                app.navi.push(.addFavoriteTeam)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text(String(localized: .addFavoriteTeam))
                        .font(.semibold16)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color("primary")))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func teamRow(_ team: FavoriteTeam) -> some View {
        HStack(spacing: 12) {
            RemoteImage(urlString: team.logo, size: 42)
            Text(team.name)
                .font(.semibold20)
                .lineLimit(1)
            Spacer()
            Button {
                store.remove(team.id)
            } label: {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 1)
        )
    }
}

#Preview {
    FavoritesView()
}
