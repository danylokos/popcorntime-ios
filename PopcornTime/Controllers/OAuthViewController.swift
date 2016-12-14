//
//  WebViewController.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/15/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

protocol OAuthViewControllerDelegate {
    func oauthViewControllerDidFinish(_ controller: OAuthViewController, token: String?, error: NSError?)
}

class OAuthViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var delegate: OAuthViewControllerDelegate?
    var URL: Foundation.URL?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let URL = URL {
            webView.loadRequest(URLRequest(url: URL))
        }
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let code = request.url?.lastPathComponent {
            if code.characters.count == 64 {
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
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {

    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        delegate?.oauthViewControllerDidFinish(self, token: nil, error: error as NSError?)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        delegate?.oauthViewControllerDidFinish(self, token: nil, error: nil)
    }
    
}
