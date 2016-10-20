//
//  ASAnimationOptions.swift
//  Pods
//
//  Created by Adam J Share on 4/11/16.
//
//

import Foundation

public struct ASAnimationOptions {
    
    public var duration: TimeInterval = 0.25
    public var delay: TimeInterval = 0.0
    public var damping: CGFloat = 0.8
    public var velocity: CGFloat = 0.0
    public var options: UIViewAnimationOptions = [.beginFromCurrentState]
    
    public init() { }
}


public extension ASAnimationOptions {
    
    func animate(_ animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: options,
            animations: animations,
            completion: completion
        )
    }
}
