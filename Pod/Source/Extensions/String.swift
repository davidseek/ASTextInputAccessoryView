//
//  NSString.swift
//  Pods
//
//  Created by Adam J Share on 12/29/15.
//
//

import Foundation
import UIKit

// MARK: + Size

public extension String {
    
    func sizeWithFont(_ font: UIFont, maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        let constraint = CGSize(width: maxWidth, height: maxHeight)
        
        let frame = self.boundingRect(
            with: constraint,
            options:[.usesLineFragmentOrigin , .usesFontLeading],
            attributes:[NSFontAttributeName: font],
            context:nil
        )
        
        return CGSize(width: frame.size.width, height: frame.size.height);
    }
}
