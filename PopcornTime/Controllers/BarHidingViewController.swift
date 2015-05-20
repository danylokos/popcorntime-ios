//
//  BarHidingViewController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class BarHidingViewController: UIViewController {

    private var barsVisible:Bool = true {
        willSet {
            self.tabBarController?.tabBar.hidden = !newValue
            self.navigationController?.navigationBar.hidden = !newValue
            UIApplication.sharedApplication().setStatusBarHidden(!newValue, withAnimation: .Fade)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //Hide bars if needed
        let sizeClass = (horizontal: self.view.traitCollection.horizontalSizeClass, vertical: self.view.traitCollection.verticalSizeClass)
        switch sizeClass{
        case (_,.Compact):
            self.barsVisible = false
        default: self.barsVisible = true
        }
    }

}
