//
//  Util.swift
//  LeagueDuel
//
//  Created by Kurt Jensen on 3/25/16.
//  Copyright © 2016 Arbor Apps LLC. All rights reserved.
//

import Foundation
import UIKit
import SafariServices
import NVActivityIndicatorView

class LoadingViewController: UIViewController {
    private var activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(0,0,50,50))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.type = .BallBeat
        activityIndicatorView.color = UIColor.defaultTintColor()
        activityIndicatorView.hidesWhenStopped = true
        view.addSubview(activityIndicatorView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicatorView.center = view.center
    }
    
    func startAnimating() {
        view.bringSubviewToFront(activityIndicatorView)
        activityIndicatorView.startAnimation()
    }
    
    func stopAnimating() {
        activityIndicatorView.stopAnimation()
    }
    
}

extension UIViewController {
    func showPopup(title: String?, message: String?, completion: (() -> Void)? ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            completion?()
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showErrorPopup(message: String?, completion: (() -> Void)? ) {
        showPopup("Error", message: message, completion: completion)
    }
    
    func showURL(urlString: String, inapp: Bool) {
        showURL(urlString, inapp: inapp, backupUrlString: nil)
    }
    
    func showURL(urlString: String, inapp: Bool, backupUrlString: String?) {
        if let url = NSURL(string: urlString) {
            if (inapp) {
                let svc = SFSafariViewController(URL: url)
                self.presentViewController(svc, animated: true, completion: nil)
            } else {
                if (UIApplication.sharedApplication().canOpenURL(url)) {
                    UIApplication.sharedApplication().openURL(url)
                } else if let backupUrlString = backupUrlString, let url = NSURL(string: backupUrlString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        
    }
    
}

extension NSDate {
    func timeAgo(numericDates:Bool) -> String {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(self)
        let latest = (earliest == now) ? self : now
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.year >= 2) {
            return "\(components.year)y ago"
        } else if (components.year >= 1){
            if (numericDates){
                return "1y ago"
            } else {
                return "Last year"
            }
        } else if (components.month >= 2) {
            return "\(components.month)m ago"
        } else if (components.month >= 1){
            if (numericDates){
                return "1m ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear >= 2) {
            return "\(components.weekOfYear)w ago"
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return "1w ago"
            } else {
                return "Last week"
            }
        } else if (components.day >= 2) {
            return "\(components.day)d ago"
        } else if (components.day >= 1){
            if (numericDates){
                return "1d ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour >= 2) {
            return "\(components.hour)h ago"
        } else if (components.hour >= 1){
            if (numericDates){
                return "1h ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute >= 2) {
            return "\(components.minute)m ago"
        } else if (components.minute >= 1){
            if (numericDates){
                return "1m ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second >= 3) {
            return "\(components.second)s ago"
        } else {
            return "Just now"
        }
        
    }
}