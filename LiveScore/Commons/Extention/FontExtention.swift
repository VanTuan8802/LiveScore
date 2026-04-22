//
//  FontExtention.swift
//  LiveScore
//
//  Created by VanTuan8802 on 21/4/26.
//

import Foundation
import SwiftUI

enum FontFamily {
    case regular
    case medium
    case semiBold
    case bold
    case extraBold

    var font: String {
        switch self {
        case .regular:
            return "Inter-Regular"
        case .medium:
            return "Inter-Medium"
        case .semiBold:
            return "Inter-Semibold"
        case .bold:
            return "Inter-Bold"
        case .extraBold:
            return "Inter-ExtraBold"
        }
    }
}

extension Font {
    /// Regular
    static let regular8 = Font.custom(FontFamily.regular.font, size: 8)
    static let regular14 = Font.custom(FontFamily.regular.font, size: 14)
    static let regular16 = Font.custom(FontFamily.regular.font, size: 16)

    /// Medium
    static let medium10 = Font.custom(FontFamily.medium.font, size: 10)
    static let medium12 = Font.custom(FontFamily.medium.font, size: 12)
    static let medium14 = Font.custom(FontFamily.medium.font, size: 14)
    static let medium16 = Font.custom(FontFamily.medium.font, size: 16)
    static let medium20 = Font.custom(FontFamily.medium.font, size: 20)

    /// SemiBold
    static let semibold12 = Font.custom(FontFamily.semiBold.font, size: 12)
    static let semibold14 = Font.custom(FontFamily.semiBold.font, size: 14)
    static let semibold16 = Font.custom(FontFamily.semiBold.font, size: 16)
    static let semibold20 = Font.custom(FontFamily.semiBold.font, size: 20)
    static let semibold24 = Font.custom(FontFamily.semiBold.font, size: 24)
    static let semibold30 = Font.custom(FontFamily.semiBold.font, size: 30)

    /// Bold
    static let bold12 = Font.custom(FontFamily.bold.font, size: 12)
    static let bold20 = Font.custom(FontFamily.bold.font, size: 20)
    static let bold30 = Font.custom(FontFamily.bold.font, size: 30)
    
    /// ExtraBold
    static let extraBold22 = Font.custom(FontFamily.extraBold.font, size: 22)
}
