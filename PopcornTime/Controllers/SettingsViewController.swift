//
//  SettingsViewController.swift
//  PopcornTime
//
//  Created by Danylo Kostyshyn on 4/4/15.
//  Copyright (c) 2015 PopcornTime. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - 
    
    func appInfoString() -> String {
        let displayName = NSBundle.mainBundle().infoDictionary?["CFBundleDisplayName"] as! String
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as! String
        let shortVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
        return "\(displayName) \(shortVersion) (\(version))"
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "SettingsCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("SettingsCell") 
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }

        cell.textLabel?.text = "Hello, PopcornTime!"
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(tableView.bounds), height: 0.0))
        label.backgroundColor = UIColor.clearColor()
        label.font = UIFont.systemFontOfSize(14.0)
        label.text = appInfoString()
        label.textAlignment = .Center
        return label
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView .deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
