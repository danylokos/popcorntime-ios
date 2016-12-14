//
//  StratchyHeader.swift
//  PopcornTime
//
//  Created by Andrew  K. on 4/6/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

protocol StratchyHeaderDelegate: class {
    ///Triggers when header max stratch value is recalculated
    func stratchyHeader(_ header: StratchyHeader, didResetMaxStratchValue value: CGFloat)
}


class StratchyHeader: UICollectionReusableView {
    
    weak var delegate: StratchyHeaderDelegate?
    
    // MARK: - Public API
    var image: UIImage? {
        didSet {
            if let image = image {
                imageAspectRatio = image.size.height / image.size.width
                backgroundImageView.image = image
                
                updateImageViewConstraints()
            }
        }
    }
    
    var headerSize: CGSize = CGSize(width: 1, height: 1) {
        didSet {
            updateImageViewConstraints()
        }
    }
    
    // MARK: - UICollectionReusableView
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let attributes = layoutAttributes as! StratchyLayoutAttributes
        
        let height = attributes.frame.height
        if (previousHeight != height) {
            
            if (maxStratch != 0) {
                let alpha = 1 - attributes.deltaY / maxStratch
                foregroundView.alpha = alpha
            }
            
            if (imageAspectRatio != 0) {
                heightConstraint.constant = imageViewActualHeight - attributes.deltaY
                widthConstraint.constant = imageViewActualWidth - (attributes.deltaY / imageAspectRatio)
            }
            previousHeight = height
        }
    }
    
    // MARK: - Private
    @IBOutlet weak fileprivate var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var backgroundImageView: UIImageView!
    
    @IBOutlet weak var foregroundView: UIView!
    @IBOutlet weak var foregroundImage: UIImageView!
    @IBOutlet weak var synopsisTextView: UILabel!
    
    
    fileprivate var maxStratch: CGFloat = 0
    
    fileprivate var zoomWidthCoef: CGFloat {
        get {
            let headerAspectRatio = headerSize.height / headerSize.width
            return (1.7 * headerAspectRatio) / 0.5325  // Experimentally calculated value :]
        }
    }
    fileprivate var imageAspectRatio: CGFloat = 0
    fileprivate var imageViewActualWidth: CGFloat {
        return headerSize.width * zoomWidthCoef
    }
    fileprivate var imageViewActualHeight: CGFloat {
        return imageViewActualWidth * imageAspectRatio
    }
    fileprivate var previousHeight: CGFloat = 0
    
    fileprivate func updateImageViewConstraints() {
        
//        let dX = fabs(headerSize.height - imageViewActualHeight)/2
        let dY = fabs(headerSize.width - imageViewActualWidth)/2
        maxStratch = dY//max(dX, dY)
        self.delegate?.stratchyHeader(self, didResetMaxStratchValue: maxStratch)
        
        widthConstraint.constant = imageViewActualWidth
        heightConstraint.constant = imageViewActualHeight
    }
    
}
