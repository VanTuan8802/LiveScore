//
//  NavigationType.swift
//  LiveScore
//
//  Created by VanTuan8802 on 19/4/26.
//


import SwiftUI

enum NavigationType: Equatable {
    case push
    case fullScreenCover
    case sheet(detents: Set<PresentationDetent>? = nil)
    
    var detents: Set<PresentationDetent>? {
        if case .sheet(let detents) = self {
            return detents
        }
        return nil
    }
}

enum PopToRootType {
    enum ModalType {
        case count(Int)
        case all
    }
    
    case modal(ModalType)
    case keepModal
    case root
}
