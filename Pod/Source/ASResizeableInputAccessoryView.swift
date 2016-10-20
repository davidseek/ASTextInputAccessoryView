//
//  ASResizeableInputAccessoryView.swift
//  Pods
//
//  Created by Adam J Share on 4/11/16.
//
//

import Foundation
import PMKVObserver
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class ASResizeableInputAccessoryView: UIView {
    
    open weak var delegate: ASResizeableInputAccessoryViewDelegate?
    
    fileprivate var isDragging = false
    fileprivate var isInteractiveEnabling = false
    
    fileprivate var contentOffsetObserver: KVObserver?
    fileprivate var stateObserver: KVObserver?
    
    fileprivate weak var interactiveScrollView: UIScrollView? {
        willSet {
            stopMonitoringScrollView()
        }
        didSet {
            monitorScrollView()
        }
    }
    
    open var animationOptions: ASAnimationOptions! = ASAnimationOptions()
    
    /**
     Animates changes to the contentView height before height change of self.
     - default: `true`
     */
    open var animateBarHeightOnReload: Bool = true
    
    /**
     The maximum point in the window's Y axis that the InputAccessoryView origin should reach.
     */
    open var maximumBarY: CGFloat {
        if let max = delegate?.inputAccessoryViewMaximumBarY(self) {
            return max
        }
        return UIViewController.topViewController.topBarHeight
    }
    
    /**
     Height of the selected content.
     */
    open var contentHeight: CGFloat {
        if let height = selectedComponent?.contentHeight {
            return height
        }
        return 0
    }
    
    /**
     Sets height to the current content height. Will animate if animateBarHeightOnReload is true.
     
     - parameters:
     - options: Optional animation options. Defaults to animationOptions.
     */
    
    open func reloadHeight(_ options: ASAnimationOptions? = nil) {
        setHeight(contentHeight, animated: animateBarHeightOnReload, options: options)
    }
    
    /**
     Internal height constraint that is created when added to keyboard. This is the true height of the view. When animating this will stay at the previous height until completion of animation. Canceling animations could cause this height to be set incorrectly
     */
    open var heightConstraint: NSLayoutConstraint?
    override open func addConstraint(_ constraint: NSLayoutConstraint) {
        // Capture the height layout constraint
        if constraint.firstAttribute == .height && constraint.firstItem as? NSObject == self {
            heightConstraint = constraint
        }
        super.addConstraint(constraint)
    }
    
    open var components: [ASComponent] = [] {
        didSet {
            selectedComponent = components.first
        }
    }
    
    fileprivate var _selectedComponent: ASComponent?
    open var selectedComponent: ASComponent? {
        set {
            var shouldSetFirstResponder = false
            var previousView: UIView?
            
            if let view = selectedComponent as? UIView {
                shouldSetFirstResponder = (selectedComponent?.textInputView as? UIView)?.isFirstResponder == true
                previousView = view
            }
            if let view = newValue as? UIView {
                contentView.addSubview(view)
                view.autoLayoutToSuperview()
                
                if shouldSetFirstResponder {
                    (newValue?.textInputView as? UIView)?.becomeFirstResponder()
                }
            }
            _selectedComponent = newValue
            
            previousView?.removeFromSuperview()
            
            reloadHeight()
        }
        get {
            return _selectedComponent
        }
    }
    
    public convenience init(components: [ASComponent]) {
        let component = components.first!
        
        self.init(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: component.contentHeight
            )
        )
        self.components = components
        selectedComponent = component
        if let view = selectedComponent as? UIView {
            contentView.addSubview(view)
            view.autoLayoutToSuperview()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        addKeyboardNotificationsAll()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContentView()
        addKeyboardNotificationsAll()
    }
    
    // MARK: Keyboard monitoring
    deinit {
        removeKeyboardNotificationsAll()
    }
    
    /**
     Keeps track of keyboard presentation as an interactive dismiss that cancels can trigger an event that mimics a standard keyboard presentation
     */
    open var keyboardPresented: Bool = false
    
    // MARK: Main Content Views
    
    /**
     Any custom views should be added to the contentView subview hierarchy.
     */
    open let contentView = UIView()
    
    /**
     Any custom views should be added to the contentView subview hierarchy.
     */
    open let selectedComponentContainerView = UIView()
    
    /**
     Background toolbar for standard appearance.
     */
    open let toolbar = UIToolbar()
    
    
    /**
     Height constraint of the contentView. Is used to animate height and therefore can be used to find the most up to date height set.
     */
    open var contentViewHeightConstraint: NSLayoutConstraint!
    
    func setupContentView() {
        
        backgroundColor = UIColor.clear
        
        addSubview(contentView)
        contentView.backgroundColor = UIColor.white
        contentView.autoLayoutToSuperview([.bottom, .left, .right], inset: 0)
        
        var constant: CGFloat = frame.size.height
        if let height = selectedComponent?.contentHeight {
            constant = height
        }
        contentViewHeightConstraint = contentView.addHeightConstraint(constant, priority: UILayoutPriorityRequired)
        
        contentView.insertSubview(toolbar, at: 0)
        toolbar.barStyle = .default
        toolbar.autoLayoutToSuperview()
    }
    
    /**
     Executes animation with completion. Override to insert animateable changes.
     */
    open func updateBarHeight(_ animated: Bool, options: ASAnimationOptions, animateableChange:@escaping () -> Void, completion:@escaping (Bool) -> Void) {
        
        if !animated {
            animateableChange()
            completion(true)
            return
        }
        
        options.animate(animateableChange, completion: completion)
    }
}


extension ASResizeableInputAccessoryView {
    
    /**
     Height of the view. Changes will be immediate. To animate use the setHeight:animated: method
     */
    public var height: CGFloat {
        set {
            setHeight(newValue, animated: false)
        }
        get {
            return contentViewHeightConstraint.constant
        }
    }
    
    /**
     Max height of the view in relation to the keyboard height and maximumBarY value.
     */
    var maximumHeight: CGFloat {
        var keyboardHeight:CGFloat = 0
        if let superview = superview {
            keyboardHeight = superview.frame.size.height
        }
        let fullHeight = UIScreen.main.bounds.size.height
        
        let barHeight = frame.size.height
        keyboardHeight -= barHeight
        
        // Space between keyboard without the bar and the top layout constraint of maximumBarY
        let max = fullHeight - keyboardHeight - maximumBarY
        
        return max
    }
    
    
    /**
     Sets the height of the view with option to animate.
     */
    public func setHeight(_ height: CGFloat, animated: Bool, options: ASAnimationOptions? = nil) {
        
        if superview == nil {
            return
        }
        
        var nextBarHeight = height
        let maxHeight = maximumHeight
        
        if nextBarHeight > maxHeight {
            nextBarHeight = maxHeight
        }
        
        if let delegatedHeight = delegate?
            .inputAccessoryViewNextHeight(self, suggestedHeight: nextBarHeight, currentHeight: contentViewHeightConstraint.constant) {
            nextBarHeight = delegatedHeight
        }
        
        guard let heightConstraint = heightConstraint else {
            print("ASTextInputAccessoryView heightConstraint was not found.")
            if autoresizingMask != UIViewAutoresizing() {
                // If internal height constraint wasn't found the view layout mask may have been set
                print("AutoresizingMask should be set to .None (0). Current autoresizingMask: ", autoresizingMask)
            }
            return
        }
        
        let contentViewEqualHeight = contentViewHeightConstraint.constant.roundToNearestHalf == nextBarHeight.roundToNearestHalf
        
        guard !contentViewEqualHeight else {
            return
        }
        
        var options = options
        if options == nil {
            options = animationOptions
        }
        
        let fullHeight = superview?.frame.size.height != nil ? superview!.frame.size.height : 0
        var keyboardHeight = fullHeight - frame.size.height + nextBarHeight
        keyboardHeight = keyboardHeight < 0 ? nextBarHeight : keyboardHeight
        
        let delegateChange = delegate?.inputAccessoryViewWillAnimateToHeight(self, height: nextBarHeight, keyboardHeight: keyboardHeight)
        
        updateBarHeight(
            animated,
            options: options!,
            animateableChange: {
                self.contentViewHeightConstraint.constant = nextBarHeight
                self.contentView.layoutIfNeeded()
                delegateChange?()
                self.selectedComponent?.animatedLayout(nextBarHeight)
            },
            completion: { (finished) in
                heightConstraint.constant = nextBarHeight
                self.layoutIfNeeded()
                self.delegate?.inputAccessoryViewDidAnimateToHeight(self, height: nextBarHeight, keyboardHeight: keyboardHeight)
                self.selectedComponent?.postAnimationLayout(nextBarHeight)
            }
        )
    }
}



//MARK: Keyboard notifications
public extension ASResizeableInputAccessoryView {
    
    /**
     Interactive dismiss causes confusion with notifications so to try and regulate we'll keep track of when it was already shown and when it's being dismissed. We can compare the FrameEnd height to the view height and FrameBegin height to filter out willShow notes based on keyboard dismissing but the view sticking around.
     */
    
    public override func keyboardWillShow(_ notification: Notification) {
        
        guard
            !keyboardPresented &&
                notification.keyboardFrameEnd.height != frame.size.height &&
                notification.keyboardFrameBegin.height == notification.keyboardFrameEnd.height
            else {
                return
        }
        
        keyboardPresented = true
        
        let animation = delegate?.inputAccessoryViewKeyboardWillPresent(self, height: presentedHeight)
        keyboardAnimation(notification, block: animation)
    }
    
    public override func keyboardWillHide(_ notification: Notification) {
        
        let height = visibleHeight
        if height < 0 || height > heightConstraint?.constant {
            return
        }
        keyboardPresented = false
        let animation = delegate?.inputAccessoryViewKeyboardWillDismiss(self, notification: notification)
        keyboardAnimation(notification, block: animation)
    }
    
    public override func keyboardDidChangeFrame(_ notification: Notification) {
        
        let isAnimating = contentView.layer.animationKeys()?.count > 0
        if !isAnimating && keyboardPresented && interactiveScrollView == nil {
            delegate?.inputAccessoryViewKeyboardDidChangeHeight(self, height: visibleHeight)
        }
    }
    
    fileprivate func keyboardAnimation(_ notification: Notification, block: (() -> Void)?) {
        guard let animationBlock = block else {
            return
        }
        
        UIView.animate(
            withDuration: notification.keyboardAnimationDuration,
            delay: 0.0,
            options: notification.keyboardAnimationCurve,
            animations: animationBlock,
            completion: nil
        )
    }
    
    /**
     Keyboard plus view height that is visible on screen.
     */
    public var visibleHeight: CGFloat {
        var keyboardY: CGFloat = 0
        if let superview = superview {
            keyboardY = superview.frame.origin.y
        }
        let fullHeight = UIScreen.main.bounds.size.height
        
        keyboardY = keyboardY + heightConstraint!.constant - contentViewHeightConstraint.constant
        
        let visibleHeight = fullHeight - keyboardY
        return visibleHeight
    }
    
    /**
     Keyboard plus view height.
     */
    public var presentedHeight: CGFloat {
        var keyboardHeight: CGFloat = 0
        if let superview = superview {
            keyboardHeight = superview.frame.size.height
        }
        
        return keyboardHeight - frame.size.height + contentViewHeightConstraint.constant
    }
}

//MARK: Interactive Engage
extension ASResizeableInputAccessoryView {
    
    fileprivate var contentOffset: String { return "contentOffset"}
    fileprivate var state: String { return "state"}
    
    /**
     - Experimental: Attempts to recreate Facebook Messenger's pull up to engage the textView.
     */
    public func interactiveEngage(_ scrollView: UIScrollView) {
        interactiveScrollView = scrollView
    }
    
    fileprivate func stopMonitoringScrollView() {
        stateObserver?.cancel()
        contentOffsetObserver?.cancel()
    }
    
    fileprivate func monitorScrollView() {
        
        guard let interactiveScrollView = interactiveScrollView else {
            return
        }
        stopMonitoringScrollView()
        contentOffsetObserver = KVObserver(object: interactiveScrollView, keyPath: "contentOffset") {[weak self] object, _, _ in
            self?.scrollViewDidScroll(object)
        }
        
        stateObserver = KVObserver(object: interactiveScrollView.panGestureRecognizer, keyPath: "state") {[weak self] object, _, _ in
            self?.panGestureStateChanged(object)
        }
    }
    
    fileprivate func panGestureStateChanged(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .began:
            isDragging = true
        case .ended, .cancelled:
            isDragging = false
            stopInteractiveEnable()
        default:
            break
        }
    }
    
    fileprivate func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isDragging {
            return
        }
        
        if !isInteractiveEnabling &&
            !keyboardPresented &&
            scrollView.isScrolledToBottom &&
            selectedComponent?.textInputView != nil {
            startInteractiveEnable(scrollView)
        }
        
        if isInteractiveEnabling {
            if !keyboardFullyExtended {
                delegate?.inputAccessoryViewKeyboardDidChangeHeight(self, height: visibleHeight)
            }
        }
    }
    
    fileprivate func startInteractiveEnable(_ scrollView: UIScrollView) {
        if isInteractiveEnabling {
            return
        }
        removeKeyboardNotificationsAll()
        
        
        isInteractiveEnabling = true
        
        let locationInputView = scrollView.panGestureRecognizer.location(in: contentView)
        heightConstraint?.constant = contentViewHeightConstraint.constant + abs(locationInputView.y)
        
        UIView.performWithoutAnimation({
            (self.selectedComponent?.textInputView as? UIView)?.becomeFirstResponder()
        })
    }
    
    fileprivate func stopInteractiveEnable() {
        if !isInteractiveEnabling {
            return
        }
        
        heightConstraint?.constant = contentViewHeightConstraint.constant
        addKeyboardNotificationsAll()
        isInteractiveEnabling = false
    }
    
    fileprivate var keyboardFullyExtended: Bool {
        return presentedHeight == visibleHeight
    }
}
