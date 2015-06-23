//
//  ParseViewController.swift
//
//
//  Created by Andriy K. on 6/22/15.
//
//

import UIKit

class ParseViewController: UIViewController, PFLogInViewControllerDelegate {
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    promptLoginIfNeeded(false)
  }
  
  // MARK: - Login
  
  func promptLoginIfNeeded(animated: Bool) {
    
    var currentUser = PFUser.currentUser()
    if currentUser != nil {
      // Do stuff with the user
      
      PFUser.logOutInBackgroundWithBlock({ (error) -> Void in
        println("logged out")
      })
    } else {
      // Show the signup or login screen
      var logInController = PFLogInViewController()
      logInController.delegate = self
      logInController.fields =
        PFLogInFields.DismissButton
        | PFLogInFields.Facebook
      logInController.facebookPermissions = ["public_profile"]
      self.presentViewController(logInController, animated:animated, completion: nil)
    }
  }
  
  // MARK: PFLogInViewControllerDelegate
  
  func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
    //
  }
  
  func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
    //
  }
  
  func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
    //
  }
  
  // MARK: - Actions
  
  @IBAction func dissmiss(sender: UIBarButtonItem) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
