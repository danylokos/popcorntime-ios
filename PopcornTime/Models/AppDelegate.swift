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
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
#if RELEASE
        Fabric.with([Crashlytics()])
#endif
      //
      Parse.enableLocalDatastore()
      Parse.setApplicationId("Zb2NtG60U9aoQcV8jlDaDocs9xtHSpKf0GucHOvD", clientKey: "5ZtO2iAJ3WBwf2IocarUvVG6po7r9byF8XEQ4Moe")
      PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
      PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
      //
        return true
    }
    
  func application(application: UIApplication,
    openURL url: NSURL,
    sourceApplication: String?,
    annotation: AnyObject) -> Bool {
      return FBSDKApplicationDelegate.sharedInstance().application(application,
        openURL: url,
        sourceApplication: sourceApplication,
        annotation: annotation)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    FBSDKAppEvents.activateApp()
  }
  
  
}
