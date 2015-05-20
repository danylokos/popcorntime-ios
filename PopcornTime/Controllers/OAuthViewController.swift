//
//  WebViewController.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/15/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

protocol OAuthViewControllerDelegate {
    func oauthViewControllerDidFinish(controller: OAuthViewController, token: String?, error: NSError?)
}

class OAuthViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var delegate: OAuthViewControllerDelegate?
    var URL: NSURL?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let URL = URL {
            webView.loadRequest(NSURLRequest(URL: URL))
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let code = request.URL?.lastPathComponent {
            if count(code) == 64 {
//                PTAPIManager.sharedManager().accessTokenWithAuthorizationCode(code, success: { (accessToken) -> Void in
//                    println("OAuth access token: \(accessToken)")
//                    self.delegate?.oauthViewControllerDidFinish(self, token: accessToken, error: nil)
//                }, failure: { (error) -> Void in
//                    println("\(error)")
//                    self.delegate?.oauthViewControllerDidFinish(self, token: nil, error: error)
//                })
            }
        }
        return true;
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {

    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        delegate?.oauthViewControllerDidFinish(self, token: nil, error: error)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.oauthViewControllerDidFinish(self, token: nil, error: nil)
    }
    
}
