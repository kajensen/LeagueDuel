//
//  UpcomingContestsViewController.swift
//  FriendlyFanduel
//
//  Created by Kurt Jensen on 3/3/16.
//  Copyright © 2016 Arbor Apps LLC. All rights reserved.
//

import UIKit

class UpcomingContestsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var contestLineups = [PFContestLineup]() {
        didSet {
            self.tableView?.reloadData()
        }
    }
    var availableEvents = [PFEvent]() {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchContests()
        fetchEvents()
    }
    
    func fetchContests() {
        let sport = SportType.MLB
        let query = PFMLBContestLineup.myUpcomingContestLineupsQuery(sport)
        query?.findObjectsInBackgroundWithBlock({ (contestLineups, error) -> Void in
            if let contestLineups = contestLineups as? [PFContestLineup] {
                self.contestLineups = contestLineups
            }
        })
    }
    
    func fetchEvents() {
        let sport = SportType.MLB
        let query = PFEvent.myUpcomingAvailableEventsQuery(sport)
        query?.findObjectsInBackgroundWithBlock({ (events, error) -> Void in
            if let events = events as? [PFEvent] {
                self.availableEvents = events
            }
        })
    }

    func toCreateLineupForEvent(event: PFEvent) {
        if let createLineupVC = storyboard?.instantiateViewControllerWithIdentifier("CreateLineupVC") as?  CreateLineupViewController {
            createLineupVC.event = event
            let navigationController = UINavigationController(rootViewController: createLineupVC)
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
}

extension UpcomingContestsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return availableEvents.count
        } else {
            return contestLineups.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! EventTableViewCell
            let event = availableEvents[indexPath.row]
            cell.configureWithEvent(event)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ContestLineupCell", forIndexPath: indexPath) as! ContestTableViewCell
            let contestLineup = contestLineups[indexPath.row]
            cell.configureWithContestLineup(contestLineup)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if (indexPath.section == 0) {
            let event = availableEvents[indexPath.row]
            toCreateLineupForEvent(event)
        } else {
            let contestLineup = contestLineups[indexPath.row]

        }

    }
    
}
