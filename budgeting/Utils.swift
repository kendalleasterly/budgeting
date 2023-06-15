//
//  Utils.swift
//  FlexiTrackr
//
//  Created by Kendall Easterly on 6/15/23.
//

import Foundation

func formatDollarAmount(amount: Float)  -> String {
    let rounded = round(amount * 100) / 100
    
    let a = rounded - floor(rounded)
    
    if (round(a * 10) / 10 == round(a * 100) / 100) {
        
        return String(rounded) + "0"
    } else {
        return String(rounded)
    }
}
