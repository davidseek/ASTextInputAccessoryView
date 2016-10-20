//
//  ASTextInputAccessoryView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import UIKit
import PMKVObserver
import ASPlaceholderTextView


open class ASTextComponentView: UIView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupMessageView()
        monitorTextViewContentSize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMessageView()
        monitorTextViewContentSize()
    }
    
    /**
     Standard height of bar without content.
     */
    open var minimumHeight: CGFloat = 44 {
        didSet {
            parentView?.reloadHeight()
        }
    }
    
    //MARK: Monitor textView contentSize updates
    
    func monitorTextViewContentSize() {
        _ = KVObserver(object: textView, keyPath: "contentSize") {[weak self] object, _, _ in
            // Awaits changes to textView otherwise will show error:
            // requesting caretRectForPosition: while the NSTextStorage has oustanding changes {x, y}
            OperationQueue.main.addOperation({ 
                self?.parentView?.reloadHeight()
            })
        }
    }
    
    // MARK: Message Views
    
    /**
     Placeholder textView.
     
     - Note: For automatic resizing, update the font var on the accessory view.
     */
    open let textView = ASPlaceholderTextView(frame: CGRect.zero, textContainer: nil)
    
    /**
     Container view for a custom button view autoresized to the left of the textView.
     */
    open let leftButtonContainerView = UIView()
    
    /**
     Container view for a custom button view autoresized to the right of the textView.
     */
    open let rightButtonContainerView = UIView()
    
    
    /**
     Space the textView and button views keep from surrounding views.
     */
    open var margin: CGFloat = 7 {
        didSet {
            updateContentConstraints()
            parentView?.reloadHeight()
            resetTextContainerInset()
        }
    }
    
    
    /**
     Resets textContainerInset based off the text line height and margin.
     */
    open func resetTextContainerInset() {
        let inset = (contentHeight - margin * 2 - textView.lineHeight)/2
        textView.textContainerInset = UIEdgeInsets(top: inset, left: 3, bottom: inset, right: 3)
    }
    
    func setupMessageView() {
        
        backgroundColor = UIColor.clear
        leftButtonContainerView.backgroundColor = UIColor.clear
        rightButtonContainerView.backgroundColor = UIColor.clear
        
        addSubview(leftButtonContainerView)
        addSubview(rightButtonContainerView)
        addSubview(textView)
        
        textView.allowImages = true
        textView.placeholder = "Text Message"
        textView.placeholderColor = UIColor.lightGray.withAlphaComponent(0.7)
        textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 0.5
        textView.delegate = self
        
        resetTextContainerInset()
        updateContentConstraints()
        addStandardSendButton()
    }
    
    func updateContentConstraints() {
        
        removeConstraints(constraints)
        
        leftButtonContainerView.autoLayoutToSuperview([.left, .bottom], inset: margin)
        rightButtonContainerView.autoLayoutToSuperview([.right, .bottom], inset: margin)
        textView.autoLayoutToSuperview([.top, .bottom], inset: margin)
        
        let left = NSLayoutConstraint(
            item: textView,
            attribute: .left,
            relatedBy: .equal,
            toItem: leftButtonContainerView,
            attribute: .right,
            multiplier: 1,
            constant: margin
        )
        let right = NSLayoutConstraint(
            item: textView,
            attribute: .right,
            relatedBy: .equal,
            toItem: rightButtonContainerView,
            attribute: .left,
            multiplier: 1,
            constant: -margin
        )
        addConstraint(left)
        addConstraint(right)
        
        textView.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .horizontal)
        textView.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
        textView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .vertical)
        
        for view in [leftButtonContainerView, rightButtonContainerView] {
            
            view.addHeightConstraint(minimumHeight - margin * 2)
            view.addWidthConstraint(0, priority: UILayoutPriorityDefaultLow)
            view.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
            view.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        }
    }
    
    
    // MARK: Button Views
    
    /**
     Standard "Send" button set as the rightButton.
     */
    open let defaultSendButton: UIButton = UIButton(type: .custom)
    
    /**
     Sets the standard "Send" button as the rightButton.
     */
    open func addStandardSendButton() {
        
        defaultSendButton.setTitle("Send", for: UIControlState())
        defaultSendButton.setTitleColor(tintColor, for: UIControlState())
        defaultSendButton.setTitleColor(tintColor.withAlphaComponent(0.5), for: .highlighted)
        defaultSendButton.setTitleColor(UIColor.lightGray.withAlphaComponent(0.5), for: .disabled)
        defaultSendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        defaultSendButton.isEnabled = false
        
        rightButton = defaultSendButton
    }
    
    /**
     Sets the left button view and removes any existing subviews.
     */
    open weak var leftButton: UIView? {
        didSet {
            leftButtonContainerView.subviews.forEach({ $0.removeFromSuperview() })
            
            if let button = leftButton {
                leftButtonContainerView.addSubview(button)
                button.autoLayoutToSuperview()
            }
        }
    }
    
    /**
     Sets the right button view and removes any existing subviews.
     */
    open weak var rightButton: UIView? {
        didSet {
            rightButtonContainerView.subviews.forEach({ $0.removeFromSuperview() })
            
            if let button = rightButton {
                rightButtonContainerView.addSubview(button)
                button.autoLayoutToSuperview()
            }
        }
    }
}

// MARK: ASComponent

extension ASTextComponentView: ASComponent {
    
    public var contentHeight: CGFloat {
        
        var nextBarHeight = minimumHeight
        
        // Nothing to calculate
        if textView.attributedText.length == 0 {
            return nextBarHeight
        }
        
        let textViewSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        let textViewMargins = textView.frame.origin.y + (textView.superview!.frame.size.height - textView.frame.size.height - textView.frame.origin.y)
        nextBarHeight = textViewSize.height + textViewMargins
        
        if nextBarHeight < minimumHeight {
            nextBarHeight = minimumHeight
        }
        
        return nextBarHeight
    }
    
    public func animatedLayout(_ newheight: CGFloat) {
        textView.scrollToBottomText()
    }
    
    public func postAnimationLayout(_ newheight: CGFloat) {
        textView.layoutIfNeeded()
    }
    
    public var textInputView: UITextInputTraits? {
        return textView
    }
}

// MARK: Get / Set

public extension ASTextComponentView {
    /**
     Font for the textView.
     */
    var font: UIFont {
        set {
            textView.font = newValue
            parentView?.reloadHeight()
            resetTextContainerInset()
        }
        get {
            return textView.font!
        }
    }
}


// MARK: Update Send Button Enabled

extension ASTextComponentView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        if textView == self.textView {
            defaultSendButton.isEnabled = textView.text.characters.count != 0
        }
    }
}


// MARK: UIInputViewAudioFeedback

extension ASTextComponentView: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
}
