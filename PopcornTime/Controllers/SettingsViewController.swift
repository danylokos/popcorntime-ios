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
        let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
        let version = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        return "\(displayName) \(shortVersion) (\(version))"
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SettingsCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") 
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }

        cell.textLabel?.text = "Hello, PopcornTime!"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: 0.0))
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = appInfoString()
        label.textAlignment = .center
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30.0
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
