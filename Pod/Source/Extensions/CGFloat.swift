//
//  CGFloat.swift
//  Pods
//
//  Created by Adam J Share on 4/10/16.
//
//

import Foundation

// MARK: + Rounding

public extension CGFloat {
    
    var roundToNearestHalf: CGFloat {
        return (self * 2).rounded()/2
    }
}
