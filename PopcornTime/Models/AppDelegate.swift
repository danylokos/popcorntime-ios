//
//  AppDelegate.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/13/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

#if RELEASE
import Fabric
import Crashlytics
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
#if RELEASE
        Fabric.with([Crashlytics()])
#endif
        return true
    }
    
}
