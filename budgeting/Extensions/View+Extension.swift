//
//  View+Extension.swift
//  FlexiTrackr
//
//  Created by Kendall Easterly on 6/13/23.
//

import SwiftUI

extension View {
    func carded(px: CGFloat = 16, py: CGFloat = 16, bgColor: Color = .white) -> some View {
        modifier(CardedModifier(px: px, py: py, bgColor: bgColor))
    }
    
    func saveSize(in size: Binding<CGSize>) -> some View {
        modifier(SizeCalculator(size: size))
    }
}

struct CardedModifier: ViewModifier {
    
    var px: CGFloat
    var py: CGFloat
    var bgColor: Color
    @State var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        
        content
            .padding(.horizontal, px)
            .padding(.vertical, py)
            .background(bgColor)
            .cornerRadius(16.0)
            .shadow(color: Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.05999999965889559)), radius:4, x:0, y:2)
    }
}

struct SizeCalculator: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        
        content
            .background(GeometryReader {proxy in
                Color.clear
                    .onAppear {
                        size = proxy.size
                    }
            })
    }
}


