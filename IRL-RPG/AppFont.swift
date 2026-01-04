//
//  AppFont.swift
//  IRL-RPG
//

import SwiftUI

enum AppFont {
    static func custom(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if let name = FontRegistrar.fontName {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight)
    }
}
