//
//  PFLeague.swift
//  FriendlyFanduel
//
//  Created by Kurt Jensen on 3/3/16.
//  Copyright © 2016 Arbor Apps LLC. All rights reserved.
//

import UIKit
import Parse

class PFLeague: PFObject, PFSubclassing {
    
    @NSManaged var commissioner: PFDueler!
    @NSManaged var duelers: [String]!
    @NSManaged var name: String?
    
    class func parseClassName() -> String {
        return "League"
    }
    
    convenience init(name: String) {
        self.init()
        self.commissioner = PFDueler.currentUser()!
        self.duelers = [PFDueler.currentUser()!.objectId!]
        self.name = name
    }
    
    func isCommissioner() -> Bool {
        return self.commissioner.objectId == PFDueler.currentUser()?.objectId
    }
    
    class func myLeaguesQuery() -> PFQuery? {
        if let userId = PFDueler.currentUser()?.objectId {
            let query = PFLeague.query()
            query?.whereKey("duelers", containsAllObjectsInArray: [userId])
            return query
        }
        return nil
    }
    
    class func availableLeaguesForEvent(event: PFEvent) -> PFQuery? {
        if let lineupQuery = PFLineup.myLineupsQuery(), let contestQuery = PFContest.query(), let contestLineupQuery = PFContestLineup.query() {
            contestLineupQuery.whereKey("event", equalTo: event)
            contestLineupQuery.whereKey("lineup", matchesQuery: lineupQuery)
            contestQuery.whereKey("objectId", matchesKey: "contestId", inQuery: contestLineupQuery)// TODO
            let query = PFLeague.myLeaguesQuery()
            query?.whereKey("objectId", matchesKey: "leagueId", inQuery: contestLineupQuery)// TODO
            return query
            
        }
        return nil
    }
    
    class func queryWithIncludes() -> PFQuery? {
        let query = PFLeague.query()
        query?.includeKey("commissioner")
        return query
    }

}