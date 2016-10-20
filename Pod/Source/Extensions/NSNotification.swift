//
//  UINotification.swift
//  Pods
//
//  Created by Adam J Share on 4/12/16.
//
//

import Foundation

// MARK: + Keyboard
public extension Notification {
    
    public var keyboardFrameBegin: CGRect {
        return frameValueForKey(UIKeyboardFrameBeginUserInfoKey)
    }
    
    public var keyboardFrameEnd: CGRect {
        return frameValueForKey(UIKeyboardFrameEndUserInfoKey)
    }
    
    fileprivate func frameValueForKey(_ key: String) -> CGRect {
        guard
            let userInfo = userInfo,
            let keyboardSize = (userInfo[key] as? NSValue)?.cgRectValue,
            let window = UIApplication.shared.keyWindow
            else {
                return CGRect.zero
        }
        
        return window.convert(keyboardSize, to:nil)
    }
    
    public var keyboardAnimationDuration: TimeInterval {
        
        guard
            let userInfo = userInfo,
            let time = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval)
            else {
                return 0
        }
        
        return time
    }
    
    public var keyboardAnimationCurve: UIViewAnimationOptions {
        guard
            let userInfo = userInfo,
            let rawValue = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int)
            else {
                return []
        }
        
        return [(UIViewAnimationOptions(rawValue: UInt(rawValue << 16))), .beginFromCurrentState]
    }
}
