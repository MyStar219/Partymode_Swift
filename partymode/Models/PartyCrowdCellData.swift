//
//  PartyCrowdCellData.swift
//  partymode
//
//  Created by Nikita on 2/11/17.
//  Copyright © 2017 com. All rights reserved.
//

import Foundation
struct PartyCrowdCellData {
    var id: String!
    var title : String!
    var location : String!
    var partyTimeStamp:Int!
    var partyTime: String!
    var invite_friends:Bool
    var color:Int!
    var members:[String]!
    var isPastParty:Bool
    var status:Int!
    
//    init(id:String, title: String, location : String, partyTimeStamp : Int, partyTime : String, invite_friends : Bool, color : Int, members : [String]) {
//        self.id = id
//        self.title = title
//        self.location = location
//        self.partyTimeStamp = partyTimeStamp
//        self.partyTime = partyTime
//        self.invite_friends = invite_friends
//        self.color = color
//        self.members = members
//        self.isPastParty = false
//        self.status = Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS
//    }
    init(id:String, title: String, location : String, partyTimeStamp : Int, partyTime : String, invite_friends : Bool, color : Int, members : [String], isPastParty:Bool) {
        self.id = id
        self.title = title
        self.location = location
        self.partyTimeStamp = partyTimeStamp
        self.partyTime = partyTime
        self.invite_friends = invite_friends
        self.color = color
        self.members = members
        self.isPastParty = isPastParty
        self.status = Constants.CROWD_STATUS_DO_NO_CHANGE_STATUS
    }
    init(id:String, title: String, location : String, partyTimeStamp : Int, partyTime : String, invite_friends : Bool, color : Int, members : [String], status:Int) {
        self.id = id
        self.title = title
        self.location = location
        self.partyTimeStamp = partyTimeStamp
        self.partyTime = partyTime
        self.invite_friends = invite_friends
        self.color = color
        self.members = members
        self.isPastParty = false
        self.status = status
    }
    
    mutating func setPastPartyValue(_ value:Bool){
        self.isPastParty = value
    }
}
