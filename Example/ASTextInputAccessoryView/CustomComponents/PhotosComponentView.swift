//
//  PhotosComponentView.swift
//  ASTextViewController
//
//  Created by Adam J Share on 4/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

import Photos
import ASTextInputAccessoryView

class PhotosComponentView: UIView {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func selectButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            reset()
        }
        else {
            collectionView.allowsMultipleSelection = true
            closeButton.setTitle("Done", for: UIControlState())
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            })
        }
    }
    
    var assets: PHFetchResult<PHAsset>!
    
    var selectedAssets: [PHAsset] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOpacity = 0.2
        collectionView.layer.shadowRadius = 2
    }
}

extension PhotosComponentView: ASComponent {
    
    var contentHeight: CGFloat {
        return 200
    }
    
    var textInputView: UITextInputTraits? {
        return searchBar
    }
    
    func animatedLayout(_ newheight: CGFloat) {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    func postAnimationLayout(_ newheight: CGFloat) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension PhotosComponentView {
    
    func reset() {
        selectButton.isSelected = false
        selectedAssets = []
        collectionView.allowsMultipleSelection = false
        closeButton.setTitle("X", for: UIControlState())
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        })
    }
    
    @IBAction func close(_ sender: AnyObject) {
        
        var shouldBecomeFirstResponder = false
        if selectedAssets.count > 0 {
            for asset in selectedAssets {
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.deliveryMode = .highQualityFormat
                let m = PHImageManager.default()
                m.requestImage(
                    for: asset,
                    targetSize: UIScreen.main.bounds.size,
                    contentMode: PHImageContentMode(rawValue: 1)!,
                    options: options
                ) { [weak self] (image, info) in
                    guard let image = image else {
                        return
                    }
                    if let view = self?.parentView?.components.first as? ASTextComponentView {
                        view.textView.insertImages([image])
                    }
                }
            }
            shouldBecomeFirstResponder = true
        }
        
        let component = parentView?.components.first
        parentView?.selectedComponent = component
        reset()
        collectionView.contentOffset = CGPoint.zero
        if shouldBecomeFirstResponder {
            (component?.textInputView as? UIView)?.becomeFirstResponder()
        }
    }
}


// MARK: Photo library
extension PhotosComponentView {
    
    func getPhotoLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        self.collectionView.reloadData()
    }
}


extension PhotosComponentView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let assets = assets else {
            return 0
        }
        
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCell
        
        cell.asset = assets?[(indexPath as NSIndexPath).item]
        cell.isSelected = selectedAssets.contains(cell.asset!)
        
        return cell
    }
}


class ImageCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.layer.borderColor = tintColor.cgColor
                imageView.layer.borderWidth = 4
            }
            else {
                imageView.layer.borderWidth = 0
            }
        }
    }
    
    var requestID: PHImageRequestID = 0
    var asset: PHAsset? {
        didSet {
            imageView.image = nil
            if let asset = asset {
                let manager = PHImageManager.default()
                
                cancelRequest()
                
                requestID = manager.requestImage(
                    for: asset,
                    targetSize: frame.size,
                    contentMode: PHImageContentMode(rawValue: 1)!,
                    options: nil
                ) { [weak self] (image, info) in
                    guard let id = info?[PHImageResultRequestIDKey] as? NSNumber
                        , PHImageRequestID(id.intValue) == self?.requestID ||
                            self?.requestID == 0  else {
                        return
                    }
                    self?.imageView.image = image
                }
            }
        }
    }
    func cancelRequest() {
        if requestID != 0 {
            PHImageManager.default().cancelImageRequest(requestID)
            requestID = 0
        }
    }
    
    let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        contentView.addSubview(imageView)
        let constraints = imageView.autoLayoutToSuperview()
        NSLayoutConstraint.activate(constraints)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.white
    }
}


extension PhotosComponentView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let asset = assets![(indexPath as NSIndexPath).item]
        
        if selectButton.isSelected {
            selectedAssets.append(asset)
            return
        }
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        let m = PHImageManager.default()
        m.requestImage(
            for: asset,
            targetSize: UIScreen.main.bounds.size,
            contentMode: PHImageContentMode(rawValue: 1)!,
            options: options
        ) { [weak self] (image, info) in
            guard let image = image else {
                return
            }
            if let view = self?.parentView?.components.first as? ASTextComponentView {
                view.textView.insertImages([image])
                self?.close(self!.closeButton)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        if let asset = assets?[(indexPath as NSIndexPath).item],
            let index = selectedAssets.index(of: asset) {
            selectedAssets.remove(at: index)
        }
    }
}


extension PhotosComponentView: UICollectionViewDelegateFlowLayout {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
}
