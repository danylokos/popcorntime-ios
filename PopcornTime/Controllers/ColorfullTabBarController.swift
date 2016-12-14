//
//  ColorfullTabBarController.swift
//  PopcornTime
//
//  Created by Andrew  K. on 4/10/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit


class ColorfullTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    fileprivate struct ColorConstants {
        static let favoritesTintColor = UIColor(red: 235/255, green: 66/255, blue: 69/255, alpha: 1.0)
        static let moviesTintColor = UIColor(red: 66/255, green: 166/255, blue: 235/255, alpha: 1.0)
        static let showsTintColor = UIColor(red: 33/255, green: 181/255, blue: 42/255, alpha: 1.0)
        static let animeTintColor = UIColor(red: 235/255, green: 66/255, blue: 164/255, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assignColors()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        assignColors()
    }
    
    fileprivate func assignColors() {
        switch selectedIndex {
        case 0: view.window?.tintColor = ColorConstants.favoritesTintColor
        case 1: view.window?.tintColor = ColorConstants.moviesTintColor
        case 2: view.window?.tintColor = ColorConstants.showsTintColor
        case 3: view.window?.tintColor = ColorConstants.animeTintColor
        default: break
        }
    }
    
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.assignColors()
    }
    
    
}
