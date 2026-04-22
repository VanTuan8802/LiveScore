//
//  NavigationRoot.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//


import SwiftUI
import Combine

struct NavigationRoot: View {
    let destination: Destination
    @StateObject var navigation: Navigation
    
    var body: some View {
        NavigationView(destinationWrapper: DestinationWrapper(destination: destination, navigationType: nil),
                       navigationController: navigation.rootNavigationController)
        .environmentObject(navigation)
    }
}
