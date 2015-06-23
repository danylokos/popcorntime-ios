//
//  EpisodeCell.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class EpisodeCell: UICollectionViewCell {
  
  let watchedAlpha:CGFloat = 0.5
  let defaultAlpha:CGFloat = 1.0
    
    @IBOutlet weak var titleLabel: UILabel!
    var watchedEpisode = false {
      didSet {
        if watchedEpisode {
          alpha = watchedAlpha
        } else {
          alpha = defaultAlpha
        }
      }
    }
}
