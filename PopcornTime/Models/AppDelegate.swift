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
      Parse.setApplicationId("c6ronV5qjSoEDJdJmpc8ZnOIyVyC2Annn95p4nlw", clientKey: "3q4VDCr9m4Lv81rArBOB5PTh5K5hlfli25C8OtU1")
      PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
      PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
      //
        return true
    }
    
  func application(application: UIApplication,
    openURL url: NSURL,
    sourceApplication: String?,
    annotation: AnyObject?) -> Bool {
      return FBSDKApplicationDelegate.sharedInstance().application(application,
        openURL: url,
        sourceApplication: sourceApplication,
        annotation: annotation)
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    FBSDKAppEvents.activateApp()
  }
  
  
}
