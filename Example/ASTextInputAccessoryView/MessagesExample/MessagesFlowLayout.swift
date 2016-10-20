//
//  MessagesFlowLayout.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public extension UICollectionViewLayoutAttributes {
    
    func alignFrameWithInset(_ inset: UIEdgeInsets) {
        var frame = self.frame
        frame.origin.x = inset.left
        self.frame = frame
    }
}

public protocol LayoutAlignment {
    func insetsForIndexPath(_ indexPath: IndexPath) -> UIEdgeInsets
}


class MessagesFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var updatedAttributes = originalAttributes
        
        for attributes in originalAttributes {
            if attributes.representedElementKind != nil {
                continue
            }
            
            if let index = updatedAttributes.index(of: attributes),
                let layout = layoutAttributesForItem(at: attributes.indexPath) {
                updatedAttributes[index] = layout
            }
        }
        
        return updatedAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes
        
        let sectionInset = evaluatedSectionInsetForItemAtIndexPath(indexPath)
        
        currentItemAttributes?.alignFrameWithInset(sectionInset)
        
        return currentItemAttributes
    }
    
    func evaluatedMinimumInteritemSpacingForItemAtIndex(_ index: Int) -> CGFloat {
        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
            let spacing = delegate.collectionView?(collectionView!, layout:self, minimumInteritemSpacingForSectionAt: index) {
            return spacing
        }
        
        return self.minimumInteritemSpacing
    }
    
    func evaluatedSectionInsetForItemAtIndexPath(_ indexPath: IndexPath) -> UIEdgeInsets {
        
        if let inset = (collectionView?.delegate as? LayoutAlignment)?.insetsForIndexPath(indexPath) {
            return inset
        }
        
        return UIEdgeInsets.zero
    }
}
