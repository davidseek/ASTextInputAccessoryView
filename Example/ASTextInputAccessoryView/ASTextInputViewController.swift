//
//  ASTextInputViewController.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Photos
import ASTextInputAccessoryView

class ASTextInputViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var iaView: ASResizeableInputAccessoryView!
    let messageView = ASTextComponentView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let photoComponent = UINib
            .init(nibName: "PhotosComponentView", bundle: nil)
            .instantiate(withOwner: self, options: nil)
            .first as! PhotosComponentView
        iaView = ASResizeableInputAccessoryView(components: [messageView, photoComponent])
        iaView.delegate = self
        
        //        Experimental feature
        //        iaView.interactiveEngage(collectionView)
        
        updateInsets(iaView.contentViewHeightConstraint.constant)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
        collectionView.scrollToBottomContent(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        Test layout of changed parameters after setup
        //        changeAppearance()
    }
    
    
    func changeAppearance() {
        messageView.minimumHeight = 60
        messageView.margin = 3
        messageView.font = UIFont.boldSystemFont(ofSize: 30)
    }
}

//MARK: Input Accessory View
extension ASTextInputViewController {
    override var inputAccessoryView: UIView? {
        return iaView
    }
    
    // IMPORTANT Allows input view to stay visible
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    // Handle Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.messageView.textView.layoutIfNeeded()
            }) { (context) in
                self.iaView.reloadHeight()
        }
    }
}


// MARK: ASResizeableInputAccessoryViewDelegate
extension ASTextInputViewController: ASResizeableInputAccessoryViewDelegate {
    
    func updateInsets(_ bottom: CGFloat) {
        var contentInset = collectionView.contentInset
        contentInset.bottom = bottom
        collectionView.contentInset = contentInset
        collectionView.scrollIndicatorInsets = contentInset
    }
    
    func inputAccessoryViewWillAnimateToHeight(_ view: ASResizeableInputAccessoryView, height: CGFloat, keyboardHeight: CGFloat) -> (() -> Void)? {
        
        return { [weak self] in
            self?.updateInsets(keyboardHeight)
            self?.collectionView.scrollToBottomContent(false)
        }
    }
    
    func inputAccessoryViewKeyboardWillPresent(_ view: ASResizeableInputAccessoryView, height: CGFloat) -> (() -> Void)? {
        return { [weak self] in
            self?.updateInsets(height)
            self?.collectionView.scrollToBottomContent(false)
        }
    }
    
    func inputAccessoryViewKeyboardWillDismiss(_ view: ASResizeableInputAccessoryView, notification: Notification) -> (() -> Void)? {
        return { [weak self] in
            self?.updateInsets(view.frame.size.height)
        }
    }
    
    func inputAccessoryViewKeyboardDidChangeHeight(_ view: ASResizeableInputAccessoryView, height: CGFloat) {
        let shouldScroll = collectionView.isScrolledToBottom
        updateInsets(height)
        if shouldScroll {
            self.collectionView.scrollToBottomContent(false)
        }
    }
}



// MARK: Actions
extension ASTextInputViewController {
    
    @IBAction func dismissKeyboard(_ sender: AnyObject) {
        self.messageView.textView.resignFirstResponder()
    }
    
    func addCameraButton() {
        
        let cameraButton = UIButton(type: .custom)
        let image = UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate)
        cameraButton.setImage(image, for: UIControlState())
        cameraButton.tintColor = UIColor.gray
        
        messageView.leftButton = cameraButton
        
        let width = NSLayoutConstraint(
            item: cameraButton,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 40
        )
        cameraButton.superview?.addConstraint(width)
        
        cameraButton.addTarget(self, action: #selector(self.showPictures), for: .touchUpInside)
    }
    
    func showPictures() {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            OperationQueue.main.addOperation({
                if let photoComponent = self.iaView.components[1] as? PhotosComponentView {
                    self.iaView.selectedComponent = photoComponent
                    photoComponent.getPhotoLibrary()
                }
            })
        }
    }
}
