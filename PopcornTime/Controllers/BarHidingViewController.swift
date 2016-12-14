//
//  BarHidingViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class BarHidingViewController: UIViewController {

    fileprivate var barsVisible:Bool = true {
        willSet {
            self.tabBarController?.tabBar.isHidden = !newValue
            self.navigationController?.navigationBar.isHidden = !newValue
            UIApplication.shared.setStatusBarHidden(!newValue, with: .fade)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //Hide bars if needed
        let sizeClass = (horizontal: self.view.traitCollection.horizontalSizeClass, vertical: self.view.traitCollection.verticalSizeClass)
        switch sizeClass{
        case (_,.compact):
            self.barsVisible = false
        default: self.barsVisible = true
        }
    }

}
