//
//  FontConstant.swift
//  VNVideoSaver
//
//  Created by vishva narola on 19/06/25.
//

import SwiftUI

struct FontConstants {
    
    // MARK: - Font Families
    struct Family {
        static let montserratLight = "Montserrat-Light"
        static let montserratRegular = "Montserrat-Regular"
        static let montserratMedium = "Montserrat-Medium"
        static let montserratSemiBold = "Montserrat-SemiBold"
        static let montserratBold = "Montserrat-Bold"
        static let syneRegular = "Syne-Regular"
        static let syneMedium = "Syne-Medium"
        static let syneSemiBold = "Syne-SemiBold"
        static let syneBold = "Syne-Bold"
        static let syneExtraBold = "Syne-ExtraBold"
    }
    
    // MARK: - Dynamic Font Provider
    struct MontserratFonts {
        static func light(size: CGFloat) -> Font {
            Font.custom(Family.montserratLight, size: size)
        }
        
        static func regular(size: CGFloat) -> Font {
            Font.custom(Family.montserratRegular, size: size)
        }
        
        static func medium(size: CGFloat) -> Font {
            Font.custom(Family.montserratMedium, size: size)
        }
        
        static func semiBold(size: CGFloat) -> Font {
            Font.custom(Family.montserratSemiBold, size: size)
        }
        
        static func bold(size: CGFloat) -> Font {
            Font.custom(Family.montserratBold, size: size)
        }
    }
    
    struct SyneFonts {
        static func light(size: CGFloat) -> Font {
            Font.custom(Family.syneRegular, size: size)
        }
        
        static func regular(size: CGFloat) -> Font {
            Font.custom(Family.syneMedium, size: size)
        }
        
        static func medium(size: CGFloat) -> Font {
            Font.custom(Family.syneSemiBold, size: size)
        }
        
        static func semiBold(size: CGFloat) -> Font {
            Font.custom(Family.syneBold, size: size)
        }
        
        static func bold(size: CGFloat) -> Font {
            Font.custom(Family.syneExtraBold, size: size)
        }
    }
}
