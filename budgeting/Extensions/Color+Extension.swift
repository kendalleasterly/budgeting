//
//  Color+Extension.swift
//  FlexiTrackr
//
//  Created by Kendall Easterly on 6/13/23.
//

import SwiftUI

extension Color {
    public static var primaryLabel: Color {
        Color("label")
    }
    
    public static var appColor: Color {
        Color(#colorLiteral(red: 0.24705882370471954, green: 0.686274528503418, blue: 0.658823549747467, alpha: 1))
    }
    
    public static var secondaryLabel: Color {
        Color(uiColor: UIColor.secondaryLabel)
    }
    
    public static var tertiaryLabel: Color {
        Color(uiColor: UIColor.tertiaryLabel)
    }
    
    public static var secondaryBackground: Color {
        Color(uiColor: UIColor.secondarySystemBackground)
    }
    
    public static var cardedBackground: Color {
        
        @Environment(\.colorScheme) var colorScheme
        
        return ((colorScheme == .light) ? Color.white : Color(uiColor: UIColor.secondarySystemBackground))
    }
    
}

