//
//  FontBook.swift
//  ExpenseTracker
//
//  Created by Yavuz Selim Durak on 26.03.2024.
//

import Foundation
import SwiftUI

extension Font{
    
    static var semiBold: Font {
        return Font.custom("Poppins-SemiBold", size: 24)
    }
    static var medium: Font {
        return Font.custom("Poppins-Medium", size: 16)
    }
    
    public func black(fontSize: CGFloat ) -> Font {
        return Font.custom("Poppins-Black", size: fontSize)
    }
    
    public func blackItalic(fontSize: CGFloat) -> Font {
        return Font.custom("Poppins-BlackItalic", size: fontSize)
    }
    
    public func bold(fontSize: CGFloat ) -> Font {
        return Font.custom("Poppins-Bold", size: fontSize)
    }
    
    public func extraBold(fontSize: CGFloat ) -> Font {
        return Font.custom("Poppins-ExtraBold", size: fontSize)
    }
    
    public func extraLight(fontSize: CGFloat ) -> Font {
        return Font.custom("Poppins-ExtraLight", size: fontSize)
    }
    
    public func medium(fontSize: CGFloat ) -> Font {
        return Font.custom("Poppins-Medium", size: fontSize)
    }
    
    public func regular(fontSize: CGFloat ) -> Font {
        return Font.custom("Poppins-Regular", size: fontSize)
    }
    
    public func semiBold(fontSize: CGFloat ) -> Font {
        return Font.custom("Poppins-SemiBold", size: fontSize)
    }
}


enum FontWeight {
    case semiBold
    case medium
    case black
    case bold
    case extraLight
    case light
    case regular
}

extension Font {
    static let customFont: (FontWeight, CGFloat) -> Font = { fontType, size in
        switch fontType {
        case .semiBold:
            Font.custom("Poppins-SemiBold", size: size)
        case .medium:
            Font.custom("Poppins-Medium", size: size)
        case .black:
            Font.custom("Poppins-Black", size: size)
        case .bold:
            Font.custom("Poppins-Bold", size: size)
        case .extraLight:
            Font.custom("Poppins-ExtraLight", size: size)
        case .light:
            Font.custom("Poppins-Light", size: size)
        case .regular:
            Font.custom("Poppins-Regular", size: size)
        }
    }
}

extension Text {
    func customFont(_ fontWeight: FontWeight? = .regular, _ size: CGFloat? = nil) -> Text {
        return self.font(.customFont(fontWeight ?? .regular, size ?? 16))
    }
}
