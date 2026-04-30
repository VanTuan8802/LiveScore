//
//  TabBarView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 21/4/26.
//



import SwiftUI
import Factory

struct TabBarView: View {
    @InjectedObject(\.matchesNavi) private var matchesNavi: Navigation
    @InjectedObject(\.statistics) private var statisticNavi: Navigation
    @InjectedObject(\.budget) private var budgetNavi: Navigation
    @InjectedObject(\.setting) private var settingNavi: Navigation
    @InjectedObject(\.app) private var app: AppManager
    
    @State private var isFirstAppear: Bool = false
    
    var body: some View {
        TabView(selection: $app.activeTab) {
            NavigationRoot(destination: .matches, navigation: matchesNavi)
                .tabItem {
                    Label {
                        Text(String(localized: .matches))
                    } icon: {
                        tabIcon("matches_tab_normal")
                    }
                }
                .tag(TabBarItem.matches)

            NavigationRoot(destination: .competitions, navigation: statisticNavi)
                .tabItem {
                    Label {
                        Text(String(localized: .competitions))
                    } icon: {
                        tabIcon("competitions_tab_normal")
                    }
                }
                .tag(TabBarItem.competitions)

            NavigationRoot(destination: .favorites, navigation: budgetNavi)
                .tabItem {
                    Label {
                        Text(String(localized: .favorites))
                    } icon: {
                        tabIcon("favorites_tab_normal")
                    }
                }
                .tag(TabBarItem.favorites)

            NavigationRoot(destination: .setting, navigation: settingNavi)
                .tabItem {
                    Label {
                        Text(String(localized: .setting))
                    } icon: {
                        tabIcon("setting_tab_normal")
                    }
                }
                .tag(TabBarItem.setting)
        }
        .tint(Color("primary"))
        .onAppear {
            guard !isFirstAppear else { return }
            isFirstAppear = true
            app.navi = matchesNavi
            setupTabBarAppearance()
        }
        .onChange(of: app.activeTab) { _, tab in
            didSelectTab(tab)
        }
        .ignoresSafeArea(.all)
    }

    private func didSelectTab(_ tab: TabBarItem) {
        switch tab {
        case .matches: app.navi = matchesNavi
        case .competitions: app.navi = statisticNavi
        case .favorites: app.navi = budgetNavi
        case .setting: app.navi = settingNavi
        }
    }

    private func setupTabBarAppearance() {
        let primary = UIColor(named: "primary") ?? .systemGreen
        let normal = primary.withAlphaComponent(0.6)
        let selected = primary

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.stackedLayoutAppearance.normal.iconColor = normal
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normal]
        appearance.stackedLayoutAppearance.selected.iconColor = selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selected]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    @ViewBuilder
    private func tabIcon(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
    }
}

#Preview {
    TabBarView()
}
