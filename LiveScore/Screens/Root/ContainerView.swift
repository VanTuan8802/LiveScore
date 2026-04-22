//
//  ContainerView.swift
//  LiveScore
//
//  Created by VanTuan8802 on 21/4/26.
//


import SwiftUI
import Factory

struct ContainerView: View {
    
    @State private var isSplashShowing: Bool = true
    @State private var isFirstLaunch: Bool = true
    @InjectedObject(\.app) private var app: AppManager
    
    @StateObject private var login = Navigation()
    
    
    var body: some View {
        contentView
        
    }
    
    @ViewBuilder @MainActor
    private var contentView: some View {
        Group {
            if isSplashShowing {
                SplashView(
                    onCompleted: {
                        withAnimation {
                            isSplashShowing = false
                            isFirstLaunch = false
                        }
                    }
                )
            } else {
                TabBarView()
            }
        }
    }
}

#Preview {
    ContainerView()
}
