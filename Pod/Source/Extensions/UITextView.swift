//
//  UITextView.swift
//  Pods
//
//  Created by Adam J Share on 11/5/15.
//
//

import UIKit

// MARK: + Content control

public extension UITextView {
    
    func scrollToBottomText() {
        if (self.text.characters.count > 0) {
            let bottom = NSMakeRange(self.text.characters.count - 1, 1);
            self.scrollRangeToVisible(bottom)
        }
    }
    
    public var sizeThatFitsWidth: CGSize {
        return sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    public var attributedTextHeight: CGFloat {
        return attributedText.boundingRect(with: CGSize(width: frame.size.width - textContainerInset.left - textContainerInset.right, height: CGFloat.greatestFiniteMagnitude), options:[.usesLineFragmentOrigin, .usesFontLeading], context:nil).height
    }
    
    public var lineHeight: CGFloat {
        guard let font = font else {
            return 0
        }
        return "line".sizeWithFont(font, maxWidth:CGFloat.greatestFiniteMagnitude, maxHeight:CGFloat.greatestFiniteMagnitude).height
    }
    
    public var numberOfRows: Int {
        return Int(round(attributedTextHeight / lineHeight))
    }
}
