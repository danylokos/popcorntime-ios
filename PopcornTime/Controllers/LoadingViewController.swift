//
//  LoadingViewController.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 3/15/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

protocol LoadingViewControllerDelegate {
    func didCancelLoading(controller: LoadingViewController)
}

class LoadingViewController: UIViewController {

    var delegate: LoadingViewControllerDelegate?
    
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var seedsLabel: UILabel!
    @IBOutlet private weak var peersLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    
    var status: String? = nil {
        didSet {
            if let status = status {
                statusLabel?.text = status
            }
        }
    }
    
    var progress: Float = 0.0 {
        didSet {
            progressView.progress = progress
            progressLabel.text = String(format: "%.0f%%", progress*100)
        }
    }
    
    var speed: Int = 0 { // bytes/s
        didSet {
            let formattedSpeed = NSByteCountFormatter.stringFromByteCount(Int64(speed), countStyle: .Binary) + "/s"
            speedLabel.text = String(format:"Speed: %@", formattedSpeed)
        }
    }
    
    var seeds: Int = 0 {
        didSet {
            seedsLabel.text = String(format: "Seeds: %d", seeds)
        }
    }
    
    var peers: Int = 0 {
        didSet {
            peersLabel.text = String(format: "Peers: %d", peers)
        }
    }
    
    var loadingTitle: String? = nil {
        didSet {
            if let title = loadingTitle {
                titleLabel?.text = title
            }
        }
    }

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = loadingTitle
        status = "Loading..."
        progress =  0.0
        speed = 0
        seeds = 0
        peers = 0
        
        UIApplication.sharedApplication().idleTimerDisabled = true;
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().idleTimerDisabled = false;
    }

    // MARK: - Actions

    @IBAction private func cancelButtonPressed(sender: AnyObject) {
        delegate?.didCancelLoading(self)
    }
    
}
