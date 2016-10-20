//
//  UIView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import Foundation


// MARK: + Layout

public extension UIView {
    
    func autoLayoutToSuperview(_ attributes: [NSLayoutAttribute] = [.left, .right, .top, .bottom], inset: CGFloat = 0) -> [NSLayoutConstraint] {
        
        var constraints: [NSLayoutConstraint] = []
        translatesAutoresizingMaskIntoConstraints = false
        
        for attribute in attributes {
            
            var constant = inset
            switch attribute {
            case .right:
                constant = -inset
            case .bottom:
                constant = -inset
            default:
                break
            }
            
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: .equal,
                toItem: self.superview,
                attribute: attribute,
                multiplier: 1,
                constant: constant
            )
            self.superview?.addConstraint(constraint)
            constraints.append(constraint)
        }
        
        return constraints
    }
    
    func addHeightConstraint(_ constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityDefaultHigh) -> NSLayoutConstraint {
        
        return addSizeConstraint(.height, constant: constant, priority: priority)
    }
    
    func addWidthConstraint(_ constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityDefaultHigh) -> NSLayoutConstraint {
        
        return addSizeConstraint(.width, constant: constant, priority: priority)
    }
    
    fileprivate func addSizeConstraint(_ attribute: NSLayoutAttribute, constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityDefaultHigh) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: constant
        )
        constraint.priority = priority
        superview?.addConstraint(constraint)
        return constraint
    }
}
