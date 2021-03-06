//
//  SetLineupViewController.swift
//  FriendlyFanduel
//
//  Created by Kurt Jensen on 3/3/16.
//  Copyright © 2016 Arbor Apps LLC. All rights reserved.
//

import UIKit
import Parse
import MZFormSheetPresentationController

protocol SetLineupViewControllerDelegate {
    func didAddOrChangeLineup()
}

class SetLineupViewController: LoadingViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var importButton: UIBarButtonItem!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var findingPlayersView: UIView!

    var duelTeam: PFDuelTeam!
    var playerEvents = [PFPlayerEvent]()
    var contestHeaderView = ContestHeaderView.contestHeaderView()
    var importableLineup: PFLineup? {
        didSet {
            importButton.enabled = (importableLineup != nil)
        }
    }
    
    var editableContestLineup: EditableContestLineup? {
        didSet {
            if let editableContestLineup = editableContestLineup {
                self.refreshLabels()
                fetchPlayerEvents(editableContestLineup.event)
                editableContestLineup.delegate = self
            }
        }
    }
    var delegate: SetLineupViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = contestHeaderView
        navigationController?.setToolbarHidden(false, animated: false)
        
        exportButton.enabled = true
        contestHeaderView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let event = editableContestLineup?.event {
            importableLineup = PFEvent.importableLineups[event]
        }
    }
    
    @IBAction func importTapped(sender: AnyObject) {
        if let importableLineup = importableLineup {
            editableContestLineup?.setupWithLineup(importableLineup)
        }
    }
    
    @IBAction func exportTapped(sender: AnyObject) {
        if let editableContestLineup = editableContestLineup, let event = editableContestLineup.event, let sport = event.dynamicType.sport() {
            let lineup = PFLineup.tempLineupFromEditableLineup(sport, editableContestLineup: editableContestLineup)
            PFEvent.importableLineups[event] = lineup
            importableLineup = lineup
        }
    }
    
    func fetchPlayerEvents(event: PFEvent) {
        if let sport = event.dynamicType.sport(), let playerQuery = PFPlayer.query(sport) {
            let query = PFPlayerEvent.queryWithIncludes(sport)
            query?.cachePolicy = PFCachePolicy.CacheThenNetwork
            query?.orderByDescending("salary")
            query?.whereKey("player", matchesQuery: playerQuery)
            query?.whereKey("event", equalTo: event)
            query?.limit = 1000
            query?.findObjectsInBackgroundWithBlock({ (playerEvents, error) -> Void in
                if let playerEvents = playerEvents as? [PFPlayerEvent] {
                    self.playerEvents = playerEvents
                }
                self.findingPlayersView.hidden = true
            })
        }
    }
    
    func refreshLabels() {
        if let editableContestLineup = editableContestLineup {
            let salary = editableContestLineup.currentSalary()
            let numplayers = editableContestLineup.lineupSize()
            let remainingSalary = editableContestLineup.maxSalary() - salary
            let remainingSalaryAvg = remainingSalary/numplayers
            remainingLabel?.text = "$\(remainingSalaryAvg) per player remaining"
            remainingLabel?.textColor = remainingSalaryAvg > 0 ? UIColor.blackColor() : UIColor.redColor()
            totalLabel?.text = "$\(remainingSalary)"
            totalLabel?.textColor = remainingSalary > 0 ? UIColor.blackColor() : UIColor.redColor()
        }
    }
    
    func toChoosePlayer(positionType: Int) {
        let playerEvents = playerEventsForType(positionType)
        if (playerEvents.count > 0) {
            toPlayerPicker(playerEvents)
        }
    }
    
    func playerEventsForType(type: Int) -> [PFPlayerEvent] {
        let disabledPlayerEventIds = editableContestLineup?.disabledPlayerEventIds(type)
        let playerEventsForType = playerEvents.filter { (playerEvent) -> Bool in
            let isDisabled = disabledPlayerEventIds?.contains(playerEvent.objectId ?? "") ?? false
            let isPosition = (playerEvent.player?.positionType() == type) ?? false
            return !isDisabled && isPosition
        }
        return playerEventsForType
    }
    
    func toPlayerPicker(playerEvents: [PFPlayerEvent]) {
        if let playerPickerVC = storyboard?.instantiateViewControllerWithIdentifier("PlayerPickerVC") as?  PlayerPickerViewController {
            playerPickerVC.editableContestLineup = editableContestLineup
            playerPickerVC.playerEvents = playerEvents
            let navigationController = UINavigationController(rootViewController: playerPickerVC)
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveToContest(contest: PFContest) {
        if let editableContestLineup = editableContestLineup, let sport = contest.dynamicType.sport(), let lineupQuery = PFLineup.myLineupsQuery(sport) {
            if let errorMesssage = editableContestLineup.errorMessageIfInvalid() {
                self.showErrorPopup(errorMesssage, completion: nil)
            } else {
                startAnimating()
                let query = PFContestLineup.query(sport)
                query?.whereKey("contest", equalTo: contest)
                query?.whereKey("lineup", matchesQuery: lineupQuery)
                query?.getFirstObjectInBackgroundWithBlock({ (contestLineup, error) -> Void in
                    if let contestLineup = contestLineup as? PFContestLineup {
                        // update
                        do {
                            let lineup = contestLineup.lineup
                            lineup.setRoster(editableContestLineup)
                            try lineup.save()
                            self.delegate?.didAddOrChangeLineup()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } catch {
                            self.showErrorPopup((error as NSError).localizedDescription, completion: nil)
                            print(error)
                        }
                    } else {
                        // create contestLineup
                        do {
                            let lineup = PFLineup.lineupFromEditableLineup(sport, duelTeam: self.duelTeam, contest: contest, editableContestLineup: editableContestLineup)
                            let contestLineup = PFContestLineup.contestLineupWithSport(sport, contest: contest, lineup: lineup)
                            try contestLineup.save()
                            self.duelTeam.incrementKey("numberContestsEntered", byAmount: 1)
                            self.duelTeam.saveInBackground()
                            self.delegate?.didAddOrChangeLineup()
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } catch {
                            self.showErrorPopup((error as NSError).localizedDescription, completion: nil)
                            print(error)
                        }
                    }
                    self.stopAnimating()
                })
            }
        }

    }
    
    @IBAction func submitTapped(sender: AnyObject) {
        // subclassed
    }
    
}

extension SetLineupViewController: ContestHeaderViewDelegate {
    func contestInfoTapped() {
        if let event = editableContestLineup?.event {
            let eventInfoViewController = self.storyboard!.instantiateViewControllerWithIdentifier("EventInfoVC") as! EventInfoViewController
            eventInfoViewController.event = event
            let nc = UINavigationController(rootViewController: eventInfoViewController)
            let formSheetController = MZFormSheetPresentationViewController(contentViewController: nc)
            formSheetController.presentationController?.shouldCenterVertically = true
            formSheetController.presentationController?.contentViewSize = CGSizeMake(self.view.frame.size.width*0.9, self.view.frame.size.height*0.75)
            self.presentViewController(formSheetController, animated: true, completion: nil)
        }
    }
}

extension SetLineupViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return editableContestLineup?.numberOfPositionsOnRoster() ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editableContestLineup?.numberOfSpotsForPosition(section) ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return editableContestLineup?.titleForPosition(section)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let playerEvent = editableContestLineup?.playerEventForPositionSpot(indexPath.section, spot: indexPath.row) {
            let cell = tableView.dequeueReusableCellWithIdentifier("PlayerSelectedCell", forIndexPath: indexPath)
            cell.textLabel?.text = playerEvent.player.name
            cell.detailTextLabel?.text = "\(playerEvent.salary)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PlayerCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Select"
            cell.detailTextLabel?.text = "Player"
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let playerEvent = editableContestLineup?.playerEventForPositionSpot(indexPath.section, spot: indexPath.row) {
            print(playerEvent.player.description)
            editableContestLineup?.swappingPlayerEvent = playerEvent
        }
        toChoosePlayer(indexPath.section)
    }
    
}

extension SetLineupViewController: EditableContestLineupDelegate {
    func editableContestLineupChanged() {
        self.tableView?.reloadData()
        self.refreshLabels()
    }
}
