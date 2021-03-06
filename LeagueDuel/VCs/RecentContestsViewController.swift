//
//  RecentContestsViewController.swift
//  FriendlyFanduel
//
//  Created by Kurt Jensen on 3/3/16.
//  Copyright © 2016 Arbor Apps LLC. All rights reserved.
//

import UIKit
import Parse

class RecentContestsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var contestLineups = [PFContestLineup]() {
        didSet {
            self.tableView?.reloadData()
            if (contestLineups.count == 0) {
                let footerView = FooterView.footerView()
                footerView.textLabel.text = "There are no recent events at the moment. Check back soon!"
                tableView.tableFooterView = footerView
            } else {
                tableView.tableFooterView?.removeFromSuperview()
                tableView.tableFooterView = UIView()
            }
        }
    }
    var lastRefreshDate = [SportType:NSDate]()
    let sport = SportType.MLB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "ContestTeamLineupTableViewCell", bundle: nil), forCellReuseIdentifier: "ContestTeamLineupCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateIfNeeded()
    }
    
    func updateIfNeeded() {
        if let lastRefreshDate = lastRefreshDate[sport] {
            if (LDCoordinator.instance.shouldRefresh(lastRefreshDate, sport: SportType.MLB, dateTypes: [DateType.End])) {
                fetchContests(false)
            }
        } else {
            fetchContests(true)
        }
    
        lastRefreshDate[sport] = NSDate()
    }
    
    func fetchContests(isFirstTime: Bool) {
        print("RECENT fetchContests: \(isFirstTime)")
        let query = PFContestLineup.myRecentContestLineupsQuery(sport)
        if (isFirstTime) {
            query?.cachePolicy = PFCachePolicy.CacheThenNetwork
        } else {
            query?.cachePolicy = PFCachePolicy.NetworkOnly
        }
        query?.findObjectsInBackgroundWithBlock({ (contestLineups, error) -> Void in
            if let contestLineups = contestLineups as? [PFContestLineup] {
                self.contestLineups = contestLineups
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "toContest") {
            if let vc = segue.destinationViewController as? LeagueContestViewController {
                vc.contest = (sender as? PFContestLineup)?.contest
            }
        }
    }
    
}

extension RecentContestsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contestLineups.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContestTeamLineupCell", forIndexPath: indexPath) as! ContestTeamLineupTableViewCell
        let contestLineup = contestLineups[indexPath.row]
        cell.configureWithContestLineup(contestLineup)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let contestLineup = contestLineups[indexPath.row]
        performSegueWithIdentifier("toContest", sender: contestLineup)
    }
    
}