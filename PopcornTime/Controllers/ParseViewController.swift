//
//  ParseViewController.swift
//
//
//  Created by Andriy K. on 6/22/15.
//
//

import UIKit

class ParseViewController: UIViewController, PFLogInViewControllerDelegate {
    
    private var canPromptLogin = true
    
    // MARK: - UIViewController
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        promptLoginIfNeeded(true)
    }
    
    // MARK: - Login
    
    func promptLoginIfNeeded(animated: Bool) {
        
        let currentUser = ParseManager.sharedInstance.user
        if currentUser == nil {
            // Show the signup or login screen
            let logInController = PFLogInViewController()
            logInController.delegate = self
            logInController.fields =
                [PFLogInFields.DismissButton, PFLogInFields.Facebook]
            logInController.facebookPermissions = ["public_profile"]
            self.presentViewController(logInController, animated:animated, completion: nil)
        }
    }
    
    // MARK: PFLogInViewControllerDelegate
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        dissmiss(nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        dissmiss(nil)
        dissmiss(nil)
    }
    
    // MARK: - Actions
    
    @IBAction func dissmiss(sender: AnyObject?) {
        canPromptLogin = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func logOutPressed(sender: UIBarButtonItem) {
        PFUser.logOut()
        dissmiss(nil)
    }
    @IBAction func clearAllDataPressed(sender: UIBarButtonItem) {
    }
    
}
