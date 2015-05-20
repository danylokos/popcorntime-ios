//
//  ShowCollectionViewCell.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/8/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class ShowCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!

    var image: UIImage? {
        didSet {
            self.imageView?.image = image
            self.titleLabel.hidden = image != nil
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.image = nil
    }
}
