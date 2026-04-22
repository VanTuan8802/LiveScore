//
//  DataFreshable.swift
//  LiveScore
//
//  Created by VanTuan8802 on 21/4/26.
//


import Foundation
import Combine

@MainActor
class DataFreshable: ObservableObject {
    @Published var homeRefresh: Bool = false
}

