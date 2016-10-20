//
//  NSObject.swift
//  Pods
//
//  Created by Adam J Share on 4/12/16.
//
//

import Foundation


public extension NSObject {
    
    func addKeyboardNotificationsAll() {
        addKeyboardNotificationsShow()
        addKeyboardNotificationsHide()
        addKeyboardNotificationsChangeFrame()
    }
    
    func addKeyboardNotificationsShow() {
        addNotificationSelectors([
            NSNotification.Name.UIKeyboardWillShow.rawValue: #selector(self.keyboardWillShow(_:)),
            NSNotification.Name.UIKeyboardDidShow.rawValue: #selector(self.keyboardDidShow(_:))
            ])
    }
    
    func addKeyboardNotificationsHide() {
        addNotificationSelectors([
            NSNotification.Name.UIKeyboardWillHide.rawValue: #selector(self.keyboardWillHide(_:)),
            NSNotification.Name.UIKeyboardDidHide.rawValue: #selector(self.keyboardDidHide(_:))
            ])
    }
    
    func addKeyboardNotificationsChangeFrame() {
        addNotificationSelectors([
            NSNotification.Name.UIKeyboardWillChangeFrame.rawValue: #selector(self.keyboardWillChangeFrame(_:)),
            NSNotification.Name.UIKeyboardDidChangeFrame.rawValue: #selector(self.keyboardDidChangeFrame(_:))
            ])
    }
    
    func addNotificationSelectors(_ keyedSelectors: [String: Selector]) {
        let nc = NotificationCenter.default
        for (name, selector) in keyedSelectors {
            nc.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
        }
    }
    
    func removeKeyboardNotificationsAll() {
        removeKeyboardNotificationsHide()
        removeKeyboardNotificationsShow()
        removeKeyboardNotificationsChangeFrame()
    }
    
    func removeKeyboardNotificationsHide() {
        removeNotificationNames(
            [NSNotification.Name.UIKeyboardWillHide.rawValue, NSNotification.Name.UIKeyboardDidHide.rawValue]
        )
    }
    
    func removeKeyboardNotificationsShow() {
        removeNotificationNames(
            [NSNotification.Name.UIKeyboardWillShow.rawValue, NSNotification.Name.UIKeyboardDidShow.rawValue]
        )
    }
    
    func removeKeyboardNotificationsChangeFrame() {
        removeNotificationNames(
            [NSNotification.Name.UIKeyboardWillChangeFrame.rawValue, NSNotification.Name.UIKeyboardDidChangeFrame.rawValue]
        )
    }
    
    fileprivate func removeNotificationNames(_ names: [String]) {
        let nc = NotificationCenter.default
        for name in names {
            nc.removeObserver(self, name: NSNotification.Name(rawValue: name), object: nil )
        }
    }
    
    func keyboardWillShow(_ notification: Notification) { }
    func keyboardDidShow(_ notification: Notification) { }
    func keyboardWillHide(_ notification: Notification) { }
    func keyboardDidHide(_ notification: Notification) { }
    func keyboardWillChangeFrame(_ notification: Notification) { }
    func keyboardDidChangeFrame(_ notification: Notification) { }
}
