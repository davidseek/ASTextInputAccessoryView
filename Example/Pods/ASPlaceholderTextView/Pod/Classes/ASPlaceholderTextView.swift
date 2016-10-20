//
//  ASPlaceholderTextView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import UIKit

@IBDesignable
open class ASPlaceholderTextView: UITextView {
    
    open var allowImages: Bool = false
    
    open var maximumImageSize: CGSize = CGSize(width: UIScreen.main.bounds.width/2, height: CGFloat.greatestFiniteMagnitude)
    
    @IBInspectable open var placeholder: String? {
        set {
            placeholderLabel.text = newValue
        }
        get {
            return placeholderLabel.text
        }
    }
    
    @IBInspectable open var placeholderColor: UIColor? {
        set {
            placeholderLabel.textColor = newValue
        }
        get {
            return placeholderLabel.textColor
        }
    }
    
    fileprivate weak var secondaryDelegate: UITextViewDelegate?
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholderLabel()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlaceholderLabel()
    }
    
    var left: NSLayoutConstraint?
    var width: NSLayoutConstraint?
    var top: NSLayoutConstraint?
    
    open var placeholderLabel: UILabel = UILabel()
    
    func setupPlaceholderLabel() {
        
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.text = placeholder
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.numberOfLines = 0
        placeholderLabel.font = font
        
        refreshLabelHidden()
        
        addSubview(placeholderLabel)
        
        let offset = textContainer.lineFragmentPadding
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        left = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .left,
            relatedBy: .equal,
            toItem: self,
            attribute: .left,
            multiplier: 1,
            constant: textContainerInset.left + offset
        )
        
        width = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1,
            constant: -(textContainerInset.right + offset + textContainerInset.left + offset)
        )
        
        top = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: textContainerInset.top
        )
        
        addConstraints([left!, width!, top!])
    }
    
    func updateLabelConstraints() {
        
        let offset = textContainer.lineFragmentPadding
        
        left?.constant = textContainerInset.left + offset
        width?.constant = -(textContainerInset.right + offset + textContainerInset.left + offset)
        top?.constant = textContainerInset.top
        
        setNeedsLayout()
    }
    
    func refreshLabelHidden() {
        if text == "" || text == nil {
            placeholderLabel.isHidden = false
            return
        } else {
            placeholderLabel.isHidden = true
        }
    }
}

// MARK: Forwarding Delegate
public extension ASPlaceholderTextView {
    
    override open var delegate: UITextViewDelegate? {
        set {
            secondaryDelegate = newValue
        }
        get {
            return self
        }
    }
    
    override open func responds(to aSelector: Selector) -> Bool {
        return super.responds(to: aSelector) || secondaryDelegate?.responds(to: aSelector) == true
    }
    
    override open func forwardingTarget(for aSelector: Selector) -> Any? {
        
        if (secondaryDelegate?.responds(to: aSelector) == true) {
            return secondaryDelegate
        }
        
        return super.forwardingTarget(for: aSelector)
    }
}


// MARK: Override text setters
public extension ASPlaceholderTextView {
    
    open override var font: UIFont? {
        didSet{
            placeholderLabel.font = font
        }
    }
    
    open override var textContainerInset: UIEdgeInsets {
        didSet {
            updateLabelConstraints()
        }
    }
    
    open override var text: String! {
        didSet {
            refreshLabelHidden()
            
            textViewDidChange(self)
        }
    }
    
    open override var attributedText: NSAttributedString! {
        didSet {
            refreshLabelHidden()
            
            textViewDidChange(self)
        }
    }
    
    open override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
}

// MARK: UITextView Delegate
extension ASPlaceholderTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        
        refreshLabelHidden()
        
        secondaryDelegate?.textViewDidChange?(textView)
    }
}

// MARK: Custom paste for images

public extension ASPlaceholderTextView {
    
    fileprivate func scaledImage(_ image: UIImage) -> UIImage {
        
        var scaleFactor: CGFloat = 1
        
        let heightScaleFactor = image.size.height / maximumImageSize.height
        let widthScaleFactor = image.size.width / maximumImageSize.width
        
        if heightScaleFactor > widthScaleFactor {
            scaleFactor = heightScaleFactor
        } else {
            scaleFactor = widthScaleFactor
        }
        
        if scaleFactor < 1 {
            scaleFactor = 1
        }
        
        return UIImage(cgImage: image.cgImage!, scale: scaleFactor, orientation: .up)
    }
    
    open override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        
        if allowImages, let images = pasteboard.images {
            insertImages(images)
        }
        else if let string = pasteboard.string {
            insertAttributedString(NSMutableAttributedString(string: string))
        }
    }
    
    public func insertImages(_ images: [UIImage], range: NSRange? = nil) {
        
        let imageAttrString = NSMutableAttributedString()
        for image in images {
            let textAttachment = NSTextAttachment()
            textAttachment.image = scaledImage(image)
            
            imageAttrString.append(NSAttributedString(attachment: textAttachment))
            imageAttrString.append(NSAttributedString(string: "\n\n"))
        }
        
        insertAttributedString(imageAttrString, range: range)
    }
    
    public func insertAttributedString(_ string: NSAttributedString, range: NSRange? = nil, overrideFont: Bool = true) {
        
        var range = range
        if range == nil {
            range = selectedRange
        }
        
        let mutableAttrString = attributedText.mutableCopy() as! NSMutableAttributedString
        mutableAttrString.replaceCharacters(in: range!, with: string)
        
        if overrideFont, let font = font {
            mutableAttrString.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: mutableAttrString.length))
        }
        
        attributedText = mutableAttrString
    }
}

