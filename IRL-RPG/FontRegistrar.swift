//
//  FontRegistrar.swift
//  IRL-RPG
//

import CoreText
import Foundation

enum FontRegistrar {
    static private(set) var fontName: String?

    @discardableResult
    static func registerFont() -> String? {
        if let name = fontName { return name }
        guard let url = Bundle.main.url(forResource: "runescape_uf", withExtension: "ttf") else {
            return nil
        }

        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor]
        let name = descriptors?.compactMap {
            CTFontDescriptorCopyAttribute($0, kCTFontNameAttribute) as? String
        }.first
        fontName = name
        return name
    }
}
